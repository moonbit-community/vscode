const fs = require('fs');
const path = require('path');

const smokeRoot = __dirname;
const repoRoot = path.resolve(smokeRoot, '..', '..', '..');
const source = path.join(
  repoRoot,
  '_build',
  'js',
  'release',
  'build',
  'vscode_mbt_smoke_extension',
  'vscode_mbt_smoke_extension.js'
);
const outputDir = path.join(smokeRoot, 'dist');
const target = path.join(outputDir, 'extension.js');

fs.mkdirSync(outputDir, { recursive: true });
fs.copyFileSync(source, target);
