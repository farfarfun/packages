class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.8"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.8/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.8/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "26e9c42a34e47f06d67635e36595eb1ef20134f36b99439326baaf09c2591c8b"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.8/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.8/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "3b35b083741e9e94764b41ef19c2223bb43c4dacf18eedc169dc45a299b021e4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.8/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.8/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "ffebcabbe3e7f4524aa3e2eb7eabea7159ea0414e60c6e7c026b9974924f754f"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.8/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.8/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "d6e284c70cfbaffb236afdfa95cab411a4387800ee948b8bf66fea3a2fd10c2f"
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
