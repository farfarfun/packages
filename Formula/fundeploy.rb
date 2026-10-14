class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.3/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.3/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "23f926c71daf04d46281c99ca544a8012c4a50f054c6fc6a855da8eedf998a85"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.3/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.3/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "c76d298c4d503ed249f9c4b4d6c24dca1afbe746a8f9fa8d92aa4c0d88e8e25b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.3/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.3/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d9e958a37027f757b7c6f071ff4a49f65643a5bb1ed588a9cc30fb98a6e0cd73"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.3/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.3/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "77e5e97ea1564e06f5a3ced4a069dedd43c7a3ffd22ab90f025943eda9833188"
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
