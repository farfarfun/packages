class Funget < Formula
  desc "HTTP file transfer tool with ranged concurrency and resume"
  homepage "https://github.com/farfarfun/funget"
  version "1.2.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funget/releases/download/v1.2.0/funget-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.2.0/funget-aarch64-apple-darwin.tar.gz"
      sha256 "f101fe72ef4d6f05592a2e002f1861381374236563e57d3f0a6ecbd310218933"
    end
    on_intel do
      url "https://github.com/farfarfun/funget/releases/download/v1.2.0/funget-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.2.0/funget-x86_64-apple-darwin.tar.gz"
      sha256 "21c7318d35aeebb37647c57cf3e27174d626cbbbcfc8b839d45c7731b1c112b8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funget/releases/download/v1.2.0/funget-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.2.0/funget-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d95e615e476d634faf86f7219af7a7d904143d7ef1062421dd6c56d32f2a2a7c"
    end
    on_intel do
      url "https://github.com/farfarfun/funget/releases/download/v1.2.0/funget-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.2.0/funget-x86_64-unknown-linux-musl.tar.gz"
      sha256 "5413e203f1a1b19f478ed9a13e9e7036587448b1809045e221313714fa9d9ac4"
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
