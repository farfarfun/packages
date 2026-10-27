import importlib.util
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
