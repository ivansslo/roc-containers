# 🚀 roc-ai orchestrator — First-Class Autonomous Mode

**roc-ai orchestrator <task>**  delegates to the patched Hermes (`roc-agent orchestrator`) for full autonomous multi-agent orchestration.

## Features (from patched hermes)
- Full model support check (all providers + gemini-2.5-flash for AIS-DEV)
- Auto import of roc-agentsroute agent into AI Studio / AIS-DEV
- Autonomous Orchestrator agent mode: Planner → Researcher → Coder → Reviewer → Tester + Grounding loop
- Support for coding, fast response, high thinking, grounding, etc.
- AIS_DEV as first-class provider (gemini-2.5-flash)
- Uses existing TOKEN auth flow

## Usage
```bash
roc-ai orchestrator "Build a multi-tenant SaaS dashboard using Next.js + Firebase + Gateway routing"
roc-ai orchestrator "Create autonomous agent mesh for research + code + test loop"
```

## Import to AI Studio / AIS-DEV
```bash
roc-agent import "My Orchestrator Agent"
# or
hermes import "My Orchestrator Agent"
# Paste the exported JSON directly into https://ais-dev-4kbznhxyc5wsr5c6oxw6zz-70765440683.asia-east1.run.app or aistudio.google.com
```

## Related
- `roc-agent` → hermes binary (patched)
- `roc-ai` → wraps + exposes orchestrator
- rocspace + gateway + ais-dev first-class

See full ecosystem docs in rocspace/HANDOFF.md
