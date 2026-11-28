class Funpub < Formula
  desc "Multi-channel artifact publishing CLI powered by Rust"
  homepage "https://github.com/farfarfun/funpub"
  version "0.2.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/funpub/releases/download/v0.2.0/funpub-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funpub/releases/download/v0.2.0/funpub-aarch64-apple-darwin.tar.gz"
      sha256 "7e813778a983b71e97153ceeb67ebcc65f69462ea9fd48aedbba8ccdd4144127"
    end
    on_intel do
      url "https://github.com/farfarfun/funpub/releases/download/v0.2.0/funpub-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/funpub/releases/download/v0.2.0/funpub-x86_64-apple-darwin.tar.gz"
      sha256 "bd7ecb7c478c7b72c3dc203f0483278c24e814b0c91dc29e7eff803ab87ee90b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/funpub/releases/download/v0.2.0/funpub-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funpub/releases/download/v0.2.0/funpub-aarch64-unknown-linux-musl.tar.gz"
      sha256 "0c981537874f69cf16959de4754daa914d486751c233719942cb91beeb797f8b"
    end
    on_intel do
      url "https://github.com/farfarfun/funpub/releases/download/v0.2.0/funpub-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/funpub/releases/download/v0.2.0/funpub-x86_64-unknown-linux-musl.tar.gz"
      sha256 "9c1e0fc3628414a67bf208b4965af167a630febbd96524b9ca5199216045d0d5"
    end
  end

  def install
    bin.install "funpub"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/funpub --version")
    assert_match "aliyun", shell_output("#{bin}/funpub channels")
  end
end
