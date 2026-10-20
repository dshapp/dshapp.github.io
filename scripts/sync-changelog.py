#!/usr/bin/env python3
"""把各模块已发布的版本同步进 data/changelog/<模块>.yaml，供 /whatsnew/ 页面使用。

由 .github/workflows/changelog-sync.yml 定时（以及发版后）调用，发现变化就提交并重新部署站点。
做两件事，都只做文本级修改，不会重排或改写人工整理的条目：

1. 状态对齐：标记为 upcoming 的条目，一旦该版本（或更新的版本）已经发布，就改成 released，
   日期改成真实的发布日期（北京时间）。
2. 补齐新版本：比文件里最新的已发布条目更新、且尚未记录的已发布版本，按两个版本之间的提交生成条目，
   只取 feat / fix / perf 类提交（对应 新增 / 修复 / 改进）；没有用户可感知变化的版本跳过。
   配置了 DEEPSEEK_API_KEY 时由模型把提交改写成面向用户的中英文案，否则直接用提交标题。
   生成的条目带 generated: true，人工润色后可删掉这一行。

「已发布」的判定：
    mac / android      本仓库的 Release mac-v<版本> / android-v<版本>（build-apps.yml 创建），
                       正文里的 source-sha 指向源码提交
    chrome             dsh-chrome-extension 的标签 v<版本>-build.<N>，同一版本以第一次构建为发布时间
    browser / bridge / cu   对应仓库的标签 v<版本>（发版流水线同时发布 npm 与 GitHub Release）

环境变量：
    GH_TOKEN / GITHUB_TOKEN        读取本仓库 Releases
    APP_SOURCE_TOKEN               读取私有仓库 dsh-macapp / dsh-androidapp
    CHROME_EXTENSION_DEPLOY_KEY    dsh-chrome-extension 的只读 deploy key（SSH 私钥）
    DEEPSEEK_API_KEY               可选，用模型改写生成的条目；DEEPSEEK_MODEL 默认 deepseek-chat
    LOCAL_SOURCES                  本地调试：直接用这个目录下已有的各仓库 checkout，不再克隆

本地预览（只打印将要做的修改）：
    GH_TOKEN=$(gh auth token -h github.com) LOCAL_SOURCES=~/dshapp python3 scripts/sync-changelog.py --dry-run
"""
from __future__ import annotations

import difflib
import json
import os
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from datetime import datetime, timedelta, timezone

ROOT = pathlib.Path(__file__).resolve().parent.parent
CHANGELOG_DIR = ROOT / "data" / "changelog"
SITE_REPO = os.environ.get("SITE_REPO", "dshapp/dshapp.github.io")
CST = timezone(timedelta(hours=8))
MAX_CHANGES = 6
SEMVER = re.compile(r"^\d+\.\d+\.\d+$")

MODULES: dict[str, dict] = {
    "mac": {"kind": "site-release", "prefix": "mac-v", "source": "dshapp/dsh-macapp",
            "token_env": "APP_SOURCE_TOKEN", "name": ("macOS App", "macOS App")},
    "android": {"kind": "site-release", "prefix": "android-v", "source": "dshapp/dsh-androidapp",
                "token_env": "APP_SOURCE_TOKEN", "name": ("Android App", "Android App")},
    "chrome": {"kind": "tag", "tag": r"^v(\d+\.\d+\.\d+)-build\.\d+$", "source": "dshapp/dsh-chrome-extension",
               "ssh_key_env": "CHROME_EXTENSION_DEPLOY_KEY", "name": ("Chrome 扩展", "Chrome extension")},
    "browser": {"kind": "tag", "tag": r"^v(\d+\.\d+\.\d+)$", "source": "dshapp/dsh-chrome-control",
                "name": ("浏览器控制", "Browser control")},
    "bridge": {"kind": "tag", "tag": r"^v(\d+\.\d+\.\d+)$", "source": "dshapp/dsh-mobile-bridge",
               "name": ("远程连接", "Remote access")},
    "cu": {"kind": "tag", "tag": r"^v(\d+\.\d+\.\d+)$", "source": "dshapp/dsh-kimi-computer-use",
           "name": ("电脑操作", "Computer use")},
}

ENTRY_RE = re.compile(r'^  - version:\s*"?([^"\s]+)"?\s*$', re.M)
STATUS_RE = re.compile(r"^    status:\s*(\w+)\s*$", re.M)
DATE_RE = re.compile(r'^    date:\s*"?([\d-]+)"?\s*$', re.M)
COMMIT_RE = re.compile(r"^(?P<type>[A-Za-z]+)(?:\([^)]*\))?!?:\s*(?P<text>.+)$")
COMMIT_TYPES = {"feat": "new", "fix": "fixed", "perf": "improved"}
# 肯定与用户无关的提交；其余非 feat/fix/perf 的提交（chore(brand) 换图标之类）只交给模型判断
INTERNAL_TYPES = {"test", "tests", "ci", "build", "docs", "release"}
TYPE_ORDER = {"new": 0, "improved": 1, "fixed": 2}
CJK = re.compile(r"[\u3400-\u9fff]")

summary: list[str] = []


def warn(msg: str) -> None:
    print(f"::warning::{msg}", file=sys.stderr)
    summary.append(f"- ⚠️ {msg}")


def note(msg: str) -> None:
    print(msg)
    summary.append(f"- {msg}")


def vkey(v: str) -> tuple[int, ...]:
    return tuple(int(x) for x in v.split("."))


def day(ts: float) -> str:
    return datetime.fromtimestamp(ts, CST).strftime("%Y-%m-%d")


def git(repo: pathlib.Path, *args: str) -> str:
    return subprocess.run(["git", "-C", str(repo), *args], check=True, capture_output=True, text=True).stdout


# ---------------------------------------------------------------- 已发布版本

def github_api(url: str) -> object:
    req = urllib.request.Request(url, headers={"Accept": "application/vnd.github+json", "User-Agent": "dsh-site"})
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)


_site_releases: list[dict] | None = None


def site_releases(prefix: str) -> dict[str, dict]:
    global _site_releases
    if _site_releases is None:
        _site_releases = []
        for page in range(1, 11):
            batch = github_api(f"https://api.github.com/repos/{SITE_REPO}/releases?per_page=100&page={page}")
            _site_releases += batch
            if len(batch) < 100:
                break
    rels: dict[str, dict] = {}
    for r in _site_releases:
        tag = r.get("tag_name") or ""
        if r.get("draft") or r.get("prerelease") or not tag.startswith(prefix):
            continue
        v = tag[len(prefix):]
        if not SEMVER.match(v):
            continue
        ts = datetime.fromisoformat((r.get("published_at") or r["created_at"]).replace("Z", "+00:00")).timestamp()
        m = re.search(r"source-sha:\s*([0-9a-f]{40})", r.get("body") or "")
        if v not in rels or ts < rels[v]["time"]:
            rels[v] = {"time": ts, "sha": m.group(1) if m else None}
    return rels


def tag_releases(repo: pathlib.Path, pattern: str) -> dict[str, dict]:
    out = git(repo, "for-each-ref", "refs/tags",
              "--format=%(refname:short)%09%(objectname)%09%(*objectname)%09%(creatordate:unix)")
    rels: dict[str, dict] = {}
    for line in out.splitlines():
        tag, obj, deref, ts = line.split("\t")
        m = re.match(pattern, tag)
        if not m:
            continue
        v, sha, t = m.group(1), deref or obj, int(ts)
        r = rels.setdefault(v, {"time": t, "last": t, "sha": sha})
        r["time"] = min(r["time"], t)          # 第一次构建 = 发布时间
        if t >= r["last"]:                      # 最后一次构建 = 这个版本包含的最新提交
            r["last"], r["sha"] = t, sha
    return rels


# ---------------------------------------------------------------- 源码仓库

def open_source(key: str, spec: dict, workdir: pathlib.Path) -> pathlib.Path | None:
    repo = spec["source"]
    short = repo.split("/")[1]
    local = os.environ.get("LOCAL_SOURCES")
    if local:
        d = pathlib.Path(local).expanduser() / short
        if (d / ".git").exists():
            r = subprocess.run(["git", "-C", str(d), "fetch", "--quiet", "--tags", "origin"], capture_output=True, text=True)
            if r.returncode:
                warn(f"{key}: 更新本地 {short} 的标签失败，使用已有数据")
            return d

    env = {**os.environ, "GIT_TERMINAL_PROMPT": "0"}
    secret = ""
    if spec.get("ssh_key_env") and os.environ.get(spec["ssh_key_env"]):
        key_file = workdir / f"{short}.key"
        key_file.write_text(os.environ[spec["ssh_key_env"]].strip() + "\n")
        key_file.chmod(0o600)
        env["GIT_SSH_COMMAND"] = f"ssh -i {key_file} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
        url = f"git@github.com:{repo}.git"
    elif spec.get("token_env") and os.environ.get(spec["token_env"]):
        secret = os.environ[spec["token_env"]]
        url = f"https://x-access-token:{secret}@github.com/{repo}.git"
    elif spec.get("ssh_key_env") or spec.get("token_env"):
        warn(f"{key}: 未配置 {spec.get('ssh_key_env') or spec.get('token_env')}，无法读取私有仓库 {repo}")
        return None
    else:
        url = f"https://github.com/{repo}.git"

    dest = workdir / short
    r = subprocess.run(["git", "clone", "--quiet", "--bare", "--filter=blob:none", url, str(dest)],
                       capture_output=True, text=True, env=env, timeout=600)
    if r.returncode:
        err = (r.stderr.strip().splitlines() or ["exit %d" % r.returncode])[-1]
        warn(f"{key}: 克隆 {repo} 失败：{err.replace(secret, '***') if secret else err}")
        return None
    return dest


def commits_between(repo: pathlib.Path, start: str, end: str) -> list[tuple[str, str]]:
    out = git(repo, "log", "--no-merges", "--format=%s%x1f%b%x1e", f"{start}..{end}")
    result = []
    for rec in out.split("\x1e"):
        if rec.strip():
            subject, _, body = rec.strip("\n").partition("\x1f")
            result.append((subject.strip(), body.strip()))
    return result


def classify(commits: list[tuple[str, str]]) -> list[dict]:
    """feat/fix/perf 带上对应 type；其他可能与用户有关的提交 type 为 other，只给模型参考。"""
    items = []
    for subject, body in commits:
        m = COMMIT_RE.match(subject)
        if not m or "[skip ci]" in subject or re.match(r"^chore\(release\)", subject):
            continue
        kind = m["type"].lower()
        if kind in INTERNAL_TYPES:
            continue
        items.append({"type": COMMIT_TYPES.get(kind, "other"), "text": m["text"].strip(), "body": body[:600]})
    return items


# ---------------------------------------------------------------- 生成条目

def sentence(text: str, zh: bool) -> str:
    text = text.strip().rstrip("。.;；")
    if not zh and text[:1].islower():
        text = text[0].upper() + text[1:]
    return text + ("。" if zh else ".")


def fallback_entry(items: list[dict]) -> dict:
    items = sorted((c for c in items if c["type"] in TYPE_ORDER), key=lambda c: TYPE_ORDER[c["type"]])[:MAX_CHANGES]
    changes = []
    for c in items:
        if CJK.search(c["text"]):
            changes.append({"type": c["type"], "zh": sentence(c["text"], True)})
        else:
            changes.append({"type": c["type"], "zh": sentence(c["text"], False), "en": sentence(c["text"], False)})
    # 只有一条变化且第一句足够短时直接用它当标题，否则按变化类型给一个通用标题，避免截断半句话
    head = re.split(r"[，,；;：:。]", items[0]["text"])[0].strip()
    kinds = {c["type"] for c in items}
    if len(items) == 1 and len(head) <= (24 if CJK.search(head) else 60):
        title = {"zh": head} if CJK.search(head) else {"zh": head[0].upper() + head[1:], "en": head[0].upper() + head[1:]}
    elif "new" in kinds:
        title = {"zh": "新功能与改进", "en": "New features"} if kinds == {"new"} else {"zh": "新功能与问题修复", "en": "New features and fixes"}
    elif kinds == {"fixed"}:
        title = {"zh": "问题修复", "en": "Bug fixes"}
    else:
        title = {"zh": "体验改进与问题修复", "en": "Improvements and fixes"}
    return {"title": title, "changes": changes}


def llm_entry(spec: dict, version: str, items: list[dict], examples: str) -> dict | None:
    key = os.environ.get("DEEPSEEK_API_KEY")
    if not key:
        return None
    commits = "\n".join(
        f"- [{c['type']}] {c['text']}" + (f"\n  {c['body'][:400].replace(chr(10), ' ')}" if c["body"] else "") for c in items
    )
    prompt = f"""你在为 DSH 产品站的「更新日志」页写一个版本条目。模块：{spec['name'][0]}（{spec['name'][1]}），版本 {version}。

下面是这个版本相对上一版的提交（已过滤掉测试、构建、发版等内部提交；[other] 是杂项提交，只有用户能看到效果时才写，例如换图标）：
{commits}

要求：
- 读者是普通用户，只写用户能感知的变化，不提内部实现、类名、函数名、测试；合并同类项，最多 {MAX_CHANGES} 条。
- type 只能是 new（新增）、improved（改进）、fixed（修复）。
- 中文用全角标点、一句话说清楚；英文自然地道，不要逐字直译。
- title 是一句话概括本版本最重要的变化（中文 20 字以内）。
- 如果没有任何用户可感知的变化，changes 返回空数组。
- 只输出 JSON：{{"title": {{"zh": "", "en": ""}}, "changes": [{{"type": "", "zh": "", "en": ""}}]}}

同一模块已有条目的写法供参考：
{examples}"""
    body = json.dumps({
        "model": os.environ.get("DEEPSEEK_MODEL", "deepseek-chat"),
        "messages": [{"role": "user", "content": prompt}],
        "response_format": {"type": "json_object"},
        "temperature": 0.3,
    }).encode()
    req = urllib.request.Request("https://api.deepseek.com/chat/completions", data=body, headers={
        "Authorization": f"Bearer {key}", "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            data = json.loads(json.load(r)["choices"][0]["message"]["content"])
        changes = [
            {"type": c["type"], "zh": c["zh"].strip(), "en": c["en"].strip()}
            for c in data.get("changes", [])
            if c.get("type") in TYPE_ORDER and str(c.get("zh", "")).strip() and str(c.get("en", "")).strip()
        ][:MAX_CHANGES]
        title = data.get("title") or {}
        if changes and not (str(title.get("zh", "")).strip() and str(title.get("en", "")).strip()):
            raise ValueError("缺少标题")
        changes.sort(key=lambda c: TYPE_ORDER[c["type"]])
        return {"title": {"zh": title.get("zh", "").strip(), "en": title.get("en", "").strip()}, "changes": changes}
    except Exception as e:  # 模型不可用时退回提交标题，不影响同步
        warn(f"模型改写 {spec['name'][1]} {version} 失败，改用提交标题：{e}")
        return None


def render(version: str, date: str, entry: dict) -> str:
    q = lambda s: json.dumps(s, ensure_ascii=False)
    lines = [f"  - version: {q(version)}", f"    date: {q(date)}", "    status: released",
             "    generated: true  # 由 scripts/sync-changelog.py 自动生成，人工润色后删掉这一行", "    title:"]
    lines += [f"      {k}: {q(entry['title'][k])}" for k in ("zh", "en") if entry["title"].get(k)]
    lines.append("    changes:")
    for c in entry["changes"]:
        lines.append(f"      - type: {c['type']}")
        lines += [f"        {k}: {q(c[k])}" for k in ("zh", "en") if c.get(k)]
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------- 主流程

def sync_module(key: str, spec: dict, workdir: pathlib.Path, dry: bool) -> bool:
    path = CHANGELOG_DIR / f"{key}.yaml"
    if not path.exists():
        return False
    text = path.read_text()
    found = list(ENTRY_RE.finditer(text))
    header = text[: found[0].start()] if found else text
    blocks = []
    for i, m in enumerate(found):
        b = text[m.start(): found[i + 1].start() if i + 1 < len(found) else len(text)]
        blocks.append({"version": m.group(1), "text": b if b.endswith("\n") else b + "\n"})

    repo = None
    try:
        if spec["kind"] == "tag":
            repo = open_source(key, spec, workdir)
            if repo is None:
                return False
            rels = tag_releases(repo, spec["tag"])
        else:
            rels = site_releases(spec["prefix"])
    except Exception as e:
        warn(f"{key}: 读取已发布版本失败：{e}")
        return False
    if not rels:
        note(f"{key}: 还没有已发布的版本")
        return False
    ordered = sorted(rels, key=vkey)
    latest = ordered[-1]

    # 1. upcoming → released
    for b in blocks:
        v = b["version"]
        st = STATUS_RE.search(b["text"])
        if not (SEMVER.match(v) and st and st.group(1) == "upcoming" and vkey(v) <= vkey(latest)):
            continue
        t = b["text"][: st.start()] + "    status: released" + b["text"][st.end():]
        if v in rels:
            t = DATE_RE.sub(f'    date: "{day(rels[v]["time"])}"', t, count=1)
        b["text"] = t
        note(f"{key} {v}: 已发布（{day(rels[v]['time']) if v in rels else '包含在 ' + latest + ' 中'}），状态改为 released")

    # 2. 补齐新版本
    known = {b["version"] for b in blocks}
    base = [v for v in known if SEMVER.match(v) and vkey(v) <= vkey(latest)]
    floor = max(base, key=vkey) if base else None
    todo = [v for v in ordered if v not in known and (floor is None and v == latest or floor and vkey(v) > vkey(floor))]
    examples = "".join(b["text"] for b in blocks if "generated: true" not in b["text"])[:2500]
    for v in todo:
        i = ordered.index(v)
        prev = ordered[i - 1] if i else None
        if not prev or not rels[prev].get("sha") or not rels[v].get("sha"):
            note(f"{key} {v}: 找不到上一版本或源码提交，跳过生成")
            continue
        if repo is None:
            repo = open_source(key, spec, workdir)
            if repo is None:
                break
        try:
            items = classify(commits_between(repo, rels[prev]["sha"], rels[v]["sha"]))
        except subprocess.CalledProcessError as e:
            warn(f"{key} {v}: 读取 {prev}..{v} 的提交失败：{e.stderr.strip()[:200]}")
            continue
        typed = [c for c in items if c["type"] in TYPE_ORDER]
        use_llm = bool(os.environ.get("DEEPSEEK_API_KEY")) and items
        if not typed and not use_llm:
            note(f"{key} {v}: 没有用户可感知的提交（只有构建、测试、发版等），不生成条目")
            continue
        entry = (llm_entry(spec, v, items, examples) if use_llm else None) or (fallback_entry(typed) if typed else None)
        if entry is None:
            note(f"{key} {v}: 没有 feat/fix/perf 提交，模型也未生成条目，跳过")
            continue
        if not entry["changes"]:
            note(f"{key} {v}: 模型判断没有用户可感知的变化，不生成条目")
            continue
        block = {"version": v, "text": render(v, day(rels[v]["time"]), entry)}
        pos = next((j for j, b in enumerate(blocks) if SEMVER.match(b["version"]) and vkey(b["version"]) < vkey(v)), len(blocks))
        blocks.insert(pos, block)
        note(f"{key} {v}: 新增条目（{len(entry['changes'])} 项变化，{'模型改写' if os.environ.get('DEEPSEEK_API_KEY') and 'en' in entry['title'] else '提交标题'}）")

    new_text = header + "".join(b["text"] for b in blocks)
    if new_text == text:
        return False
    if dry:
        sys.stdout.writelines(difflib.unified_diff(text.splitlines(True), new_text.splitlines(True),
                                                   f"a/{path.relative_to(ROOT)}", f"b/{path.relative_to(ROOT)}"))
    else:
        path.write_text(new_text)
    return True


def main() -> int:
    dry = "--dry-run" in sys.argv[1:]
    only = [a for a in sys.argv[1:] if not a.startswith("--")]
    workdir = pathlib.Path(tempfile.mkdtemp(prefix="changelog-src-"))
    changed = []
    try:
        for key, spec in MODULES.items():
            if only and key not in only:
                continue
            if sync_module(key, spec, workdir, dry):
                changed.append(key)
    finally:
        shutil.rmtree(workdir, ignore_errors=True)   # 含 deploy key 临时文件
    print(f"changed: {' '.join(changed) or '(none)'}")
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as f:
            f.write("### 更新日志同步\n\n" + ("\n".join(summary) or "- 没有变化") + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
