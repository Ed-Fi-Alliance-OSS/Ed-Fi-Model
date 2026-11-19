# Agent instructions for Ed-Fi-Model

This repo is **MetaEd source** for the Ed-Fi Data Standard. Most changes are edits to `package/**/*.metaed`, then validating by generating artifacts with `@edfi/metaed-console`.

## Build / validation commands

### Install

```powershell
npm ci
# or
npm install
```

Notes:
- `.npmrc` points the `@edfi` scope at an Azure Artifacts npm feed. If `npm ci` fails with auth/registry errors, fix npm feed credentials first.

### Generate artifacts (primary validation)

```powershell
npm start
```

What this does:
- Runs `cross-env NODE_NO_WARNINGS=1 LOG_LEVEL=error node --no-deprecation node_modules/@edfi/metaed-console/dist/index.js -c ./config.json -a` (see `scripts.start` in the root `package.json`)
- Loads MetaEd projects from `config.json` (`projectPaths: ["package"]`)
- Writes generated artifacts under: `package\MetaEdOutput\`

CLI help (when you need to confirm supported flags):

```powershell
node node_modules/@edfi/metaed-console/dist/index.js --help
```

Output format:
- `npm start` logs are **JSON lines** (one JSON object per line). Treat any `{"level":"error"...}` lines as build failures.

### Optional validations (used in CI/eng scripts)

Validate generated XSDs compile:

```powershell
pwsh -File .\eng\ValidateSchema.ps1 -Workspace "$PWD\package"
```

Validate generated SQL scripts against a local SQL Server instance (requires `sqlcmd` + a local SQL Server; uses `sa` login):

```powershell
pwsh -File .\eng\ValidateSQL.ps1 -Workspace "$PWD\package" -Password "<sa-password>"
```

## High-level architecture

- **Source of truth**: `package/**/*.metaed` files (Domain Entities, Associations, Commons, Descriptors, Choices, Enumerations, Shared types, etc.).
- **Build driver**: root `npm start` runs `@edfi/metaed-console` using `config.json`.
- **Generated artifacts**: `package/MetaEdOutput/` (XSDs, SQL, API schema artifacts, handbook/dictionaries, etc.). Treat this as build output; changes typically belong in `.metaed` inputs.
- **Versioning metadata**: `package/package.json` contains `metaEdProject.projectVersion` for the model package; root `config.json` declares the Ed-Fi project(s) compiled.
- **Automation/CI**: `.github/workflows/*` runs MetaEd generation for data standard artifacts and publishing. `eng/*.ps1` contains validation and support scripts (schema/SQL validation, XSD management).

## Key repo conventions (MetaEd authoring)

### MetaEd grammar constraints are required

Most property blocks must include a constraint line; leaving it out causes MetaEd parse errors.
Common constraint statements you’ll see:
- `is required`
- `is optional`
- `is optional collection` / `is required collection`
- `is part of identity`
- `is queryable field` / `is queryable only`

### Common patterns you’ll encounter

- `Common`, `Inline Common ...`, and `inline common ...` are used to compose reusable structures under `package\Common`.
- `descriptor ...` properties commonly participate in identity (`is part of identity`) and may use `role name` to disambiguate multiple descriptors of the same type.
- `shared string ...` is used for reused scalar concepts; `named` is used when a type needs a specific name (e.g., `shared string URI named ImageURL`).
- `allow primary key updates` appears on Associations that permit primary key (identity) mutation.

### Keep validation tight

Because this repo’s “tests” are essentially the artifact generator, the safest loop is:
1. Make a small `.metaed` change
2. Run `npm start`
3. Fix any JSON-line `error` messages and re-run

Agent hooks run this build automatically, so keeping `npm start` clean avoids tool friction:
- **Claude Code**: `.claude/hooks/metaed-build.js` runs after each `.metaed` edit and reports errors immediately.
- **GitHub Copilot** (CLI / coding agent): `.github/hooks/metaed-build.json` notes `.metaed` edits and runs the build once when the agent is about to finish; it keeps the agent working until errors are fixed (up to three attempts).

## After editing

Run the `review-model-pr` skill (`/review-model-pr`) to review your MetaEd changes against the Ed-Fi-Model checklist. The skill lives in `.claude/skills/review-model-pr/`, which both Claude Code and GitHub Copilot load as a project skill.
