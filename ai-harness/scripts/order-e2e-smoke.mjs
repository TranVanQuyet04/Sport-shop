import fs from 'node:fs/promises';
import path from 'node:path';
import { loadHarnessEnv, requiredEnvValue } from './env-loader.mjs';

loadHarnessEnv();

const root = path.resolve(import.meta.dirname, '..', '..');
const stateDir = path.join(root, 'ai-harness', 'state');
const reportPath = path.join(stateDir, 'order-e2e-smoke-latest.json');
const mdReportPath = path.join(stateDir, 'order-e2e-smoke-latest.md');
const baseUrl = requiredEnvValue('SPORTSHOP_API_URL');
const runId = `E2E_${Date.now()}`;

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

function record(step, status, detail = '', endpoint = '') {
  steps.push({ step, status, endpoint, detail });
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

async function runStep(step, endpoint, action) {
  try {
    const detail = await action();
    record(step, 'pass', detail || 'OK', endpoint);
    return detail;
  } catch (error) {
    record(step, 'fail', error instanceof Error ? error.message : String(error), endpoint);
    throw error;
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

try {
  let adminToken = '';
  let shopStaffToken = '';
  let memberToken = '';
  let shipperToken = '';

  await runStep('login admin', 'POST /api/auth/login', async () => {
    adminToken = await login('admin');
    return 'Admin login OK';
  });
  await runStep('login shop staff', 'POST /api/auth/login', async () => {
    shopStaffToken = await login('shopStaff');
    return 'Shop staff login OK';
  });
  await runStep('login member', 'POST /api/auth/login', async () => {
    memberToken = await login('member');
    return 'Member login OK';
  });
  await runStep('login shipper', 'POST /api/auth/login', async () => {
    shipperToken = await login('shipper');
    return 'Shipper login OK';
  });

  const categoryName = `${runId}_Category`;
  const brandName = `${runId} Brand`;
  const sportName = `${runId}_Sport`;
  const productName = `${runId} Performance Tee`;
  const sku = `${runId}-TEE-BLK-M`;

  const category = unwrap(
    (await runStep('admin create category', 'POST /api/admin/categories', async () =>
      (await request('POST', '/admin/categories', {
        token: adminToken,
        body: { categoryName, description: 'E2E category', parentId: null },
      })).json,
    )) || {},
  );

  const sport = unwrap(
    (await runStep('admin create sport', 'POST /api/admin/sports', async () =>
      (await request('POST', '/admin/sports', {
        token: adminToken,
        body: { sportName, description: 'E2E sport' },
      })).json,
    )) || {},
  );

  const brand = unwrap(
    (await runStep('admin create brand', 'POST /api/brands', async () =>
      (await request('POST', '/brands', {
        token: adminToken,
        body: {
          name: brandName,
          slug: runId.toLowerCase().replaceAll('_', '-'),
          logo: 'https://example.com/e2e-logo.png',
          banner: 'https://example.com/e2e-banner.png',
          description: 'E2E brand',
          isActive: true,
        },
      })).json,
    )) || {},
  );

  const product = unwrap(
    (await runStep('admin create product with stock', 'POST /api/admin/products', async () =>
      (await request('POST', '/admin/products', {
        token: adminToken,
        body: {
          productName,
          description: 'E2E product for full order flow',
          categoryName,
          brandName,
          sportName,
          variants: [
            {
              size: 'M',
              color: 'Black',
              price: 250000,
              stockQuantity: 5,
              sku,
              imageUrls: ['https://example.com/e2e-product.png'],
            },
          ],
        },
      })).json,
    )) || {},
  );

  const productId = idOf(product);
  const variantId = product?.variants?.[0]?.id;
  if (!productId || !variantId) {
    throw new Error(`Product/variant creation did not return ids: productId=${productId}, variantId=${variantId}`);
  }

  const address = unwrap(
    (await runStep('customer create address', 'POST /api/user/addresses', async () =>
      (await request('POST', '/user/addresses', {
        token: memberToken,
        body: {
          recipientName: 'E2E Member',
          phoneNumber: '0987654321',
          city: 'Ho Chi Minh',
          district: 'Quan 1',
          ward: 'Ben Nghe',
          street: `${runId} Street`,
          isDefault: true,
        },
      })).json,
    )) || {},
  );
  const addressId = idOf(address);
  if (!addressId) throw new Error('Address creation did not return id');

  await runStep('customer add variant to cart', 'POST /api/cart/add', async () => {
    const cart = unwrap(
      (await request('POST', '/cart/add', {
        token: memberToken,
        body: { variantId, quantity: 2 },
      })).json,
    );
    const totalItems = Number(cart?.totalItems ?? 0);
    if (totalItems < 2) throw new Error(`Expected cart totalItems >= 2, got ${totalItems}`);
    return `variantId=${variantId}; totalItems=${totalItems}`;
  });

  const order = unwrap(
    (await runStep('customer checkout COD', 'POST /api/orders/checkout', async () =>
      (await request('POST', '/orders/checkout', {
        token: memberToken,
        body: { addressId, paymentMethod: 'COD', note: `E2E order ${runId}` },
      })).json,
    )) || {},
  );
  const orderId = idOf(order);
  if (!orderId) throw new Error('Checkout did not return order id');
  if (String(order.status || '').toUpperCase() !== 'PENDING') {
    throw new Error(`Expected checkout order status PENDING, got ${order.status}`);
  }

  await runStep('customer cart cleared after checkout', 'GET /api/cart', async () => {
    const cart = unwrap((await request('GET', '/cart', { token: memberToken })).json);
    const totalItems = Number(cart?.totalItems ?? 0);
    if (totalItems !== 0) throw new Error(`Expected empty cart after checkout, got totalItems=${totalItems}`);
    return 'cart empty';
  });

  await runStep('shop staff confirm order', 'PATCH /api/orders/{id}/status?status=CONFIRMED', async () => {
    const updated = unwrap(
      (await request('PATCH', `/orders/${orderId}/status`, {
        token: shopStaffToken,
        query: { status: 'CONFIRMED' },
      })).json,
    );
    if (String(updated.status || '').toUpperCase() !== 'CONFIRMED') throw new Error(`Got ${updated.status}`);
    return `orderId=${orderId}`;
  });

  await runStep('shop staff pack order', 'PATCH /api/orders/{id}/status?status=PACKING', async () => {
    const updated = unwrap(
      (await request('PATCH', `/orders/${orderId}/status`, {
        token: shopStaffToken,
        query: { status: 'PACKING' },
      })).json,
    );
    if (String(updated.status || '').toUpperCase() !== 'PACKING') throw new Error(`Got ${updated.status}`);
    return `orderId=${orderId}`;
  });

  await runStep('shop staff ship order', 'PATCH /api/orders/{id}/status?status=SHIPPED', async () => {
    const updated = unwrap(
      (await request('PATCH', `/orders/${orderId}/status`, {
        token: shopStaffToken,
        query: { status: 'SHIPPED' },
      })).json,
    );
    if (String(updated.status || '').toUpperCase() !== 'SHIPPED') throw new Error(`Got ${updated.status}`);
    return `orderId=${orderId}`;
  });

  await runStep('shipper complete order', 'PATCH /api/orders/{id}/status?status=COMPLETED', async () => {
    const updated = unwrap(
      (await request('PATCH', `/orders/${orderId}/status`, {
        token: shipperToken,
        query: { status: 'COMPLETED' },
      })).json,
    );
    if (String(updated.status || '').toUpperCase() !== 'COMPLETED') throw new Error(`Got ${updated.status}`);
    return `orderId=${orderId}`;
  });

  await runStep('admin verify completed order', 'GET /api/orders/admin/{id}', async () => {
    const fetched = unwrap((await request('GET', `/orders/admin/${orderId}`, { token: adminToken })).json);
    if (String(fetched.status || '').toUpperCase() !== 'COMPLETED') throw new Error(`Got ${fetched.status}`);
    return `orderId=${orderId}; total=${fetched.totalAmount ?? fetched.totalPrice ?? ''}`;
  });

  await runStep('customer verify order history', 'GET /api/orders', async () => {
    const orders = unwrap((await request('GET', '/orders', { token: memberToken })).json);
    if (!Array.isArray(orders)) throw new Error('Customer orders response is not a list');
    const found = orders.find((item) => String(idOf(item)) === String(orderId));
    if (!found) throw new Error(`Order ${orderId} not found in member order history`);
    if (String(found.status || '').toUpperCase() !== 'COMPLETED') throw new Error(`Got ${found.status}`);
    return `orderId=${orderId}`;
  });

  await runStep('admin verify stock deducted', 'GET /api/admin/products/{id}', async () => {
    const fetched = unwrap((await request('GET', `/admin/products/${productId}`, { token: adminToken })).json);
    const stock = Number(fetched?.variants?.find((item) => String(item.id) === String(variantId))?.stockQuantity);
    if (stock !== 3) throw new Error(`Expected stock 3 after buying 2 from 5, got ${stock}`);
    return `variantId=${variantId}; stock=${stock}`;
  });

  await runStep('customer cleanup address', 'DELETE /api/user/addresses/{id}', async () => {
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
    categoryId: idOf(category),
    brandId: idOf(brand),
    sportId: idOf(sport),
    steps,
  };
} catch (error) {
  finalSummary = {
    generatedAt: new Date().toISOString(),
    baseUrl,
    runId,
    status: 'fail',
    error: error instanceof Error ? error.message : String(error),
    steps,
  };
}

await fs.writeFile(reportPath, `${JSON.stringify(finalSummary, null, 2)}\n`, 'utf8');
await fs.writeFile(
  mdReportPath,
  [
    '# Order End-to-End Smoke Report',
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
    '| Step | Endpoint | Status | Detail |',
    '|---|---|---|---|',
    ...steps.map((item) =>
      `| ${item.step} | ${item.endpoint} | ${item.status} | ${String(item.detail || '').replaceAll('|', '\\|')} |`,
    ),
    '',
  ].filter(Boolean).join('\n'),
  'utf8',
);

console.log(JSON.stringify(finalSummary, null, 2));
if (finalSummary.status !== 'pass') {
  process.exitCode = 1;
}
