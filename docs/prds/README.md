# Product requirements (PRDs)

A PRD records what a product change must achieve and how we'll know it did.
Write one when a change is big enough to need agreed requirements; a change
that implements one cites it.

- One file per PRD, named `YYYY-MM-<slug>.md` (for example
  `2026-11-team-dashboards.md`).
- Start with its status (Draft, Accepted or Superseded) and date, then:
  Context, Goals, Non-goals, Requirements, Success metrics, Open questions.
- Number requirements (R1, R2, …) so changes and ADRs can cite them.
- Architecture decisions a PRD leads to are recorded in
  [`../adr/`](../adr/README.md), and the PRD links them.
