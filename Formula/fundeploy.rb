class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.23"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.23/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.23/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "d98b46dcd5006aeb5a00201ef805c397bcf0b934c0adf4f8e163ce96be335f34"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.23/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.23/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "18e5b71e5c9cc9262373e74cab729ce7f861d59a83ba7104d804f6608ad6c212"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.23/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.23/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "4df915c4ffe7157d2cfb75bcd2cb8c261d9abc28273c85a3d425f15819f3beb8"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.23/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.23/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "4aefd6680ddad0b78aeb6a1b49e44a33589bc300847954e1c840b4a3c0a7f0a1"
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
