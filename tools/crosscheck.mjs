// Cross-check: each of the 135 rates of R/rates.R (and, with --dump, of the file written by
// tools/dump.R from the installed package) compared field by field with the Go package
// rates.go, plus the 5 source texts. Exit 0 only with 135/135 and 5/5.
// Usage: node tools/crosscheck.mjs [--dump path.tsv] [path/to/macalc-go/baremekm]
import { readFileSync } from "node:fs";
import { DEFAULT_GO, DEST, canon, parse } from "./gen_data.mjs";

const args = process.argv.slice(2);
const d = args.indexOf("--dump");
const dump = d >= 0 ? args.splice(d, 2)[1] : null;
const go = parse(args[0] || DEFAULT_GO);
const expected = go.rates.map(canon);
const num = (s) => (/^[+]?inf(inity)?$/i.test(s) ? Infinity : Number(s));

// R/rates.R read as is (not regenerated): one column per line, c(...).
const rsrc = readFileSync(DEST, "utf-8");
const cols = {};
for (const l of rsrc.split("\n")) {
  const m = l.match(/^\s+(\w+) = c\((.*)\),$/);
  if (m) cols[m[1]] = m[2].split(", ").map((t) => (t.startsWith('"') ? JSON.parse(t) : num(t.replace(/L$/, ""))));
}
const COLS = ["year", "vehicle", "class", "min_km", "max_km", "coef", "constant"];
const rdata = {
  rates: (cols.year || []).map((_, i) => COLS.map((k) => cols[k]?.[i])),
  sources: [...rsrc.matchAll(/^\s+"(\d{4})" = ("(?:[^"\\]|\\.)*"),?$/gm)].map((m) => ({ year: Number(m[1]), text: JSON.parse(m[2]) })),
};

function compare(name, got) {
  const diffs = [];
  let ok = 0;
  for (let i = 0; i < Math.max(expected.length, got.rates.length); i++) {
    const a = expected[i], b = got.rates[i];
    if (a && b && a.length === b.length && a.every((x, j) => x === b[j])) ok++;
    else diffs.push(`${name} rate ${i + 1}: go=${JSON.stringify(a)} got=${JSON.stringify(b)}`);
  }
  let src = 0;
  for (let i = 0; i < Math.max(go.sources.length, got.sources.length); i++) {
    const a = go.sources[i], b = got.sources[i];
    if (a && b && a.year === b.year && a.text === b.text) src++;
    else diffs.push(`${name} source ${i}: go=${JSON.stringify(a)} got=${JSON.stringify(b)}`);
  }
  console.log(`${name}: ${ok}/${expected.length} rates match rates.go, sources ${src}/${go.sources.length}, diff=${diffs.length}`);
  diffs.slice(0, 10).forEach((x) => console.log("  " + x));
  return diffs.length + (ok === 135 ? 0 : 1);
}

let total = compare("R/rates.R", rdata);
if (dump) {
  const lines = readFileSync(dump, "utf-8").split(/\r?\n/).filter(Boolean).map((l) => l.split("\t"));
  total += compare("R installed dump", {
    rates: lines.filter((f) => f[0] === "rate").map((f) => [Number(f[1]), f[2], f[3], ...f.slice(4).map(num)]),
    sources: lines.filter((f) => f[0] === "source").map((f) => ({ year: Number(f[1]), text: f[2] })),
  });
}
process.exit(total === 0 ? 0 : 1);
