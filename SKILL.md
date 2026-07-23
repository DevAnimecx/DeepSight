---
name: deepsight
description: >
  Premium token-optimized code intelligence platform for staff-engineer-level reviews.
  Use when the user requests security audits, architectural reviews, code quality analysis,
  performance reviews, PR reviews, shift-left security, or any comprehensive multi-agent
  code review. Triggers on: /review, /audit, /deepsight, "review this code", "audit security",
  "check architecture", "find bugs", "performance review", "code quality check".
---
> **DeepSight v0.2.1 — Universal AI Skill Platform**
> This skill now supports Claude Desktop, Claude Code, OpenAI Codex CLI, and Custom GPT.
> Platform-specific instructions in `_platforms/` directory.



# DeepSight — Agentic Code Intelligence Platform

## Install (One Command)

One command installs to any AI platform:

```bash
# Any OS (requires Node.js)
npx deepsight

# macOS / Linux (no Node.js needed)
bash <(curl -fsSL https://raw.githubusercontent.com/DevAnimecx/DeepSight/main/install.sh)

# Windows (CMD or PowerShell)
powershell -c "iwr -useb https://raw.githubusercontent.com/DevAnimecx/DeepSight/main/install.ps1 | iex"
```

Or copy this folder to any of these paths:
- `~/.agents/skills/deepsight/` (Claude Code CLI)
- `%APPDATA%\Claude\agents\skills\deepsight` (Claude Desktop — Windows)
- `~/Library/Application Support/Claude/agents/skills/deepsight/` (Claude Desktop — macOS)
- `~/.config/Claude/agents/skills/deepsight/` (Claude Desktop — Linux)

## Three-Layer Depth-Charge Protocol

### Layer 1: Deterministic Guardrails (0-5s, 0 tokens)
1. Run Layer 1 from `scripts/run-semgrep.sh` against changed files.
2. Block obvious errors (eval, hardcoded keys) before invoking any agent.
3. Output: PASS / FAIL with specific file:line findings.

### Layer 2: Semantic Diff Review (10-30s, <10K tokens)
4. Collect `git diff` (changed hunks only, never full files).
5. Route diff hunks to relevant agents based on file patterns:

| Pattern | Agent |
|---------|-------|
| auth, login, jwt, oauth, session | security |
| controller, route, api, service, repo | architecture |
| db, query, migration, model | performance |
| test, spec, __test__ | test |
| util, helper, middleware | error |
| component, hook, view | pattern |
| pii, secret, token, key, env | data |
| any | solid, smell |

6. Escalate to Opus-4.7 only for Critical findings; use Haiku-4 for routine checks.

### Layer 3: Agentic Cross-File Trace (1-3min, <40K tokens)
7. For Critical findings, agents trace data flow on-demand using Grep/Glob/Read.
8. Verify end-to-end paths (e.g., is sanitize() actually called by routes.ts?).
9. Lazy load: agents read only the specific functions/classes needed.

## Agent Orchestration

Load agent instructions **lazily** from `agents/<name>.md`. Never load all 9 at once.

For each triggered agent:
1. Read `agents/<name>.md` for that agent's focused instructions.
2. Load `references/<relevant>.md` only if the agent's scan triggers it.
3. Collect findings as `file:line → severity → finding → fix`.
4. Return in **Caveman Output** format: no filler phrases, no "Here is the code."

## "Grill Me" Pre-Flight
Before starting review, ask the developer 3 context questions:
1. What is the primary threat model?
2. Are there performance constraints (e.g., <100ms)?
3. What existing patterns should this mimic?
**If answers are vague, pause the review.**

## Output Format

Synthesize all agent findings into a **single GitHub Comment**:

1. **Executive Summary**: Risk Score (0-10) + Approve / Request Changes
2. **Critical (Must Fix)**: Findings with runnable PoC exploits (curl/Python)
3. **Architectural Warnings**: Cross-file coupling, pattern violations
4. **Suggestions**: Performance tweaks, code smells
5. **Verified Correct**: Explicitly praised patterns (positive reinforcement)

**Constraint**: Every finding must reference `file:line` and offer a concrete fix. No generic advice.

## Token Efficiency Rules
- Caveman Output: `file:line → severity → finding → fix`. No filler.
- Progressive Disclosure: Load references only when triggered.
- Diff-Only: Never read unchanged code unless Layer 3 requires it.
- Model Routing: Haiku-4 for routine, Opus-4.7 for complex.
- Session Compaction: Use /recap for long threads.
## Universal Platform Support

DeepSight now runs on multiple AI platforms:

- **Claude Desktop** — via `claude_desktop_config.json` skill integration
- **Claude Code** — via `~/.agents/skills/deepsight/` auto-detection
- **OpenAI Codex CLI** — instructions in `_platforms/openai/codex-instructions.md`
- **ChatGPT Custom GPT** — instructions in `_platforms/openai/gpt-instructions.md`

### Cross-Platform Detection
```bash
node detect-platform.js
# or with JSON output
node detect-platform.js --json
```

### Platform-Specific Configs
- `_platforms/claude/skill-instructions.md`
- `_platforms/openai/unified-instructions.md`
- `_platforms/openai/codex-instructions.md`
- `_platforms/openai/gpt-instructions.md`

### New in v0.2.1
- **10th agent**: Dependency Auditor (`agents/dependency.md`)
- **Framework guides**: Vue.js (`references/framework-vue.md`), Django (`references/framework-django.md`)
- **Auto-detect installer**: Detects all installed AI platforms and configures each
- **Agent upgrades**: All 9 agents with enhanced detection patterns
- **Unified output schema**: Same `file:line -> severity -> finding -> fix` format across all platforms
