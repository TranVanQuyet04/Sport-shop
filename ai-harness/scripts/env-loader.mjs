import fs from 'node:fs';
import path from 'node:path';

export function loadHarnessEnv() {
  const root = path.resolve(import.meta.dirname, '..', '..');
  const envPath = path.join(root, '.env');
  if (!fs.existsSync(envPath)) {
    return;
  }

  const content = fs.readFileSync(envPath, 'utf8');
  for (const rawLine of content.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) {
      continue;
    }

    const separatorIndex = line.indexOf('=');
    if (separatorIndex <= 0) {
      continue;
    }

    const key = line.slice(0, separatorIndex).trim();
    let value = line.slice(separatorIndex + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }

    if (!(key in process.env)) {
      process.env[key] = value;
    }
  }
}

export function envValue(name, fallbackValue = '') {
  const value = process.env[name];
  return value === undefined || value === '' ? fallbackValue : value;
}

export function requiredEnvValue(name) {
  const value = process.env[name];
  if (value === undefined || value === '') {
    throw new Error(`Missing required environment variable ${name}. Add it to .env.`);
  }
  return value;
}
