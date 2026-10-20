class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.16"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.16/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.16/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "123ea72e77cdfb2cc04c55055788ce0309e518de9f469316a183bcf2039c8dad"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.16/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.16/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "ad94c254542183facb6fdc16921e86b494b67c51a7cfea62147390a142ce0591"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.16/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.16/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "fd1161a2ce76e566ef83d92e16da0c5ab4b85fd0c3d8b2e14fd618eeb4ec4c61"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.16/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.16/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "b4a15ca25e361025ddd9c9f1a5e452e4184ea90be00ffbda7b0648cd6dd1f6ff"
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
