class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.32"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.32/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.32/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "53d4b1363c8bfa7f25a292dd2846d8e10721e6be8ef854136d3262b7fe942c94"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.32/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.32/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "3b885b2add0014a5d02e3c5b35606d827276d01b09dbb9acaeac846449b2eb18"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.32/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.32/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "6de567d8c413696de984c20be26babf2968baba2fd847046063ffda60027ec80"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.32/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.32/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "d4f99de63cc5eaed0da00c42db407cc7ea6de8e78cc9786a386fa37d415898fe"
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
