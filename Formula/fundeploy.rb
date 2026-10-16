class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.9"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.9/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.9/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "4852fc38fa8b26b7887ba83d89edbb8ade31874ed7e996ef5bbc49448d343e15"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.9/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.9/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "7d7257d80f886f333b23398f70348f69714f7430cbbcf56c8afc35f941cdeadf"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.9/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.9/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "abc6fdd0772b89f2a624cb2a9b535594b10fdd5c16ce66d29bada3357723f16f"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.9/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.9/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "89126a05dbc8ffe8229886046f24f8546a237e90e21c044185b21768e83684a6"
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
