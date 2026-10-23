# Architecture decision records (ADRs)

An ADR records one architecture decision and why it was made, so a later
reader can see why the code is shaped the way it is.

- One file per decision, named `NNNN-<slug>.md` and numbered in order from
  `0001`. A number is never reused or changed.
- Start with Status (Proposed, Accepted, or Superseded by NNNN), Date and
  Deciders, then: Context, Decision, Alternatives considered, Consequences.
- An accepted ADR isn't rewritten. To change a decision, write a new ADR that
  supersedes it and update the old one's Status.
- `docs/ADR/` is the folder Cerebe's tools use by default (`docs.adrDir` in
  `cerebe.yaml`), so they find these records without configuration.
