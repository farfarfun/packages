class Funbuild < Formula
  desc "One-command release pipeline for Python, frontend, Flutter and Rust repos"
  homepage "https://github.com/farfarfun/funbuild"
  version "1.6.106"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.106/funbuild-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.106/funbuild-aarch64-apple-darwin.tar.gz"
      sha256 "3547077144e58333e5ea0650a5de730bacd402665639ec538653c1b8869d4447"
    end
    on_intel do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.106/funbuild-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.106/funbuild-x86_64-apple-darwin.tar.gz"
      sha256 "3699c9d1493f79eefd51e7d03984b5c222d37998bdaadb1748934717b2f1130d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.106/funbuild-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.106/funbuild-aarch64-unknown-linux-musl.tar.gz"
      sha256 "58850cd98fb76f5d4ccc8c70e089c67be13df663a53b796e557c3cda07758e46"
    end
    on_intel do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.106/funbuild-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.106/funbuild-x86_64-unknown-linux-musl.tar.gz"
      sha256 "515dbef5c596dda8585ec44eacc288b5ea084730eb51f66032f493b36fe246ec"
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
