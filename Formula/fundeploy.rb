class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.10"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.10/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.10/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "ca5101f3cd9ddd5a357389938879e9ae0cbe26e057125593eb7e4b577cad3e79"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.10/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.10/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "de76c3ce259070c69fab7952f94131ab787136838bfd94f1392b0dfa64366bd5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.10/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.10/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "2d9f4fbbe804b1c8e80e0f92fea8cd1ec1323ec1ea99ea4893436ce9001c9b11"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.10/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.10/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "fdae02b1287838260a7d967e8dcb81cafd26bd070724d4493fb4c2f7023fc695"
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
