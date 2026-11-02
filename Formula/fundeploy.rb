class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.24"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.24/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.24/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "3d90387572956b0a3d90e66fe0da2f80bf4f30269fdfdf60845953ad2c8479c9"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.24/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.24/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "05a22cbb7e1be3e7c5edf428fd2587900df74058832382a9d24ce17c9100a038"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.24/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.24/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "fb0cd91c8c417033c7f2a14048ab56df6829e16e0909ee23814417a34c99837c"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.24/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.24/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "f136df0b966ea7ea4ec7bfab82b4040c182ab1a98390fbfaaa0bb53dee866f31"
    end
  end

  def install
    bin.install "fundeploy"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fundeploy --version")
    assert_match "\u670d\u52a1", shell_output("#{bin}/fundeploy list")
  end
end
