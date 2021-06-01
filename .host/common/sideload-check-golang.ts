#!/usr/bin/env -S deno run --allow-write --allow-env --allow-run --allow-net --allow-read
/**
 * Checks whether version of golang is the most up to date.
 *
 * Uses golang source repo's version tags to determine this, comparing to
 * `go version` output.
 */
// TODO(jzacsh) rm '.ts' extension on this file once deno solves this:
// https://github.com/denoland/deno/issues/5088

const { openSync, args, env, exit, writeTextFileSync, readTextFileSync, lstatSync, writeTextFile, errors } = Deno;

import { exec } from 'https://deno.land/x/execute@v1.1.0/mod.ts';

const SEC_MS = 1000;
const MIN_MS = 60 * SEC_MS;
const HRS_MS = 60 * MIN_MS;
const DAY_MS = 24 * HRS_MS;

type AntiAssert = null | undefined | 0;
type Asserted<T> = T & Exclude<keyof T, AntiAssert>;
function assert<T>(subject: T | AntiAssert, msg: string): Asserted<T> {
  if (!subject) throw new Error(`assert: ${msg}`);
  return subject as Asserted<T>; // dirty but works
}

// basic tools above this line

const MAX_CACHE_AGE_MS = 7 * DAY_MS;
const DEBUGGING = false;

const EXPERIMENT_JUST_FILTER = true;

function isReadableDir(absPath: string): boolean {
  let isReadableDir = false;
  let f;
  try {
    f = openSync(absPath, {read: true});
    const stat = f.statSync();
    isReadableDir = stat.isDirectory;
  } finally {
    if (f) f.close();
  }
  return isReadableDir;
}

/**
 * Returns `content` string with the following first line removed:
 *   )]}'
 */
function stripXsrfTokens(content: string): string {
  return content.replace(new RegExp(`^\\s*\\)]}'\\s*`), '');
}

/**
 * Fetches from a URL unless we're within TTL of /var/run/user/$UID/.. cache
 * file, in which case local file is used.
 */
class RuntimeCacheUrl {
  private static readonly TTL_MS = DEBUGGING ? 2 * SEC_MS : MAX_CACHE_AGE_MS;
  private readonly cachePath: string;
  /**
   * @param url remote URL for JSON data
   * @param runtimePath file path, relative to /var/run/user/$UID/, where data
   *    should be cached.
   */
  constructor(
    private readonly url: string,
    private readonly runtimePath: string,
  ) {
    const rootDir: string = assert(env.get('XDG_RUNTIME_DIR'), `failed getting $XDG_RUNTIME_DIR`);
    assert(isReadableDir(rootDir), 'failed ensuring $XDG_RUNTIME_DIR is available');
    this.cachePath = `${rootDir}/${runtimePath}`;
  }

  /** Content of cache, or undefined if too old. */
  private async getFreshCache(): Promise<string|undefined> {
    // Fail early if the file looks old, empty, or we can't access it
    try {
      const stats = lstatSync(this.cachePath);
      if (!stats.mtime) return undefined;
      const diffMs = Date.now() - stats.mtime.getTime();
      if (stats.size <= 1 || diffMs > RuntimeCacheUrl.TTL_MS) return undefined;
    } catch (error) {
      assert(
        error instanceof errors.NotFound,
        `unexpected error reading runtime file (at ${this.cachePath}): ${error}`);
      return undefined;
    }

    try {
      return readTextFileSync(this.cachePath);
    } catch {
    }
    return undefined;
  }

  async fetch(): Promise<string> {
    const cache = await this.getFreshCache();
    if (cache !== undefined) return cache;

    if (DEBUGGING) console.log('cache stale, fetching fresh data');
    const content = await fetch(this.url).then(resp => resp.text());
    writeTextFileSync(this.cachePath, content);
    return content;
  }
}

/**
 * Fetches results from golang git repo's API, which looks something like:
 *    {
 *      "go1": {
 *        "value": "6174b5e21e73714c63061e66efdbe180e1c5491d"
 *      },
 *      "go1.0.1": {
 *        "value": "2fffba7fe19690e038314d17a117d6b87979c89f"
 *      },
 *      "go1.0.2": {
 *        "value": "cb6c6570b73a1c4d19cad94570ed277f7dae55ac"
 *      }
 *    }
 */
async function golangRefsApi(): Promise<string> {
  const tagsJsonUrl = 'https://go.googlesource.com/go/+refs/tags?format=JSON';

  return new RuntimeCacheUrl(tagsJsonUrl, `golang-update_702a271a9c9b8ca0c41cff7394613979b59853f6.txt`).fetch();
}

const comparatorALarger: ComparatorALarger = -1;
const comparatorEqual: ComparatorEqual = 0;
const comparatorBLarger: ComparatorBLarger = 1;

type ComparatorALarger = -1;
type ComparatorEqual = 0;
type ComparatorBLarger = 1;
type ComparatorResult = ComparatorALarger|ComparatorEqual|ComparatorBLarger;

function comparatorString(result: ComparatorResult): string {
  switch(result) {
    case comparatorALarger:
      return 'A larger';
    case comparatorEqual:
      return 'equal';
    case comparatorBLarger:
      return 'B larger';
  }
}

function compareNumbers(a: number, b: number): ComparatorResult {
  if (a === b) return comparatorEqual;
  return a < b ? comparatorBLarger : comparatorALarger;
}

function maybeLog(
  logLabel: string,
  a: string,
  b: string,
  result: ComparatorResult,
): ComparatorResult {
  if (DEBUGGING) {
    console.log(`[${logLabel}] comparing a="${a}" vs b="${b}" --> ${
      comparatorString(result)
    }`);
  }
  return result;
}

class SemVerPart {
  private static readonly NumericRegexp = /^(\d+)/;
  public isNumeric: boolean;
  constructor(private readonly part: string) {
    this.isNumeric = !!part.match(SemVerPart.NumericRegexp);
  }
  getNumber(): number {
    const match: string = assert(
      this.part.match(/^(\d+)/),
      `parse error: encountered semver identity "${this.part}" with no numeric component`,
    )![1];
    return Number.parseInt(match, 10 /*radix*/);
  }

  toString(): string {
    return `${this.part}[num=${this.getNumber()}]`
  }

  compare(b: SemVerPart): ComparatorResult {
    return maybeLog(
        "SemVerPart",  // logLabel
        this.toString(),
        b.toString(),
        SemVerPart.comparator(this  /*a*/, b));
  }
  static comparator(a: SemVerPart, b: SemVerPart): ComparatorResult {
    const aNum = a.getNumber();
    const bNum = b.getNumber();
    const naiveResult = compareNumbers(aNum, bNum);
    if (a.isNumeric && b.isNumeric) return naiveResult;

    if (naiveResult !== comparatorEqual) return naiveResult;
    return b.isNumeric ? comparatorBLarger : comparatorALarger;
  }
}

class SemVer {
  public readonly parse: Array<SemVerPart>;
  private static readonly SEM_VER_DELIM: string = '.';
  constructor(private readonly raw: string) {
    assert(raw.trim().length, `parsing an empty string: "${raw}"`);
    const parts: Array<string> = raw.split(SemVer.SEM_VER_DELIM);
    parts.forEach(p => assert(p.trim(), `found empty identifier "${p}"`));
    assert(parts.length, `zero parts found on version tag: "${raw}"`);
    this.parse = parts.map(p => new SemVerPart(p));
  }

  toString(): string {
    return this.raw;
  }

  compare(b: SemVer): ComparatorResult {
    return maybeLog(
        "SemVer",  // logLabel
        this.toString(),
        b.toString(),
        SemVer.comparator(this  /*a*/, b));
  }

  static comparator(a: SemVer, b: SemVer): ComparatorResult {
    for (let i = 0; i < Math.min(a.parse.length, b.parse.length); i++) {
      if (i > a.parse.length - 1 || i > b.parse.length - 1) break; // impossible

      let idResult = a.parse[i].compare(b.parse[i]);
      if (idResult === comparatorEqual) continue;
      return idResult;
    }
    if (a.parse.length === b.parse.length) return comparatorEqual;
    return a.parse.length < b.parse.length ? comparatorBLarger : comparatorALarger;
  }
}

/**
 * Super crude semver utility. Does not support 90% of the grammar of
 * any semver.org specifications.
 *
 * NOTE: golang does NOT adhere semver.org spec anyway.
 */
class SemVerReader {
  private readonly slugRegexp: RegExp;
  constructor(
    private readonly slug: string = '',
  ) {
    this.slugRegexp = new RegExp(`^${this.slug}`);
  }

  isTag(tag: string): boolean {
    if (!this.slug)
      throw new Error(`unimplemented: SemVer doesn't parse tags to check for semver.org validity`);

    return !!tag.match(this.slugRegexp);
  }

  private tagToSemver(tag: string): SemVer {
    return new SemVer(tag.replace(this.slugRegexp, ''));
  }

  comparator(aTag: string, bTag: string): ComparatorResult {
    const a = this.tagToSemver(aTag);
    const b = this.tagToSemver(bTag);
    const result = a.compare(b);
    return maybeLog(
        "SemVerReader"  /*logLabel*/,
        a.toString(),
        b.toString(),
        result);
  }
}

const GOLANG_SEMVER_READER = new SemVerReader('go');

async function golangTags(): Promise<Array<string>> {
  const resp = await stripXsrfTokens(await golangRefsApi());

  return Object.
    keys(JSON.parse(resp)).

    // Do some simple hygiene of inputs
    map(tag => tag.trim()).
    filter(tag => tag).

    // Interpret semver values as presented as git tags
    filter(tag => GOLANG_SEMVER_READER.isTag(tag));
}

/** Returns _roughly_ semver-sorted golang repository tags for main releases. */
async function golangTagsSorted(): Promise<Array<string>> {
  const tags = await golangTags();

  return tags.sort((a, b) => GOLANG_SEMVER_READER.comparator(a, b));
}

async function latestUpstreamVersion(): Promise<string> {
  return golangTagsSorted().then(tags => tags[0]);
}

async function installedVersion(): Promise<string> {
  // Expecting "go version go1.1.6.4 linux/amd64" output for `go version`
  return exec('go version').then((goline: string) => {
    const parts = assert(goline, 'expected non-empty `go version` output').split(' ');
    assert(
        parts.length === 4,
        `internal bug: 'go version' output changed from usual format; got: "${goline}"`);
    const tag = parts[2];
    assert(
      GOLANG_SEMVER_READER.isTag(tag),
      `internal bug: 'go version' output a version tag we don't understand: "${tag}"`);
    return tag;
  });
}

/// actual main logic
function settled(goodVersion: string) {
  if (DEBUGGING) console.log(`installed and upstream versions match (${goodVersion})`);
  exit(0);
}

const installedVer = await installedVersion();
if (EXPERIMENT_JUST_FILTER) {
  const tags = await golangTags();
  let newerUpstreams = tags.find(upstream => GOLANG_SEMVER_READER.comparator(installedVer, upstream) === comparatorBLarger);
  if (newerUpstreams === undefined) settled(installedVer);
  console.error(
    `golang is old - visit https://golang.org/dl - installed "${installedVer}" vs. a newer upstream: "${newerUpstreams}"`);
  exit(1);
} else {
  const latestUpstream = await latestUpstreamVersion();
  if (DEBUGGING) {
    console.log('installed version: "%s"', installedVer);
    console.log('newest upstream: "%s"', latestUpstream);
  }

  const result = GOLANG_SEMVER_READER.comparator(installedVer, latestUpstream);
  if (result === comparatorEqual) settled(installedVer);
  console.error(`golang is old: installed=${installedVer} vs. upstream=${latestUpstream}`);
  exit(1);
}
