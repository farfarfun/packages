class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.20"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.20/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.20/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "4c18fe75c84ca52f41b187ec0f04deab68f98f8de3053092b8d5face3f547ae2"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.20/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.20/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "a53b0c09d09a9017a2be64c4d2116a1443b8f6e5f2a67d6a2479169a4c9b0834"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.20/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.20/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "8ba4ba5c1ec7741cc606e53d7f28e64407778e8514daafb95d5d1a56aa118368"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.20/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.20/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "7fa4022b62f79481227bc50e24ab4fd86f5daf2242918631654642ecca0edee1"
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
