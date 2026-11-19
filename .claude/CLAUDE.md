# CLAUDE.md

Guidance for Claude Code in this repository. Shared agent instructions live in `AGENTS.md` at the repo root (the single source of truth), imported here:

@../AGENTS.md

## Claude Code-specific notes

- **Auto-build hook**: a PostToolUse hook (`.claude/settings.json` -> `.claude/hooks/metaed-build.js`) runs `npm start` after edits to `.metaed` files and reports any `"level":"error"` lines back as build errors. Fix those before moving on.
- **Copilot parity**: `.github/hooks/metaed-build.js` is the GitHub Copilot copy of this hook. When you change one, update the other.
