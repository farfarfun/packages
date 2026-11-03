class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.25"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.25/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.25/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "11ed6cc1653b59b516865c226d4e711237e4e1b68f284ff6a5523caa00221546"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.25/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.25/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "cb275a1a212f746060b7fa4e80245ce128b19eb9d7551a7bdde3ca23dadf902b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.25/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.25/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "953025bf5293784eb1553d94821e6e676a4440cc7a2f6e53d62b271a0dedc12e"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.25/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.25/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "7f911885fb93931be1a224c0973004909b33c6dbcc2b5188d5b0a05fc48bc8ab"
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
