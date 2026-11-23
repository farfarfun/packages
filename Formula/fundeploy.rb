class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.34"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.34/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.34/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "e5b2402f05f1351af33c17ee121b40ca7d7b940374beaf68ee2a8afe1d4a307f"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.34/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.34/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "712ce4c32259c48bdc5e532bd03177d3bf1e1eefca95f9d7791f201957d17736"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.34/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.34/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "044df42efa179441e50cace5c136c8c62f73bac389d11ec2b93f8f0d77e2a6d5"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.34/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.34/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "62238e45706082a67872adb77b2402a75bc16dec5e265db3a3c5708625d20384"
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
