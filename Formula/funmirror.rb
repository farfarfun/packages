class Funmirror < Formula
  desc "Parallel repository and release mirroring CLI across GitHub, Gitee, GitLab and GitCode"
  homepage "https://github.com/farfarfun/funmirror"
  version "0.7.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funmirror/releases/download/v0.7.0/funmirror-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funmirror/releases/download/v0.7.0/funmirror-aarch64-apple-darwin.tar.gz"
      sha256 "d429f688f20278a9fa999cc4320eaf09590f2b8f0d4b85b2ab1958374bdb7cbd"
    end
    on_intel do
      url "https://github.com/farfarfun/funmirror/releases/download/v0.7.0/funmirror-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funmirror/releases/download/v0.7.0/funmirror-x86_64-apple-darwin.tar.gz"
      sha256 "8f62b942f7f1569ddaf34b0098be945c1b3a98127ea7931460a07ba2a4766f14"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funmirror/releases/download/v0.7.0/funmirror-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funmirror/releases/download/v0.7.0/funmirror-aarch64-unknown-linux-musl.tar.gz"
      sha256 "fcf61659cc055a20e48080a02cb62494f31937617f8edf527a82f9d561799dff"
    end
    on_intel do
      url "https://github.com/farfarfun/funmirror/releases/download/v0.7.0/funmirror-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funmirror/releases/download/v0.7.0/funmirror-x86_64-unknown-linux-musl.tar.gz"
      sha256 "58c9fc8c68cabbd80f92cdbebffe71f256a02c36af0f3e3ca20fddf804d88f30"
    end
  end

  def install
    bin.install "funmirror"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/funmirror --version")
    assert_match "mirror", shell_output("#{bin}/funmirror --help")
  end
end
