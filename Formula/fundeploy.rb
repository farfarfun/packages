class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.29"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.29/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.29/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "7c2255b0cd0d78a3ad195826f97fb4e741d765925b956aa6ac1a73dfd9f9e9e9"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.29/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.29/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "ac889fe633d3b1ee01b97a278d9bd38129b5f016313d908999e828e898450836"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.29/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.29/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "0fcff905f04f2275cb1ea16642d293829a67ab588b4c6792a25dbea3ed7962bc"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.29/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.29/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "373d949ee27d3c6ec3696b44508f9351c3a6095ccce9364ceb81e26f28253f92"
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
