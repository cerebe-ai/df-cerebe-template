# df-cerebe-template

> Internal dashboard template with AI chat. **Bun + Hono + LangGraph.js** backend,
> **Vite + Svelte** frontend, shared TypeScript types, gated by **Cerebe Factory**.
> Native dev in seconds — Docker/Kubernetes exist for deployment only and are
> never in your way while building.

The backend agent streams chat responses from Cerebe (Momentiq's cognitive
engine) with full long-term memory support — pre-turn recall, mid-turn search,
and post-turn harvest. Auth (Clerk) and secrets (Doppler) are wired but
graceful-optional, off until you add keys. Dependencies are **declared and
pinned but not installed** — your `bun install` brings them in. See
[`docs/getting-started.md`](docs/getting-started.md) for the walkthrough and
[`docs/notes.md`](docs/notes.md) for open decisions.

## Quickstart

```bash
# 1. Install Bun once: https://bun.sh
bun install                 # installs all workspaces

# 2. Wire the Cerebe Factory gate: install the cerebe CLI once per machine,
#    then run `cerebe init` in each fresh clone (cerebe/ is committed)
curl -fsSL https://raw.githubusercontent.com/cerebe-ai/cerebe/main/install.sh | sh
cerebe init                 # installs the post-commit + pre-push git hooks

# 3. Configure
cp .env.example .env        # set CEREBE_API_KEY (Clerk keys optional)

# 4. Run
bun run dev                 # backend (:8787) + frontend (:5173), both hot-reload
```

Open <http://localhost:5173>. That's it — no containers, no cluster, no k8s.

> Send a message in the chat and the reply streams back from Cerebe. Without a
> key set, the chat shows a clear `authentication_error` — that's the full path
> working; just add `CEREBE_API_KEY`.

### Renaming for your project

```bash
bun run init                # interactive: replaces template slug + display name everywhere
```

This is a lightweight Copier replacement — pure text substitution, no Python.
Run `bun run init -- --dry-run --name "Your App"` to preview first.

## Layout

```
df-cerebe-template/
├── backend/        Hono + LangGraph.js agent  → dev: bun --hot (native)
├── frontend/       Vite + Svelte SPA          → dev: vite (native)
├── shared/         TypeScript types imported by BOTH sides
├── deploy/         Docker + k8s — DEPLOY ONLY, dev never touches it
├── cerebe/         Cerebe Factory gate config; cerebe init wires the hooks
├── cerebe.yaml     Cerebe Factory team config (deny list, locked keys)
├── scripts/        init script + optional docker-build evidence shim
└── docs/           getting-started, notes, coding standards, PRDs, ADRs
```

## The three ideas this template commits to

1. **One language, both ends.** TypeScript backend + frontend, sharing types via
   `shared/`. Change a shape once; both sides re-type-check.
2. **Native dev is sacred.** `bun install` → `bun run dev` → app on screen. Docker
   and Kubernetes are quarantined in `deploy/` and are an opt-in *deployment*
   step, never a *development* requirement.
3. **Gated from commit one.** The Cerebe Factory gate is committed in
   [`cerebe/`](cerebe/) and [`cerebe.yaml`](cerebe.yaml); `cerebe init` wires its
   post-commit (review) and pre-push (gate) hooks. Local critics are opt-in
   (`cerebe model add <vendor>`), and the hosted Cerebe Factory App reviews pull
   requests. See [`docs/getting-started.md`](docs/getting-started.md) Step 6.

## Deploying (later, optional)

Everything container/k8s is in [`deploy/`](deploy/README.md) with its own guide.
You graduate into it when you're ready to ship — it changes nothing about dev.
