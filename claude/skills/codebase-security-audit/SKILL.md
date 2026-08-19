---
name: codebase-security-audit
description: >
  Use when performing a security audit, vulnerability hunt, or code review of a codebase.
  Use when asked to find bugs, security issues, or vulnerabilities across multiple files.
  Use when triaging findings by severity, constructing reproducers, or cross-checking upstream.
  Covers Rust, C/C++, Go, and other systems languages. Works on any codebase size.
---

# Codebase Security Audit

## Overview

A four-phase methodology for systematic vulnerability hunting in codebases. Produces ranked, reproducible findings with severity, trust-boundary analysis, and upstream cross-checks.

**Core principle:** Breadth first (find all instances of known bug classes), then depth (per-function audit of high-value surfaces), then tooling (static analysis + fuzzing), then differential review (recent commits).

## When to Use

- User asks for a security audit, vulnerability hunt, or penetration test of source code
- User asks to find bugs, panics, UB, or memory safety issues across a codebase
- User provides a list of known vulnerability patterns and asks to extrapolate
- User wants to assess the security posture of a project before release

**When NOT to use:**
- Single-file code review (use `pr-review-toolkit:code-reviewer` instead)
- Reviewing a specific PR diff (use `differential-review:diff-review`)
- Running a specific static analysis tool (use `static-analysis:semgrep` or `static-analysis:codeql`)

## Phase Overview

```
Phase A: Pattern Sweep (breadth) ─── find all instances of known bug classes
    ↓
Phase B: Deep Dives (depth) ─────── per-function audit of ranked surfaces
    ↓
Phase C: Tooling (automation) ───── static analysis + fuzz harness gaps
    ↓
Phase D: Diff Review (recency) ──── recent commits for regressions
```

## Phase A — Pattern Sweep

Enumerate every instance of validated bug classes across the repo. Use Grep/ripgrep sweeps. Do NOT validate yet — produce a raw candidate list.

**Universal bug classes to sweep for:**

| Class | Grep pattern (adapt per language) | Severity heuristic |
|-------|----------------------------------|-------------------|
| Panic on untrusted input | `assert!\|panic!\|unwrap()\|expect(` | HIGH if input is external |
| Untrusted-length slicing | `\[.*\.\..*\]\|as usize` | HIGH if length from network/guest/user |
| Path traversal | `strip_prefix\|canonicalize\|PathBuf::from` | MEDIUM+ if path from API/config |
| Arithmetic overflow | `unchecked_\|checked_.*unwrap\|as (u8\|u16\|u32)` | Varies by reachability |
| Command injection | `Command::new\|exec\|system\|popen` | HIGH if args from user input |
| Supply chain | `branch\s*=\|Command::new.*git` in build scripts | LOW unless build env untrusted |

**Exit criterion:** For every candidate, annotate as "not reachable" (skip) or "promote to Phase B" (deep dive).

## Phase B — Deep Dives

Rank surfaces by `churn x pattern-density x trust-boundary`. Use `audit-context-building:function-analyzer` subagents for per-function analysis. Launch up to 4 in parallel.

**Per-function audit template:**

```
Function: name (file:line)
Input origin: [user/guest/network/config/firmware/internal]
Trust boundary: [which boundary is crossed]
Defensive checks: [present or missing]
Potential issues: [panics, UB, logic bugs]
Reproducer sketch: [if exploitable]
```

**Prioritize by threat model:**
1. Untrusted external input (network, guest, user) → anything reachable is HIGH
2. Semi-trusted input (config, migration peer, API) → file access or crash is MEDIUM+
3. Trusted input (kernel, internal) → defensive gaps are LOW/INFO

## Phase C — Tooling

Run in parallel with Phase B.

| Tool | Skill to invoke | When to use |
|------|----------------|-------------|
| Semgrep | `static-analysis:semgrep` | Broad sweep with community rules |
| Custom Semgrep rules | `semgrep-rule-creator:semgrep-rule` | Target Phase A patterns not caught by community rules |
| CodeQL | `static-analysis:codeql` | Dataflow/taint tracking (if installed) |
| cargo audit / npm audit | Direct CLI | Dependency vulnerability check |
| Fuzz coverage gaps | `testing-handbook-skills:coverage-analysis` | Identify untested surfaces |
| Fuzz harness writing | `testing-handbook-skills:harness-writing` | Write harnesses for missing coverage |

**Fuzz harness priority:** Write harnesses for surfaces that directly exercise known HIGH findings. A harness that triggers a known bug in seconds validates the finding and provides a regression test.

## Phase D — Differential Review

Review recent commits (e.g., last 90 days) for regressions and new attack surface.

```bash
# Git
git log --oneline --since="90 days ago" -- <critical-paths>

# Jujutsu
jj log -r 'ancestors(trunk()) & committer_date(after:"YYYY-MM-DD")'
```

Use `differential-review:diff-review` on commits touching Phase A pattern neighborhoods or security-sensitive features.

## Verification Protocol

For every candidate finding at MEDIUM or above:

1. **Re-read source at HEAD** — line numbers drift; confirm the code is as described
2. **Confirm trust boundary** — trace the input from its origin to the sink
3. **Construct reproducer** — inline asm, API JSON body, crafted file bytes, or config stanza. If no reproducer is constructible, cap severity at MEDIUM.
4. **Cross-check upstream:**
   ```bash
   gh api repos/OWNER/REPO/security-advisories
   gh search issues --repo OWNER/REPO "keyword1 keyword2" --limit 5
   gh search prs --repo OWNER/REPO "keyword" --limit 5
   git log --all --oneline --grep="keyword" -- path/to/file
   ```
5. **Classify for disclosure** — novel HIGHs with RCE/escape potential warrant responsible disclosure before public mention

## Findings Template

```markdown
### ID — Title — **SEVERITY**

\`\`\`language
// file:line
code snippet showing the bug
\`\`\`

**Input origin:** [source of untrusted data]
**Trust boundary:** [which boundary is crossed]
**Defensive checks present:** [what exists]
**Defensive checks missing:** [what's absent]

**Reproducer:** [concrete steps or code]

**Impact:** [what an attacker achieves]
**Gating:** [feature flags, config, or conditions that limit reach]

**Fix direction:** [suggested remediation]
```

## Severity Calibration

| Severity | Criteria |
|----------|----------|
| **HIGH** | Reachable from untrusted input on default builds. Crash, UB, memory safety, or arbitrary file access. |
| **MEDIUM** | Reachable but feature-gated, requires semi-trusted input, or produces DoS (not escape). |
| **LOW** | Defensive gap not currently reachable, or requires trusted/pathological input. |
| **INFO** | Code smell, missing defense-in-depth, or correctness issue without security impact. |

**Architecture matters:** In 1:1 process-per-unit architectures (e.g., one VMM per VM, one worker per request), a crash kills only that unit. Adjust impact accordingly.

## Common Mistakes

- **Re-reporting known issues.** Always read existing findings/advisories before starting.
- **Trusting line numbers from earlier passes.** Code changes between phases — re-read at HEAD.
- **Calling everything HIGH.** If the input is kernel-trust or admin-only, it's not HIGH unless the threat model says otherwise.
- **Skipping the reproducer.** A finding without a reproducer is a hypothesis. Construct one or downgrade severity.
- **Ignoring feature gates.** A bug behind `#[cfg(feature = "foo")]` where `foo` is off by default is lower severity than the same bug on default builds.
