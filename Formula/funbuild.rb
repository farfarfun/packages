class Funbuild < Formula
  desc "One-command release pipeline for Python, frontend, Flutter and Rust repos"
  homepage "https://github.com/farfarfun/funbuild"
  version "1.6.109"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.109/funbuild-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.109/funbuild-aarch64-apple-darwin.tar.gz"
      sha256 "6213ec2d9a91d33396a97ea05f2bd07439c29d8fe835ac4f670af9834e9b7277"
    end
    on_intel do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.109/funbuild-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.109/funbuild-x86_64-apple-darwin.tar.gz"
      sha256 "4674ef62f051f6893631ad77ef13e4a366c3bf2a643f870ea879bcfcbb07a295"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.109/funbuild-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.109/funbuild-aarch64-unknown-linux-musl.tar.gz"
      sha256 "8318b204deb3cafe47e4388af12d87f0140370f1fcb3c35fc4c8782855795ec4"
    end
    on_intel do
      url "https://github.com/farfarfun/funbuild/releases/download/v1.6.109/funbuild-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funbuild/releases/download/v1.6.109/funbuild-x86_64-unknown-linux-musl.tar.gz"
      sha256 "9a2311d1c8e2effc315e569f49d2c95a290afb7d1ab49609b4b56f1353c20cd0"
    end
  end

  def install
    bin.install "funbuild"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/funbuild --version")
    assert_match "build", shell_output("#{bin}/funbuild --help")
  end
end
