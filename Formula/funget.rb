class Funget < Formula
  desc "HTTP file transfer tool with ranged concurrency and resume"
  homepage "https://github.com/farfarfun/funget"
  version "1.1.73"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funget/releases/download/v1.1.73/funget-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.1.73/funget-aarch64-apple-darwin.tar.gz"
      sha256 "b26427a0564018e9df1caeedcf2d0488193b1b9ac2ec3625ccb39d7364313503"
    end
    on_intel do
      url "https://github.com/farfarfun/funget/releases/download/v1.1.73/funget-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.1.73/funget-x86_64-apple-darwin.tar.gz"
      sha256 "1b07212b994d3e3403395b298be855ce24ce3354920cab0966f1584d7f6b9f90"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funget/releases/download/v1.1.73/funget-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.1.73/funget-aarch64-unknown-linux-musl.tar.gz"
      sha256 "f9b8c9081a4db97006ea500c35cf714f8b21fefc2a077d8906168856564d511b"
    end
    on_intel do
      url "https://github.com/farfarfun/funget/releases/download/v1.1.73/funget-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.1.73/funget-x86_64-unknown-linux-musl.tar.gz"
      sha256 "a33b9a2ad63b7ace3ef84f993a9b422479d73eda6e950c6dd3f7838baa3867d1"
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
