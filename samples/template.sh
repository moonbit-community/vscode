#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: bash samples/template.sh <sample-name>

Examples:
  bash samples/template.sh vim
  bash samples/template.sh vim-sample
EOF
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd -- "$script_dir/.." && pwd)
template_dir="$repo_root/samples/helloworld-minimal-sample"

if [[ ! -d "$template_dir" ]]; then
  echo "Template directory not found: $template_dir" >&2
  exit 1
fi

for tool in moon node; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing required tool: $tool" >&2
    exit 1
  fi
done

raw_name="$1"
sample_name=$(printf '%s' "$raw_name" | tr '[:upper:]_' '[:lower:]-')

if [[ "$sample_name" != *-sample ]]; then
  sample_name="${sample_name}-sample"
fi

if ! printf '%s' "$sample_name" | grep -Eq '^[a-z0-9][a-z0-9-]*$'; then
  echo "Invalid sample name: $raw_name" >&2
  echo "Use lowercase letters, numbers, hyphens, or underscores." >&2
  exit 1
fi

module_name=$(printf '%s' "$sample_name" | tr '-' '_')
sample_dir="$repo_root/samples/$sample_name"

if [[ -e "$sample_dir" ]]; then
  echo "Sample already exists: $sample_dir" >&2
  exit 1
fi

cp -R "$template_dir" "$sample_dir"

REPO_ROOT="$repo_root" SAMPLE_DIR="$sample_dir" SAMPLE_NAME="$sample_name" MODULE_NAME="$module_name" node <<'NODE'
const fs = require("fs");
const path = require("path");

const sampleDir = process.env.SAMPLE_DIR;
const sampleName = process.env.SAMPLE_NAME;
const moduleName = process.env.MODULE_NAME;

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, value) {
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function replaceAll(text, from, to) {
  return text.split(from).join(to);
}

const extensionPath = path.join(sampleDir, "extension.mbt");
let extension = fs.readFileSync(extensionPath, "utf8");
extension = replaceAll(extension, "extension.helloWorld", `${sampleName}.helloWorld`);
extension = replaceAll(extension, "Hello World!", `Hello from ${sampleName}!`);
fs.writeFileSync(extensionPath, extension);

const moonModPath = path.join(sampleDir, "moon.mod.json");
const moonMod = readJson(moonModPath);
moonMod.name = moduleName;
writeJson(moonModPath, moonMod);

const packageJsonPath = path.join(sampleDir, "package.json");
const packageJson = readJson(packageJsonPath);
packageJson.name = sampleName;
packageJson.displayName = sampleName;
packageJson.description = `${sampleName} example for VS Code`;
packageJson.main = `../../_build/js/release/build/${moduleName}/${moduleName}.js`;
packageJson.contributes = packageJson.contributes || {};
packageJson.contributes.commands = [
  {
    command: `${sampleName}.helloWorld`,
    title: "Hello World",
  },
];
writeJson(packageJsonPath, packageJson);
NODE

# Anchor the update to the root workspace; otherwise Moon creates a nested
# moon.work inside the generated sample directory.
moon -C "$sample_dir" work use . --manifest-path "$repo_root/moon.work"

REPO_ROOT="$repo_root" SAMPLE_NAME="$sample_name" MODULE_NAME="$module_name" node <<'NODE'
const fs = require("fs");
const path = require("path");

const repoRoot = process.env.REPO_ROOT;
const sampleName = process.env.SAMPLE_NAME;
const moduleName = process.env.MODULE_NAME;
const workspaceFolder = "${workspaceFolder}";

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

const launchPath = path.join(repoRoot, ".vscode", "launch.json");
const launch = fs.existsSync(launchPath)
  ? readJson(launchPath)
  : { version: "0.2.0", configurations: [] };
launch.configurations = Array.isArray(launch.configurations) ? launch.configurations : [];
const launchConfig = {
  name: `Run ${sampleName}`,
  type: "extensionHost",
  request: "launch",
  runtimeExecutable: "${execPath}",
  args: [
    `--extensionDevelopmentPath=${workspaceFolder}/samples/${sampleName}`,
  ],
  preLaunchTask: `build-${sampleName}`,
  outFiles: [
    `${workspaceFolder}/_build/js/release/build/${moduleName}/*.js`,
  ],
};
const launchIndex = launch.configurations.findIndex((config) =>
  config.name === launchConfig.name ||
  config.preLaunchTask === launchConfig.preLaunchTask
);
if (launchIndex >= 0) {
  launch.configurations[launchIndex] = launchConfig;
} else {
  launch.configurations.push(launchConfig);
}
writeJson(launchPath, launch);

const tasksPath = path.join(repoRoot, ".vscode", "tasks.json");
const tasks = fs.existsSync(tasksPath)
  ? readJson(tasksPath)
  : { version: "2.0.0", tasks: [] };
tasks.tasks = Array.isArray(tasks.tasks) ? tasks.tasks : [];
const taskConfig = {
  label: `build-${sampleName}`,
  type: "shell",
  command: `moon build --target js --release ./samples/${sampleName}`,
  options: {
    cwd: workspaceFolder,
  },
  group: {
    kind: "build",
  },
  problemMatcher: [],
};
const taskIndex = tasks.tasks.findIndex((task) => task.label === taskConfig.label);
if (taskIndex >= 0) {
  tasks.tasks[taskIndex] = taskConfig;
} else {
  tasks.tasks.push(taskConfig);
}
writeJson(tasksPath, tasks);
NODE

echo "Created samples/$sample_name"
echo "Updated moon.work, .vscode/launch.json, and .vscode/tasks.json"
