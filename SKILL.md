---
name: cc-orchestrator-cli-skill
description: Operate Claude Code from the CLI in experimental agent-team mode on Windows. Use when Codex needs to instruct Claude Code to spawn its own teammates from PowerShell, run a structured build or review task, capture debug logs, distinguish true agent teams from --agents subagents, and report what each teammate did.
---

# CC Orchestrator CLI Skill

Use this skill to drive Claude Code from the command line on Windows when the goal is true agent-team execution, not session-scoped `--agents` subagents.

## Follow this workflow

1. Write a prompt that tells Claude Code to create an agent team itself.
2. Pipe the prompt over stdin instead of passing a long multiline prompt as a positional argument.
3. Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.
4. Use `--dangerously-skip-permissions` only when the task needs hands-off file edits or unrestricted tool usage and the user expects that behavior.
5. Capture a debug log and confirm teammate spawn from the log before claiming team mode worked.
6. Read generated text files with UTF-8 in PowerShell when Japanese or other non-ASCII text is involved.

## Do not mix up team mode and subagents

- Use true team mode when Claude Code should spawn teammates itself.
- Do not use `--agents` for this workflow unless the user explicitly wants custom subagents instead of agent teams.
- In team mode, tell Claude Code things like `Create an agent team`, `Spawn exactly 3 teammates`, `coder`, `designer`, `reviewer`, and `Clean up the team when done`.

## Build prompts with explicit ownership

Include all of these elements in the prompt:

- Team creation instruction:
  `Create an agent team in this workspace`
- Exact teammate count and roles:
  `Spawn exactly 3 teammates yourself`
- Ownership:
  `coder owns HTML and JavaScript`, `designer owns CSS and visual polish`, `reviewer owns review and final signoff`
- Coordination rules:
  `Delegate meaningful work to all teammates`, `Avoid file conflicts`, `Fix reviewer findings before finishing`
- Product requirements:
  file names, frameworks allowed, UX requirements, target states, and output expectations
- Final response requirements:
  ask for teammate-by-teammate task reporting, changed files, and reviewer findings or signoff

Use [references/prompt-patterns.md](./references/prompt-patterns.md) for ready-to-adapt prompt shapes.

## Run the CLI

Use [scripts/run-claude-team.ps1](./scripts/run-claude-team.ps1) on Windows PowerShell.

Typical flow:

1. Create a UTF-8 prompt file or pass `-PromptText`.
2. Run the script with `-Dangerous` when appropriate.
3. Save the returned debug path.

Example:

```powershell
.\scripts\run-claude-team.ps1 -PromptFile .\tmp\prompt.txt -Dangerous
```

## Verify that team mode actually ran

Inspect the debug log for entries like:

- `spawnInProcessTeammate`
- `coder@...`
- `designer@...`
- `reviewer@...`
- `TeammateIdle`
- `TaskCompleted`

If the log only shows `SubagentStart with query: Explore` or behavior tied to `--agents`, do not claim that true team mode ran.

## Report results back clearly

Summarize:

- whether Claude Code spawned a real team
- which teammates ran
- what each teammate actually did
- which files changed
- any reviewer issues and how they were resolved

If Claude Code returns a too-short final answer, inspect the generated files and debug log yourself before responding.

## PowerShell encoding note

When checking Japanese or other non-ASCII output in PowerShell, prefer:

```powershell
Get-Content .\index.html -Encoding UTF8
```

This avoids false mojibake during review.
