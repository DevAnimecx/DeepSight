# DeepSight — The Agentic Code Intelligence Platform

> Premium, token-optimized Claude Skill that orchestrates a Nine-Agent "Squad Review" to simulate a Senior Staff Engineer's audit.

**Version:** v0.2.1  
**Date:** July 21, 2026  
**Token Efficiency Target:** <50K tokens/session (vs. 500K industry avg)

---

## Quick Install

One command. Installs to any AI platform.

**Quickest (any OS — no download)**
```bash
npx deepsight
```

**macOS / Linux**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/DevAnimecx/DeepSight/main/install.sh)
```

**Windows (CMD or PowerShell)**
```powershell
powershell -c "iwr -useb https://raw.githubusercontent.com/DevAnimecx/DeepSight/main/install.ps1 | iex"
```

## Quick Start

```bash
# Layer 1 — deterministic guardrails
bash scripts/run-semgrep.sh path/to/your/code

# Trigger a review (in Claude Code)
/review this PR
/audit security of src/auth/
"review this code for architecture issues"
```

## Directory Structure

```
deepsight-skill/
├── SKILL.md                # Main orchestrator (YAML header + workflow)
├── agents/                 # 9 specialized sub-agent instructions
│   ├── security.md         # DeepSight-Sec (Red Teamer)
│   ├── architecture.md     # DeepSight-Arch (Staff Architect)
│   ├── solid.md            # DeepSight-Solid (Design Patterns)
│   ├── performance.md      # DeepSight-Perf (Performance Eng)
│   ├── test.md             # DeepSight-Test (QA Lead)
│   ├── error.md            # DeepSight-Err (Reliability Eng)
│   ├── smell.md            # DeepSight-Smell (Code Hygienist)
│   ├── pattern.md          # DeepSight-Pattern (Framework Guru)
│   └── data.md             # DeepSight-Data (Privacy Officer)
├── scripts/                # Layer 1 deterministic analysis
│   ├── run-semgrep.sh      # Semgrep + regex security scanner
│   ├── generate-poc.py     # Exploit PoC generator
│   └── trace-data-flow.js  # Cross-file dependency tracer
├── references/             # On-demand context loaded by agents
│   ├── security-rules.md   # OWASP Top 10 rules
│   ├── arch-patterns.md    # Hexagonal/Clean Architecture
│   ├── team-playbook.md    # Project conventions (customize per repo)
│   └── framework-guides/   # React, Laravel, Next.js specifics
│       ├── react.md
│       ├── laravel.md
│       └── nextjs.md
├── assets/                 # Templates and configuration
│   ├── report-template.md  # GitHub Comment template
│   └── risk-matrix.json    # Severity scoring logic
├── tests/                  # Validation fixtures
│   ├── vulnerable-code/    # Sample bad code (7 files)
│   └── expected-output/    # Ground truth test cases
└── README.md               # This file
```

## The Three-Layer Depth-Charge

### Layer 1: Deterministic Guardrails (0-5s, 0 tokens)
Runs locally via `scripts/run-semgrep.sh`. Blocks obvious errors before any LLM invocation:
- `eval()` usage
- Hardcoded secrets/credentials
- SQL injection patterns
- Semgrep rules (OWASP Top 10, security audit)

**Exit codes:** 0 = pass/proceed, 1 = too many findings

### Layer 2: Semantic Diff Review (10-30s, <10K tokens)
Sends **only the git diff** (not full files) to the Lead Architect, which routes hunks to relevant agents based on file patterns.

**Model routing:** Haiku-4 for routine checks, Opus-4.7 for Critical findings.

### Layer 3: Agentic Cross-File Trace (1-3min, <40K tokens)
Agents trace data flow on-demand using Grep/Glob/Read. Validates end-to-end security paths (e.g., "Is `sanitize()` actually called by `routes.ts`?").

**Lazy loading:** Agents read only the specific functions/classes needed.

## The Nine Agents

| Agent | Role | Focus |
|-------|------|-------|
| **DeepSight-Sec** | Red Teamer | PoC exploits for Critical findings |
| **DeepSight-Arch** | Staff Architect | Circular deps, god objects, layer violations |
| **DeepSight-Solid** | Design Patterns | SOLID violations, pattern suggestions |
| **DeepSight-Perf** | Performance Eng | N+1 queries, O(n²), missing indexes |
| **DeepSight-Test** | QA Lead | Untested methods, test stubs |
| **DeepSight-Err** | Reliability Eng | Swallowed exceptions, missing timeouts |
| **DeepSight-Smell** | Code Hygienist | Long methods, magic numbers, duplication |
| **DeepSight-Pattern** | Framework Guru | Stack-specific idioms (React, Laravel) |
| **DeepSight-Data** | Privacy Officer | PII leakage, hardcoded secrets |

## Output Format

DeepSight produces a **single GitHub Comment** with:

1. **Executive Summary** — Risk Score (0-10) + Approve/Request Changes
2. **Critical (Must Fix)** — Findings with runnable PoC exploits
3. **Architectural Warnings** — Cross-file coupling, pattern violations
4. **Suggestions** — Performance tweaks, code smells
5. **Verified Correct** — Positive reinforcement for good patterns

Every finding uses the **Caveman Output** format: `file:line → severity → finding → fix`

## Token Efficiency Protocols

1. **Caveman Output** — No filler phrases, no "Here is the code"
2. **Progressive Disclosure** — Load references only when triggered
3. **Model Routing** — Haiku-4 for routine, Opus-4.7 for complex
4. **Diff-Only** — Never read unchanged code unless Layer 3 requires it
5. **Session Compaction** — Use /recap for long threads

**Target:** 500K → 30-50K tokens/session (90% reduction)

## Customization

### Team Playbook
Edit `references/team-playbook.md` with your team's conventions (naming, error handling, API design, etc.).

### Framework Guides
Add framework-specific guides in `references/framework-guides/`. Currently includes React, Laravel, Next.js.

### Security Rules
Extend `references/security-rules.md` with custom rules or company-specific policies.

## Requirements

- Claude Code with skill support
- Node.js (for `trace-data-flow.js`)
- Python 3 (for `generate-poc.py`)
- Optional: Semgrep (`pip install semgrep`) for enhanced Layer 1 scanning

## License

MIT



