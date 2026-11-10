class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.28"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.28/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.28/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "e2d8537d59669dad9b28f52ae38c29636e8208666d3c0d8926c0e46087a83a54"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.28/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.28/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "54bd04cc8b731c0d55f869af33a4df83f4633dda709f7df528a996a7b26aec4c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.28/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.28/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "24efd60cc7d7399220fc45ea824fac532fdcf7f0be0a2f4e3cd39b99bc1c09d2"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.28/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.28/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "48a3c185bfdc44be03a7274f883a3f036106901373a36560d169bd8547aae371"
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
