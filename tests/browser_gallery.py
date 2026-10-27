"""Exercise the generated gallery in the runner's Chrome, without downloading a browser."""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import shutil
import sys
from threading import Thread

from playwright.sync_api import expect, sync_playwright


root = Path(sys.argv[1]).resolve()
pages = list(root.glob("*/index.html"))
multi = next(p for p in pages if p.read_text().count('class="shot ') > 1)
single = next(p for p in pages if p.read_text().count('class="shot ') == 1)
server = ThreadingHTTPServer(("127.0.0.1", 0), partial(SimpleHTTPRequestHandler, directory=str(root)))
Thread(target=server.serve_forever, daemon=True).start()
base = f"http://127.0.0.1:{server.server_port}/"
shots = Path("/tmp/gallery-screenshots")
shots.mkdir(exist_ok=True)

try:
    with sync_playwright() as pw:
        browser = pw.chromium.launch(executable_path=shutil.which("google-chrome"), args=["--no-sandbox"])
        page = browser.new_page(viewport={"width": 1440, "height": 1000}, reduced_motion="no-preference")
        errors = []
        page.on("pageerror", lambda error: errors.append(str(error)))
        page.clock.install()
        page.goto(base + multi.parent.name + "/?lang=zh")
        gallery = page.locator("#screens")
        expect(gallery).to_have_class("section wrap product-screens is-carousel")
        gallery.scroll_into_view_if_needed()
        thumbs = gallery.locator(".gallery-thumbs button")
        total = thumbs.count()
        count = gallery.locator(".gallery-count")
        play = gallery.locator(".gallery-play")
        page.wait_for_timeout(200)
        page.clock.fast_forward(6100)
        expect(count).to_have_text(f"2 / {total}")
        expect(gallery.locator(".shot:visible")).to_have_count(1)

        gallery.locator(".shot-link:visible").hover()
        page.clock.fast_forward(13000)
        expect(count).to_have_text(f"2 / {total}")
        page.mouse.move(0, 0)
        page.clock.fast_forward(6100)
        expect(count).to_have_text(f"{3 if total > 2 else 1} / {total}")

        thumbs.first.click()
        page.mouse.move(0, 0)
        page.clock.fast_forward(13000)
        expect(count).to_have_text(f"1 / {total}")
        expect(thumbs.first).to_have_attribute("aria-pressed", "true")
        thumbs.first.press("ArrowLeft")
        expect(count).to_have_text(f"{total} / {total}")
        expect(thumbs.last).to_be_focused()
        play.click()
        page.mouse.move(0, 0)
        page.clock.fast_forward(6100)
        expect(count).to_have_text(f"1 / {total}")
        play.click()
        page.mouse.move(0, 0)
        page.clock.fast_forward(13000)
        expect(count).to_have_text(f"1 / {total}")
        expect(play).to_have_text("自动播放")

        play.click()
        page.mouse.move(0, 0)
        page.emulate_media(reduced_motion="reduce")
        expect(play).to_have_text("自动播放")
        page.clock.fast_forward(13000)
        expect(count).to_have_text(f"1 / {total}")
        page.screenshot(path=str(shots / "desktop.png"))

        for width in (390, 320):
            page.set_viewport_size({"width": width, "height": 844})
            thumbs.last.click()
            expect(thumbs.last).to_have_attribute("aria-pressed", "true")
            assert page.evaluate("document.documentElement.scrollWidth <= innerWidth")
            page.screenshot(path=str(shots / f"mobile-{width}.png"))

        page.goto(base + single.parent.name + "/?lang=zh")
        expect(page.locator(".shot:visible")).to_have_count(1)
        expect(page.locator(".gallery-tools")).to_be_hidden()
        assert not errors, errors

        fallback = browser.new_page(java_script_enabled=False)
        fallback.goto(base + multi.parent.name + "/?lang=zh")
        expect(fallback.locator(".shot:visible")).to_have_count(total)
        expect(fallback.locator(".gallery-tools")).to_be_hidden()
        browser.close()
finally:
    server.shutdown()
