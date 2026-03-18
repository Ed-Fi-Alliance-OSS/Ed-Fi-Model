import { execSync } from 'child_process';

let output = '';

try {
  output = execSync('npm start', {
    encoding: 'utf8',
    cwd: process.env.CLAUDE_PROJECT_DIR || process.cwd(),
    stdio: ['pipe', 'pipe', 'pipe'],
  });
} catch (err) {
  output = (err.stdout || '') + (err.stderr || '');
}

const errors = output
  .split('\n')
  .filter((line) => line.trim().startsWith('{'))
  .map((line) => {
    try {
      const parsed = JSON.parse(line);
      if (parsed.level === 'error') return parsed.message;
    } catch {
      // not JSON
    }
    return null;
  })
  .filter(Boolean);

if (errors.length > 0) {
  console.log(
    JSON.stringify({
      decision: 'block',
      reason: 'MetaEd build errors:\n' + errors.join('\n'),
    })
  );
}

process.exit(0);
