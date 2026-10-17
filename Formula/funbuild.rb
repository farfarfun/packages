class Funbuild < Formula
  desc "One-command release pipeline for Python, frontend, Flutter and Rust repos"
  homepage "https://github.com/farfarfun/funbuild"
  version "1.6.105"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.105/funbuild-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.105/funbuild-aarch64-apple-darwin.tar.gz"
      sha256 "ce14a24d01403c299cae7ede3e0f2a1a512d92789d78cfc536722b415d78b873"
    end
    on_intel do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.105/funbuild-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.105/funbuild-x86_64-apple-darwin.tar.gz"
      sha256 "c0ff6ec9c94ba1885794c1960d256776b0327308aff4e39be3b1e03ad07fc009"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.105/funbuild-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.105/funbuild-aarch64-unknown-linux-musl.tar.gz"
      sha256 "e1cb5c222faa5f8680a7cdab7374ae01e874fcab0592bebeeacfca1ff1131b6d"
    end
    on_intel do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.105/funbuild-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.105/funbuild-x86_64-unknown-linux-musl.tar.gz"
      sha256 "b3eebab826af4a2dcadb1b88ff88a6ca6087d71c7afa315bc812c4501d357b9e"
    end
  end

  def install
    bin.install "funbuild"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/funbuild --version")
    assert_match "build", shell_output("#{bin}/funbuild --help")
  end
end
