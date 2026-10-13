class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.1/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.1/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "bdf327ce8a5a63cfd67cce37be2b3a01092a0588fbc2ed8203c8617b2821bc26"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.1/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.1/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "0af2ddfa121fa5f45f0311180b1f04bd3b5ef1ab590c5545d9b63a9c6281a55b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.1/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.1/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "30b525c9f16294a8edfe2aaf4d9110e8a038092640cc39ef2e4fbd4bd0d060ac"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.1/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.1/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "4593d93ee5713441f1431f45a0acc5f6d4168484559cd494e025f0150d5679ba"
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
