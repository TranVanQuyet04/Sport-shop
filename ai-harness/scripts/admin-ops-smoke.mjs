import fs from 'node:fs/promises';
import path from 'node:path';
import { loadHarnessEnv, requiredEnvValue } from './env-loader.mjs';

loadHarnessEnv();

const root = path.resolve(import.meta.dirname, '..', '..');
const stateDir = path.join(root, 'ai-harness', 'state');
const reportPath = path.join(stateDir, 'admin-ops-smoke-latest.json');
const mdReportPath = path.join(stateDir, 'admin-ops-smoke-latest.md');
const baseUrl = requiredEnvValue('SPORTSHOP_API_URL');
const runId = `OPS_${Date.now()}`;

const accounts = {
  admin: {
    email: requiredEnvValue('SPORTSHOP_ADMIN_EMAIL'),
    password: requiredEnvValue('SPORTSHOP_ADMIN_PASSWORD'),
  },
  shopStaff: {
    email: requiredEnvValue('SPORTSHOP_SHOP_STAFF_EMAIL'),
    password: requiredEnvValue('SPORTSHOP_SHOP_STAFF_PASSWORD'),
  },
  shipper: {
    email: requiredEnvValue('SPORTSHOP_SHIPPER_EMAIL'),
    password: requiredEnvValue('SPORTSHOP_SHIPPER_PASSWORD'),
  },
};

const results = [];
const cleanup = [];

function record(area, step, status, detail = '', endpoint = '') {
  results.push({ area, step, status, endpoint, detail });
}

function headers(token) {
  return {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };
}

async function request(method, endpoint, { token, body, expected = [200], query } = {}) {
  const url = new URL(`${baseUrl}${endpoint}`);
  if (query) {
    for (const [key, value] of Object.entries(query)) {
      if (value !== undefined && value !== null) {
        url.searchParams.set(key, String(value));
      }
    }
  }
  const response = await fetch(url, {
    method,
    headers: headers(token),
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await response.text();
  let json = null;
  if (text) {
    try {
      json = JSON.parse(text);
    } catch {
      json = text;
    }
  }
  if (!expected.includes(response.status)) {
    throw new Error(`${method} ${endpoint} returned ${response.status}: ${text.slice(0, 800)}`);
  }
  return { status: response.status, json, text };
}

function unwrap(json) {
  if (json && typeof json === 'object' && 'result' in json) return json.result;
  if (json && typeof json === 'object' && 'data' in json) return json.data;
  return json;
}

function idOf(value) {
  if (!value || typeof value !== 'object') return undefined;
  return value.id ?? value.userId ?? value.staffId;
}

async function login(roleKey) {
  const account = accounts[roleKey];
  const { json } = await request('POST', '/auth/login', {
    body: { email: account.email, password: account.password },
  });
  const source = unwrap(json);
  const token = source?.accessToken || source?.token;
  if (!token) throw new Error(`No token returned for ${roleKey}`);
  return token;
}

async function run(area, step, endpoint, action) {
  try {
    const detail = await action();
    record(area, step, 'pass', detail || 'OK', endpoint);
    return detail;
  } catch (error) {
    record(area, step, 'fail', error instanceof Error ? error.message : String(error), endpoint);
    throw error;
  }
}

function addDays(date, days) {
  const copy = new Date(date);
  copy.setDate(copy.getDate() + days);
  return copy.toISOString().slice(0, 10);
}

await fs.mkdir(stateDir, { recursive: true });

try {
  let adminToken = '';
  let shopStaffToken = '';
  let shipperToken = '';

  await run('auth', 'login admin', 'POST /api/auth/login', async () => {
    adminToken = await login('admin');
    return 'Admin login OK';
  });

  await run('auth', 'login shop staff', 'POST /api/auth/login', async () => {
    shopStaffToken = await login('shopStaff');
    return 'Shop staff login OK';
  });

  await run('auth', 'login shipper', 'POST /api/auth/login', async () => {
    shipperToken = await login('shipper');
    return 'Shipper login OK';
  });

  const usersRaw = unwrap((await request('GET', '/admin/users', { token: adminToken })).json);
  const users = Array.isArray(usersRaw) ? usersRaw : Array.isArray(usersRaw?.users) ? usersRaw.users : [];
  const shopStaff = users.find((user) => String(user.roleName || user.roleCode || user.role || '').includes('SHOP_STAFF'));
  const shipper = users.find((user) => String(user.roleName || user.roleCode || user.role || '').includes('SHIPPER'));
  const shopStaffId = idOf(shopStaff);
  const shipperId = idOf(shipper);
  if (!shopStaffId) throw new Error('SHOP_STAFF user not found from /admin/users');
  if (!shipperId) throw new Error('SHIPPER user not found from /admin/users');

  await run('work-shift', 'admin create/update/read/delete work shift', 'POST/GET/PUT/DELETE /api/admin/work-shifts', async () => {
    const shiftDate = addDays(new Date(), 3);
    const created = unwrap(
      (await request('POST', '/admin/work-shifts', {
        token: adminToken,
        body: {
          userId: shopStaffId,
          shiftDate,
          shiftCode: 'MORNING',
          note: `${runId} work shift`,
        },
      })).json,
    );
    const shiftId = idOf(created);
    if (!shiftId) throw new Error('Work shift create did not return id');
    cleanup.push(() => request('DELETE', `/admin/work-shifts/${shiftId}`, { token: adminToken, expected: [200, 204, 404] }));
    await request('GET', `/admin/work-shifts/${shiftId}`, { token: adminToken });
    const updated = unwrap(
      (await request('PUT', `/admin/work-shifts/${shiftId}`, {
        token: adminToken,
        body: { note: `${runId} work shift updated`, shiftCode: 'AFTERNOON' },
      })).json,
    );
    if (updated.shiftCode !== 'AFTERNOON') throw new Error(`Expected AFTERNOON, got ${updated.shiftCode}`);
    await request('DELETE', `/admin/work-shifts/${shiftId}`, { token: adminToken, expected: [200, 204] });
    return `shiftId=${shiftId}`;
  });

  await run('leave-request', 'staff create/update and admin approve/delete leave', 'POST/PUT/PATCH/DELETE /api/*/leave-requests', async () => {
    const startDate = addDays(new Date(), 8);
    const created = unwrap(
      (await request('POST', '/user/leave-requests', {
        token: shopStaffToken,
        body: {
          startDate,
          days: 1,
          reason: `${runId} leave request`,
        },
      })).json,
    );
    const leaveId = idOf(created);
    if (!leaveId) throw new Error('Leave request create did not return id');
    cleanup.push(() => request('DELETE', `/admin/leave-requests/${leaveId}`, { token: adminToken, expected: [200, 204, 404] }));
    await request('PUT', `/user/leave-requests/${leaveId}`, {
      token: shopStaffToken,
      body: { days: 2, reason: `${runId} leave request updated` },
    });
    const decided = unwrap(
      (await request('PATCH', `/admin/leave-requests/${leaveId}/decision`, {
        token: adminToken,
        body: { status: 'APPROVED' },
      })).json,
    );
    if (decided.status !== 'APPROVED') throw new Error(`Expected APPROVED, got ${decided.status}`);
    await request('DELETE', `/admin/leave-requests/${leaveId}`, { token: adminToken, expected: [200, 204] });
    return `leaveId=${leaveId}`;
  });

  await run('order-assignment', 'admin assign/update/read/delete E2E order', 'PUT/GET/DELETE /api/admin/order-assignments', async () => {
    const orders = unwrap((await request('GET', '/orders/admin', { token: adminToken })).json);
    const e2eOrder = Array.isArray(orders)
      ? orders.find((order) => String(order.note || '').startsWith('E2E order'))
      : null;
    if (!e2eOrder?.id) {
      return 'Skipped: no E2E order available. Run order-e2e-smoke first.';
    }
    const assignment = unwrap(
      (await request('PUT', `/admin/order-assignments/orders/${e2eOrder.id}`, {
        token: adminToken,
        body: { staffId: shipperId, note: `${runId} assign shipper` },
      })).json,
    );
    const assignmentId = idOf(assignment);
    if (!assignmentId) throw new Error('Assignment did not return id');
    cleanup.push(() => request('DELETE', `/admin/order-assignments/${assignmentId}`, { token: adminToken, expected: [200, 204, 404] }));
    await request('GET', `/admin/order-assignments/orders/${e2eOrder.id}`, { token: shipperToken });
    const updated = unwrap(
      (await request('PUT', `/admin/order-assignments/${assignmentId}`, {
        token: adminToken,
        body: { note: `${runId} assignment updated`, staffId: shipperId },
      })).json,
    );
    if (!String(updated.note || '').includes('updated')) throw new Error('Assignment update not reflected');
    await request('DELETE', `/admin/order-assignments/${assignmentId}`, { token: adminToken, expected: [200, 204] });
    return `assignmentId=${assignmentId}; orderId=${e2eOrder.id}`;
  });

  await run('delivery-report', 'shipper create and admin update/delete delivery report on test order', 'POST/GET/PUT/DELETE /api/*/delivery-reports', async () => {
    const orders = unwrap((await request('GET', '/orders/admin', { token: adminToken })).json);
    const e2eOrder = Array.isArray(orders)
      ? orders.find((order) => String(order.note || '').startsWith('E2E order'))
      : null;
    if (!e2eOrder?.id) {
      return 'Skipped: no E2E order available. Run order-e2e-smoke first.';
    }
    const report = unwrap(
      (await request('POST', `/orders/${e2eOrder.id}/delivery-reports`, {
        token: shipperToken,
        body: {
          status: 'FAILED',
          reason: `${runId} simulated failed delivery`,
          note: 'Harness report',
          evidenceImageUrl: 'https://example.com/evidence.png',
        },
      })).json,
    );
    const reportId = idOf(report);
    if (!reportId) throw new Error('Delivery report create did not return id');
    cleanup.push(() => request('DELETE', `/admin/delivery-reports/${reportId}`, { token: adminToken, expected: [200, 204, 404] }));
    await request('GET', `/orders/${e2eOrder.id}/delivery-reports`, { token: shipperToken });
    const updated = unwrap(
      (await request('PUT', `/admin/delivery-reports/${reportId}`, {
        token: adminToken,
        body: { status: 'RETURNED', note: `${runId} report updated` },
      })).json,
    );
    if (updated.status !== 'RETURNED') throw new Error(`Expected RETURNED, got ${updated.status}`);
    await request('DELETE', `/admin/delivery-reports/${reportId}`, { token: adminToken, expected: [200, 204] });
    return `reportId=${reportId}; orderId=${e2eOrder.id}`;
  });
} catch (error) {
  record('harness', 'admin ops smoke stopped', 'fail', error instanceof Error ? error.message : String(error));
} finally {
  for (const task of cleanup.reverse()) {
    try {
      await task();
    } catch {
      // Best effort cleanup.
    }
  }
}

const summary = {
  generatedAt: new Date().toISOString(),
  baseUrl,
  runId,
  pass: results.filter((item) => item.status === 'pass').length,
  fail: results.filter((item) => item.status === 'fail').length,
  results,
};

await fs.writeFile(reportPath, `${JSON.stringify(summary, null, 2)}\n`, 'utf8');
await fs.writeFile(
  mdReportPath,
  [
    '# Admin Operations Smoke Report',
    '',
    `- Generated: ${summary.generatedAt}`,
    `- API URL: ${baseUrl}`,
    `- Run ID: ${runId}`,
    `- Pass: ${summary.pass}`,
    `- Fail: ${summary.fail}`,
    '',
    '| Area | Step | Endpoint | Status | Detail |',
    '|---|---|---|---|---|',
    ...results.map((item) =>
      `| ${item.area} | ${item.step} | ${item.endpoint} | ${item.status} | ${String(item.detail || '').replaceAll('|', '\\|')} |`,
    ),
    '',
  ].join('\n'),
  'utf8',
);

console.log(JSON.stringify(summary, null, 2));
if (summary.fail > 0) process.exitCode = 1;
