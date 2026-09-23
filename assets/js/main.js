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
    var mq = window.matchMedia("(min-width: 1025px)");
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

  /* ---- 键盘提示：⌘/Ctrl 修饰符本地化 ---- */
  if (!/Mac|iPhone|iPad/.test(navigator.platform || "")) {
    doc.querySelectorAll("[data-mod-mac]").forEach(function (el) {
      el.textContent = el.getAttribute("data-mod-alt") || el.textContent;
    });
  }
})();
