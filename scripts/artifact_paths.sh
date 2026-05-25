#!/usr/bin/env bash
# Shared artifact path resolver for local automation and CI jobs.

resolve_mallcore_artifact_root() {
	local repo_root="${1:-}"
	if [ -z "$repo_root" ]; then
		repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
	fi

	local artifact_root="${MALLCORE_ARTIFACT_DIR:-}"
	if [ -z "$artifact_root" ]; then
		if [ -n "${GITHUB_WORKSPACE:-}" ]; then
			artifact_root="$GITHUB_WORKSPACE/artifacts"
		else
			artifact_root="$repo_root/artifacts"
		fi
	fi

	mkdir -p "$artifact_root"
	printf '%s\n' "$artifact_root"
}

mallcore_artifact_path() {
	local artifact_root="$1"
	local relative_path="${2#/}"
	printf '%s/%s\n' "${artifact_root%/}" "$relative_path"
}
