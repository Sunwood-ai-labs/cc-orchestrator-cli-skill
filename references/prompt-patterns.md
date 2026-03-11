# Prompt Patterns

## Build App Team Prompt

Use this when Claude Code should create and run a product-building team.

```text
Create an agent team in this workspace and build a small static browser app.

Before making changes, create a short QA inventory that lists:
- the requested deliverables
- the files you expect to create or change
- the final claims you expect to make
- the checks required before signoff

Team instructions:
- Spawn exactly 3 teammates yourself.
- Roles must be coder, designer, and reviewer.
- coder owns HTML structure and JavaScript behavior.
- designer owns CSS, layout, copy, visual mood, and responsive polish.
- reviewer owns review, bug-finding, and final signoff.
- Delegate meaningful work to all three teammates before you integrate.
- If reviewer finds issues, fix them before finishing.
- Avoid file conflicts by assigning clear ownership.
- Clean up the team when done.

Product requirements:
- Plain HTML, CSS, and JavaScript only.
- Use or create index.html, style.css, and script.js in the current workspace.
- State the exact product requirements here.

Final response requirements:
- Briefly confirm that you spawned the agent team.
- Report what tasks each teammate actually performed, in concrete terms.
- List the files created or changed.
- Mention any issues found by the reviewer and how they were resolved.
- Confirm that the final signoff covered the QA inventory.
```

## Review-Only Team Prompt

Use this when the code already exists and Claude Code should run a review-oriented team.

```text
Create an agent team in this workspace and review the current implementation.

Before reviewing, create a short QA inventory that lists:
- the target files or surfaces under review
- the claims you expect to make in the review summary
- the checks needed to support those claims

Team instructions:
- Spawn exactly 3 teammates yourself: coder, designer, reviewer.
- coder checks behavior and integration gaps.
- designer checks layout, copy, accessibility, and responsive polish.
- reviewer owns final review findings and signoff.
- Do not make changes until the reviewer or another teammate identifies a concrete issue.
- If issues are found, fix them and then run a final reviewer pass.
- Clean up the team when done.

Final response requirements:
- Confirm that the team was spawned.
- List findings first, ordered by severity.
- Then report what each teammate actually did.
- Then list the files changed, if any.
- Mention whether the QA inventory was fully covered.
```

## Debug Log Checks

Use these patterns to confirm true team mode:

- `spawnInProcessTeammate`
- `coder@`
- `designer@`
- `reviewer@`
- `TeammateIdle`
- `TaskCompleted`

If these do not appear, inspect whether the run fell back to subagents or never spawned teammates.
