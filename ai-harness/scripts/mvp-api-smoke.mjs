import fs from 'node:fs/promises';
import path from 'node:path';
import { loadHarnessEnv, requiredEnvValue } from './env-loader.mjs';

loadHarnessEnv();

const root = path.resolve(import.meta.dirname, '..', '..');
const stateDir = path.join(root, 'ai-harness', 'state');
const reportPath = path.join(stateDir, 'mvp-api-smoke-latest.json');
const mdReportPath = path.join(stateDir, 'mvp-api-smoke-latest.md');
const baseUrl = requiredEnvValue('SPORTSHOP_API_URL');
const runId = `HARNESS_${Date.now()}`;
const allowOrderMutation = process.env.SPORTSHOP_ALLOW_MUTATING_ORDER_STATUS === 'true';

const accounts = {
  admin: {
    email: requiredEnvValue('SPORTSHOP_ADMIN_EMAIL'),
    password: requiredEnvValue('SPORTSHOP_ADMIN_PASSWORD'),
  },
  member: {
    email: requiredEnvValue('SPORTSHOP_MEMBER_EMAIL'),
    password: requiredEnvValue('SPORTSHOP_MEMBER_PASSWORD'),
  },
  shipper: {
    email: requiredEnvValue('SPORTSHOP_SHIPPER_EMAIL'),
    password: requiredEnvValue('SPORTSHOP_SHIPPER_PASSWORD'),
  },
};

const results = [];
const cleanupTasks = [];

function record({ area, caseId, status, detail = '', endpoint = '' }) {
  results.push({ area, caseId, status, endpoint, detail });
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
    throw new Error(`${method} ${endpoint} returned ${response.status}: ${text.slice(0, 600)}`);
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
  return value.id ?? value.categoryId ?? value.sportId ?? value.brandId ?? value.collectionId;
}

async function runCase(area, caseId, endpoint, fn) {
  try {
    const detail = await fn();
    record({ area, caseId, endpoint, status: 'pass', detail: detail || 'OK' });
  } catch (error) {
    record({
      area,
      caseId,
      endpoint,
      status: 'fail',
      detail: error instanceof Error ? error.message : String(error),
    });
  }
}

async function login(roleKey) {
  const account = accounts[roleKey];
  const { json } = await request('POST', '/auth/login', {
    body: { email: account.email, password: account.password },
  });
  const source = unwrap(json);
  const token = source?.accessToken || source?.token;
  if (!token) {
    throw new Error(`No token returned for ${roleKey}`);
  }
  return token;
}

await fs.mkdir(stateDir, { recursive: true });

let adminToken = '';
let memberToken = '';
let shipperToken = '';

await runCase('auth', 'login-admin', 'POST /api/auth/login', async () => {
  adminToken = await login('admin');
  return 'Admin login OK';
});
await runCase('auth', 'login-member', 'POST /api/auth/login', async () => {
  memberToken = await login('member');
  return 'Member login OK';
});
await runCase('auth', 'login-shipper', 'POST /api/auth/login', async () => {
  shipperToken = await login('shipper');
  return 'Shipper login OK';
});

if (adminToken) {
  await runCase('admin-catalog', 'category-crud', 'POST/GET/PUT/DELETE /api/admin/categories', async () => {
    const create = unwrap(
      (await request('POST', '/admin/categories', {
        token: adminToken,
        body: {
          categoryName: `${runId}_Category`,
          description: 'Harness category create',
          parentId: null,
        },
      })).json,
    );
    const id = idOf(create);
    if (!id) throw new Error('Category create did not return id');
    cleanupTasks.push(() => request('DELETE', `/admin/categories/${id}`, { token: adminToken, expected: [200, 204, 404] }));
    await request('GET', `/admin/categories/${id}`, { token: adminToken });
    const updated = unwrap(
      (await request('PUT', `/admin/categories/${id}`, {
        token: adminToken,
        body: {
          categoryName: `${runId}_Category_Updated`,
          description: 'Harness category update',
          parentId: null,
        },
      })).json,
    );
    if (!String(updated.categoryName || '').includes('Updated')) throw new Error('Category update not reflected');
    await request('DELETE', `/admin/categories/${id}`, { token: adminToken, expected: [200, 204] });
    return `categoryId=${id}`;
  });

  await runCase('admin-catalog', 'sport-crud', 'POST/GET/PUT/DELETE /api/admin/sports', async () => {
    const create = unwrap(
      (await request('POST', '/admin/sports', {
        token: adminToken,
        body: {
          sportName: `${runId}_Sport`,
          description: 'Harness sport create',
        },
      })).json,
    );
    const id = idOf(create);
    if (!id) throw new Error('Sport create did not return id');
    cleanupTasks.push(() => request('DELETE', `/admin/sports/${id}`, { token: adminToken, expected: [200, 204, 404] }));
    await request('GET', `/admin/sports/${id}`, { token: adminToken });
    const updated = unwrap(
      (await request('PUT', `/admin/sports/${id}`, {
        token: adminToken,
        body: {
          sportName: `${runId}_Sport_Updated`,
          description: 'Harness sport update',
        },
      })).json,
    );
    if (!String(updated.sportName || updated.name || '').includes('Updated')) throw new Error('Sport update not reflected');
    await request('DELETE', `/admin/sports/${id}`, { token: adminToken, expected: [200, 204] });
    return `sportId=${id}`;
  });

  await runCase('admin-catalog', 'brand-crud', 'POST/GET/PUT/DELETE /api/brands', async () => {
    const slug = runId.toLowerCase().replaceAll('_', '-');
    const create = unwrap(
      (await request('POST', '/brands', {
        token: adminToken,
        body: {
          name: `${runId} Brand`,
          slug,
          logo: 'https://example.com/logo.png',
          description: 'Harness brand create',
          banner: 'https://example.com/banner.png',
          isActive: true,
        },
      })).json,
    );
    const id = idOf(create);
    if (!id) throw new Error('Brand create did not return id');
    cleanupTasks.push(() => request('DELETE', `/brands/${id}`, { token: adminToken, expected: [200, 204, 404] }));
    await request('GET', `/brands/${id}`, { token: adminToken });
    const updated = unwrap(
      (await request('PUT', `/brands/${id}`, {
        token: adminToken,
        body: {
          name: `${runId} Brand Updated`,
          slug: `${slug}-updated`,
          logo: 'https://example.com/logo-updated.png',
          description: 'Harness brand update',
          banner: 'https://example.com/banner-updated.png',
          isActive: true,
        },
      })).json,
    );
    if (!String(updated.brandName || updated.name || '').includes('Updated')) throw new Error('Brand update not reflected');
    await request('DELETE', `/brands/${id}`, { token: adminToken, expected: [200, 204] });
    return `brandId=${id}`;
  });

  await runCase('admin-catalog', 'collection-crud', 'POST/GET/PUT/DELETE /api/collections/admin', async () => {
    const slug = runId.toLowerCase().replaceAll('_', '-');
    const create = unwrap(
      (await request('POST', '/collections/admin', {
        token: adminToken,
        body: {
          name: `${runId} Collection`,
          slug,
          description: 'Harness collection create',
          imageUrl: 'https://example.com/collection.png',
          type: 'SEASONAL',
          isActive: true,
          startDate: '2026-01-01',
          endDate: '2026-12-31',
          variantIds: [],
        },
      })).json,
    );
    const id = idOf(create);
    if (!id) throw new Error('Collection create did not return id');
    cleanupTasks.push(() => request('DELETE', `/collections/admin/${id}`, { token: adminToken, expected: [200, 204, 404] }));
    await request('GET', `/collections/${id}`);
    const updated = unwrap(
      (await request('PUT', `/collections/admin/${id}`, {
        token: adminToken,
        body: {
          name: `${runId} Collection Updated`,
          slug: `${slug}-updated`,
          description: 'Harness collection update',
          imageUrl: 'https://example.com/collection-updated.png',
          type: 'CAMPAIGN',
          isActive: true,
          startDate: '2026-01-01',
          endDate: '2026-12-31',
          variantIds: [],
        },
      })).json,
    );
    if (!String(updated.name || '').includes('Updated')) throw new Error('Collection update not reflected');
    await request('DELETE', `/collections/admin/${id}`, { token: adminToken, expected: [200, 204] });
    return `collectionId=${id}`;
  });
}

if (memberToken) {
  await runCase('customer', 'profile-read', 'GET /api/user/profile/me', async () => {
    const profile = unwrap((await request('GET', '/user/profile/me', { token: memberToken })).json);
    if (!profile?.email) throw new Error('Profile did not include email');
    return profile.email;
  });

  await runCase('customer', 'address-crud', 'POST/GET/PATCH/PUT/DELETE /api/user/addresses', async () => {
    const create = unwrap(
      (await request('POST', '/user/addresses', {
        token: memberToken,
        body: {
          recipientName: 'Harness Member',
          phoneNumber: '0987654321',
          city: 'Ho Chi Minh',
          district: 'Quan 1',
          ward: 'Ben Nghe',
          street: `${runId} Street`,
          isDefault: false,
        },
      })).json,
    );
    const id = idOf(create);
    if (!id) throw new Error('Address create did not return id');
    cleanupTasks.push(() => request('DELETE', `/user/addresses/${id}`, { token: memberToken, expected: [200, 204, 404] }));
    await request('GET', '/user/addresses', { token: memberToken });
    await request('PATCH', `/user/addresses/${id}/default`, { token: memberToken, expected: [200, 204] });
    const updated = unwrap(
      (await request('PUT', `/user/addresses/${id}`, {
        token: memberToken,
        body: {
          recipientName: 'Harness Member Updated',
          phoneNumber: '0987654321',
          city: 'Ho Chi Minh',
          district: 'Quan 3',
          ward: 'Vo Thi Sau',
          street: `${runId} Street Updated`,
          isDefault: true,
        },
      })).json,
    );
    if (!String(updated.street || '').includes('Updated')) throw new Error('Address update not reflected');
    await request('DELETE', `/user/addresses/${id}`, { token: memberToken, expected: [200, 204] });
    return `addressId=${id}`;
  });

  await runCase('customer', 'chat-room-message', 'POST/GET /api/chat/rooms and /api/chat/rooms/{id}/messages', async () => {
    const room = unwrap(
      (await request('POST', '/chat/rooms', {
        token: memberToken,
        body: { customerName: `${runId} Member` },
      })).json,
    );
    const id = idOf(room);
    if (!id) throw new Error('Chat room create did not return id');
    await request('GET', '/chat/rooms/me', {
      token: memberToken,
      query: { customerName: `${runId} Member` },
    });
    const messages = unwrap(
      (await request('POST', `/chat/rooms/${id}/messages`, {
        token: memberToken,
        body: { content: 'Harness smoke message', sender: 'MEMBER' },
      })).json,
    );
    if (!Array.isArray(messages)) throw new Error('Chat message response is not a list');
    await request('GET', `/chat/rooms/${id}/messages`, { token: memberToken });
    return `roomId=${id}`;
  });

  await runCase('customer', 'product-cart-readiness', 'GET /api/products then optional POST/PUT/DELETE /api/cart', async () => {
    const productsRaw = unwrap((await request('GET', '/products')).json);
    const products = Array.isArray(productsRaw) ? productsRaw : productsRaw?.products;
    if (!Array.isArray(products)) throw new Error('Products response is not a list');
    const firstVariant = products
      .flatMap((product) => product.variants || product.productVariants || [])
      .find((variant) => idOf(variant));
    if (!firstVariant) {
      return 'No product variant available; cart mutation skipped safely';
    }
    const variantId = idOf(firstVariant);
    const cart = unwrap(
      (await request('POST', '/cart/add', {
        token: memberToken,
        body: { variantId, quantity: 1 },
      })).json,
    );
    const item = (cart.items || []).find((cartItem) => String(idOf(cartItem.variant || cartItem)) === String(variantId)) || (cart.items || [])[0];
    if (!item?.id) return `variantId=${variantId}; add ok but no cart item id returned`;
    await request('PUT', `/cart/items/${item.id}`, {
      token: memberToken,
      query: { quantity: 1 },
    });
    await request('DELETE', `/cart/items/${item.id}`, {
      token: memberToken,
      expected: [200, 204],
    });
    return `variantId=${variantId}; cartItemId=${item.id}`;
  });
}

if (shipperToken) {
  await runCase('staff-delivery', 'assigned-orders-read', 'GET /api/orders/admin', async () => {
    const orders = unwrap((await request('GET', '/orders/admin', { token: shipperToken })).json);
    if (!Array.isArray(orders)) throw new Error('Orders response is not a list');
    return `${orders.length} orders visible`;
  });

  await runCase('staff-delivery', 'order-status-update-guarded', 'PATCH /api/orders/{id}/status', async () => {
    if (!allowOrderMutation) {
      return 'Skipped by default to avoid mutating real order status. Set SPORTSHOP_ALLOW_MUTATING_ORDER_STATUS=true to enable.';
    }
    const orders = unwrap((await request('GET', '/orders/admin', { token: shipperToken })).json);
    const first = Array.isArray(orders) ? orders[0] : null;
    if (!first?.id) return 'No order available to mutate';
    await request('PATCH', `/orders/${first.id}/status`, {
      token: shipperToken,
      query: { status: 'SHIPPING' },
    });
    return `orderId=${first.id} -> SHIPPING`;
  });
}

for (const cleanup of cleanupTasks.reverse()) {
  try {
    await cleanup();
  } catch {
    // The case may already have deleted its entity. Cleanup is best-effort.
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
    '# MVP API Smoke Report',
    '',
    `- Generated: ${summary.generatedAt}`,
    `- API URL: ${baseUrl}`,
    `- Run ID: ${runId}`,
    `- Pass: ${summary.pass}`,
    `- Fail: ${summary.fail}`,
    '',
    '| Area | Case | Endpoint | Status | Detail |',
    '|---|---|---|---|---|',
    ...results.map((item) =>
      `| ${item.area} | ${item.caseId} | ${item.endpoint} | ${item.status} | ${String(item.detail || '').replaceAll('|', '\\|')} |`,
    ),
    '',
  ].join('\n'),
  'utf8',
);

console.log(JSON.stringify(summary, null, 2));
if (summary.fail > 0) {
  process.exitCode = 1;
}
