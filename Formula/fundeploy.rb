class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.17"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.17/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.17/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "731bb22699cc28c2027fa19bee0c149df6d31bef3a44d5be9b8b6b2b020094e8"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.17/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.17/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "25fd1007a15bf684ef102d550acc434190c3689e8ee826c1046654c4b5fb1855"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.17/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.17/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "2bdfa0f68ee62adb632b2280c4bf60fb485af1d37849bad35af00300dfefb6a7"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.17/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.17/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "6b302fd1f4b5812655c9d18bef5747cede8bc0ef9f579488813f503d026976b0"
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
