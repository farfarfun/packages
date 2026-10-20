class Funbuild < Formula
  desc "One-command release pipeline for Python, frontend, Flutter and Rust repos"
  homepage "https://github.com/farfarfun/funbuild"
  version "1.6.108"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.108/funbuild-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.108/funbuild-aarch64-apple-darwin.tar.gz"
      sha256 "f50d7cfe3894f99d5f1783a6aea10359e95d5f407532539a570bf6fd381fd268"
    end
    on_intel do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.108/funbuild-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.108/funbuild-x86_64-apple-darwin.tar.gz"
      sha256 "52a471dda95ea4c0fbf9f64af989fd3f0442f4b2a2346d276c0dfdc86aa454f7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.108/funbuild-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.108/funbuild-aarch64-unknown-linux-musl.tar.gz"
      sha256 "00d8c52b04a601f9add4da2e7248961e34f4ec60720a5032a848a11f803b41a4"
    end
    on_intel do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.108/funbuild-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.108/funbuild-x86_64-unknown-linux-musl.tar.gz"
      sha256 "abc1c7a59cc4a3ebcf709112dbafecbef9318d8d49edcd6da8f36807b5eeb535"
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
