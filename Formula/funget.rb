class Funget < Formula
  desc "HTTP file transfer tool with ranged concurrency and resume"
  homepage "https://github.com/farfarfun/funget"
  version "1.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funget/releases/download/v1.3.0/funget-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.3.0/funget-aarch64-apple-darwin.tar.gz"
      sha256 "d2677a81a3b86886b571ed45c321d2060e130feb09d791641a088ba19a420530"
    end
    on_intel do
      url "https://github.com/farfarfun/funget/releases/download/v1.3.0/funget-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.3.0/funget-x86_64-apple-darwin.tar.gz"
      sha256 "221a4d15df5f0ba05a5ac1d956729ccf3e7038e3ccf90c8fba6ce16cabcd63e2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funget/releases/download/v1.3.0/funget-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.3.0/funget-aarch64-unknown-linux-musl.tar.gz"
      sha256 "69fe9051ea410e830e42841d315b9b1a9ada31f2dad88bf9028cf1669912df80"
    end
    on_intel do
      url "https://github.com/farfarfun/funget/releases/download/v1.3.0/funget-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funget/releases/download/v1.3.0/funget-x86_64-unknown-linux-musl.tar.gz"
      sha256 "bc1135cc5971d051ca445694cad000374d9ce324a015fb93d88a75afaa439e24"
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
