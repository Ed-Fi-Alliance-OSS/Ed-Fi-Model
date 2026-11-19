# CLAUDE.md

Guidance for Claude Code in this repository. Shared agent instructions live in `AGENTS.md` at the repo root (the single source of truth), imported here:

@../AGENTS.md

## Claude Code-specific notes

- **Auto-build hook**: a PostToolUse hook (`.claude/settings.json` -> `.claude/hooks/metaed-build.js`) runs `npm start` after edits to `.metaed` files and reports any `"level":"error"` lines back as build errors. Fix those before moving on.
- **Review skill**: after editing, run the `review-model-pr` skill (`/review-model-pr`) to review your MetaEd changes against the Ed-Fi-Model checklist.
