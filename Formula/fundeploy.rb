class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.7"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.7/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.7/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "e0980a95599237caacfbee000346bcb1654b95e34f7c84b62f4a26d840b7efd7"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.7/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.7/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "49f5531ff7067538b213c3e48d24f4ca13a1b19fa2048dab521cd882a1a46bac"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.7/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.7/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "aee598443772034799294ec965fb875ff272631a4b19019370cdd89705399ba0"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.7/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.7/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "15b542fb8ecf3d142c39d3dc25f3cf78947ba6a2306cdeb68905420c8c78d9ed"
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
