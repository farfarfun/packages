class Funshell < Formula
  desc "Cross-platform shell execution and port/process query & kill CLI"
  homepage "https://github.com/farfarfun/funshell"
  version "2.0.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funshell/releases/download/v2.0.0/funshell-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funshell/releases/download/v2.0.0/funshell-aarch64-apple-darwin.tar.gz"
      sha256 "d328347fa05d4aa5f3aeaf3bc6976540cc72a86f201455b398de2cebf190b951"
    end
    on_intel do
      url "https://github.com/farfarfun/funshell/releases/download/v2.0.0/funshell-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funshell/releases/download/v2.0.0/funshell-x86_64-apple-darwin.tar.gz"
      sha256 "4ac16c28fa91b15dcb041719ff888567c29ba676971bf0f0af83d7ee97b612e7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funshell/releases/download/v2.0.0/funshell-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funshell/releases/download/v2.0.0/funshell-aarch64-unknown-linux-musl.tar.gz"
      sha256 "6b30cd7ef0f379fbc28c5b062e429d5b5bd652c5844522e3445d2bff785c24dd"
    end
    on_intel do
      url "https://github.com/farfarfun/funshell/releases/download/v2.0.0/funshell-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funshell/releases/download/v2.0.0/funshell-x86_64-unknown-linux-musl.tar.gz"
      sha256 "779a1f794d5538a110ace1407aca625def17316c2b1b83904e3573dd3e36fd96"
    end
  end

  def install
    bin.install "funshell"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/funshell --version")
    assert_match "port", shell_output("#{bin}/funshell --help")
  end
end
