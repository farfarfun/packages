class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.27"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.27/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.27/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "02ba498aa54f0c59996a222b0c225fe4a612fe04f80b12b859fb3374d552753d"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.27/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.27/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "35f729340878ebdd29f954fa301257d308ecb5dd03bd414fc2f9d0f82d656339"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.27/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.27/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "be595eafd194681289473839c1236a63a7ab9ff621ff637e2842ae23eb1554c2"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.27/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.27/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "89089fc85bb930e55006bcea4659b64c6d2c68758857276dbbb0f83769425ba0"
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
