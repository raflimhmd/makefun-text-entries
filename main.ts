// A make.fun text entry: the program writes one text to /output/entry.txt.
// Text and length cap are per-bounty; each bounty's entry is its own commit.
import { mkdirSync, writeFileSync } from 'node:fs';

const TEXT = 'I unmuted myself to sigh, and the whole call learned something about me.';
const MAX = 200;

const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';
const body = TEXT.trim();
if (body.length < 1 || body.length > MAX) {
  process.stderr.write(`entry text must be 1..${MAX} characters, got ${body.length}\n`);
  process.exit(1);
}
mkdirSync(out, { recursive: true });
writeFileSync(`${out}/entry.txt`, `${body}\n`);
