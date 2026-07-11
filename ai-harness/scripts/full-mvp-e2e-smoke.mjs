import fs from 'node:fs/promises';
import path from 'node:path';
import { loadHarnessEnv, requiredEnvValue } from './env-loader.mjs';

loadHarnessEnv();

const root = path.resolve(import.meta.dirname, '..', '..');
const stateDir = path.join(root, 'ai-harness', 'state');
const reportPath = path.join(stateDir, 'full-mvp-e2e-latest.json');
const mdReportPath = path.join(stateDir, 'full-mvp-e2e-latest.md');
const baseUrl = requiredEnvValue('SPORTSHOP_API_URL');
const runId = `FULL_E2E_${Date.now()}`;

const accounts = {
  admin: {
    email: requiredEnvValue('SPORTSHOP_ADMIN_EMAIL'),
    password: requiredEnvValue('SPORTSHOP_ADMIN_PASSWORD'),
  },
  shopStaff: {
    email: requiredEnvValue('SPORTSHOP_SHOP_STAFF_EMAIL'),
    password: requiredEnvValue('SPORTSHOP_SHOP_STAFF_PASSWORD'),
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

const steps = [];
const cleanupTasks = [];

function record(area, step, status, detail = '', endpoint = '') {
  steps.push({ area, step, status, endpoint, detail });
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
  return value.id ?? value.categoryId ?? value.sportId ?? value.brandId ?? value.collectionId;
}

function detailText(value) {
  if (value === undefined || value === null || value === '') return 'OK';
  if (typeof value === 'string') return value;
  return JSON.stringify(value).replaceAll('|', '\\|');
}

async function runStep(area, step, endpoint, action) {
  try {
    const detail = await action();
    record(area, step, 'pass', detailText(detail), endpoint);
    return detail;
  } catch (error) {
    record(area, step, 'fail', error instanceof Error ? error.message : String(error), endpoint);
    throw error;
  }
}

async function runCleanup(token) {
  for (const task of cleanupTasks.reverse()) {
    try {
      await task(token);
    } catch {
      // Cleanup is best effort so reports focus on product behavior, not test data already removed by the app.
    }
  }
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

await fs.mkdir(stateDir, { recursive: true });

let finalSummary;
let adminToken = '';
let shopStaffToken = '';
let memberToken = '';
let shipperToken = '';
let orderId;
let productId;
let variantId;
let addressId;

try {
  await runStep('auth', 'admin login', 'POST /api/auth/login', async () => {
    adminToken = await login('admin');
    return 'Admin authenticated';
  });
  await runStep('auth', 'shop staff login', 'POST /api/auth/login', async () => {
    shopStaffToken = await login('shopStaff');
    return 'Shop staff authenticated';
  });
  await runStep('auth', 'customer login', 'POST /api/auth/login', async () => {
    memberToken = await login('member');
    return 'Customer authenticated';
  });
  await runStep('auth', 'shipper login', 'POST /api/auth/login', async () => {
    shipperToken = await login('shipper');
    return 'Shipper authenticated';
  });

  await runStep('customer', 'customer profile loads', 'GET /api/user/profile/me', async () => {
    const profile = unwrap((await request('GET', '/user/profile/me', { token: memberToken })).json);
    if (!profile?.email) throw new Error('Profile response does not include email');
    return { email: profile.email, role: profile.role || profile.roleName };
  });

  await runStep('customer', 'home navigation loads', 'GET /api/navigation/main', async () => {
    const navigation = unwrap((await request('GET', '/navigation/main')).json);
    if (!Array.isArray(navigation)) throw new Error('Navigation response is not a list');
    return `items=${navigation.length}`;
  });

  await runStep('security', 'customer cannot access admin categories', 'GET /api/admin/categories', async () => {
    await request('GET', '/admin/categories', { token: memberToken, expected: [401, 403] });
    return 'blocked as expected';
  });

  await runStep('admin', 'dashboard report loads', 'GET /api/admin/reports/dashboard', async () => {
    const now = new Date();
    const start = new Date(now.getTime() - 24 * 60 * 60 * 1000).toISOString().replace('Z', '');
    const end = new Date(now.getTime() + 60 * 60 * 1000).toISOString().replace('Z', '');
    const report = unwrap(
      (await request('GET', '/admin/reports/dashboard', {
        token: adminToken,
        query: { startDate: start, endDate: end },
      })).json,
    );
    for (const key of ['totalRevenue', 'totalOrders', 'newUsers', 'pendingOrders']) {
      if (!(key in report)) throw new Error(`Dashboard report missing ${key}`);
    }
    return report;
  });

  const settingKey = `harness.notification.${runId.toLowerCase()}`;
  await runStep('admin', 'notification setting upsert', 'PUT /api/admin/settings/{key}', async () => {
    const setting = unwrap(
      (await request('PUT', `/admin/settings/${settingKey}`, {
        token: adminToken,
        body: {
          value: 'true',
          description: 'Harness notification toggle smoke test',
        },
      })).json,
    );
    cleanupTasks.push(() => request('DELETE', `/admin/settings/${settingKey}`, { token: adminToken, expected: [200, 204, 404] }));
    if (setting?.value !== 'true') throw new Error('Notification setting value was not saved');
    return `key=${settingKey}`;
  });

  const categoryName = `${runId}_Category`;
  const sportName = `${runId}_Sport`;
  const brandName = `${runId} Brand`;
  const productName = `${runId} Runner Tee`;
  const sku = `${runId}-RUN-BLU-M`;

  const category = unwrap(
    await runStep('admin', 'create category', 'POST /api/admin/categories', async () =>
      (await request('POST', '/admin/categories', {
        token: adminToken,
        body: { categoryName, description: 'Full E2E category', parentId: null },
      })).json),
  );
  cleanupTasks.push(() => request('DELETE', `/admin/categories/${idOf(category)}`, { token: adminToken, expected: [200, 204, 404, 500] }));

  const sport = unwrap(
    await runStep('admin', 'create sport', 'POST /api/admin/sports', async () =>
      (await request('POST', '/admin/sports', {
        token: adminToken,
        body: { sportName, description: 'Full E2E sport' },
      })).json),
  );
  cleanupTasks.push(() => request('DELETE', `/admin/sports/${idOf(sport)}`, { token: adminToken, expected: [200, 204, 404, 500] }));

  const brand = unwrap(
    await runStep('admin', 'create brand', 'POST /api/brands', async () =>
      (await request('POST', '/brands', {
        token: adminToken,
        body: {
          name: brandName,
          slug: runId.toLowerCase().replaceAll('_', '-'),
          logo: 'https://example.com/full-e2e-logo.png',
          banner: 'https://example.com/full-e2e-banner.png',
          description: 'Full E2E brand',
          isActive: true,
        },
      })).json),
  );
  cleanupTasks.push(() => request('DELETE', `/brands/${idOf(brand)}`, { token: adminToken, expected: [200, 204, 404, 500] }));

  const product = unwrap(
    await runStep('admin', 'create product stock=1', 'POST /api/admin/products', async () =>
      (await request('POST', '/admin/products', {
        token: adminToken,
        body: {
          productName,
          description: 'Full MVP order product',
          categoryName,
          brandName,
          sportName,
          variants: [
            {
              size: 'M',
              color: 'Blue',
              price: 199000,
              stockQuantity: 1,
              sku,
              imageUrls: ['https://example.com/full-e2e-product.png'],
            },
          ],
        },
      })).json),
  );
  productId = idOf(product);
  variantId = product?.variants?.[0]?.id;
  if (!productId || !variantId) throw new Error('Product creation did not return product and variant ids');

  await runStep('customer', 'cart rejects quantity above stock', 'POST /api/cart/add', async () => {
    await request('POST', '/cart/add', {
      token: memberToken,
      body: { variantId, quantity: 2 },
      expected: [400, 409, 500],
    });
    return 'stock guard triggered';
  });

  const address = unwrap(
    await runStep('customer', 'create delivery address', 'POST /api/user/addresses', async () =>
      (await request('POST', '/user/addresses', {
        token: memberToken,
        body: {
          recipientName: 'Full E2E Customer',
          phoneNumber: '0987654321',
          city: 'Ho Chi Minh',
          district: 'Quan 1',
          ward: 'Ben Nghe',
          street: `${runId} Street`,
          isDefault: true,
        },
      })).json),
  );
  addressId = idOf(address);
  if (!addressId) throw new Error('Address creation did not return id');

  await runStep('customer', 'add valid product to cart', 'POST /api/cart/add', async () => {
    const cart = unwrap(
      (await request('POST', '/cart/add', {
        token: memberToken,
        body: { variantId, quantity: 1 },
      })).json,
    );
    if (Number(cart?.totalItems ?? 0) < 1) throw new Error('Cart totalItems did not increase');
    return `totalItems=${cart.totalItems}`;
  });

  const order = unwrap(
    await runStep('customer', 'checkout VNPAY order', 'POST /api/orders/checkout', async () =>
      (await request('POST', '/orders/checkout', {
        token: memberToken,
        body: { addressId, paymentMethod: 'VNPAY', note: `Full MVP order ${runId}` },
      })).json),
  );
  orderId = idOf(order);
  if (!orderId) throw new Error('Checkout did not return order id');
  if (String(order.status || '').toUpperCase() !== 'PENDING') throw new Error(`Expected PENDING, got ${order.status}`);

  await runStep('customer', 'payment URL can be generated', 'GET /api/payment/create_payment/{orderId}', async () => {
    const payment = unwrap((await request('GET', `/payment/create_payment/${orderId}`, { token: memberToken })).json);
    if (!payment?.paymentUrl || !String(payment.paymentUrl).startsWith('http')) {
      throw new Error('Payment response does not include a valid paymentUrl');
    }
    return { status: payment.status, hasPaymentUrl: true };
  });

  await runStep('staff', 'staff sees order queue', 'GET /api/orders/admin', async () => {
    const orders = unwrap((await request('GET', '/orders/admin', { token: shopStaffToken })).json);
    if (!Array.isArray(orders)) throw new Error('Admin orders response is not a list');
    if (!orders.some((item) => String(idOf(item)) === String(orderId))) throw new Error(`Order ${orderId} not visible to staff`);
    return `orders=${orders.length}`;
  });

  await runStep('staff', 'staff confirms order', 'PATCH /api/orders/{id}/status?status=CONFIRMED', async () => {
    const updated = unwrap(
      (await request('PATCH', `/orders/${orderId}/status`, {
        token: shopStaffToken,
        query: { status: 'CONFIRMED' },
      })).json,
    );
    if (String(updated.status || '').toUpperCase() !== 'CONFIRMED') throw new Error(`Got ${updated.status}`);
    return `orderId=${orderId}`;
  });

  await runStep('security', 'shipper cannot complete before shipped', 'PATCH /api/orders/{id}/status?status=COMPLETED', async () => {
    await request('PATCH', `/orders/${orderId}/status`, {
      token: shipperToken,
      query: { status: 'COMPLETED' },
      expected: [400, 403, 500],
    });
    return 'invalid transition blocked';
  });

  await runStep('staff', 'staff packs order', 'PATCH /api/orders/{id}/status?status=PACKING', async () => {
    const updated = unwrap(
      (await request('PATCH', `/orders/${orderId}/status`, {
        token: shopStaffToken,
        query: { status: 'PACKING' },
      })).json,
    );
    if (String(updated.status || '').toUpperCase() !== 'PACKING') throw new Error(`Got ${updated.status}`);
    return `orderId=${orderId}`;
  });

  await runStep('staff', 'staff ships order', 'PATCH /api/orders/{id}/status?status=SHIPPED', async () => {
    const updated = unwrap(
      (await request('PATCH', `/orders/${orderId}/status`, {
        token: shopStaffToken,
        query: { status: 'SHIPPED' },
      })).json,
    );
    if (String(updated.status || '').toUpperCase() !== 'SHIPPED') throw new Error(`Got ${updated.status}`);
    return `orderId=${orderId}`;
  });

  await runStep('shipper', 'shipper completes delivery', 'PATCH /api/orders/{id}/status?status=COMPLETED', async () => {
    const updated = unwrap(
      (await request('PATCH', `/orders/${orderId}/status`, {
        token: shipperToken,
        query: { status: 'COMPLETED' },
      })).json,
    );
    if (String(updated.status || '').toUpperCase() !== 'COMPLETED') throw new Error(`Got ${updated.status}`);
    return `orderId=${orderId}`;
  });

  await runStep('admin', 'admin verifies completed order', 'GET /api/orders/admin/{id}', async () => {
    const fetched = unwrap((await request('GET', `/orders/admin/${orderId}`, { token: adminToken })).json);
    if (String(fetched.status || '').toUpperCase() !== 'COMPLETED') throw new Error(`Got ${fetched.status}`);
    return { orderId, status: fetched.status, totalAmount: fetched.totalAmount ?? fetched.totalPrice };
  });

  await runStep('admin', 'admin verifies stock became zero', 'GET /api/admin/products/{id}', async () => {
    const fetched = unwrap((await request('GET', `/admin/products/${productId}`, { token: adminToken })).json);
    const stock = Number(fetched?.variants?.find((item) => String(item.id) === String(variantId))?.stockQuantity);
    if (stock !== 0) throw new Error(`Expected stock 0 after buying 1 from 1, got ${stock}`);
    return `variantId=${variantId}; stock=${stock}`;
  });

  await runStep('customer', 'customer order history contains delivered order', 'GET /api/orders/my-orders', async () => {
    const orders = unwrap((await request('GET', '/orders/my-orders', { token: memberToken })).json);
    if (!Array.isArray(orders)) throw new Error('My orders response is not a list');
    const found = orders.find((item) => String(idOf(item)) === String(orderId));
    if (!found) throw new Error(`Order ${orderId} not found in customer history`);
    return { orderId, status: found.status };
  });

  await runStep('customer', 'customer cleans address', 'DELETE /api/user/addresses/{id}', async () => {
    await request('DELETE', `/user/addresses/${addressId}`, { token: memberToken, expected: [200, 204] });
    return `addressId=${addressId}`;
  });

  finalSummary = {
    generatedAt: new Date().toISOString(),
    baseUrl,
    runId,
    status: 'pass',
    orderId,
    productId,
    variantId,
    steps,
  };
} catch (error) {
  finalSummary = {
    generatedAt: new Date().toISOString(),
    baseUrl,
    runId,
    status: 'fail',
    orderId,
    productId,
    variantId,
    error: error instanceof Error ? error.message : String(error),
    steps,
  };
} finally {
  if (adminToken) {
    await runCleanup(adminToken);
  }
}

await fs.writeFile(reportPath, `${JSON.stringify(finalSummary, null, 2)}\n`, 'utf8');
await fs.writeFile(
  mdReportPath,
  [
    '# Full MVP End-to-End Report',
    '',
    `- Generated: ${finalSummary.generatedAt}`,
    `- API URL: ${baseUrl}`,
    `- Run ID: ${runId}`,
    `- Status: ${finalSummary.status}`,
    finalSummary.orderId ? `- Order ID: ${finalSummary.orderId}` : '',
    finalSummary.productId ? `- Product ID: ${finalSummary.productId}` : '',
    finalSummary.variantId ? `- Variant ID: ${finalSummary.variantId}` : '',
    finalSummary.error ? `- Error: ${finalSummary.error}` : '',
    '',
    '| Area | Step | Endpoint | Status | Detail |',
    '|---|---|---|---|---|',
    ...steps.map((item) =>
      `| ${item.area} | ${item.step} | ${item.endpoint} | ${item.status} | ${String(item.detail || '').replaceAll('|', '\\|')} |`,
    ),
    '',
  ].filter(Boolean).join('\n'),
  'utf8',
);

console.log(JSON.stringify(finalSummary, null, 2));
if (finalSummary.status !== 'pass') {
  process.exitCode = 1;
}
