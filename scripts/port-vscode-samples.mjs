#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const repoRoot = process.cwd();
const sourceRoot = path.join(
  repoRoot,
  '.codex/skills/moonbit-vscode-samples/references/vscode-extension-samples',
);
const targetRoot = path.join(repoRoot, 'test/samples');

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function writeJson(filePath, value) {
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`, 'utf8');
}

function normalizePath(value) {
  return value.replaceAll('\\', '/').replace(/^\.\//, '');
}

function slugify(name) {
  let slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
  if (slug.length === 0) slug = 'sample';
  if (/^[0-9]/.test(slug)) slug = `sample-${slug}`;
  return slug;
}

function normalizeCommands(rawCommands, slug) {
  const commands = [];
  if (Array.isArray(rawCommands)) {
    for (const command of rawCommands) {
      if (!command || typeof command !== 'object') continue;
      const id = typeof command.command === 'string' ? command.command : '';
      if (!id) continue;
      const title =
        typeof command.title === 'string' && command.title.trim().length > 0
          ? command.title
          : `MoonBit Port Command: ${id}`;
      commands.push({ id, title });
    }
  }

  if (commands.length === 0) {
    const fallbackId = `moonbit.sample.${slug}.run`;
    commands.push({ id: fallbackId, title: `MoonBit Sample ${slug}` });
  }

  return commands;
}

function normalizeActivationEvents(rawEvents, commands) {
  const events = [];
  const seen = new Set();

  if (Array.isArray(rawEvents)) {
    for (const event of rawEvents) {
      if (typeof event !== 'string') continue;
      const trimmed = event.trim();
      if (!trimmed || seen.has(trimmed)) continue;
      seen.add(trimmed);
      events.push(trimmed);
    }
  }

  for (const command of commands) {
    const onCommand = `onCommand:${command.id}`;
    if (seen.has(onCommand)) continue;
    seen.add(onCommand);
    events.push(onCommand);
  }

  return events;
}

function entryCandidatesFromMain(pkgMain) {
  if (typeof pkgMain !== 'string' || pkgMain.trim().length === 0) {
    return [];
  }

  const main = normalizePath(pkgMain.trim());
  const baseNoExt = main.replace(/\.js$/, '');
  const candidates = [main, `${baseNoExt}.js`, `${baseNoExt}.ts`];

  const rewrites = [
    ['/out/', '/src/'],
    ['/dist/', '/src/'],
    ['/build/', '/src/'],
  ];

  for (const [from, to] of rewrites) {
    if (baseNoExt.includes(from)) {
      const rewritten = baseNoExt.replace(from, to);
      candidates.push(`${rewritten}.ts`, `${rewritten}.js`);
    }
  }

  return candidates;
}

function resolveEntrypoint(sourceDir, sourcePkg) {
  const candidates = [
    ...entryCandidatesFromMain(sourcePkg.main),
    'src/extension.ts',
    'src/extension.js',
    'client/src/extension.ts',
    'client/src/extension.js',
    'src/web/extension.ts',
    'src/web/extension.js',
    'extension.ts',
    'extension.js',
  ];

  const seen = new Set();
  for (const candidate of candidates) {
    if (!candidate) continue;
    const normalized = normalizePath(candidate);
    if (seen.has(normalized)) continue;
    seen.add(normalized);

    const absolute = path.join(sourceDir, normalized);
    if (fs.existsSync(absolute) && fs.statSync(absolute).isFile()) {
      return absolute;
    }
  }

  return null;
}

function buildWithEsbuild(entrypoint, outfile) {
  const commonArgs = [
    '--yes',
    'esbuild',
    entrypoint,
    '--bundle',
    '--platform=node',
    '--format=cjs',
    '--target=node18',
    '--external:vscode',
    `--outfile=${outfile}`,
    '--log-level=warning',
  ];

  try {
    execFileSync('npx', commonArgs, {
      cwd: repoRoot,
      stdio: 'pipe',
      encoding: 'utf8',
      maxBuffer: 16 * 1024 * 1024,
    });
    return { ok: true, mode: 'bundle' };
  } catch (error) {
    try {
      execFileSync(
        'npx',
        [...commonArgs, '--packages=external'],
        {
          cwd: repoRoot,
          stdio: 'pipe',
          encoding: 'utf8',
          maxBuffer: 16 * 1024 * 1024,
        },
      );
      return { ok: true, mode: 'bundle-packages-external' };
    } catch (retryError) {
      const stderr = retryError && typeof retryError.stderr === 'string' ? retryError.stderr : '';
      const stdout = retryError && typeof retryError.stdout === 'string' ? retryError.stdout : '';
      const details = `${stderr}${stdout}`.trim();
      return { ok: false, mode: 'failed', error: details.slice(0, 4000) };
    }
  }
}

function buildExtensionMbt(sampleName, sourceRel, hasUpstreamBundle) {
  const lines = [];
  lines.push('///|');
  lines.push('/// MoonBit entrypoint for upstream sample `' + sampleName + '`.');
  lines.push('/// Source: `' + sourceRel + '`');
  lines.push('');

  if (hasUpstreamBundle) {
    lines.push('extern "js" fn upstream_activate(ctx : @core.ExtensionContext) -> Unit =');
    lines.push('  #| (ctx) => {');
    lines.push('  #|   try {');
    lines.push('  #|     const mod = require("./upstream/extension.js")');
    lines.push('  #|     if (typeof mod.activate === "function") {');
    lines.push('  #|       const out = mod.activate(ctx)');
    lines.push('  #|       if (out && typeof out.then === "function") {');
    lines.push('  #|         out.catch((err) => console.error(err))');
    lines.push('  #|       }');
    lines.push('  #|     }');
    lines.push('  #|   } catch (err) {');
    lines.push('  #|     console.error(err)');
    lines.push('  #|   }');
    lines.push('  #| }');
    lines.push('');
    lines.push('extern "js" fn upstream_deactivate() -> Unit =');
    lines.push('  #| () => {');
    lines.push('  #|   try {');
    lines.push('  #|     const mod = require("./upstream/extension.js")');
    lines.push('  #|     if (typeof mod.deactivate === "function") {');
    lines.push('  #|       const out = mod.deactivate()');
    lines.push('  #|       if (out && typeof out.then === "function") {');
    lines.push('  #|         out.catch((err) => console.error(err))');
    lines.push('  #|       }');
    lines.push('  #|     }');
    lines.push('  #|   } catch (err) {');
    lines.push('  #|     console.error(err)');
    lines.push('  #|   }');
    lines.push('  #| }');
    lines.push('');
    lines.push('pub fn activate(ctx : @core.ExtensionContext) -> Unit {');
    lines.push('  upstream_activate(ctx)');
    lines.push('}');
    lines.push('');
    lines.push('pub fn deactivate() -> Unit {');
    lines.push('  upstream_deactivate()');
    lines.push('}');
  } else {
    lines.push('pub fn activate(_ctx : @core.ExtensionContext) -> Unit {');
    lines.push('  ()');
    lines.push('}');
    lines.push('');
    lines.push('pub fn deactivate() -> Unit {');
    lines.push('  ()');
    lines.push('}');
  }

  lines.push('');
  return `${lines.join('\n')}`;
}

function buildMoonMod(moduleName) {
  return {
    name: moduleName,
    version: '0.0.0',
    deps: {
      'username/vscode': { path: '../../..' },
      'moonbitlang/async': { path: '../../../../async' },
    },
    'preferred-target': 'js',
  };
}

function buildMoonPkg() {
  return {
    import: [{ path: 'username/vscode/core' }],
    link: {
      js: {
        exports: ['activate', 'deactivate'],
        format: 'cjs',
      },
    },
    targets: {
      'extension.mbt': ['js'],
    },
  };
}

function buildPackageJson(sampleName, sourcePkg, jsModuleName, activationEvents, commands) {
  const displayName =
    typeof sourcePkg.displayName === 'string' && sourcePkg.displayName.trim().length > 0
      ? sourcePkg.displayName
      : sampleName;

  const vscodeEngine =
    sourcePkg.engines && typeof sourcePkg.engines.vscode === 'string'
      ? sourcePkg.engines.vscode
      : '^1.86.0';

  const dependencies = sourcePkg.dependencies && typeof sourcePkg.dependencies === 'object'
    ? sourcePkg.dependencies
    : undefined;

  const result = {
    name: `${slugify(sampleName)}-moonbit-port`,
    displayName: `MoonBit Port: ${displayName}`,
    publisher: 'moonbit',
    version: '0.0.1',
    engines: { vscode: vscodeEngine },
    main: `./_build/js/release/build/${jsModuleName}.js`,
    activationEvents,
    contributes: {
      commands: commands.map((command) => ({
        command: command.id,
        title: command.title,
      })),
    },
    scripts: {
      'build:moonbit': 'moon build --target js',
    },
    repository: {
      type: 'git',
      url: 'https://www.github.com/bzy-debug/vscode.mbt',
    },
  };

  if (dependencies && Object.keys(dependencies).length > 0) {
    result.dependencies = dependencies;
  }

  return result;
}

ensureDir(targetRoot);

const sampleDirs = fs
  .readdirSync(sourceRoot, { withFileTypes: true })
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name)
  .filter((name) => !name.startsWith('.') && name !== 'node_modules')
  .sort();

const generated = [];

for (const sampleName of sampleDirs) {
  const sourceDir = path.join(sourceRoot, sampleName);
  const sourcePkgPath = path.join(sourceDir, 'package.json');
  if (!fs.existsSync(sourcePkgPath)) {
    continue;
  }

  const sourcePkg = JSON.parse(fs.readFileSync(sourcePkgPath, 'utf8'));
  const slug = slugify(sampleName);
  const moduleName = `moonbit/vscode-sample-${slug}`;
  const jsModuleName = moduleName.split('/')[1];
  const commands = normalizeCommands(sourcePkg.contributes?.commands, slug);
  const activationEvents = normalizeActivationEvents(sourcePkg.activationEvents, commands);

  const destinationDir = path.join(targetRoot, sampleName);
  ensureDir(destinationDir);

  const entrypoint = resolveEntrypoint(sourceDir, sourcePkg);
  let buildInfo = { ok: false, mode: 'missing-entrypoint', error: '' };

  if (entrypoint) {
    const upstreamDir = path.join(destinationDir, 'upstream');
    ensureDir(upstreamDir);
    const outfile = path.join(upstreamDir, 'extension.js');
    buildInfo = buildWithEsbuild(entrypoint, outfile);
    if (!buildInfo.ok && fs.existsSync(outfile)) {
      fs.rmSync(outfile, { force: true });
    }
  }

  const sourceRel = normalizePath(path.relative(repoRoot, sourceDir));
  fs.writeFileSync(
    path.join(destinationDir, 'extension.mbt'),
    buildExtensionMbt(sampleName, sourceRel, buildInfo.ok),
    'utf8',
  );

  writeJson(path.join(destinationDir, 'moon.mod.json'), buildMoonMod(moduleName));
  writeJson(path.join(destinationDir, 'moon.pkg.json'), buildMoonPkg());
  writeJson(
    path.join(destinationDir, 'package.json'),
    buildPackageJson(sampleName, sourcePkg, jsModuleName, activationEvents, commands),
  );
  writeJson(path.join(destinationDir, 'settings.json'), {});

  generated.push({
    sampleName,
    commands: commands.length,
    activationEvents: activationEvents.length,
    entrypoint: entrypoint ? normalizePath(path.relative(sourceDir, entrypoint)) : '-',
    buildMode: buildInfo.mode,
    bundled: buildInfo.ok ? 'yes' : 'no',
  });
}

const summaryLines = [
  '# MoonBit Sample Ports',
  '',
  'Generated from upstream `vscode-extension-samples`.',
  '',
  '| Sample | Commands | Activation Events | Entrypoint | Bundled Upstream | Build Mode |',
  '| --- | ---: | ---: | --- | --- | --- |',
  ...generated.map(
    (item) =>
      '| `' +
      item.sampleName +
      '` | ' +
      item.commands +
      ' | ' +
      item.activationEvents +
      ' | `' +
      item.entrypoint +
      '` | ' +
      item.bundled +
      ' | `' +
      item.buildMode +
      '` |',
  ),
  '',
  `Total generated sample ports: ${generated.length}`,
  '',
];

fs.writeFileSync(path.join(targetRoot, 'PORT_SUMMARY.md'), summaryLines.join('\n'), 'utf8');

const bundledCount = generated.filter((item) => item.bundled === 'yes').length;
console.log(`Generated ${generated.length} sample ports in test/samples.`);
console.log(`Bundled upstream behavior for ${bundledCount} samples.`);
