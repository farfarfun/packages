class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.30"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.30/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.30/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "c45d852ff1cb79975de0da040c5e1ea6b01f88e723640418aaf8d3f369137dc8"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.30/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.30/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "d30647be1075bd31ee92bf7dd5c3c96f0ac498991c91fcd4624e6e6dc6d92106"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.30/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.30/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "be17f15a9109550f90b7230ee771659c430b0c62a25e2cc1dfa97ad7ef3f5436"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.30/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.30/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "edd5247288e0f93d06c840b3b37f497a51b80c859f47a623b76a15a4fccf3b54"
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
