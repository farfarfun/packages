class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.15"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.15/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.15/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "bab03e463a15f2ffbd1465c51a80cc849cb4e767802aa91ed57251e4e337f241"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.15/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.15/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "a4ad45fc8faaa0b35132729ba8c2d93291b0c6d7bbd95460d386d9617feb3e66"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.15/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.15/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "c85d6094e2838a1d6baf0832ab4bd405ddcec9528b9df588d893623e1d0d7878"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.15/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.15/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "2094ddce94a46f75d26ffe65be0dcfdd075d565488647f4b7143f99acfec82e0"
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
