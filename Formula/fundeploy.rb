class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.18"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.18/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.18/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "7ac16c9220738a6652bf7b2f75857cd0b2990bec26e174313b997c7ba1c03082"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.18/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.18/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "139c370b4296aaab816c7b22e7fe512d13a3aa4b3e4fc2891417ecf00864667d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.18/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.18/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "530670ace1740c3aa953530fa5f374a59b46127acf544acc6f55274cf3b485ed"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.18/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.18/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "4a659657a3c71f70e9a0079a8f48db01b59ca3ab77a470c97829068d8db59240"
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
