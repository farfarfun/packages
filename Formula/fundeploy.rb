class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.31"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.31/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.31/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "b8894db05b6bcca0d276bcfa97a1ac1cd35d3fbccec7b63b9fcba464f73ba159"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.31/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.31/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "64f4ae4e903300ee44aa12721ab305ef388328421119c10ce511c1371cd1de60"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.31/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.31/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "eaddb5813b29f7bd7e83489457e3e8a2c2997ca8ec6f61976fcaa8dcca981964"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.31/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.31/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "3a7a8ab76890ef86c9632e6fcd252831057ae32590001fa8fd521020f33c065d"
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
