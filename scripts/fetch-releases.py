#!/usr/bin/env python3
"""把站点仓库 Releases 里各平台的最新安装包拉到 static/downloads/，并写出 data/releases.json。

Pages 构建（.github/workflows/pages.yml）在跑 Hugo 之前调用它；本地预览想看到真实版本号时也可以手动跑：

    GH_TOKEN=$(gh auth token -h github.com) python3 scripts/fetch-releases.py

安装包的 Release 由 .github/workflows/build-apps.yml 创建，tag 约定：
    mac-v<版本>       资产 *.dmg
    android-v<版本>   资产 *.apk

没有任何 Release 或拉取失败的平台不会中断构建：模板会把下载按钮退回到 /download/ 页并显示「即将推出」。
"""
from __future__ import annotations

import hashlib
import json
import os
import pathlib
import sys
import urllib.request

REPO = os.environ.get("RELEASE_REPO", "dshapp/dshapp.github.io")
SITE_URL = os.environ.get("SITE_URL", "https://dshapp.github.io/").rstrip("/") + "/"
ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "static" / "downloads"
DATA_FILE = ROOT / "data" / "releases.json"

PLATFORMS = {
    "mac": {"prefix": "mac-v", "suffix": ".dmg"},
    "android": {"prefix": "android-v", "suffix": ".apk"},
}


def api(url: str) -> urllib.request.Request:
    req = urllib.request.Request(url, headers={"Accept": "application/vnd.github+json", "User-Agent": "dsh-site"})
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    return req


def list_releases() -> list[dict]:
    with urllib.request.urlopen(api(f"https://api.github.com/repos/{REPO}/releases?per_page=100"), timeout=30) as r:
        return json.load(r)


def download(url: str, dest: pathlib.Path) -> str:
    req = api(url)
    req.add_header("Accept", "application/octet-stream")
    h = hashlib.sha256()
    tmp = dest.with_suffix(dest.suffix + ".part")
    with urllib.request.urlopen(req, timeout=600) as r, open(tmp, "wb") as f:
        while chunk := r.read(1 << 20):
            h.update(chunk)
            f.write(chunk)
    tmp.replace(dest)
    return h.hexdigest()


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    DATA_FILE.parent.mkdir(parents=True, exist_ok=True)
    try:
        releases = list_releases()
    except Exception as e:  # 网络/权限问题：保留空数据继续构建
        print(f"::warning::无法读取 {REPO} 的 Releases：{e}", file=sys.stderr)
        releases = []

    data: dict[str, dict] = {}
    keep: set[str] = set()
    for key, spec in PLATFORMS.items():
        cands = [
            r for r in releases
            if not r.get("draft") and not r.get("prerelease") and r["tag_name"].startswith(spec["prefix"])
        ]
        cands.sort(key=lambda r: r.get("published_at") or "", reverse=True)
        for rel in cands:
            asset = next((a for a in rel.get("assets", []) if a["name"].endswith(spec["suffix"])), None)
            if not asset:
                continue
            dest = OUT_DIR / asset["name"]
            try:
                if dest.exists() and dest.stat().st_size == asset["size"]:
                    sha = hashlib.sha256(dest.read_bytes()).hexdigest()
                else:
                    sha = download(asset["url"], dest)
            except Exception as e:
                print(f"::warning::下载 {asset['name']} 失败：{e}", file=sys.stderr)
                continue
            keep.add(asset["name"])
            data[key] = {
                "version": rel["tag_name"][len(spec["prefix"]):],
                "tag": rel["tag_name"],
                "published": rel.get("published_at"),
                "file": asset["name"],
                "size": asset["size"],
                "sha256": sha,
                "path": f"downloads/{asset['name']}",
                "url": f"{SITE_URL}downloads/{asset['name']}",
                "releaseUrl": rel["html_url"],
            }
            print(f"{key}: {rel['tag_name']} -> {dest.relative_to(ROOT)} ({asset['size']} bytes)")
            break
        else:
            print(f"::notice::{key}: 还没有可用的 Release（tag 前缀 {spec['prefix']}）", file=sys.stderr)

    # 只保留最新版本，避免旧安装包在本地/产物里越积越多
    for f in OUT_DIR.iterdir():
        if f.is_file() and f.name not in keep and f.suffix in (".dmg", ".apk", ".part"):
            f.unlink()

    DATA_FILE.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
    # 同一份信息也发布成 /downloads/latest.json，方便 App 内检查更新或脚本调用
    (OUT_DIR / "latest.json").write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
