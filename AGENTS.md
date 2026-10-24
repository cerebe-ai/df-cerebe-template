# AGENTS.md

DF Cerebe is an internal dashboard with streaming AI chat. `backend/` is a
Bun + Hono + LangGraph.js agent that calls Cerebe, `frontend/` a Vite + Svelte
SPA, and `shared/` the TypeScript types both import. Quickstart and layout:
[`README.md`](README.md).

## Commands

Bun is the runtime, package manager and script runner: use `bun` and `bunx`,
not `npm`, `npx` or `node`. Scripts live in the root
[`package.json`](package.json) (dev loop, deploy) and in each workspace's
`package.json`, each with a `type-check` script. In a fresh clone, run
`cerebe init` once: it installs the git hooks that run the critic gate on every
commit and push.

## Where things live

| Need | Read |
|---|---|
| Coding standards (before writing code) | [`docs/engineering/coding-standards.md`](docs/engineering/coding-standards.md) |
| Product requirements (PRDs) | [`docs/prds/`](docs/prds/README.md) |
| Architecture decisions (ADRs) | [`docs/ADR/`](docs/ADR/README.md) |
| Setup walkthrough, opt-in hosted PR gate | [`docs/getting-started.md`](docs/getting-started.md) |
| Open decisions, verification log | [`docs/notes.md`](docs/notes.md) |
| Critic gate configuration | [`cerebe/config.json`](cerebe/config.json), [`cerebe.yaml`](cerebe.yaml) (explained in getting-started Step 6) |
| Deployment (Docker, Kubernetes) | [`deploy/README.md`](deploy/README.md) |
| Area rules (nested `AGENTS.md`), skills (`.claude/skills/`) | None yet |

## Rules

- **Dev never needs Docker or Kubernetes.** `bun install` then `bun run dev`
  is the whole loop. Container and cluster files stay in `deploy/`, out of the
  dev scripts and the dev path. No check enforces this; review holds it.
- **The gate stays intact.** Don't disable, bypass or weaken the git hooks
  `cerebe init` installs, `cerebe/config.json` or `cerebe.yaml` to get a commit
  through. Fix the critic's findings (`cerebe status`, `cerebe show`) in a new
  commit; never amend. Bypass a push only in a genuine emergency, with
  `CEREBE_BYPASS="<reason>"`, which is audited. The pre-push hook
  (`cerebe gate-push`) enforces the gate; review holds the rest.
- **Lockfile.** A project created from this template commits `bun.lock` after
  its first `bun install`. The template repository itself stays uninstalled
  and commits no lockfile ([`docs/notes.md` §1](docs/notes.md#1-dependency-versions-are-placeholders-verify-before-first-install)).
  Review holds this.

<!-- cerebe:pack-digest:v1 sha256=4cc3f38a5b2ce6608ec15a4caa7a5d584768fedfdbe72adb00953b244f548093 -->
# Working with Cerebe's review

Cerebe reviews your changes and reports findings. Each finding names a file, the evidence, the impact and the fix it requires.

- Locally, when review is on: `cerebe status` shows the verdict and findings for your latest commit, and `cerebe show` prints the full review. The pre-push hook runs `cerebe gate-push`, which blocks a push while a blocking finding is unresolved.
- On a pull request: findings are annotations on the `cerebe/critic` check. `cerebe review-status --pr <number>` prints the result as data.
- Fix each finding whose evidence holds. When the evidence does not hold, say why in the pull request, citing the code.
- Commit and push again; the new commit is reviewed.

---

# When review rounds stop converging

A round is one review and the fixes that answer it.

- Budget three rounds by default; use the repository's number if its guidance sets one.
- After each round, compare the new findings with the last. You are converging when there are fewer and no new kinds. A lower severity, or the same finding moved to another file, is not progress.
- When new kinds of finding keep appearing in the same part of the change, stop fixing them one by one. Restructure that part: simplify it, remove it, or split it into its own change.
- Ask the person you work for only when a mergeable change needs a decision that is theirs.

---

# When a gate fails because of the base branch

Before you fix a failing gate, find out whose failure it is.

- Run `cerebe verify --triage-base <base-ref> --route <id>`, or `cerebe verify --triage-base <base-ref> --gate "<command>"` for a gate that is not a route. It runs the gate in your tree and at the base, and prints one verdict.
- `in-diff` or `inconclusive`: treat it as yours and fix it.
- `pre-existing`: leave it out of this change unless the fix is a few adjacent lines. File an issue naming the gate and cite it in your pull request.
- If the push gate blocks only on that failure, push with the reason: `CEREBE_BYPASS="<gate> fails at <base-ref>; tracked at #<issue>" git push`. Never bypass a failure your change caused.

---

# Producing the evidence the gate reads

This applies when the repository defines verification routes: commands that must pass when a change touches certain paths.

- Before you push, run `cerebe verify`. It runs the routes your commit triggers and records the result for that exact commit. `cerebe verify --route <id>` runs one route.
- `cerebe gate-push` blocks a push when a triggered route has no passing evidence. Evidence is bound to the diff, so run `cerebe verify` again after you change the commit.
- A failing route is a real failure: fix the cause. Never write or edit evidence by hand.
- `cerebe gates` runs the quality gates and the triggered routes with no model call.
<!-- /cerebe:pack-digest:v1 -->
