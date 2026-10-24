# AGENTS.md — context for AI agents working in this repo

This file orients any AI coding agent (Claude Code, Cursor, Codex, etc.) working
in this repo. Humans: see [`README.md`](README.md) and
[`docs/getting-started.md`](docs/getting-started.md).

## What this is

This is an **internal dashboard** template built as a deliberately lean scaffold:

- **Backend:** Bun + Hono + LangGraph.js (TypeScript agent runtime) — `backend/`
- **Frontend:** Vite + Svelte SPA (TypeScript) — `frontend/`
- **Shared types:** `shared/` — imported by both ends; the point of TS-on-both-sides
- **Gate:** Cerebe Factory — `cerebe/` + `cerebe.yaml`; `cerebe init` wires the git hooks
- **Deploy:** Docker + Kubernetes — `deploy/`, **opt-in, never used in dev**

## Non-negotiable principles

1. **Native dev must never require Docker or Kubernetes.** The dev loop is
   `bun install` → `bun run dev`. Anything container/k8s belongs in `deploy/` and
   must not leak into the dev path or root dev scripts. If a change would make
   `bun run dev` depend on Docker, it's wrong.
2. **One language, shared types.** Cross-cutting shapes (API requests, stream
   events) live in `shared/` and are imported by both `backend/` and `frontend/`.
   Don't duplicate a type across the two sides.
3. **The Cerebe Factory gate is load-bearing.** Don't disable, bypass, or weaken
   the git hooks `cerebe init` installs, `cerebe/config.json` or `cerebe.yaml` to
   get a commit through. Address findings in a **new commit** (never amend —
   artifacts are bound to the original SHA). Bypass only with
   `CEREBE_BYPASS="reason"` for genuine emergencies, which is audited.

## Current status: WORKING TEMPLATE

- The backend agent (`backend/src/agent/graph.ts`, `index.ts`) and the streaming
  chat frontend (`frontend/src/App.svelte`) are **implemented and verified** —
  `bun install`, dev loop, type-checks, frontend build, and a live LangGraph→Cerebe
  call were all exercised. Versions are **pinned to verified-compatible exacts**.
- **Auth is implemented** (Clerk, graceful-optional): `requireAuth` +
  `frontend/src/lib/auth.ts` — official `@clerk/backend` + `@clerk/clerk-js`, off
  until keys are set (notes §5). Dependencies are declared but the template itself
  stays **uninstalled** (no `node_modules`/lockfile committed).
- **Code and examples must be accurate.** When extending the agent or wiring
  auth, verify the real API against the installed version. Open decisions live in
  [`docs/notes.md`](docs/notes.md).

## Conventions

- **Bun** is the runtime, package manager, and script runner. Prefer `bun` over
  `npm`/`node` in commands and docs.
- **Commit the Bun lockfile** — installs stay reproducible, and the Docker
  builds run `bun install --frozen-lockfile`.
- **Secrets:** local dev reads `.env` (gitignored); prod uses Doppler. Only
  `.env.example` is committed. Never commit a real secret.
- **LLM work:** the agent's default engine is **Cerebe** (Momentiq's cognitive
  engine) via its OpenAI-compatible endpoint through `@langchain/openai`. When
  touching model ids, SDK calls, streaming, or tool use, consult the current
  Cerebe docs (https://cerebe.ai) rather than memory.

## Where to look

| Need | File |
|---|---|
| Run it / overview | [`README.md`](README.md) |
| Full walkthrough | [`docs/getting-started.md`](docs/getting-started.md) |
| Open decisions / verify list | [`docs/notes.md`](docs/notes.md) |
| Gate config (explained in getting-started Step 6) | [`cerebe/config.json`](cerebe/config.json), [`cerebe.yaml`](cerebe.yaml) |
| Deploy path | [`deploy/README.md`](deploy/README.md) |

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
