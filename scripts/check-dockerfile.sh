#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# OPTIONAL — Cerebe Factory docker-build evidence shim.
# Source contract: CONSUMER-ADOPTION.md §5.5.
#
# WHY THIS EXISTS: the Cerebe Factory critics run in a sandbox with NO Docker
# socket, so they cannot run `docker build` to validate a Dockerfile-touching
# commit. Without evidence, the critic emits a `requiresHumanJudgment: true`
# finding on every such commit. This shim runs `docker build` on a host that DOES
# have Docker (your laptop, pre-push) and writes a SHA-bound evidence file the
# critic reads, so Dockerfile changes get clean signal.
#
# THIS IS A SKELETON. It is NOT wired into any pre-push hook yet — wire it only
# once you start changing the deploy/docker/*.Dockerfile files and want clean
# critic signal. Until then, Dockerfile commits simply surface a human-judgment
# finding (harmless for a deploy-only folder you review manually).
#
# To activate later: call this from a pre-push hook you own BEFORE
# `cerebe gate-push`, only when the push touches a Dockerfile. Don't edit the
# pre-push hook `cerebe init` writes — `cerebe init` regenerates it.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# The cerebe CLI reads the evidence from its artifact dir, cerebe/reviews/ at
# the repo root (git-ignored by cerebe/.gitignore).
REPO_ROOT="$(git rev-parse --show-toplevel)"
EVIDENCE="${REPO_ROOT}/cerebe/reviews/_dockerbuild-evidence.json"
SHA="$(git rev-parse HEAD)"

# TODO(impl): for each Dockerfile under deploy/docker/, run `docker build` and
# capture exitCode, then write ONE record per Dockerfile into ${EVIDENCE} in the
# canonical shape (CONSUMER-ADOPTION.md §5.5) — one object, or an array of them:
#   [{"schemaVersion":"1.0","reviewedSha":"<SHA>",
#     "dockerfile":"deploy/docker/backend.Dockerfile","context":".",
#     "exitCode":0,"timestamp":"<ISO-8601>"}]
# Optional per record: imageSha, imageSize, buildLogPath. The reader drops a
# record that is missing a required field.
#
# CRITICAL (security): stamp the SHA you ACTUALLY built against. A stale/forged
# record from an earlier push is dropped by the reader (SHA-binding gate). Do not
# reuse a previous run's record.

echo "check-dockerfile.sh: SKELETON — not implemented. SHA=${SHA}" >&2
echo "Would write evidence to ${EVIDENCE} after running docker build." >&2
exit 0
