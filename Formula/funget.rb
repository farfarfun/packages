class Funget < Formula
  desc "HTTP file transfer tool with ranged concurrency and resume"
  homepage "https://github.com/farfarfun/funget"
  version "1.4.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funget/releases/download/v1.4.0/funget-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.4.0/funget-aarch64-apple-darwin.tar.gz"
      sha256 "d2eef3145bdf56d029836329094e7b0685c04f945ae5ce6544c537f0795f7e30"
    end
    on_intel do
      url "https://github.com/farfarfun/funget/releases/download/v1.4.0/funget-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.4.0/funget-x86_64-apple-darwin.tar.gz"
      sha256 "7fbe6c6320f5c41a4cb1d8072483c810fa273e71e1b93de00b32754b7dcd1ae1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funget/releases/download/v1.4.0/funget-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.4.0/funget-aarch64-unknown-linux-musl.tar.gz"
      sha256 "e41dd2253e2c4496a4f1ae40cb92d3fd309782fc2132df2e979e4e7032732cc5"
    end
    on_intel do
      url "https://github.com/farfarfun/funget/releases/download/v1.4.0/funget-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.4.0/funget-x86_64-unknown-linux-musl.tar.gz"
      sha256 "863de61e4080f5a0b4b113a7e60fd1bf6d23173c4b9ad30c0468a4b8dc29e419"
    end
  end

  def install
    bin.install "funget"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/funget --version")
    assert_match "download", shell_output("#{bin}/funget --help")
  end
end
