// GitHub Copilot agent hook: validate .metaed edits with the MetaEd build.
// Copilot counterpart of .claude/hooks/metaed-build.js; registered in
// .github/hooks/metaed-build.json.
//
// Copilot ignores postToolUse hook output, so a build error cannot be fed back
// right after an edit (as the Claude hook does). Instead:
//   post-tool-use  records that a .metaed file was edited in this session.
//   agent-stop     runs `npm start` once, before the agent finishes, and
//                  returns {"decision":"block","reason":...} so the agent keeps
//                  working and fixes the reported errors.
import { spawnSync } from 'child_process';
import { existsSync, readFileSync, rmSync, writeFileSync } from 'fs';
import { tmpdir } from 'os';
import { join } from 'path';

const mode = process.argv[2];
// Stop blocking after this many build failures in one session, so an agent
// that cannot fix the model is not trapped in an endless loop.
const MAX_BLOCKS = 3;
const EDIT_TOOLS = new Set(['edit', 'create', 'str_replace_editor', 'str_replace', 'insert', 'write', 'apply_patch']);

const cwd = process.cwd(); // the hook config sets cwd to the repo root
// Test seam: override the build command (e.g. a stub that prints JSON log lines).
const buildCmd = process.env.METAED_HOOK_BUILD_CMD || 'npm start';

function readInput() {
  try {
    return process.stdin.isTTY ? {} : JSON.parse(readFileSync(0, 'utf8'));
  } catch {
    return {};
  }
}

const input = readInput();
const sessionId = String(input.sessionId || 'unknown').replace(/[^\w.-]/g, '_');
const markerPath = join(tmpdir(), `edfi-metaed-hook-${sessionId}.json`);

function readMarker() {
  try {
    return JSON.parse(readFileSync(markerPath, 'utf8'));
  } catch {
    return null;
  }
}

function block(reason, marker) {
  const blocks = (marker.blocks || 0) + 1;
  if (blocks >= MAX_BLOCKS) {
    rmSync(markerPath, { force: true });
    reason += `\n(Reported ${blocks} times; the hook will not block again this session. Tell the user the model does not build.)`;
  } else {
    writeFileSync(markerPath, JSON.stringify({ ...marker, blocks }));
  }
  console.log(JSON.stringify({ decision: 'block', reason }));
  process.exit(0);
}

function tail(text, lines = 15) {
  return text.trim().split('\n').slice(-lines).join('\n');
}

if (mode === 'post-tool-use') {
  // toolArgs is a JSON string (or, defensively, an object). Matching on the
  // raw text also covers apply_patch, whose file paths live inside the patch.
  const args = typeof input.toolArgs === 'string' ? input.toolArgs : JSON.stringify(input.toolArgs ?? '');
  if (EDIT_TOOLS.has(input.toolName) && /\.metaed\b/i.test(args) && !readMarker()) {
    writeFileSync(markerPath, JSON.stringify({ blocks: 0 }));
  }
  process.exit(0);
}

if (mode !== 'agent-stop') {
  console.error(`metaed-build.js: unknown mode "${mode}" (expected post-tool-use or agent-stop)`);
  process.exit(0);
}

const marker = readMarker();
if (!marker) process.exit(0); // no .metaed edits this session

if (!process.env.METAED_HOOK_BUILD_CMD && !existsSync(join(cwd, 'node_modules', '@edfi', 'metaed-console'))) {
  // Report once; the agent cannot install the package itself, so don't loop.
  rmSync(markerPath, { force: true });
  console.log(
    JSON.stringify({
      decision: 'block',
      reason:
        'MetaEd build did not run — validation unavailable. node_modules/@edfi/metaed-console is not installed ' +
        '(`npm ci` requires access to the Ed-Fi Azure Artifacts npm feed). Tell the user your .metaed changes were not validated.',
    })
  );
  process.exit(0);
}

const result = spawnSync(buildCmd, { cwd, shell: true, encoding: 'utf8', timeout: 115_000 });
const output = (result.stdout || '') + (result.stderr || '');

// `npm start` sets LOG_LEVEL=error, so a clean build may print no JSON lines;
// failure is detected from "level":"error" lines and the exit code.
const errors = output
  .split('\n')
  .filter((line) => line.trim().startsWith('{'))
  .map((line) => {
    try {
      const parsed = JSON.parse(line);
      return parsed.level === 'error' ? parsed.message : null;
    } catch {
      return null;
    }
  })
  .filter(Boolean);

if (errors.length > 0) {
  block('MetaEd build errors — fix these before finishing:\n' + errors.join('\n'), marker);
}

if (result.error || result.status !== 0) {
  const why = result.error ? result.error.message : result.signal ? `killed by ${result.signal}` : `exit code ${result.status}`;
  block(`MetaEd build failed: \`${buildCmd}\` ${why}. Output tail:\n${tail(output) || '(no output)'}`, marker);
}

rmSync(markerPath, { force: true }); // clean build
process.exit(0);
