# AGENTS.md

DF Cerebe is an internal dashboard with streaming AI chat. `backend/` is a
Bun + Hono + LangGraph.js agent that calls Cerebe, `frontend/` a Vite + Svelte
SPA, and `shared/` the TypeScript types both import. Quickstart and layout:
[`README.md`](README.md).

## Commands

Bun is the runtime, package manager and script runner: use `bun` and `bunx`,
not `npm`, `npx` or `node`. Scripts live in the root
[`package.json`](package.json) (dev loop, gate, deploy) and in each
workspace's `package.json`, each with a `type-check` script. The hooks in
[`.husky/`](.husky/) run the critic gate on every commit and push.

## Where things live

| Need | Read |
|---|---|
| Coding standards (before writing code) | [`docs/engineering/coding-standards.md`](docs/engineering/coding-standards.md) |
| Product requirements (PRDs) | [`docs/prds/`](docs/prds/README.md) |
| Architecture decisions (ADRs) | [`docs/adr/`](docs/adr/README.md) |
| Setup walkthrough, opt-in hosted PR gate | [`docs/getting-started.md`](docs/getting-started.md) |
| Open decisions, verification log | [`docs/notes.md`](docs/notes.md) |
| Critic gate configuration | [`.agent-review/README.md`](.agent-review/README.md) |
| Deployment (Docker, Kubernetes) | [`deploy/README.md`](deploy/README.md) |
| Area rules (nested `AGENTS.md`), skills (`.claude/skills/`) | None yet |

## Rules

- **Dev never needs Docker or Kubernetes.** `bun install` then `bun run dev`
  is the whole loop. Container and cluster files stay in `deploy/`, out of the
  dev scripts and the dev path. No check enforces this; review holds it.
- **The gate stays intact.** Don't disable, bypass or weaken the `.husky/`
  hooks or `.agent-review/config.json` to get a commit through. Fix the
  critic's findings (`.git/agent-reviews/<sha>.md`) in a new commit; never
  amend. Bypass a push only in a genuine emergency, with
  `AGENT_REVIEW_BYPASS="<reason>"`. `.husky/pre-push` (`df gate-push`)
  enforces the gate and logs every bypass to `.git/agent-reviews/_runs.ndjson`;
  review holds the rest.
- **Lockfile.** A project created from this template commits `bun.lock` after
  its first `bun install`. The template repository itself stays uninstalled
  and commits no lockfile ([`docs/notes.md` §1](docs/notes.md#1-dependency-versions-are-placeholders-verify-before-first-install)).
  Review holds this.

<!-- cerebe:pack-digest:v1 sha256=eb00e3761e0e78df6a29deb8ea1159e721e5c928266469a5dea25d4f9e08a1f6 -->
# SOTA-first doctrine

Push forward to the current state of the art. Choose the approach a well-run
team would choose today, not the one that merely happens to already be in the
tree.

## Mandate

- Prefer the current best-practice API, pattern, or library over a legacy
  default. Match an older pattern already in the codebase only when consistency
  is the actual point; otherwise upgrade it in scope.
- Rename or replace legacy paths and remove dead code you touch — do not leave a
  second way to do the same thing sitting behind the new one.
- No backward-compatibility shims unless explicitly requested. The one exception
  is a published or otherwise public surface, where breaking changes are
  version-gated rather than free.

## Legacy-default tripwires

Stop and justify when you notice yourself:

- Reaching for a deprecated function, flag, or config because it was the first
  hit, not because it is the right one.
- Copying an existing pattern that is itself out of date ("it's already like
  this here").
- Leaving a "temporary" shortcut, TODO, or cast that hides a real type or
  contract.
- Duplicating logic that already has a canonical home instead of calling it.

If you choose a legacy default deliberately, name the reason in one line — a
real constraint, not habit. If you cannot name the reason, that is the signal to
pick the current approach instead.

---

# Iteration ceiling — restructure, don't thrash

Fixing review findings has a hard iteration ceiling. Respect it.

## The N=2 ceiling

- After 2 rounds of fixes, if a third round of findings on the same area is
  appearing, STOP. Do not reach for a third patch first.
- "Same finding-class" does not require identical text. ANY new finding
  introduced by a fix is a thrash signal — regardless of:
  - severity dropping (high to medium is not convergence),
  - the finding moving to a different file (relocation is not progress), or
  - reviewers agreeing across vendors (consensus is real signal, but the right
    response is to restructure, not to patch again).

## Mandatory response at the 2nd consecutive round of fix-introduced findings

1. Stop patching.
2. Get an independent read — call the advisor, or the equivalent
   independent-reviewer capability in your tool.
3. Name the structural cause: the surface that keeps generating findings.
4. Restructure that surface — DRY it, delete it, or redesign it — BEFORE any
   further fix attempt.

A fix that eliminates the finding-generating structure ends the loop; a fix that
merely reshapes the same surface restarts it. When in doubt, restructure the
thing being iterated on rather than the latest symptom.

---

# Parking-lot protocol — pre-existing blockers

Not every failure you hit is yours to fix in this change. Separate the two
cleanly instead of chasing an inherited failure down a rabbit hole.

## Triage first

When a gate fails, decide whether the failure is caused by your diff or
inherited from the base branch:

- Reproduce against a pristine checkout of the base branch (a disposable
  worktree), with the same build and the same failing gate.
- If it fails identically there, it is pre-existing — not introduced by your
  change.

## If it is pre-existing — park it, don't absorb it

1. File a tracking issue: the failing command, the error excerpt, and the
   file or workflow that is broken.
2. Note the pre-existing failure (with its issue link) in your change
   description, so a reviewer sees it is known and tracked.
3. Proceed with a structured, cited reason — never a silent skip.

## Budget

If you have spent more than about 30 minutes trying to fix something that turns
out to be pre-existing, that is the signal to park-and-track it instead of
continuing.

## Hard stops — do NOT park these

- The failure IS in your diff. Fix it.
- The fix is trivial and adjacent to your scope (a few lines, no new test
  infrastructure). Fix it inline.

Park to stay focused, not to dodge real findings. A finding your change caused is
never a parking-lot candidate.

---

# Decision protocol

When you hit a decision that is not already settled, follow this order instead
of guessing or stalling.

## 1. Look it up first

Check whether the decision is already made — in the decision ledger, in the
change's stated objectives, in the repo's contributor docs, or in an existing
ADR. A settled decision is not yours to re-open; apply it and move on.

## 2. Decide it yourself when it is reversible AND in your authority

If the decision is cheap to reverse and within the scope you were handed, make
it, act, and record it — for example with `cyclone decisions record` — so the
next agent inherits the rationale rather than re-deriving it. A recorded
reversible decision keeps momentum without losing the trail.

## 3. Escalate — with a timeout — when it is irreversible OR out of authority

If the decision is expensive to undo (a public contract, a security posture, a
data migration) or outside your scope, escalate with a concrete proposal and a
decision deadline. Do not spin idle waiting for an answer.

## 4. If the escalation times out: safe default or park

When no answer arrives in time, either take the reversible safe default (and
record it, per step 2) or park the work behind a tracking issue (per the
parking-lot protocol). Never ship an irreversible choice on an unanswered
escalation.

Rule of thumb: reversible-and-yours means decide and record; irreversible-or-
not-yours means escalate; no answer in time means safe default or park.
<!-- /cerebe:pack-digest:v1 -->
