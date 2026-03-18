# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

MetaEd source for the Ed-Fi Data Standard. Changes are almost always edits to `package/**/*.metaed` files, validated by generating artifacts with `@edfi/metaed-console`.

## Build / validation

### Install

```bash
npm ci
```

`.npmrc` points the `@edfi` scope at an Azure Artifacts npm feed. If this fails with auth/registry errors, fix npm feed credentials first.

### Generate artifacts (primary validation)

```bash
npm start
```

This runs `@edfi/metaed-console` with `config.json`, loading MetaEd projects from `package/` and writing artifacts to `package/MetaEdOutput/`.

Logs are **JSON lines** — treat any `{"level":"error"...}` lines as build failures.

### Optional validations

```powershell
# Validate generated XSDs compile
pwsh -File .\eng\ValidateSchema.ps1 -Workspace "$PWD\package"

# Validate generated SQL against a local SQL Server (requires sqlcmd + sa login)
pwsh -File .\eng\ValidateSQL.ps1 -Workspace "$PWD\package" -Password "<sa-password>"
```

### After editing

Run the `review-model-pr` skill (`/review-model-pr`) to get a review of your MetaEd changes.

## Architecture

- **Source of truth**: `package/**/*.metaed` — Domain Entities, Associations, Commons, Descriptors, Choices, Enumerations, Shared types, etc.
- **Generated artifacts**: `package/MetaEdOutput/` — XSDs, SQL, API schema artifacts, handbook/dictionaries. Treat as build output; don't edit directly.
- **Build config**: root `config.json` declares the Ed-Fi project namespace/version; `package/package.json` contains `metaEdProject.projectVersion`.
- **CI**: `.github/workflows/` runs MetaEd generation and publishing; `eng/*.ps1` holds schema/SQL validation scripts.

## MetaEd authoring conventions

### Every property block needs a constraint

Omitting the constraint causes a parse error. Common constraints:

```
is required
is optional
is optional collection
is required collection
is part of identity
is queryable field
is queryable only
```

### Common patterns

- `Inline Common` / `inline common` — composes reusable structures from `package/Common/`
- `descriptor` properties often use `is part of identity` and may use `role name` to disambiguate multiple descriptors of the same type
- `shared string URI named ImageURL` — `named` gives a specific name to a shared scalar type
- `allow primary key updates` — appears on Associations that permit PK mutation

### Validation loop

1. Edit a `.metaed` file
2. Run `npm start`
3. Fix any `"level":"error"` lines and re-run

A Claude Code hook automatically runs `npm start` after file edits in this repo.
