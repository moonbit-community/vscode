import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '../../../..');
const typesRoot = path.join(repoRoot, 'node_modules', '@types', 'vscode');
const source = path.join(typesRoot, 'index.d.ts');
const destDir = path.join(
  repoRoot,
  '.codex',
  'skills',
  'moonbit-vscode-api-binding-style',
  'references',
);
const dest = path.join(destDir, 'vscode.d.ts');

if (!fs.existsSync(source)) {
  console.error('Missing @types/vscode. Run: npm install');
  process.exit(1);
}

fs.mkdirSync(destDir, { recursive: true });
fs.copyFileSync(source, dest);

let version = 'unknown';
const pkgJson = path.join(typesRoot, 'package.json');
if (fs.existsSync(pkgJson)) {
  try {
    const parsed = JSON.parse(fs.readFileSync(pkgJson, 'utf8'));
    if (parsed && typeof parsed.version === 'string') {
      version = parsed.version;
    }
  } catch {
    // Ignore JSON parse errors; keep version as unknown.
  }
}

console.log(`Copied @types/vscode@${version} to ${path.relative(repoRoot, dest)}`);
