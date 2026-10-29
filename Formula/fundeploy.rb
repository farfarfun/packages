class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.21"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.21/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.21/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "134fcde36ea98fef3ad3c7cf9bdb6d42c3a5f8ca17b1871e0c578c2dc537174c"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.21/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.21/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "59d2a559fc8867a79eacd78a3467476ba7d443c205fabdcea20a1ad0ff01e236"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.21/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.21/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "602c30db54803b6e4c6736d5072328e4d2bd7f3262f60e4badedcb8d1a7f2bc2"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.21/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.21/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "6617f4f982f2c7b5b826a61bc59d691eddd266340eca1399756aae8df95acca3"
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
