class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.19"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.19/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.19/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "25dfd86929e3f236f1110448a283287f5e95ac101c4861c412af2b512d7f1b7a"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.19/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.19/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "480f1147f3c9471ee5ca9c782690ed5ccdbc6a028140c1de2d184f301c581ec8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.19/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.19/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "cdf80ef96ae62f4d6ba98dc3334c785af6a5bbc52a574b3516aeff9444d66efa"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.19/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.19/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "60eafb99fae1cf03ce3c58802b8ecc9c37a33256f39cfb2a6db55c37ee0872f5"
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
