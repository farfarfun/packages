class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.36"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.36/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.36/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "2b838f09a5b2bbaff45e98acda76790e1da960489d6c92610ae220a2a2dba313"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.36/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.36/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "652f3d1f833f90267af0e416e8216dfaf181759a9d6774bfb211b849f7be1bec"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.36/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.36/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "28f49fce5b38a5d60a00c81159b3b9a21db6c717046ca09576daa77f03b5bf8c"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.36/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.36/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "0f585216d0013a47b6dfc14a6172aebe6ac59e36783152175be73bd3d6f6ee43"
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
