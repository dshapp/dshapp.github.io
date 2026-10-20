/* ==========================================================================
   main.js —— 移动端导航、滚动进场、代码复制。无框架，无第三方依赖。
   CSS 由 --minify 压缩后类名可能变化，故脚本只读写 data-* 属性。
   ========================================================================== */
(function () {
  "use strict";

  var doc = document;
  // html.js 打开增强样式；同时摘掉 body.no-js，否则「无 JS 兜底」规则会一直压住移动端抽屉。
  doc.documentElement.classList.add("js");
  if (doc.body) doc.body.classList.remove("no-js");

  /* ---- 移动端导航抽屉 ---- */
  var toggle = doc.querySelector("[data-nav-toggle]");
  var nav = doc.querySelector("[data-nav]");
  if (toggle && nav) {
    var setOpen = function (open) {
      nav.setAttribute("data-open", open ? "true" : "false");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
    };
    setOpen(false);
    toggle.addEventListener("click", function () {
      setOpen(nav.getAttribute("data-open") !== "true");
    });
    doc.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && nav.getAttribute("data-open") === "true") {
        setOpen(false);
        toggle.focus();
      }
    });
    nav.addEventListener("click", function (e) {
      if (e.target.closest("a")) setOpen(false);
    });
    // 视口变宽时收起，避免抽屉状态残留
    var mq = window.matchMedia("(min-width: 1281px)");   // 与 layout.css 的导航抽屉断点一致
    var onChange = function (e) { if (e.matches) setOpen(false); };
    if (mq.addEventListener) mq.addEventListener("change", onChange);
    else if (mq.addListener) mq.addListener(onChange);
  }

  /* ---- 文档目录：窄屏收起。宽屏恒定展开，<details> 保持 open 即可。 ---- */
  var docsNav = doc.querySelector("[data-docs-nav]");
  if (docsNav) {
    var narrow = window.matchMedia("(max-width: 900px)");
    // 首次加载就按当前宽度定状态：窄屏收起，宽屏展开。
    docsNav.open = !narrow.matches;
    var onNavMq = function (e) { docsNav.open = !e.matches; };
    if (narrow.addEventListener) narrow.addEventListener("change", onNavMq);
    else if (narrow.addListener) narrow.addListener(onNavMq);
  }

  /* ---- 文档：按端筛选（URL 的 ?platform= 与顶部选择器双向同步） ----
     当前端 = ?platform= → 页面的主端（data-page-platform 的第一项）→ all。目录靠 CSS 按 data-platform 隐藏；
     这里负责：选择器选中态、同一页内切端不刷新（pushState）、站内文档链接带上当前端、上下页按当前端重排。
     一页可以属于多个端（data-page-platform / data-for-platform 都是空格分隔的列表），第一项是主端。 */
  var shell = doc.querySelector("[data-docs-shell]");
  if (shell) {
    var ownList = (shell.getAttribute("data-page-platform") || "").split(" ").filter(Boolean);
    var own = ownList[0] || "";   // 主端
    var pTabs = [].slice.call(shell.querySelectorAll("[data-platform-tab]"));
    var pKeys = pTabs.map(function (t) { return t.getAttribute("data-platform-tab"); });
    var navLinks = [].slice.call(shell.querySelectorAll("[data-docs-nav] nav a"));
    var pager = shell.querySelector("[data-docs-pager]");
    var platformOf = {};   // 文档页 pathname → 所属端，空格分隔、第一项为主端（"" = 通用）
    navLinks.forEach(function (a) {
      var li = a.closest("li");
      platformOf[new URL(a.href, location.href).pathname] = (li && li.getAttribute("data-for-platform")) || "";
    });
    var fromQuery = function () {
      var p = new URLSearchParams(location.search).get("platform");
      return pKeys.indexOf(p) >= 0 ? p : "";
    };
    var has = function (pf, p) { return (" " + pf + " ").indexOf(" " + p + " ") >= 0; };
    var shows = function (pf, eff) { return eff === "all" || !pf || has(pf, eff); };

    var buildPager = function (eff) {
      if (!pager) return;
      var seq = navLinks.filter(function (a) {
        return !a.hasAttribute("data-docs-root") &&
          shows(platformOf[new URL(a.href, location.href).pathname], eff);
      });
      var idx = -1;
      seq.forEach(function (a, i) { if (new URL(a.href, location.href).pathname === location.pathname) idx = i; });
      if (idx < 0) return;
      var make = function (a, dir) {
        var el = doc.createElement("a");
        el.className = "docs-pager__link docs-pager__link--" + dir;
        el.setAttribute("href", a.getAttribute("data-href-base") || a.getAttribute("href"));
        var d = doc.createElement("span");
        d.className = "docs-pager__dir";
        d.textContent = pager.getAttribute("data-" + dir) || "";
        var t = doc.createElement("span");
        t.className = "docs-pager__title";
        t.textContent = a.textContent.trim();
        el.appendChild(d);
        el.appendChild(t);
        return el;
      };
      pager.textContent = "";
      pager.appendChild(idx > 0 ? make(seq[idx - 1], "prev") : doc.createElement("span"));
      if (idx < seq.length - 1) pager.appendChild(make(seq[idx + 1], "next"));
    };

    var apply = function (p) {
      var eff = p || own || "all";
      shell.setAttribute("data-platform", eff);
      pTabs.forEach(function (t) {
        if (t.getAttribute("data-platform-tab") === eff) t.setAttribute("aria-current", "true");
        else t.removeAttribute("aria-current");
      });
      buildPager(eff);
      // 站内文档链接：指向通用页的带上当前端；指向属于当前端、但主端不是它的页面也带上；
      // 其余（目标页主端就是当前端，或与当前端无关）不带参数，打开后按目标页自己的主端显示
      doc.querySelectorAll("a[href]").forEach(function (a) {
        if (a.hasAttribute("data-platform-tab")) return;
        var base = a.getAttribute("data-href-base");
        if (base === null) base = a.getAttribute("href");
        var u;
        try { u = new URL(base, location.href); } catch (e) { return; }
        if (u.origin !== location.origin || u.pathname.indexOf("/docs/") < 0) return;
        a.setAttribute("data-href-base", base);
        // 不在本语言目录里的（语言切换）就是本页译文，与本页同端
        var target = u.pathname in platformOf ? platformOf[u.pathname] : ownList.join(" ");
        var keep = eff !== "all" && (!target || (has(target, eff) && target.split(" ")[0] !== eff));
        if (keep) u.searchParams.set("platform", eff);
        else u.searchParams.delete("platform");
        a.setAttribute("href", u.pathname + u.search + u.hash);
      });
    };

    pTabs.forEach(function (t) {
      t.addEventListener("click", function (e) {
        if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey || e.button) return;
        var u = new URL(t.getAttribute("href"), location.href);
        if (u.pathname !== location.pathname) return;   // 切到与本页无关的端：跳到那个端的第一页
        e.preventDefault();
        if (u.search !== location.search) history.pushState(null, "", u.pathname + u.search + location.hash);
        apply(fromQuery());
      });
    });
    window.addEventListener("popstate", function () { apply(fromQuery()); });
    apply(fromQuery());
  }

  /* ---- 滚动进场 ---- */
  var revealables = doc.querySelectorAll(".reveal");
  var reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  if (revealables.length) {
    if (reduced || !("IntersectionObserver" in window)) {
      revealables.forEach(function (el) { el.classList.add("is-visible"); });
    } else {
      var io = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-visible");
            io.unobserve(entry.target);
          }
        });
      }, { rootMargin: "0px 0px -8% 0px", threshold: 0.05 });
      revealables.forEach(function (el) { io.observe(el); });
    }
  }

  /* ---- 代码块复制 ---- */
  doc.querySelectorAll("[data-copy]").forEach(function (btn) {
    btn.addEventListener("click", function () {
      var block = btn.closest(".code-block");
      var code = block && block.querySelector("code");
      if (!code) return;
      var text = code.innerText;
      var done = function () {
        var prev = btn.getAttribute("data-label") || btn.textContent;
        btn.setAttribute("data-label", prev);
        btn.textContent = btn.getAttribute("data-copied") || "Copied";
        window.setTimeout(function () { btn.textContent = prev; }, 1400);
      };
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(done, function () {});
      }
    });
  });

  /* ---- 更新日志：按模块筛选（#mac 这类 hash 可直达某个模块，#mac-0-1-64 直达某个版本） ---- */
  var wn = doc.querySelector("[data-whatsnew]");
  if (wn) {
    var tabs = [].slice.call(wn.querySelectorAll("[data-wn-tab]"));
    var entries = [].slice.call(wn.querySelectorAll("[data-wn-module]"));
    var infos = [].slice.call(wn.querySelectorAll("[data-wn-module-info]"));
    var empty = wn.querySelector("[data-wn-empty]");
    var keys = tabs.map(function (t) { return t.getAttribute("data-wn-tab"); });
    var select = function (key, push) {
      if (keys.indexOf(key) < 0) key = "all";
      tabs.forEach(function (t) {
        var on = t.getAttribute("data-wn-tab") === key;
        t.setAttribute("aria-selected", on ? "true" : "false");
        t.tabIndex = on ? 0 : -1;
      });
      var shown = 0;
      entries.forEach(function (el) {
        var on = key === "all" || el.getAttribute("data-wn-module") === key;
        el.hidden = !on;
        if (on) { shown++; el.classList.add("is-visible"); }
      });
      infos.forEach(function (el) { el.hidden = el.getAttribute("data-wn-module-info") !== key; });
      if (empty) empty.hidden = shown > 0;
      if (push && history.replaceState) {
        history.replaceState(null, "", key === "all" ? location.pathname : "#" + key);
      }
    };
    tabs.forEach(function (t, i) {
      t.addEventListener("click", function () { select(t.getAttribute("data-wn-tab"), true); });
      t.addEventListener("keydown", function (e) {
        var d = e.key === "ArrowRight" ? 1 : e.key === "ArrowLeft" ? -1 : 0;
        if (!d) return;
        e.preventDefault();
        var next = tabs[(i + d + tabs.length) % tabs.length];
        next.focus();
        select(next.getAttribute("data-wn-tab"), true);
      });
    });
    var fromHash = function () {
      var h = decodeURIComponent(location.hash.slice(1));
      if (!h) return select("all");
      if (keys.indexOf(h) >= 0) return select(h);
      var target = doc.getElementById(h);   // 版本锚点：选中其所属模块再滚动过去
      if (target && target.hasAttribute("data-wn-module")) {
        select(target.getAttribute("data-wn-module"));
        target.scrollIntoView();
      } else select("all");
    };
    window.addEventListener("hashchange", fromHash);
    fromHash();
  }

  /* ---- 键盘提示：⌘/Ctrl 修饰符本地化 ---- */
  if (!/Mac|iPhone|iPad/.test(navigator.platform || "")) {
    doc.querySelectorAll("[data-mod-mac]").forEach(function (el) {
      el.textContent = el.getAttribute("data-mod-alt") || el.textContent;
    });
  }
})();
