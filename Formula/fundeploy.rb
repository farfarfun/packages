class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.13"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.13/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.13/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "d673843d347de81c3682e09e95da16ea397d6226ca7f3068693bc362679c6c60"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.13/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.13/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "25e5796797562e322b7982719414ab2a4cfb5d4cb69a896ac8ce5aef98c5ddde"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.13/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.13/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "b04d66631c91fd5fb3c3786e68a41293299d411ac5e534baac1b21a260b3f95e"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.13/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.13/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "26bddb1cb36a9773da1637cdc992f0fa750b6494cb107f55fbf54b13bac70f74"
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
