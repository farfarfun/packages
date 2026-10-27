/* 页面增强。页面本身是渲染器预先出好的静态 HTML，这个文件只负责「锦上添花」：
 * 主题开关、复制按钮、分段切换、按系统预选、更新日志过滤。关掉 JS 的话（head 里有
 * 一段 noscript 样式）分段控件消失、所有面板展开，内容一句不少。
 *
 * **这里没有一个字的文案。** 要用的标签都由 render-site.py 写进 data-* 和
 * aria-label —— 中英两份页面共用同一个脚本，文案只能有一个来源（site/strings.toml），
 * 否则加一种语言就得同时改两个地方，而漏改的那一半不会有任何报错。
 */
(function () {
  'use strict';

  var root = document.documentElement;
  var reduced = matchMedia('(prefers-reduced-motion: reduce)');
  var $ = function (selector, scope) {
    return (scope || document).querySelector(selector);
  };
  var all = function (selector, scope) {
    return Array.prototype.slice.call((scope || document).querySelectorAll(selector));
  };

  /* ---- 当前系统 ---- */

  function detectOs() {
    var ua = navigator.userAgent || '';
    var platform = (navigator.userAgentData && navigator.userAgentData.platform) || navigator.platform || '';
    if (/Android/i.test(ua)) return 'android';
    // iPadOS 在桌面模式下报的是 Mac，分不开也没关系：这个站上 macOS 和 iPad 的落点
    // 都是 Homebrew 那一栏，而 iPad 上本来也装不了。
    if (/iPhone|iPod/i.test(ua)) return 'ios';
    if (/Mac/i.test(platform) || /Mac OS X/i.test(ua)) return 'macos';
    if (/Win/i.test(platform) || /Windows/i.test(ua)) return 'windows';
    if (/Linux|X11|CrOS/i.test(platform + ua)) return 'linux';
    return null;
  }

  var os = detectOs();

  /* ---- 复制 ---- */

  function copy(text, button) {
    var done = function () {
      button.classList.add('done');
      var label = button.dataset.copied;
      // SHA 那种按钮上写着字，换成「已复制」；图标按钮只换图标。
      if (label && button.classList.contains('sha')) {
        if (!button.dataset.label) button.dataset.label = button.textContent;
        button.textContent = label;
      }
      clearTimeout(button._reset);
      button._reset = setTimeout(function () {
        button.classList.remove('done');
        if (button.dataset.label) button.textContent = button.dataset.label;
      }, 1600);
    };
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(done, function () {
        if (legacyCopy(text)) done();
      });
      return;
    }
    if (legacyCopy(text)) done();
  }

  function legacyCopy(text) {
    // http:// 或者老浏览器上没有 navigator.clipboard。这个站是 https 的，但本地用
    // file:// 预览时走的就是这条路。
    var area = document.createElement('textarea');
    area.value = text;
    area.setAttribute('readonly', '');
    area.style.cssText = 'position:fixed;top:0;opacity:0';
    document.body.appendChild(area);
    area.select();
    var ok = false;
    try {
      ok = document.execCommand('copy');
    } catch (e) {}
    document.body.removeChild(area);
    return ok;
  }

  document.addEventListener('click', function (event) {
    var button = event.target.closest && event.target.closest('.copy, .sha');
    if (!button) return;
    // 命令块的按钮不另存一份文本，直接读它旁边那段 <code> —— 显示的和复制的必须是
    // 同一份。
    var text = button.dataset.copy;
    if (!text) {
      var code = button.closest('.cmd') && $('code', button.closest('.cmd'));
      text = code ? code.textContent : '';
    }
    if (text) copy(text, button);
  });

  /* ---- 分段控件 ---- */

  function moveInk(seg, button, still) {
    var ink = $('.seg-ink', seg);
    if (!ink) return;
    if (still) ink.classList.add('still');
    ink.style.width = button.offsetWidth + 'px';
    ink.style.transform = 'translateX(' + (button.offsetLeft - 4) + 'px)';
    if (still) {
      // 下一帧再把过渡打开，初次定位就不会有一段从左边滑过来的动画。
      requestAnimationFrame(function () {
        ink.classList.remove('still');
      });
    }
  }

  function wireSeg(panes) {
    var seg = $('.seg', panes);
    if (!seg) return;
    var tabs = all('button', seg);
    var list = all('.pane', panes);

    function select(value, focus, still) {
      tabs.forEach(function (tab) {
        var on = tab.dataset.value === value;
        tab.setAttribute('aria-selected', on ? 'true' : 'false');
        tab.tabIndex = on ? 0 : -1;
        if (on) {
          moveInk(seg, tab, still);
          if (focus) tab.focus();
        }
      });
      list.forEach(function (pane) {
        pane.hidden = pane.dataset.value !== value;
      });
    }

    seg.addEventListener('click', function (event) {
      var tab = event.target.closest('button');
      if (tab) select(tab.dataset.value, false, false);
    });

    seg.addEventListener('keydown', function (event) {
      var at = tabs.indexOf(document.activeElement);
      if (at < 0 || ['ArrowLeft', 'ArrowRight', 'Home', 'End'].indexOf(event.key) < 0) return;
      event.preventDefault();
      var next = at;
      if (event.key === 'ArrowLeft') next = (at - 1 + tabs.length) % tabs.length;
      if (event.key === 'ArrowRight') next = (at + 1) % tabs.length;
      if (event.key === 'Home') next = 0;
      if (event.key === 'End') next = tabs.length - 1;
      select(tabs[next].dataset.value, true, false);
    });

    // 按当前系统预选。猜不出来、或者这一组里没有对应的那一项（iOS 上就是这样），
    // 就留在渲染器选的第一项上。
    var match = os && tabs.filter(function (tab) { return tab.dataset.os === os; })[0];
    var current = tabs.filter(function (tab) { return tab.getAttribute('aria-selected') === 'true'; })[0];
    select((match || current || tabs[0]).dataset.value, false, true);
  }

  all('.panes').forEach(wireSeg);

  // 字体加载完、或者窗口变了，按钮宽度会变，墨块得跟着重新量一次。
  function remeasure() {
    all('.panes').forEach(function (panes) {
      var seg = $('.seg', panes);
      var on = seg && $('button[aria-selected="true"]', seg);
      if (on) moveInk(seg, on, true);
    });
  }

  addEventListener('resize', remeasure);
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(remeasure);

  /* ---- 主题 ---- */

  function effectiveTheme() {
    return root.dataset.theme || (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  }

  var themeToggle = $('#theme-toggle');
  if (themeToggle) {
    themeToggle.addEventListener('click', function (event) {
      var next = effectiveTheme() === 'dark' ? 'light' : 'dark';
      var apply = function () {
        root.dataset.theme = next;
        try {
          localStorage.setItem('farfarfun.theme', next);
        } catch (e) {}
      };
      if (!document.startViewTransition || reduced.matches) {
        apply();
        return;
      }
      var box = event.currentTarget.getBoundingClientRect();
      var x = box.left + box.width / 2;
      var y = box.top + box.height / 2;
      var radius = Math.hypot(Math.max(x, innerWidth - x), Math.max(y, innerHeight - y));
      document
        .startViewTransition(apply)
        .ready.then(function () {
          root.animate(
            {
              clipPath: [
                'circle(0px at ' + x + 'px ' + y + 'px)',
                'circle(' + radius + 'px at ' + x + 'px ' + y + 'px)',
              ],
            },
            { duration: 520, easing: 'ease-in-out', pseudoElement: '::view-transition-new(root)' }
          );
        })
        .catch(function () {});
    });
  }

  /* ---- 语言 ---- */

  var langToggle = $('#lang-toggle');
  if (langToggle) {
    langToggle.addEventListener('click', function () {
      // 记下这一次的选择，下次进中文根页就不会再把人送走（或者反过来）。
      // 按钮上的 lang 属性是「要切去的那种语言」。
      var to = (langToggle.getAttribute('lang') || '').indexOf('zh') === 0 ? 'zh' : 'en';
      try {
        localStorage.setItem('farfarfun.lang', to);
      } catch (e) {}
    });
  }

  /* ---- 截图画廊；没有 JS 时仍展示全部图片 ---- */

  var gallery = $('#screens');
  if (gallery) {
    var slides = all('.shot', gallery);
    if (slides.length > 1) {
      var thumbs = $('.gallery-thumbs', gallery);
      var play = $('.gallery-play', gallery);
      var count = $('.gallery-count', gallery);
      var current = 0;
      var paused = reduced.matches;
      var hovered = false;
      var visible = true;
      var timer;
      var buttons = slides.map(function (slide, index) {
        var button = document.createElement('button');
        button.type = 'button';
        button.setAttribute('aria-label', gallery.dataset.select.replace('{index}', index + 1));
        var preview = ($('picture', slide) || $('img', slide)).cloneNode(true);
        var img = preview.tagName === 'IMG' ? preview : $('img', preview);
        img.alt = '';
        img.loading = 'lazy';
        img.removeAttribute('fetchpriority');
        button.appendChild(preview);
        button.addEventListener('click', function () { select(index); });
        thumbs.appendChild(button);
        return button;
      });

      function show(index) {
        current = (index + slides.length) % slides.length;
        slides.forEach(function (slide, i) {
          slide.hidden = i !== current;
          buttons[i].setAttribute('aria-pressed', String(i === current));
        });
        count.textContent = (current + 1) + ' / ' + slides.length;
        var active = buttons[current];
        thumbs.scrollLeft = active.offsetLeft - (thumbs.clientWidth - active.offsetWidth) / 2;
      }

      function schedule() {
        clearTimeout(timer);
        play.textContent = paused ? play.dataset.play : play.dataset.pause;
        if (!paused && !hovered && visible && !document.hidden) {
          timer = setTimeout(function () { show(current + 1); schedule(); }, 6000);
        }
      }

      function select(index) {
        paused = true;
        show(index);
        schedule();
      }

      $('.gallery-prev', gallery).addEventListener('click', function () { select(current - 1); });
      $('.gallery-next', gallery).addEventListener('click', function () { select(current + 1); });
      play.addEventListener('click', function () { paused = !paused; schedule(); });
      gallery.addEventListener('mouseenter', function () { hovered = true; schedule(); });
      gallery.addEventListener('mouseleave', function () { hovered = false; schedule(); });
      gallery.addEventListener('focusin', function (event) {
        if (event.target !== play) { paused = true; schedule(); }
      });
      gallery.addEventListener('keydown', function (event) {
        if (event.key !== 'ArrowLeft' && event.key !== 'ArrowRight') return;
        event.preventDefault();
        select(current + (event.key === 'ArrowRight' ? 1 : -1));
        buttons[current].focus();
      });
      document.addEventListener('visibilitychange', schedule);
      reduced.addEventListener('change', function () {
        if (reduced.matches) paused = true;
        schedule();
      });
      if ('IntersectionObserver' in window) {
        new IntersectionObserver(function (entries) {
          visible = entries[0].isIntersecting;
          schedule();
        }).observe(gallery);
      }
      gallery.classList.add('is-carousel');
      $('.gallery-tools', gallery).hidden = false;
      thumbs.hidden = false;
      show(0);
      schedule();
    }
  }

  /* ---- 顶栏 ---- */

  var nav = $('#nav');
  var links = all('.nav-links a[href^="#"]');
  var sections = links
    .map(function (link) {
      return document.getElementById(link.getAttribute('href').slice(1));
    })
    .filter(Boolean);

  function onScroll() {
    if (nav) nav.classList.toggle('scrolled', scrollY > 8);
    if (!sections.length) return;
    var line = parseFloat(getComputedStyle(root).scrollPaddingTop || '0') + 8;
    var current = null;
    sections.forEach(function (section) {
      if (section.getBoundingClientRect().top <= line) current = section.id;
    });
    links.forEach(function (link) {
      var on = link.getAttribute('href') === '#' + current;
      if (on) link.setAttribute('aria-current', 'true');
      else link.removeAttribute('aria-current');
    });
  }

  addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  /* ---- 更新日志过滤 ---- */

  var search = $('#cl-search');
  var timeline = $('#timeline');
  var status = $('#cl-status');

  if (search && timeline && status) {
    var releases = all('.release', timeline).map(function (release) {
      return {
        node: release,
        version: (release.dataset.version || '').toLowerCase(),
        groups: all('.group', release),
        entries: all('.entry', release).map(function (entry) {
          return { node: entry, text: entry.textContent.toLowerCase() };
        }),
      };
    });

    var clear = null;

    function filter() {
      var query = search.value.trim().toLowerCase();
      var hits = 0;
      var shown = 0;
      releases.forEach(function (release) {
        // 版本号命中时整块都留着：搜 1.0.2 要的是那一版的全部内容，不是其中某一条。
        var whole = query && release.version.indexOf(query) !== -1;
        var count = 0;
        release.entries.forEach(function (entry) {
          var on = !query || whole || entry.text.indexOf(query) !== -1;
          entry.node.hidden = !on;
          if (on) count++;
        });
        release.groups.forEach(function (group) {
          group.hidden = !!query && !group.querySelector('.entry:not([hidden])');
        });
        release.node.hidden = !!query && !count;
        if (!release.node.hidden) {
          shown++;
          hits += count;
        }
      });

      if (!query) {
        status.textContent = '';
        if (clear) clear.hidden = true;
        return;
      }
      status.textContent = hits
        ? search.dataset.results.replace('{entries}', hits).replace('{versions}', shown)
        : search.dataset.none;
      if (search.dataset.clear) {
        if (!clear) {
          clear = document.createElement('button');
          clear.type = 'button';
          clear.textContent = search.dataset.clear;
          clear.addEventListener('click', function () {
            search.value = '';
            filter();
            search.focus();
          });
          status.appendChild(document.createTextNode(' '));
          status.appendChild(clear);
        } else {
          status.appendChild(document.createTextNode(' '));
          status.appendChild(clear);
          clear.hidden = false;
        }
      }
    }

    search.addEventListener('input', filter);
    addEventListener('keydown', function (event) {
      if (event.key !== '/' || event.metaKey || event.ctrlKey || event.altKey) return;
      var tag = document.activeElement && document.activeElement.tagName;
      if (tag === 'INPUT' || tag === 'TEXTAREA') return;
      event.preventDefault();
      search.focus();
    });
  }
})();
