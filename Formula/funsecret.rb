class Funsecret < Formula
  desc "Local-first encrypted secret manager CLI with SQLite, MySQL and PostgreSQL sync"
  homepage "https://github.com/farfarfun/funsecret"
  version "2.0.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.0.1/funsecret-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.0.1/funsecret-aarch64-apple-darwin.tar.gz"
      sha256 "745ae49f40ecf350aaf4a13ed5d2c908484a557875fb34aaba76c4f79f0b8971"
    end
    on_intel do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.0.1/funsecret-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.0.1/funsecret-x86_64-apple-darwin.tar.gz"
      sha256 "6da25a17417a3ff54c9e80d9f376ff2e03aeceb739573c63de87ff3a87580f06"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.0.1/funsecret-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.0.1/funsecret-aarch64-unknown-linux-musl.tar.gz"
      sha256 "44340ddbebeb782a9923fe07e3d9b59d3bac8e0e3dbf21ad66d6cbf8f4706de6"
    end
    on_intel do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.0.1/funsecret-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.0.1/funsecret-x86_64-unknown-linux-musl.tar.gz"
      sha256 "0877cf01183e53a08384e6590b90723320529874604e897e5f7a62ba2090e7d0"
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
