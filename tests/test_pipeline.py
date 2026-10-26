import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
GH = '''#!/usr/bin/env python3
import json
import os
import pathlib
import sys

args = sys.argv[1:]
repo = args[args.index("--repo") + 1]
failure = os.environ.get("GH_FAIL", "")
if args[:2] == ["release", "list"]:
    if failure == "list" and repo.endswith("/bad"):
        sys.exit(1)
    print(json.dumps([{"tagName": "v1.0.0", "isDraft": False,
                      "isPrerelease": False, "publishedAt": "2026-01-01T00:00:00Z"}]))
elif args[:2] == ["release", "view"]:
    if failure == "view" and repo.endswith("/bad"):
        sys.exit(1)
    if failure == "empty" and repo.endswith("/bad"):
        sys.exit(0)
    print("bad_1.0.0_amd64.deb")
elif args[:2] == ["release", "download"]:
    if failure == "download" and repo.endswith("/bad"):
        sys.exit(1)
    out = pathlib.Path(args[args.index("--dir") + 1])
    if "SHA256SUMS" in args:
        (out / "SHA256SUMS").write_text("")
    else:
        (out / (repo.rsplit("/", 1)[-1] + "_1.0.0_amd64.deb")).write_text("deb")
else:
    sys.exit(2)
'''


class PipelineTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.path = Path(self.tmp.name)
        mock = self.path / "gh"
        mock.write_text(GH)
        mock.chmod(0o755)
        self.env = {**os.environ, "PATH": f"{self.path}:{os.environ['PATH']}"}

    def run_script(self, script, *args, failure=""):
        command = [str(ROOT / "scripts" / script)]
        if script.endswith(".py"):
            command.insert(0, sys.executable)
        return subprocess.run(
            [*command, *map(str, args)],
            env={**self.env, "GH_FAIL": failure},
            capture_output=True,
            text=True,
        )

    def test_collect_stops_on_release_errors(self):
        manifest = self.path / "packages.toml"
        manifest.write_text('[[source]]\nrepo = "org/good"\n[[source]]\nrepo = "org/bad"\n')
        for failure in ("list", "view", "download"):
            with self.subTest(failure=failure):
                out = self.path / failure
                result = self.run_script("collect-debs.sh", manifest, out, failure=failure)
                self.assertNotEqual(result.returncode, 0, result.stdout)

        out = self.path / "empty"
        result = self.run_script("collect-debs.sh", manifest, out, failure="empty")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([p.name for p in out.glob("*.deb")], ["good_1.0.0_amd64.deb"])

    def test_renderers_reject_missing_latest_assets(self):
        manifest = self.path / "packages.toml"
        manifest.write_text(
            '[[source]]\nrepo = "org/good"\n'
            '[source.brew]\ndesc = "Test"\n'
            '[source.cask]\napp = "Good"\ndesc = "Test"\n'
        )
        for script in ("render-formula.py", "render-cask.py"):
            with self.subTest(script=script):
                out = self.path / script
                out.mkdir()
                old = out / "good.rb"
                old.write_text("old version")
                result = self.run_script(script, manifest, out)
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertEqual(old.read_text(), "old version")

    def test_download_only_skips_apt_collection_and_verification(self):
        manifest = self.path / "packages.toml"
        manifest.write_text(
            '[[source]]\nrepo = "org/good"\n'
            '[[source]]\nrepo = "org/bad"\napt = false\ncli = false\n'
        )
        selected = self.run_script("select-releases.py", manifest, failure="list")
        self.assertEqual(selected.returncode, 0, selected.stderr)
        self.assertEqual(selected.stdout.strip(), "org/good\tv1.0.0")
        listed = self.run_script("list-packages.py", manifest)
        self.assertEqual(listed.stdout.strip(), "good\tgood")
        out = self.path / "downloads"
        collected = self.run_script("collect-debs.sh", manifest, out, failure="download")
        self.assertEqual(collected.returncode, 0, collected.stderr)
        self.assertEqual([p.name for p in out.iterdir()], ["good_1.0.0_amd64.deb"])

    @unittest.skipUnless(all(shutil.which(c) for c in ("dpkg-deb", "dpkg-scanpackages", "apt-ftparchive")), "APT tools unavailable")
    def test_apt_rejects_package_missing_arm64(self):
        manifest = self.path / "packages.toml"
        manifest.write_text('[[source]]\nrepo = "org/good"\n[[source]]\nrepo = "org/bad"\n')
        debs = self.path / "debs"
        debs.mkdir()
        for name, arch in (("good", "amd64"), ("good", "arm64"), ("bad", "amd64")):
            package = self.path / f"{name}-{arch}"
            control = package / "DEBIAN"
            control.mkdir(parents=True)
            (control / "control").write_text(
                f"Package: {name}\nVersion: 1.0.0\nArchitecture: {arch}\n"
                "Maintainer: Test <test@example.com>\nDescription: Test package\n"
            )
            subprocess.run(
                ["dpkg-deb", "--build", str(package), str(debs / f"{name}_1.0.0_{arch}.deb")],
                check=True, capture_output=True,
            )
        result = self.run_script("build-deb-repo.sh", debs, self.path / "repo", "unused", manifest)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("bad: arm64", result.stderr)


if __name__ == "__main__":
    unittest.main()
