class Funsecret < Formula
  desc "Local-first encrypted secret manager CLI with SQLite, MySQL and PostgreSQL sync"
  homepage "https://github.com/farfarfun/funsecret"
  version "2.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.1.0/funsecret-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.1.0/funsecret-aarch64-apple-darwin.tar.gz"
      sha256 "be7bb6f5af66cb5588805bd654fb1225cc999324481c06df4d5bebd7094520b9"
    end
    on_intel do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.1.0/funsecret-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.1.0/funsecret-x86_64-apple-darwin.tar.gz"
      sha256 "ce37197d0dbac729fe0b1ad0cf155c65fd4329d82ba9cdf2f5eeb95743746d3c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.1.0/funsecret-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.1.0/funsecret-aarch64-unknown-linux-musl.tar.gz"
      sha256 "333f2fc3e03930652944b662706f18900dc278d1343d2baf0d929cec5d1a9788"
    end
    on_intel do
      url "https://github.com/farfarfun/funsecret/releases/download/v2.1.0/funsecret-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funsecret/releases/download/v2.1.0/funsecret-x86_64-unknown-linux-musl.tar.gz"
      sha256 "8497f38b8bf81b884ade367130e4af6a3b9222a3cbc85da297396a4d321147fa"
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
