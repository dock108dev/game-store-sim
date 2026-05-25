#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

python3 - "$ROOT" <<'PY'
import json
import sys
from pathlib import Path

ROOT = Path(sys.argv[1])
CONFIGS = [
	".gutconfig.json",
	".gutconfig.pr-smoke.json",
]
CONTRACTS = [
	"tests/automation/README.md",
	"tests/flows/README.md",
	"tests/visual/README.md",
	"tests/baselines/README.md",
]


def res_path_to_file(path: str) -> Path:
	if not path.startswith("res://"):
		raise ValueError(f"{path} must use a res:// path")
	return ROOT / path.removeprefix("res://")


def files_for_dir(path: str, prefix: str, suffix: str, include_subdirs: bool) -> list[str]:
	base = res_path_to_file(path)
	if not base.is_dir():
		raise FileNotFoundError(f"{path} does not exist")
	pattern = "**/*" if include_subdirs else "*"
	files = []
	for candidate in base.glob(pattern):
		if candidate.is_file() and candidate.name.startswith(prefix) and candidate.name.endswith(suffix):
			files.append("res://" + str(candidate.relative_to(ROOT)))
	return sorted(files)


def check_config(config_name: str) -> list[str]:
	config_path = ROOT / config_name
	if not config_path.is_file():
		raise FileNotFoundError(config_name)
	config = json.loads(config_path.read_text())
	prefix = config.get("prefix", "test_")
	suffix = config.get("suffix", ".gd")
	include_subdirs = bool(config.get("include_subdirs", False))
	seen = {}
	errors = []
	for directory in config.get("dirs", []):
		for script in files_for_dir(directory, prefix, suffix, include_subdirs):
			seen.setdefault(script, []).append(directory)
	for script in config.get("tests", []):
		script_path = res_path_to_file(script)
		if not script_path.is_file():
			errors.append(f"{config_name}: missing explicit test {script}")
		seen.setdefault(script, []).append("tests")
	for script, sources in sorted(seen.items()):
		if len(sources) > 1:
			errors.append(f"{config_name}: duplicate discovery for {script}: {', '.join(sources)}")
	if config_name == ".gutconfig.pr-smoke.json" and not config.get("tests"):
		errors.append(f"{config_name}: PR smoke config must use explicit high-signal tests")
	return errors


failures = []
for contract in CONTRACTS:
	if not (ROOT / contract).is_file():
		failures.append(f"missing ownership contract: {contract}")
for config_name in CONFIGS:
	failures.extend(check_config(config_name))

if failures:
	for failure in failures:
		print(f"FAIL: {failure}", file=sys.stderr)
	sys.exit(1)

print("GUT config discovery OK")
PY
