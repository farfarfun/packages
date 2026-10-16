class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.11"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.11/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.11/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "29b06810a21e78622c2d30fe348f9e50cf1f33fa2537b7bf164c11e3fcf405d8"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.11/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.11/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "fa7a4df0ccb24715f3d999351e5038c2365830e9cd66aefa8818dcb110fe49b7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.11/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.11/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "f883604fccdb1fb0f2944c10b661ee995b0e11f78d12de3995237a31b4a6bbb2"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.11/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.11/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "6f8167af7b1cb6515f863095fcaac44c264e0e36668ff82b2a5f706eb604aab7"
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
