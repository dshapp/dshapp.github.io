/* app-mock.js —— 首页 macOS 版块里 App Mock 的交互。
   全部是本地展示行为：切换会话、收起侧栏、把输入内容追加成一条用户消息。
   不发任何请求，不改动页面其它部分。所有钩子都走 data-appmock-* 属性。 */
(function () {
  "use strict";

  var mock = document.querySelector("[data-appmock]");
  if (!mock) return;

  var rows = mock.querySelectorAll("[data-appmock-row]");
  var threads = mock.querySelectorAll("[data-appmock-thread]");
  var titleEl = mock.querySelector("[data-appmock-title]");
  var scroller = mock.querySelector("[data-appmock-transcript]");
  var input = mock.querySelector("[data-appmock-input]");

  function select(key, label) {
    for (var i = 0; i < rows.length; i++) {
      var on = rows[i].getAttribute("data-appmock-row") === key;
      rows[i].classList.toggle("is-active", on);
      if (on) rows[i].setAttribute("aria-current", "true");
      else rows[i].removeAttribute("aria-current");
    }
    for (var j = 0; j < threads.length; j++) {
      threads[j].classList.toggle("is-hidden", threads[j].getAttribute("data-appmock-thread") !== key);
    }
    if (titleEl && label) titleEl.textContent = label;
    if (scroller) scroller.scrollTop = 0;
  }

  for (var i = 0; i < rows.length; i++) {
    rows[i].addEventListener("click", function () {
      select(this.getAttribute("data-appmock-row"), this.getAttribute("data-appmock-label"));
    });
  }

  var toggle = mock.querySelector("[data-appmock-toggle]");
  if (toggle) {
    toggle.addEventListener("click", function () {
      var collapsed = mock.classList.toggle("is-side-hidden");
      toggle.setAttribute("aria-expanded", collapsed ? "false" : "true");
    });
  }

  function send() {
    var text = input && input.value.replace(/^\s+|\s+$/g, "");
    if (!text) return;
    var thread = mock.querySelector("[data-appmock-thread]:not(.is-hidden)");
    if (thread) {
      var p = document.createElement("p");
      p.className = "appmock__p appmock__p--user";
      p.textContent = text;
      thread.appendChild(p);
    }
    input.value = "";
    autosize();
    if (scroller) scroller.scrollTop = scroller.scrollHeight;
  }

  function autosize() {
    if (!input) return;
    input.style.height = "auto";
    input.style.height = Math.min(input.scrollHeight, 96) + "px";
  }

  if (input) {
    input.addEventListener("input", autosize);
    input.addEventListener("keydown", function (e) {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        send();
      }
    });
  }

  var sendBtn = mock.querySelector("[data-appmock-send]");
  if (sendBtn) sendBtn.addEventListener("click", send);
})();
