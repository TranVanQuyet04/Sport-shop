import fs from 'node:fs/promises';
import path from 'node:path';
import { createRequire } from 'node:module';
import { loadHarnessEnv, requiredEnvValue } from './env-loader.mjs';

loadHarnessEnv();

const root = path.resolve(import.meta.dirname, '..', '..');
const require = createRequire(import.meta.url);
const { chromium } = require('../.playwright-runner/node_modules/playwright');
const stateDir = path.join(root, 'ai-harness', 'state', 'browser-admin-smoke');
const reportPath = path.join(root, 'ai-harness', 'state', 'admin-mobile-browser-smoke-latest.json');
const mdReportPath = path.join(root, 'ai-harness', 'state', 'admin-mobile-browser-smoke-latest.md');
const baseUrl = requiredEnvValue('SPORTSHOP_WEB_URL');
const backendUrl = requiredEnvValue('SPORTSHOP_API_URL');
const adminEmail = requiredEnvValue('SPORTSHOP_ADMIN_EMAIL');
const adminPassword = requiredEnvValue('SPORTSHOP_ADMIN_PASSWORD');
const chromePath = process.env.CHROME_PATH || 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const deviceProfilesPath = path.join(root, 'ai-harness', 'config', 'device-profiles.json');
const deviceProfiles = JSON.parse(await fs.readFile(deviceProfilesPath, 'utf8'));
const deviceKey = process.env.SPORTSHOP_TEST_DEVICE || deviceProfiles.defaultDevice || 'pixel7';
const testDevice = deviceProfiles.devices?.[deviceKey];

if (!testDevice) {
  throw new Error(`Unknown test device "${deviceKey}" in ${deviceProfilesPath}`);
}

const routes = [
  { key: 'dashboard', path: '/admin/dashboard' },
  { key: 'products', path: '/admin/products' },
  { key: 'productsSportTab', path: '/admin/products?tab=sport' },
  { key: 'sports', path: '/admin/sports' },
  { key: 'collections', path: '/admin/collections' },
  { key: 'orders', path: '/admin/orders' },
  { key: 'staff', path: '/admin/staff' },
  { key: 'users', path: '/admin/users' },
  { key: 'chatRooms', path: '/admin/chats' },
  { key: 'settings', path: '/admin/settings' },
  { key: 'profile', path: '/admin/profile' },
  { key: 'changePassword', path: '/admin/change-password' },
];

await fs.mkdir(stateDir, { recursive: true });

async function backendLogin() {
  const response = await fetch(`${backendUrl}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: adminEmail, password: adminPassword }),
  });
  if (!response.ok) {
    throw new Error(`Backend login failed: ${response.status} ${await response.text()}`);
  }
  const json = await response.json();
  const source = json.result && typeof json.result === 'object' ? json.result : json;
  const user = source.user && typeof source.user === 'object' ? source.user : {};
  return {
    accessToken: String(source.accessToken || source.token || ''),
    refreshToken: String(source.refreshToken || ''),
    role: String(source.role || source.roleName || user.role || user.roleName || 'ADMIN'),
    email: String(source.email || user.email || adminEmail),
  };
}

function appUrl(routePath) {
  return `${baseUrl}/#${routePath}`;
}

function isBlankScreenshot(buffer) {
  // Cheap PNG byte heuristic: a blank loader/white screen compresses very small
  // or has very low diversity in the first content chunk. This is not visual QA,
  // but it catches "Flutter never mounted" during smoke tests.
  const sample = buffer.subarray(100, Math.min(buffer.length, 5000));
  const unique = new Set(sample).size;
  return buffer.length < 12000 || unique < 18;
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

async function loginThroughUi(page) {
  await page.goto(appUrl('/admin/dashboard'), { waitUntil: 'domcontentloaded', timeout: 30000 });
  await page.waitForTimeout(12000);
  await page.goto(appUrl('/login'), { waitUntil: 'domcontentloaded', timeout: 30000 });
  await waitForFlutter(page);

  const inputCount = await page.locator('input').count().catch(() => 0);
  if (inputCount >= 2) {
    await page.locator('input').nth(0).fill(adminEmail, { timeout: 10000 });
    await page.locator('input').nth(1).fill(adminPassword, { timeout: 10000 });
    const buttonCount = await page.locator('button').count().catch(() => 0);
    if (buttonCount > 0) {
      await page.locator('button').nth(0).click({ timeout: 10000 });
    } else {
      await page.mouse.click(195, 367);
    }
  } else {
    await page.mouse.click(150, 204);
    await page.keyboard.type(adminEmail);
    await page.mouse.click(150, 292);
    await page.keyboard.type(adminPassword);
    await page.mouse.click(195, 367);
  }

  await page.waitForTimeout(25000);
  if (page.url().includes('/login')) {
    const failedShot = path.join(stateDir, 'login-failed.png');
    await page.screenshot({ path: failedShot, fullPage: false }).catch(() => {});
    const signals = await readPageSignals(page).catch(() => ({}));
    throw new Error(`UI login did not leave the login route. Screenshot: ${failedShot}. Signals: ${JSON.stringify(signals)}`);
  }
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

const backendSession = await backendLogin();
if (!backendSession.accessToken) {
  throw new Error('Backend login succeeded but no access token was returned.');
}

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

const results = [];

try {
  await loginThroughUi(page);

  for (const route of routes) {
    const routeConsoleStart = consoleMessages.length;
    const url = appUrl(route.path);
    const screenshotPath = path.join(stateDir, `${route.key}.png`);
    let status = 'pass';
    let error = '';
    let signals = {};
    let screenshotBytes = 0;
    let blank = false;

    try {
      await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 30000 });
      await waitForFlutter(page);
      signals = await readPageSignals(page);
      const shot = await page.screenshot({ path: screenshotPath, fullPage: false });
      screenshotBytes = shot.length;
      blank = isBlankScreenshot(shot);
      const currentUrl = page.url();
      const redirectedToLogin = currentUrl.includes('/login');
      const routeConsole = consoleMessages.slice(routeConsoleStart);
      const hasRuntimeError = routeConsole.some((item) =>
        /RenderFlex overflow|Unexpected null value|Assertion failed|There is nothing to pop|TypeError|ReferenceError/i.test(
          item.text,
        ),
      );

      if (redirectedToLogin) {
        status = 'fail';
        error = 'Route redirected to login after token seed.';
      } else if (signals.loaderVisible || (!signals.glassPane && signals.canvasCount === 0)) {
        status = 'fail';
        error = 'Flutter UI did not mount for this route.';
      } else if (blank) {
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
        ...route,
        url,
        finalUrl: currentUrl,
        status,
        error,
        signals,
        screenshot: screenshotPath,
        screenshotBytes,
        console: routeConsole,
      });
    } catch (routeError) {
      status = 'fail';
      error = routeError.message;
      try {
        const shot = await page.screenshot({ path: screenshotPath, fullPage: false });
        screenshotBytes = shot.length;
      } catch {
        // ignore screenshot failure after route failure
      }
      results.push({
        ...route,
        url,
        finalUrl: page.url(),
        status,
        error,
        signals,
        screenshot: screenshotPath,
        screenshotBytes,
        console: consoleMessages.slice(routeConsoleStart),
      });
    }
  }
} finally {
  await browser.close();
}

const summary = {
  generatedAt: new Date().toISOString(),
  baseUrl,
  backendUrl,
  device: { key: deviceKey, ...testDevice },
  totalRoutes: routes.length,
  pass: results.filter((item) => item.status === 'pass').length,
  warning: results.filter((item) => item.status === 'warning').length,
  fail: results.filter((item) => item.status === 'fail').length,
  results,
};

await fs.writeFile(reportPath, JSON.stringify(summary, null, 2), 'utf8');

const lines = [
  '# Admin Mobile Browser Smoke Test',
  '',
  `- Generated: ${summary.generatedAt}`,
  `- Base URL: ${summary.baseUrl}`,
  `- Backend URL: ${summary.backendUrl}`,
  `- Device: ${summary.device.label || deviceKey} (${summary.device.viewport.width}x${summary.device.viewport.height})`,
  `- Routes: ${summary.totalRoutes}`,
  `- Pass: ${summary.pass}`,
  `- Warning: ${summary.warning}`,
  `- Fail: ${summary.fail}`,
  '',
];

for (const result of results) {
  lines.push(`## ${result.key}`);
  lines.push('');
  lines.push(`- Path: \`${result.path}\``);
  lines.push(`- Status: ${result.status}`);
  if (result.error) lines.push(`- Issue: ${result.error}`);
  lines.push(`- Final URL: ${result.finalUrl}`);
  lines.push(`- Screenshot: \`${result.screenshot}\``);
  lines.push(
    `- Signals: glassPane=${result.signals.glassPane}, canvas=${result.signals.canvasCount}, loader=${result.signals.loaderVisible}, mojibake=${result.signals.mojibakeCount || 0}`,
  );
  if (result.console.length > 0) {
    lines.push(`- Console warnings/errors: ${result.console.length}`);
  }
  lines.push('');
}

await fs.writeFile(mdReportPath, lines.join('\n'), 'utf8');

console.log(`Browser smoke report: ${mdReportPath}`);
console.log(`Status: ${summary.fail > 0 ? 'needs-fix' : summary.warning > 0 ? 'warning' : 'pass'}`);
if (summary.fail > 0) {
  process.exit(1);
}
