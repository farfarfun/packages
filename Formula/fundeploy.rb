class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.26"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.26/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.26/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "9c4969d473462562b1036803b8e8ba711b0033857d985bedc130d02c153d15bf"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.26/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.26/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "7250b2b0f94d3ab3c30d195d0f95516f77169cadf3fe6edd099c7983ba853db1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.26/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.26/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "85eb4431a70a18c3da39a4dd41988e32cdeb31c86cef93b6c3034a6653fd2b79"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.26/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.26/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "21e96f1d213f3a0d9c7a9c67f21da94c063d85a149c8fc2e33c141785e1c66e2"
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
