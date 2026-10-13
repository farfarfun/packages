class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.2/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.2/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "4e710adc05eda2f13d2ff604ef704514c0dce974ecf7af1ae7556d7075b331df"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.2/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.2/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "75ab414af479baa84946c4acec641d0c4f99644bcc3133170b62b41d271f850a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.2/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.2/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "38145588ed622f300d3a96f7589b7301a766bb3beb29af5d605e1a0303ae27d0"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.2/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.2/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "3ace9b8b197a6be526b777b1505e00a4ce7a2a4805c1ffde19ee721ccd1fd4bf"
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
