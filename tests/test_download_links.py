import importlib.util
import re
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
import manifest
import sitedata

spec = importlib.util.spec_from_file_location("render_site", ROOT / "scripts/render-site.py")
renderer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(renderer)


class DownloadLinksTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.manifest = self.root / "packages.toml"
        self.manifest.write_text('[[source]]\nrepo = "example/desktop-app"\napt = false\ncli = false\n')

    def test_existing_channels_keep_their_apt_behavior(self):
        self.assertTrue(manifest.in_apt({"repo": "org/cli"}))
        self.assertTrue(manifest.in_apt({"repo": "org/cli", "apt": True}))
        self.assertFalse(manifest.in_apt({"repo": "org/app", "apt": False}))
        self.assertFalse(manifest.in_apt({"repo": "org/plugin", "utools": {}}))

    def test_home_separates_utools_plugins_in_both_languages(self):
        data = sitedata.collect(str(ROOT / "packages.toml"), offline=True)
        site = renderer.Site(ROOT / "site", self.root / "site", data, renderer.SITE_URL)
        plugins = [p for p in data["packages"] if "utools" in p["channels"]]
        apps = [p for p in data["packages"] if "utools" not in p["channels"]]
        self.assertTrue(plugins)
        self.assertTrue(apps)
        for language in renderer.LANGS:
            with self.subTest(language=language[0]):
                page = renderer.render_home(site, *language)
                sections = {
                    name: re.search(rf'<section[^>]* id="{name}"[^>]*>(.*?)</section>', page, re.S).group(1)
                    for name in ("packages", "utools")
                }
                self.assertIn('href="#utools"', page)
                self.assertIn('aria-labelledby="utools-title"', page)
                self.assertIn(site.t("pluginsSub", count=len(plugins)), sections["utools"])
                self.assertIn(site.t("packagesSub", count=len(apps)), sections["packages"])
                self.assertIn(".upxs", sections["utools"])
                for pkg in data["packages"]:
                    section = "utools" if "utools" in pkg["channels"] else "packages"
                    other = "packages" if section == "utools" else "utools"
                    link = f'href="./{pkg["name"]}/"'
                    self.assertEqual(sections[section].count(link), 1)
                    self.assertNotIn(link, sections[other])

    def test_download_page_uses_release_urls_even_with_stale_apt_index(self):
        names = ["desktop-app_0.1.1_amd64.deb", "desktop-app_0.1.1_x64-setup.exe", "desktop-app-0.1.1-macos-arm64.dmg", "SHA256SUMS"]
        assets = [{"name": name, "size": 123, "sha256": "a" * 64,
                   "url": f"https://github.com/example/desktop-app/releases/download/v0.1.1/{name}"}
                  for name in names]
        for index in ({}, {"desktop-app": [{"version": "0.0.1"}]}):
            with self.subTest(index=index), \
                    patch.object(sitedata, "packages_index", return_value=index), \
                    patch.object(sitedata, "releases_of", return_value=[{"tag": "v0.1.1", "date": "2026-10-26"}]), \
                    patch.object(sitedata, "release_assets", return_value=assets), \
                    patch.object(sitedata, "fetch_changelog", return_value=""):
                data = sitedata.collect(str(self.manifest), deb_dir=self.root)
            pkg = data["packages"][0]
            self.assertFalse(pkg["in_apt"])
            self.assertEqual(pkg["channels"], [])
            self.assertEqual(pkg["versions"][0]["version"], "0.1.1")
            self.assertEqual({p["id"] for p in pkg["downloads"]["platforms"]}, {"linux", "windows", "macos"})
            site = renderer.Site(ROOT / "site", self.root / "site", data, renderer.SITE_URL)
            for language in renderer.LANGS:
                page = renderer.render_package(site, pkg, *language)
                self.assertNotIn('href="#install"', page)
                self.assertNotIn('id="install"', page)
                self.assertNotIn("sudo apt install desktop-app", page)
                self.assertIn('class="btn primary" href="#download"', page)
                for asset in assets:
                    self.assertIn(asset["url"], page)

    def test_offline_page_links_to_releases_without_empty_install_section(self):
        data = sitedata.collect(str(self.manifest), offline=True)
        site = renderer.Site(ROOT / "site", self.root / "site", data, renderer.SITE_URL)
        page = renderer.render_package(site, data["packages"][0], *renderer.LANGS[0])
        self.assertNotIn('id="install"', page)
        self.assertNotIn('href="#install"', page)
        self.assertIn('class="btn primary" href="https://github.com/example/desktop-app/releases"', page)

    def test_package_shows_images_then_overview_then_install(self):
        self.manifest.write_text(
            '[[source]]\nrepo = "example/plugin"\n[source.utools]\napp = "Example"\n'
        )
        data = sitedata.collect(str(self.manifest), offline=True)
        pkg = data["packages"][0]
        pkg["page"] = {
            "tagline": {"zh": "一句话简介", "en": "Short introduction"},
            "description": {"zh": "详细产品介绍", "en": "Detailed product description"},
            "features": [{"title": "Feature title", "text": "Feature detail"}],
            "shots": [{"light": key, "dark": "dark", "alt": "Product screenshot"}
                      for key in ("missing", "desktop", "phone")],
        }
        site = renderer.Site(ROOT / "site", self.root / "site", data, renderer.SITE_URL)
        for available in (False, True):
            site.shots = {
                "desktop": {"href": "assets/shots/desktop.png", "width": 1280, "height": 800},
                "phone": {"href": "assets/shots/phone.png", "width": 390, "height": 844},
                "dark": {"href": "assets/shots/dark.png", "width": 1280, "height": 800},
            } if available else {}
            for language in renderer.LANGS:
                with self.subTest(shots=available, language=language[0]):
                    page = renderer.render_package(site, pkg, *language)
                    overview = page.index('id="overview"')
                    self.assertLess(overview, page.index('id="install"'))
                    self.assertGreater(page.index("Feature detail"), overview)
                    self.assertGreater(page.index("Detailed product description" if language[0] == "en"
                                                  else "详细产品介绍", overview), overview)
                    nav = re.search(r'<nav .*?</nav>', page, re.S).group(0)
                    self.assertLess(nav.index('#overview'), nav.index('#install'))
                    if available:
                        self.assertLess(page.index('id="screens"'), overview)
                        self.assertLess(nav.index('#screens'), nav.index('#overview'))
                        self.assertIn('class="skip" href="#screens"', page)
                        self.assertEqual(page.count('loading="eager" fetchpriority="high"'), 1)
                        self.assertEqual(page.count('loading="lazy"'), 1)
                        self.assertIn('width="1280" height="800"', page)
                        self.assertIn('media="(prefers-color-scheme: dark)"', page)
                        self.assertRegex(page, r'class="shot-link" href="(?:\.\./)+assets/shots/desktop.png"')
                    else:
                        self.assertNotIn('id="screens"', page)
                        self.assertNotIn('href="#screens"', page)
                        self.assertIn('class="skip" href="#overview"', page)

    def test_utools_upxs_is_the_install_download_in_both_languages(self):
        self.manifest.write_text(
            '[[source]]\nrepo = "example/plugin"\n[source.utools]\napp = "Example"\n'
        )
        for extensions in (("upxs",), ("upx", "upxs")):
            assets = [{"name": f"plugin-1.0.1.{ext}", "size": 123, "sha256": "a" * 64,
                       "url": f"https://github.com/example/plugin/releases/download/v1.0.1/plugin-1.0.1.{ext}"}
                      for ext in extensions]
            with self.subTest(extensions=extensions), \
                    patch.object(sitedata, "packages_index", return_value={}), \
                    patch.object(sitedata, "releases_of", return_value=[{"tag": "v1.0.1", "date": "2026-10-27"}]), \
                    patch.object(sitedata, "release_assets", return_value=assets), \
                    patch.object(sitedata, "fetch_changelog", return_value=""):
                data = sitedata.collect(str(self.manifest), deb_dir=self.root)
                pkg = data["packages"][0]
                self.assertEqual(pkg["channels"], ["utools"])
                self.assertFalse(pkg["downloads"]["other"])
                platform = pkg["downloads"]["platforms"][0]
                self.assertEqual(platform["id"], "any")
                self.assertEqual(platform["files"][0]["kind"], "UPXS")
                site = renderer.Site(ROOT / "site", self.root / "site", data, renderer.SITE_URL)
                for language in renderer.LANGS:
                    page = renderer.render_package(site, pkg, *language)
                    self.assertIn('id="install"', page)
                    self.assertIn(assets[-1]["url"], page)
                    self.assertIn("UPXS", page)
                    self.assertIn("a" * 64, page)
                    self.assertNotIn('id="download"', page)
                    self.assertNotIn('href="#download"', page)
                    self.assertNotIn('plugin-1.0.1.upx"', page)
