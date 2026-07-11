import fs from 'node:fs/promises';
import path from 'node:path';
import { createRequire } from 'node:module';
import { loadHarnessEnv, requiredEnvValue } from './env-loader.mjs';

loadHarnessEnv();

const root = path.resolve(import.meta.dirname, '..', '..');
const require = createRequire(import.meta.url);
const { chromium } = require('../.playwright-runner/node_modules/playwright');

const stateDir = path.join(root, 'ai-harness', 'state', 'browser-customer-staff-smoke');
const reportPath = path.join(root, 'ai-harness', 'state', 'customer-staff-browser-smoke-latest.json');
const mdReportPath = path.join(root, 'ai-harness', 'state', 'customer-staff-browser-smoke-latest.md');
const baseUrl = requiredEnvValue('SPORTSHOP_WEB_URL');
const backendUrl = requiredEnvValue('SPORTSHOP_API_URL');
const chromePath = process.env.CHROME_PATH || 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const deviceProfilesPath = path.join(root, 'ai-harness', 'config', 'device-profiles.json');
const deviceProfiles = JSON.parse(await fs.readFile(deviceProfilesPath, 'utf8'));
const deviceKey = process.env.SPORTSHOP_TEST_DEVICE || deviceProfiles.defaultDevice || 'pixel7';
const testDevice = deviceProfiles.devices?.[deviceKey];

if (!testDevice) {
  throw new Error(`Unknown test device "${deviceKey}" in ${deviceProfilesPath}`);
}

const roles = [
  {
    key: 'customer',
    email: requiredEnvValue('SPORTSHOP_MEMBER_EMAIL'),
    password: requiredEnvValue('SPORTSHOP_MEMBER_PASSWORD'),
    routes: [
      { key: 'customerHome', path: '/customer/home' },
      { key: 'customerSearch', path: '/customer/search' },
      { key: 'customerCart', path: '/customer/cart' },
      { key: 'customerCheckout', path: '/customer/checkout' },
      { key: 'customerAddresses', path: '/customer/addresses' },
      { key: 'customerOrders', path: '/customer/orders' },
      { key: 'customerProfile', path: '/customer/profile' },
      { key: 'customerSupport', path: '/customer/support' },
      { key: 'customerChat', path: '/customer/support/chat' },
    ],
  },
  {
    key: 'deliveryStaff',
    email: requiredEnvValue('SPORTSHOP_SHIPPER_EMAIL'),
    password: requiredEnvValue('SPORTSHOP_SHIPPER_PASSWORD'),
    routes: [
      { key: 'deliveryHome', path: '/delivery-staff/home' },
      { key: 'deliveryOrders', path: '/delivery-staff/orders' },
      { key: 'deliveryAccount', path: '/delivery-staff/account' },
    ],
  },
];

const publicRoutes = [
  { key: 'splash', path: '/' },
  { key: 'onboarding', path: '/onboarding' },
  { key: 'login', path: '/login' },
  { key: 'register', path: '/register' },
  { key: 'forgotPassword', path: '/forgot-password' },
  { key: 'resetPassword', path: '/reset-password' },
  { key: 'guestChat', path: '/guest-chat' },
  { key: 'unauthorized', path: '/unauthorized' },
];

await fs.mkdir(stateDir, { recursive: true });

function appUrl(routePath) {
  return `${baseUrl}/#${routePath}`;
}

function isBlankScreenshot(buffer) {
  const sample = buffer.subarray(100, Math.min(buffer.length, 5000));
  const unique = new Set(sample).size;
  return buffer.length < 12000 || unique < 18;
}

async function readPageSignals(page) {
  return page.evaluate(() => {
    const text = document.body?.innerText || '';
    const mojibakeMatches =
      text.match(
        /\u00C3[\u0080-\u00BF\u00A0-\u00FF]|\u00C2[\u0080-\u00BF\u00A0-\u00FF]|(?:\u00E1\u00BA|\u00E1\u00BB|\u00C4\u2018|\u00C4\u0091|\u00C6\u00B0|\u00C6\u00A1|\u00C5\u00A9)|\uFFFD/gu,
      ) || [];
    return {
      href: location.href,
      title: document.title,
      bodyTextLength: text.length,
      mojibakeCount: mojibakeMatches.length,
      mojibakeSamples: mojibakeMatches.slice(0, 6),
      canvasCount: document.querySelectorAll('canvas').length,
      glassPane: Boolean(document.querySelector('flt-glass-pane')),
      semanticsHost: Boolean(document.querySelector('flt-semantics-host')),
      loaderVisible: Boolean(document.querySelector('.flutter-loader')),
      htmlLength: document.body?.innerHTML?.length || 0,
    };
  });
}

async function waitForFlutter(page) {
  await page.waitForLoadState('domcontentloaded', { timeout: 30000 });
  const started = Date.now();
  let lastSignals = {};
  let lastShot = Buffer.from([]);
  while (Date.now() - started < 45000) {
    await page.waitForTimeout(1000);
    lastSignals = await readPageSignals(page).catch(() => ({}));
    lastShot = await page.screenshot({ fullPage: false }).catch(() => Buffer.from([]));
    if (
      (lastSignals.glassPane || lastSignals.canvasCount > 0 || lastSignals.htmlLength > 1200) &&
      !lastSignals.loaderVisible &&
      !isBlankScreenshot(lastShot)
    ) {
      await page.waitForTimeout(700);
      return;
    }
  }
  throw new Error(
    `Flutter UI did not become visually ready. Last signals: ${JSON.stringify(lastSignals)}, screenshotBytes=${lastShot.length}`,
  );
}

async function loginThroughUi(page, role) {
  await page.goto(appUrl('/admin/dashboard'), { waitUntil: 'domcontentloaded', timeout: 30000 });
  await page.waitForTimeout(12000);
  await page.goto(appUrl('/login'), { waitUntil: 'domcontentloaded', timeout: 30000 });
  await waitForFlutter(page);

  const inputCount = await page.locator('input').count().catch(() => 0);
  if (inputCount >= 2) {
    await page.locator('input').nth(0).fill(role.email, { timeout: 10000 });
    await page.locator('input').nth(1).fill(role.password, { timeout: 10000 });
    const buttonCount = await page.locator('button').count().catch(() => 0);
    if (buttonCount > 0) {
      await page.locator('button').nth(0).click({ timeout: 10000 });
    } else {
      await page.mouse.click(195, 367);
    }
  } else {
    await page.mouse.click(150, 204);
    await page.keyboard.type(role.email);
    await page.mouse.click(150, 292);
    await page.keyboard.type(role.password);
    await page.mouse.click(195, 367);
  }

  await page.waitForTimeout(18000);
  if (page.url().includes('/login')) {
    throw new Error(`UI login did not leave login route for ${role.key}.`);
  }
}

async function tryAddDynamicRoutes(role) {
  if (role.key !== 'deliveryStaff') {
    return [];
  }
  try {
    const login = await fetch(`${backendUrl}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: role.email, password: role.password }),
    });
    if (!login.ok) {
      return [];
    }
    const loginJson = await login.json();
    const source = loginJson.result && typeof loginJson.result === 'object' ? loginJson.result : loginJson;
    const token = source.accessToken || source.token;
    if (!token) {
      return [];
    }
    const orders = await fetch(`${backendUrl}/orders/admin`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    if (!orders.ok) {
      return [];
    }
    const ordersJson = await orders.json();
    const items = Array.isArray(ordersJson.result)
      ? ordersJson.result
      : Array.isArray(ordersJson.data)
        ? ordersJson.data
        : Array.isArray(ordersJson)
          ? ordersJson
          : [];
    const first = items[0];
    if (!first?.id) {
      return [];
    }
    return [{ key: 'deliveryStatusUpdate', path: `/delivery-staff/orders/${first.id}/status` }];
  } catch {
    return [];
  }
}

const results = [];

async function visitRoute(page, route, roleKey, consoleMessages, screenshotPrefix = roleKey) {
  const routeConsoleStart = consoleMessages.length;
  const url = appUrl(route.path);
  const screenshotPath = path.join(stateDir, `${screenshotPrefix}-${route.key}.png`);
  let status = 'pass';
  let error = '';
  let signals = {};
  let screenshotBytes = 0;

  try {
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 30000 });
    await waitForFlutter(page);
    signals = await readPageSignals(page);
    const shot = await page.screenshot({ path: screenshotPath, fullPage: false });
    screenshotBytes = shot.length;
    const currentUrl = page.url();
    const routeConsole = consoleMessages.slice(routeConsoleStart);
    const hasRuntimeError = routeConsole.some((item) =>
      /RenderFlex overflow|Unexpected null value|Assertion failed|There is nothing to pop|TypeError|ReferenceError/i.test(
        item.text,
      ),
    );

    if (signals.loaderVisible || (!signals.glassPane && signals.canvasCount === 0)) {
      status = 'fail';
      error = 'Flutter UI did not mount for this route.';
    } else if (isBlankScreenshot(shot)) {
      status = 'warning';
      error = 'Screenshot looks blank or visually low-information.';
    } else if ((signals.mojibakeCount || 0) > 0) {
      status = 'fail';
      error = `Visible text contains mojibake/encoding-broken text (${signals.mojibakeCount} match(es)).`;
    } else if (hasRuntimeError) {
      status = 'fail';
      error = 'Runtime console contains Flutter/JS error.';
    }

    results.push({
      role: roleKey,
      ...route,
      url,
      finalUrl: currentUrl,
      status,
      error,
      signals,
      screenshotPath,
      screenshotBytes,
    });
  } catch (err) {
    results.push({
      role: roleKey,
      ...route,
      url,
      status: 'fail',
      error: err instanceof Error ? err.message : String(err),
      signals,
      screenshotPath,
      screenshotBytes,
    });
  }
}

async function runPublicRouteSmoke() {
  const browser = await chromium.launch({
    headless: true,
    executablePath: chromePath,
    args: ['--disable-gpu', '--no-sandbox'],
  });
  const context = await browser.newContext({
    viewport: testDevice.viewport,
    deviceScaleFactor: testDevice.deviceScaleFactor,
    isMobile: testDevice.isMobile,
    hasTouch: testDevice.hasTouch,
  });
  const page = await context.newPage();
  const consoleMessages = [];
  page.on('console', (message) => {
    if (['error', 'warning'].includes(message.type())) {
      consoleMessages.push({
        type: message.type(),
        text: message.text(),
        location: message.location(),
      });
    }
  });
  page.on('pageerror', (error) => {
    consoleMessages.push({ type: 'pageerror', text: error.message });
  });

  try {
    for (const route of publicRoutes) {
      await visitRoute(page, route, 'public', consoleMessages, 'public');
    }

    const routeConsoleStart = consoleMessages.length;
    await page.goto(appUrl('/login'), { waitUntil: 'domcontentloaded', timeout: 30000 });
    await waitForFlutter(page);
    await page.mouse.click(94, 218);
    await page.waitForTimeout(1200);
    const finalUrl = page.url();
    const routeConsole = consoleMessages.slice(routeConsoleStart);
    const hasPopCrash = routeConsole.some((item) => /There is nothing to pop/i.test(item.text));
    const status = finalUrl.includes('/onboarding') && !hasPopCrash ? 'pass' : 'fail';
    results.push({
      role: 'public',
      key: 'loginBackFallback',
      path: '/login',
      url: appUrl('/login'),
      finalUrl,
      status,
      error: status === 'pass' ? '' : 'Login back button did not fall back to onboarding.',
      signals: await readPageSignals(page).catch(() => ({})),
      screenshotPath: '',
      screenshotBytes: 0,
    });
  } finally {
    await context.close();
    await browser.close();
  }
}

try {
  await runPublicRouteSmoke();

  for (const role of roles) {
    const browser = await chromium.launch({
      headless: true,
      executablePath: chromePath,
      args: ['--disable-gpu', '--no-sandbox'],
    });

    const context = await browser.newContext({
      viewport: testDevice.viewport,
      deviceScaleFactor: testDevice.deviceScaleFactor,
      isMobile: testDevice.isMobile,
      hasTouch: testDevice.hasTouch,
    });
    const page = await context.newPage();
    const consoleMessages = [];

    page.on('console', (message) => {
      console.log(`[Browser Console ${message.type()}] ${message.text()}`);
      if (['error', 'warning'].includes(message.type())) {
        consoleMessages.push({
          type: message.type(),
          text: message.text(),
          location: message.location(),
        });
      }
    });
    page.on('pageerror', (error) => {
      console.error(`[Browser PageError] ${error.stack || error.message}`);
      consoleMessages.push({ type: 'pageerror', text: error.message });
    });

    try {
      await loginThroughUi(page, role);
      const routes = [...role.routes, ...(await tryAddDynamicRoutes(role))];

      for (const route of routes) {
        await visitRoute(page, route, role.key, consoleMessages);
        const latest = results.at(-1);
        if (latest?.finalUrl?.includes('/login')) {
          latest.status = 'fail';
          latest.error = 'Route redirected to login after role login.';
        }
      }
    } catch (err) {
      console.error(`[Login Exception for ${role.key}]`, err);
      results.push({
        role: role.key,
        key: 'login',
        path: '/login',
        url: appUrl('/login'),
        status: 'fail',
        error: err instanceof Error ? err.message : String(err),
      });
    } finally {
      await context.close();
      await browser.close();
    }
  }
} finally {
  // browser already closed inside loop
}

const summary = {
  generatedAt: new Date().toISOString(),
  baseUrl,
  backendUrl,
  device: { key: deviceKey, ...testDevice },
  pass: results.filter((item) => item.status === 'pass').length,
  warning: results.filter((item) => item.status === 'warning').length,
  fail: results.filter((item) => item.status === 'fail').length,
  results,
};

await fs.writeFile(reportPath, `${JSON.stringify(summary, null, 2)}\n`, 'utf8');
await fs.writeFile(
  mdReportPath,
  [
    '# Customer & Staff Browser Smoke Report',
    '',
    `- Generated: ${summary.generatedAt}`,
    `- Base URL: ${baseUrl}`,
    `- Backend URL: ${backendUrl}`,
    `- Device: ${summary.device.label || deviceKey} (${summary.device.viewport.width}x${summary.device.viewport.height})`,
    `- Pass: ${summary.pass}`,
    `- Warning: ${summary.warning}`,
    `- Fail: ${summary.fail}`,
    '',
    '| Role | Route | Status | Error | Screenshot |',
    '|---|---|---|---|---|',
    ...results.map((item) =>
      `| ${item.role} | ${item.path} | ${item.status} | ${(item.error || '').replaceAll('|', '\\|')} | ${item.screenshotPath || ''} |`,
    ),
    '',
  ].join('\n'),
  'utf8',
);

if (summary.fail > 0) {
  process.exitCode = 1;
}

console.log(JSON.stringify(summary, null, 2));
