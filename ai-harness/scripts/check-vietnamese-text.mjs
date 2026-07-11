import fs from 'node:fs/promises';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '..', '..');
const scanRoots = [
  path.join(root, 'mobile', 'lib', 'view'),
  path.join(root, 'mobile', 'lib', 'presenter'),
  path.join(root, 'mobile', 'test'),
];
const scanFiles = [path.join(root, 'mobile', 'init.ps1')];
const reportPath = path.join(root, 'ai-harness', 'state', 'vietnamese-text-check-latest.json');
const mdReportPath = path.join(root, 'ai-harness', 'state', 'vietnamese-text-check-latest.md');

const mojibakePatterns = [
  { code: 'UTF8_AS_LATIN1_A', pattern: /\u00C3[\u0080-\u00BF\u00A0-\u00FF]/u },
  { code: 'UTF8_AS_LATIN1_B', pattern: /\u00C2[\u0080-\u00BF\u00A0-\u00FF]/u },
  {
    code: 'VIETNAMESE_BYTES_VISIBLE',
    pattern: /(?:\u00E1\u00BA|\u00E1\u00BB|\u00C4\u2018|\u00C4\u0091|\u00C6\u00B0|\u00C6\u00A1|\u00C5\u00A9)/u,
  },
  { code: 'REPLACEMENT_CHARACTER', pattern: /\uFFFD/u },
];

async function* walk(dir) {
  let entries = [];
  try {
    entries = await fs.readdir(dir, { withFileTypes: true });
  } catch {
    return;
  }
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      yield* walk(fullPath);
    } else if (entry.isFile() && /\.(dart|md|json|mjs|ps1)$/i.test(entry.name)) {
      yield fullPath;
    }
  }
}

function findLine(content, index) {
  return content.slice(0, index).split(/\r?\n/u).length;
}

function scanContent(filePath, content) {
  const findings = [];
  for (const { code, pattern } of mojibakePatterns) {
    const globalPattern = new RegExp(pattern.source, `${pattern.flags.replace('g', '')}g`);
    for (const match of content.matchAll(globalPattern)) {
      findings.push({
        code,
        file: path.relative(root, filePath).replaceAll(path.sep, '/'),
        line: findLine(content, match.index ?? 0),
        sample: content
          .slice(Math.max(0, (match.index ?? 0) - 40), (match.index ?? 0) + 80)
          .replace(/\s+/gu, ' ')
          .trim(),
      });
    }
  }
  return findings;
}

const findings = [];
for (const scanRoot of scanRoots) {
  for await (const filePath of walk(scanRoot)) {
    const content = await fs.readFile(filePath, 'utf8');
    findings.push(...scanContent(filePath, content));
  }
}
for (const filePath of scanFiles) {
  const content = await fs.readFile(filePath, 'utf8');
  findings.push(...scanContent(filePath, content));
}

await fs.mkdir(path.dirname(reportPath), { recursive: true });
const summary = {
  generatedAt: new Date().toISOString(),
  scanRoots: [
    ...scanRoots.map((item) => path.relative(root, item).replaceAll(path.sep, '/')),
    ...scanFiles.map((item) => path.relative(root, item).replaceAll(path.sep, '/')),
  ],
  totalFindings: findings.length,
  findings,
};

await fs.writeFile(reportPath, `${JSON.stringify(summary, null, 2)}\n`, 'utf8');
await fs.writeFile(
  mdReportPath,
  [
    '# Vietnamese Text Encoding Check',
    '',
    `- Generated: ${summary.generatedAt}`,
    `- Findings: ${summary.totalFindings}`,
    '',
    '| Code | File | Line | Sample |',
    '|---|---|---:|---|',
    ...findings.map((item) =>
      `| ${item.code} | ${item.file} | ${item.line} | ${item.sample.replaceAll('|', '\\|')} |`,
    ),
    '',
  ].join('\n'),
  'utf8',
);

if (findings.length > 0) {
  console.error(`Vietnamese text encoding check failed: ${findings.length} finding(s).`);
  console.error(`Report: ${mdReportPath}`);
  process.exit(1);
}

console.log(`Vietnamese text encoding check passed. Report: ${mdReportPath}`);
