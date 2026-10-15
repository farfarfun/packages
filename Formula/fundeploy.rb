class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.5/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.5/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "96727fb5b1bf3845c2573e2d07783f642e6b69d7261086bd394f4e6154d436f2"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.5/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.5/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "79fe86b376161520ea8557a9be221c73eaad393fdd83fd86ddb6a5f12c30fdd5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.5/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.5/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "fdb78c16f3b2b31a2a9643fd9da17450cd57a063be4c171cb92ffc8d891fc011"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.5/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.5/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "9a12fc94363fc74008e59155783d40af9b79a3990402491db135b418e2a53d31"
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
