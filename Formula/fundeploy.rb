class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.14"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.14/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.14/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "2ea3c932a95bfa31c7bbf8cb312a82f8c10c3031ae0ce1d400967ed018af0690"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.14/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.14/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "389adf8fb5e15fa17df64e2e8839b2845cc1e9c7d36ce95a7605c0b82abcbaeb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.14/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.14/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d728275e30004343798722ec4540b098130327cbf1c4ce68dd7f3f51b27a9acc"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.14/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.14/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "2c6846c35253a43f9534e305a227b57965d1d25f20a1c67263a05e77dbfc45d9"
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
