class Funbuild < Formula
  desc "One-command release pipeline for Python, frontend, Flutter and Rust repos"
  homepage "https://github.com/farfarfun/funbuild"
  version "1.6.107"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.107/funbuild-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.107/funbuild-aarch64-apple-darwin.tar.gz"
      sha256 "f80d71fea29139471a5593f9c2af9c646ee593cc53edc8e56fd4dc8755650f22"
    end
    on_intel do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.107/funbuild-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.107/funbuild-x86_64-apple-darwin.tar.gz"
      sha256 "2f297530766dd50963d2ba18d97eb208991b60f9bcf40bb86e0b682f306685ac"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.107/funbuild-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.107/funbuild-aarch64-unknown-linux-musl.tar.gz"
      sha256 "cdd2efb6fff8f589b34d5b21a858697c17e034fd0fee3da2b033532f70ad15d3"
    end
    on_intel do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.107/funbuild-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.107/funbuild-x86_64-unknown-linux-musl.tar.gz"
      sha256 "095f96550f3203fdd15e8cd7b4c8b66f7a0fd08cc957aefbc8dba9373eb9d650"
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
