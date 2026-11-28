class Funsecret < Formula
  desc "Local-first encrypted secret manager CLI with SQLite, MySQL and PostgreSQL sync"
  homepage "https://github.com/farfarfun/funsecret"
  version "2.1.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.1.1/funsecret-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.1.1/funsecret-aarch64-apple-darwin.tar.gz"
      sha256 "086d2f5e31882f1dcca99765cd6d93898ae3d1355647cadd538f369453f5eee3"
    end
    on_intel do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.1.1/funsecret-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.1.1/funsecret-x86_64-apple-darwin.tar.gz"
      sha256 "4c67ee1cff7a54b6de7cf5abbe4d9ad2aceab94e41c636041b96b0d127ad4eb0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.1.1/funsecret-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.1.1/funsecret-aarch64-unknown-linux-musl.tar.gz"
      sha256 "b4bd9021d081c8d42fb5c80934c290ceb0d6dbee1a8a475594b09d62e082611a"
    end
    on_intel do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.1.1/funsecret-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.1.1/funsecret-x86_64-unknown-linux-musl.tar.gz"
      sha256 "d8ac0fa3a7590f6d3e2b5bfd597cd36b74980633ac57884958bd6a7822014ba2"
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
