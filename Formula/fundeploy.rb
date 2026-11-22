class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.33"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.33/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.33/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "e00fcc967fe8fc20ee8a8d3182fb5f286bf08988731ca48bb0fb3b30ecc24698"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.33/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.33/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "ec2989a7217ebf9563f0c30b1b9a1445bd640b1d75c6b5f53ca696e07c76eddc"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.33/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.33/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "0aabbb60060727d80c80450917e349ca1557c127b52da2d5742dafc35da803cb"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.33/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.33/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "b2cf42725b5a50d08bb94a458242abc1b00acf716653f3ed861ab574fbcd509d"
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
