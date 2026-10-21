#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
upstream_dir="$(mktemp -d)"
source_dir="${UPSTREAM_SOURCE_DIR:-}"

cleanup() {
  rm -rf "${upstream_dir}"
}
trap cleanup EXIT

# Upstream publishes no releases or tags, so build the current main head.
if [[ -z "${source_dir}" ]]; then
  upstream_sha="$(git ls-remote https://github.com/joeseesun/lexfridman-cn.git refs/heads/main | awk '{print $1}')"
  test -n "${upstream_sha}"
  source_dir="${upstream_dir}/source"
  mkdir -p "${source_dir}"
  curl --fail --location --retry 3 --retry-all-errors     "https://codeload.github.com/joeseesun/lexfridman-cn/tar.gz/${upstream_sha}"     | tar -xz --strip-components=1 -C "${source_dir}"
else
  source_dir="$(cd "${source_dir}" && pwd)"
fi

# The site builder generates the 506 episode pages under site/ep/ plus data
# files; the repo as checked out is not fully self-contained without it.
cd "${source_dir}"
python3 tools/build.py

rm -rf "${project_root}/dist"
cp -a site "${project_root}/dist"
