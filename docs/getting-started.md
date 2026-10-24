# Get started — run DF Cerebe locally in minutes, deploy when you choose

> **Native dev first. Infrastructure last, and only if you want it.**
> TypeScript on both ends, one agent runtime, with the Cerebe Factory gate wired
> from the first commit. No Kubernetes, no Docker, no cluster to bring up before you see
> your dashboard on screen.

This walkthrough takes you from a fresh clone to a running internal dashboard
with the gate wired. The core loop is **a couple of minutes** — most of it is `bun install`.
Deployment (Docker + k8s) is a separate, optional path at the end.

> **Template status:** the backend (Hono + LangGraph.js agent), the streaming
> chat frontend, the shared types, and the Cerebe Factory gate are **implemented
> and verified** — `bun install`, the dev loop, type-checks, the frontend build,
> the agent's call to Cerebe, and `cerebe init` + `cerebe doctor` were all
> exercised end to end. Auth (Clerk) is also **wired and verified** —
> graceful-optional, off until you add Clerk keys.
> What's left for you: add your Cerebe key (Step 3); add Clerk keys if/when you
> want auth (Step 4). Dependencies are **declared (pinned) but not installed** in
> the template itself — your `bun install` brings them in. Open decisions are
> collected in [`notes.md`](notes.md).

## What you'll build

By the end you have:

- A **TypeScript dashboard** — Hono + LangGraph.js backend, Vite + Svelte
  frontend, sharing types through one `shared/` package
- It **running natively** at `http://localhost:5173` — no containers involved
- A **first agent turn** streamed from the backend to the chat surface
- **Auth via Clerk** and **secrets via Doppler** (both optional to start)
- A **first commit through the Cerebe Factory hooks**, reviewed by your local
  critics once you enable one (`cerebe show` prints the per-commit artifact)
- A **fully-working but isolated deploy path** (Docker + Kubernetes) you can
  reach for later — and never have to think about until then

## Drive this with an AI agent (optional)

Paste this into Claude Code, Cursor, or any agentic surface and it will run the
walkthrough interactively — showing each command, confirming before anything
destructive, and surfacing URLs:

```
You are helping me stand up DF Cerebe, an internal dashboard built on:
  Backend  — Bun + Hono + LangGraph.js (TypeScript agent runtime)
  Frontend — Vite + Svelte SPA (TypeScript), Clerk auth
  Shared   — a TypeScript types package imported by both sides
  Gate     — Cerebe Factory (the cerebe CLI; config committed in cerebe/)
  Deploy   — Docker + Kubernetes, isolated in deploy/, OPTIONAL

Native local dev must never require Docker or Kubernetes. Walk me through the
steps in docs/getting-started.md interactively: show the command, ask before
anything destructive, run it, verify the expected outcome, then continue. If
something fails, diagnose and propose a fix.

1. Verify prereqs: bun (>=1.1), git, and the cerebe CLI. On Windows, confirm I'm
   running in WSL2 with the repo on the Linux filesystem (~/..., not /mnt/c).
   docker + kubectl are deploy-path only. Give the install one-liner for anything
   missing on my OS (cerebe: curl -fsSL
   https://raw.githubusercontent.com/cerebe-ai/cerebe/main/install.sh | sh).
2. (Optional) Rename the template to my product: run
   `bun run init -- --dry-run --name "<my product>"` to preview, then apply it.
3. bun install, then cerebe init. Confirm `cerebe doctor` reports the
   post-commit and pre-push hooks as installed.
4. Copy .env.example to .env. Help me get a Cerebe API key and Clerk keys.
5. bun run dev. Surface http://localhost:5173 and confirm the backend health
   check at http://localhost:8787/health.
6. (Optional) Turn on a local critic with `cerebe model add <vendor>` (claude,
   cursor or codex) for a vendor CLI I'm signed in to. Make a trivial change,
   commit it, and confirm `cerebe status` shows a verdict for the commit.

Start at step 1. Ask before each shell command.
```

## …or follow the steps manually

## Requirements before you start

**Must have — dev won't run without these:**

- **[Bun](https://bun.sh) ≥ 1.1** — the runtime, package manager, and script
  runner for the whole repo. (`curl -fsSL https://bun.sh/install | bash`)
- **Git ≥ 2.40** — source control + the Cerebe Factory commit/push hooks.
- **macOS or Linux.** Native dev assumes a Unix shell. **On Windows, use
  [WSL2](https://learn.microsoft.com/windows/wsl/install):** install Bun *inside*
  the WSL2 distro and keep the repo on the Linux filesystem (`~/...`, not
  `/mnt/c/...`) — otherwise hot-reload and the git hooks are slow and flaky.

**Needed for the commit/push gate (Steps 1 and 6):**

- **The `cerebe` CLI** (Cerebe Factory), installed once per machine:
  `curl -fsSL https://raw.githubusercontent.com/cerebe-ai/cerebe/main/install.sh | sh`.
  It is a standalone binary that verifies its release signature on install. It
  is not an npm package, so nothing in `package.json` pins it.
- **Optional: a Claude Code, Cursor or Codex subscription, signed in locally**,
  if you want local critics. They review on your flat-rate login instead of API
  keys. Local review stays off until you enable a critic (Step 6).

**Needed only when you reach that step — not upfront:**

- A **Cerebe API key** (the agent's engine, Step 3) — <https://cerebe.ai>.
  *(Prefer raw Anthropic? See [`notes.md`](notes.md) §4.)*
- A **Clerk** account for auth (Step 4) — <https://clerk.com>. Optional while prototyping.
- A **Doppler** account for production secrets (Step 5) — <https://doppler.com>.
  Optional; a local `.env` works until you deploy.
- **Docker + kubectl** — **deploy path only**, never for dev. See
  [`deploy/README.md`](../deploy/README.md).

> **Node.js never runs your app** here — Bun does. You don't even need Node
> installed for dev. (The `cerebe` CLI is a standalone binary, so the gate
> doesn't need Node either.) See [`notes.md`](notes.md) "Node vs Bun".

## Step 0 — Name your product (~30 sec, one time)

If you created this repo from the template and want it called something other
than "df-cerebe", run the init script — the lightweight replacement for Copier
(pure text substitution, no Python):

```bash
bun run init -- --dry-run --name "Your Product"   # preview the changes first
bun run init -- --name "Your Product"             # apply (derives a slug)
```

It replaces the `df-cerebe` slug (npm scope, k8s names, hostnames) and the `DF Cerebe`
display name throughout the tree, and removes the template's own build journals
(`WORK_LOG_*.txt`). No files are renamed — the name only ever appears in file
contents. Pass `--slug my-slug` to override the derived slug, or `--fresh-git` to
detach from the template's git history. Skip this step entirely to keep `df-cerebe`.

## Step 1 — Install (~1 min)

```bash
bun install
```

This installs every workspace (`backend`, `frontend`, `shared`). Then wire the
Cerebe Factory gate: install the `cerebe` CLI once per machine (skip this if you
already have it), and initialize this clone:

```bash
curl -fsSL https://raw.githubusercontent.com/cerebe-ai/cerebe/main/install.sh | sh
cerebe init
cerebe doctor     # hook:post-commit and hook:pre-push report "installed"
```

> **`cerebe init` is what turns the gate on.** The gate config is committed
> (`cerebe/config.json`, `cerebe.yaml`), but git doesn't clone hooks, so a fresh
> clone has none until `cerebe init` writes the `post-commit` and `pre-push`
> hooks. Run it once in every clone; the installer runs it for you when you run
> it from inside the clone. There is no Husky and no npm package: the CLI lives
> outside the repo, and `package.json` pins no gate version. If you bootstrapped
> via the tarball and have no `.git` yet, run `git init -b main` **before**
> `cerebe init` so it has a repo to wire. Upgrading a clone that used the old
> Husky hooks? Run `git config --unset core.hooksPath` first: `cerebe init`
> writes into whatever directory that setting names, so without the unset the
> hooks land in Husky's leftover directory instead of `.git/hooks`.

> **Commit the lockfile.** Bun writes `bun.lock` (or `bun.lockb`) — commit it.
> Installs stay reproducible, and the Docker builds run
> `bun install --frozen-lockfile` (see [`notes.md`](notes.md)).

## Step 2 — Run the dev loop (~seconds)

```bash
cp .env.example .env       # we'll fill it in next step; dev starts without keys
bun run dev
```

This starts **both** services natively, each with hot reload:

- Backend (Hono + LangGraph.js) on `http://localhost:8787`
- Frontend (Vite + Svelte) on `http://localhost:5173`

Open <http://localhost:5173> — you'll see the dashboard chat surface. Sanity
check the backend:

```bash
curl http://localhost:8787/health        # → {"ok":true,"service":"df-cerebe-backend"}
```

No Docker. No cluster. This is the whole inner loop.

| Command | What it does |
|---|---|
| `bun run dev` | Start both backend and frontend (hot-reload) |
| `bun run dev:backend` | Start only the backend on `:8787` |
| `bun run dev:frontend` | Start only the frontend on `:5173` |
| `Ctrl+C` | Stop all running servers |

Both servers hot-reload on file changes — no restart needed after editing code or
`.env`. `Ctrl+C` stops everything cleanly.

## Step 3 — Add your key + first agent turn

The agent runtime is **already implemented** — a LangGraph.js `StateGraph` in
`backend/src/agent/graph.ts` calling Cerebe, streamed to the chat UI over SSE.
All it needs is a key.

1. Put your Cerebe key in `.env`:
   ```bash
   CEREBE_API_KEY=ck_live_...
   LLM_MODEL=gpt-4o      # default; see notes.md "Model selection"
   ```
2. The dev server hot-reloads, so just **send a message from the dashboard chat
   box** at <http://localhost:5173>. You'll see the reply stream in token by
   token. (Without a key you'll get a clear `authentication_error` in the chat —
   that's the wiring working; add the key.)

> **Why LangGraph.js (not Python):** one language across the repo and shared
> types with the frontend. The JS port trails Python LangGraph on the newest
> features — fine for a dashboard agent. Full trade-off in [`notes.md`](notes.md).
> Want to extend the agent? `graph.ts` is a minimal single-node graph — add tool
> nodes + conditional edges there.

## Step 4 — Auth with Clerk *(optional — already wired, graceful-optional)*

Clerk auth is **implemented** with the official packages (`@clerk/backend` on the
server, `@clerk/clerk-js` on the frontend — Svelte is just JS, so no framework
wrapper is needed). It's **graceful-optional**: it turns on only when you provide
keys.

- **No keys → open mode.** The app runs with `/api/*` unauthenticated and the
  backend logs a loud warning. Perfect for prototyping; do not deploy like this.
- **Keys set → enforced.** The frontend gates behind Clerk sign-in and sends the
  session token; the backend verifies it with `verifyToken` and 401s otherwise.

To turn it on: create a Clerk app and put both keys in `.env`, then restart dev:

```bash
CLERK_SECRET_KEY=sk_test_...           # backend verifies tokens
VITE_CLERK_PUBLISHABLE_KEY=pk_test_... # frontend sign-in UI
```

That's it — no code to write. The wiring lives in `backend/src/index.ts`
(`requireAuth`) and `frontend/src/lib/auth.ts` + `main.ts`. Each deployment brings
its **own** Clerk keys (via `.env` / Doppler, never committed).

## Step 5 — Secrets via Doppler *(optional)*

For local dev a `.env` file is enough. When you want managed secrets (teams,
prod), Doppler injects them at runtime — no `.env` shipped:

```bash
doppler login
doppler setup --project df-cerebe          # bind this dir to a Doppler project
doppler secrets set CEREBE_API_KEY=ck_live_... CLERK_SECRET_KEY=sk_test_...
doppler run -- bun run dev              # run with secrets injected
```

In production the same secrets reach Kubernetes via a `Secret` or the Doppler
operator — see [`deploy/README.md`](../deploy/README.md).

## Step 6 — First commit hits the Cerebe Factory gate (~1–2 min)

The gate config is committed, and `cerebe init` (Step 1) installed the hooks:

| File | What it holds |
|---|---|
| `cerebe/config.json` | The local critic fleet and quorum (empty at first); which finding severities block a push (`blocker`, `high`); the guidance files critics read (`AGENTS.md`, `CLAUDE.md`) and the prompt fragment [`cerebe/prompts/local-critic.md`](../cerebe/prompts/local-critic.md); the docs-only verification route; the advisory TDD classifier |
| `cerebe.yaml` | Team config: agent autonomy, a deny list of destructive git commands (`git push --force`, `git reset --hard`, `git clean`), and which keys a developer can't override locally |
| `cerebe/.gitignore` | Keeps the CLI's runtime output (`reviews/`, `runs.ndjson`, …) out of git |

### Turn on a local critic (optional)

Local review starts **off** (no critics). To turn it on, enable a critic for a
vendor CLI you're signed in to. It reviews on your flat-rate subscription, not
an API key:

```bash
cerebe model add claude     # or: cursor, codex
cerebe model list           # the fleet, its models and the quorum
```

`cerebe model add` edits `cerebe/config.json`: it adds the critic, sets the
quorum to the number of enabled critics, and makes a push block when its commit
has no review. Commit that change when the whole team should run that critic.

### Make a change and commit

```bash
# edit README.md or anything
git add -A
git commit -m "chore: first commit"
```

The `post-commit` hook runs `cerebe review` in the **background**
(non-blocking). With a critic enabled, the verdict lands after a few minutes:

```bash
cerebe status                               # verdict + per-critic status for HEAD
cerebe show                                 # the full review
cerebe findings --range origin/main..HEAD   # every commit in a range
```

A verdict is `APPROVED` or `CHANGES_REQUESTED`. On `CHANGES_REQUESTED`, fix the
findings in a **new commit** (never amend — the artifact is bound to the
original SHA). `CEREBE_SKIP_REVIEW=1 git commit` skips the review of one commit.

### Push

```bash
git push
```

The `pre-push` hook runs `cerebe gate-push`, which checks the commit you push
(HEAD): it blocks while that commit has an unresolved `blocker` or `high`
finding, or has no review once a critic is enabled. With no critic enabled there
is no review to check, so it passes (it still enforces any verification routes
you add to `cerebe/config.json`). Genuine emergencies only:
`CEREBE_BYPASS="reason" git push` (recorded in `cerebe/runs.ndjson`;
`cerebe stats` summarizes bypasses).

> **Opt-in next layer:** a hosted critic that posts a **check on your pull
> requests** (the local gate only protects your own machine). It's not wired by
> default because it needs the Cerebe Factory GitHub App on your repo and a
> branch ruleset. When you're ready (typically before multi-author merges), see
> the **[Appendix — Enabling the hosted gate](#appendix--enabling-the-hosted-gate-opt-in)**.

## Step 7 — Deploy (later, fully optional)

When — and only when — you want to ship, the entire container + Kubernetes path
lives in [`deploy/`](../deploy/README.md) with its own guide. Nothing in that
folder is required for, or touched by, the dev loop above. Build images with
`bun run docker:build:*`, apply with `bun run k8s:apply`.

## What you have now

- A **native TypeScript dev loop** — `bun install` → `bun run dev` → dashboard
  on screen, hot-reloading, zero infrastructure
- **One language end to end**, with backend ↔ frontend types shared in `shared/`
- A **first commit through the Cerebe Factory hooks**, with review artifacts
  under `cerebe/reviews/` once a local critic is on
- A **deployment path that exists and works** but stays out of your way until you
  choose it

## Where to go next

- [`notes.md`](notes.md) — every open decision and `NOTE(verify)` in one place:
  dependency version pins, LangGraph.js API verification, model selection, Clerk
  -on-Svelte choice, Bun compatibility, Helm-vs-kustomize, the hosted CI gate.
- [`deploy/README.md`](../deploy/README.md) — the optional deploy graduation path.
- [`cerebe/config.json`](../cerebe/config.json) — the gate config (explained in
  Step 6); `cerebe <command> --help` documents each command.
- Cerebe Factory docs: <https://cerebe.ai/docs/factory/install>. The CLI and its
  installer: [`cerebe-ai/cerebe`](https://github.com/cerebe-ai/cerebe).

## Appendix — Enabling the hosted gate (opt-in)

The local gate (Step 6) only protects *your* machine — it does nothing for merges
done through the GitHub UI, the merge queue, auto-merge, or a PR opened from
another machine. To gate **pull requests**, install the hosted critic, which
posts a check on every PR, then require that check in a branch ruleset.

### 1. Install the Cerebe Factory GitHub App

Install the **[Cerebe Factory GitHub App](https://github.com/apps/cerebe-factory/installations/new)**
on your repo (walkthrough: <https://cerebe.ai/docs/factory/install>). It reviews
each PR head on Cerebe's side and posts the **`cerebe/critic`** check. There is
no workflow file to add and no vendor API keys to manage. The hosted review runs
the latest `cerebe`, which is why the repo pins no CLI version.

A green local review is not the PR gate: the hosted fleet, its blocking policy
and its CLI version are chosen separately from your local setup, so the two can
disagree on a diff.

> Can't reach the hosted App (an air-gapped network, say)? Run
> `cerebe critic` from a workflow you write, with your own vendor API keys, and
> require that job's check instead of `cerebe/critic`. The old reusable
> `agent-critic.yml` workflow has been deleted, so there is no `uses:` line to
> copy.

### 2. Make it binding

Installing the App posts a verdict but **does not block merges** — a ruleset
does. Wait until `cerebe/critic` has reported on a real PR, then create a
ruleset that requires it to be green and bot review threads resolved. The
`cyclone` CLI (installed alongside `cerebe`) prints one:

```bash
cyclone admit-pr --print-ruleset main --source <your-org>/<your-repo> \
  --required-contexts 'cerebe/critic' > main-enforcement.json
gh api -X POST repos/<your-org>/<your-repo>/rulesets --input main-enforcement.json
```

Require the **exact** context `cerebe/critic`, and optionally pin it to the
Cerebe Factory App (`"integration_id": 3859191` on that entry) so a check of the
same name from another app can't satisfy it. The pre-rename
`dark-factory/critic` is no longer posted, so a ruleset that requires it blocks
every PR forever.
