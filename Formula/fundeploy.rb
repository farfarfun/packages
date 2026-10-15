class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.6"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.6/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.6/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "115a6ab55e8c25f7edcfe29856284c88ee3b1cb8b53b0ae4bfca8d317e4419f3"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.6/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.6/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "0d3e596f3a2fee96ab2e5022669a88aab091379951c88f049ff38d6ba9bced27"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.6/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.6/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "297752f6c1b7d4669ae0680f2f24f60d1b089d8e924182edc63237492aee0c0f"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.6/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.6/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "9ee6bd101b13f95235c37f841683bb8d85ff47d7326f5478fd7cfb135fe1ab6a"
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
