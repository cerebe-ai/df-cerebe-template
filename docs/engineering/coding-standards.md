# Coding standards

Conventions for code in this repo that the tooling doesn't enforce. Read this
before writing code. The local critic reviews every commit against it (it is
listed in `.agent-review/config.json` under `context.guidanceFiles`).

What the tooling already checks is not repeated here: strict TypeScript from
[`tsconfig.base.json`](../../tsconfig.base.json), run by each workspace's
`type-check` script. No formatter or linter is configured; when one is added,
delete any convention below that it enforces.

## Shared types

A shape that crosses the HTTP boundary (request and response bodies, stream
events, header names) is defined once in `shared/` and imported from
`@df-cerebe/shared` by both `backend/` and `frontend/`. Never redeclare it on
either side.

## Library and model APIs

- Check a library's API against the installed version (its types under
  `node_modules`), not memory, and keep code examples in docs correct for the
  pinned versions.
- For model ids, SDK calls, streaming and tool use, check Cerebe's current
  docs (<https://cerebe.ai>) rather than memory.

## Dependencies

Pin every dependency to an exact version, with no `^` or `~` range: add it
with `bun add --exact`.

## Configuration and secrets

Add every environment variable the code reads to
[`.env.example`](../../.env.example), with a comment and no real value. Real
values live in `.env` (git-ignored) or Doppler, never in code.

## Rendering model output

Model output reaches the page as HTML only through
`frontend/src/lib/markdown.ts`, which sanitizes it with DOMPurify. Never pass
unsanitized markup to Svelte's `{@html}`.
