class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.22"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.22/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.22/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "2c1792131fac785ead96c8080d57492c61b22ed6f54380f5d09f22c7ecd18eb7"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.22/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.22/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "51de219de9de5db95b85a5fc9b67ed8aedea0aafbf9af68d6dede83532ae1b37"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.22/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.22/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "efe8df8fd7583784ccb29842fac11777de43c291b336b0d54e0cad060404248a"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.22/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.22/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "af3f9a3c32ea7de24ec53fa575a12ac62a4bd4c52da0f3756edbf7e90e95b7fb"
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
