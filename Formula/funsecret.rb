class Funsecret < Formula
  desc "Local-first encrypted secret manager CLI with SQLite, MySQL and PostgreSQL sync"
  homepage "https://github.com/farfarfun/funsecret"
  version "2.0.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.0.2/funsecret-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.0.2/funsecret-aarch64-apple-darwin.tar.gz"
      sha256 "594f9cddc40638a09b342e22a6f8698a2f37c41e5c00664d0834cf35ede39a92"
    end
    on_intel do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.0.2/funsecret-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.0.2/funsecret-x86_64-apple-darwin.tar.gz"
      sha256 "695e8c47b698c498633337e6e307e2a04e5d377a5e54bb3ded37841c2a44486e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.0.2/funsecret-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.0.2/funsecret-aarch64-unknown-linux-musl.tar.gz"
      sha256 "c23cdf3c9c368f1b8563396d7bacc5c3ec1b4e7f047b40d1e20cb845761973ab"
    end
    on_intel do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.0.2/funsecret-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.0.2/funsecret-x86_64-unknown-linux-musl.tar.gz"
      sha256 "49d51162c99fa47aedffc6450a5d39194892ec81fc4f8c66a61e90bd3de5be4c"
    end
  end

  def install
    bin.install "funsecret"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/funsecret --version")
    assert_match "read", shell_output("#{bin}/funsecret --help")
  end
end
