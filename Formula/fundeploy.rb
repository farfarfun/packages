class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.12"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.12/fundeploy-aarch64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.12/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "645324e86edaf354c8587a2513070af4fa033f55b7f2e53b409b6ee7658afc46"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.12/fundeploy-x86_64-apple-darwin.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.12/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "a8a856e15f8424712906177cc4500d8da89cfdc74bbc71ec83983163485d2559"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.12/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.12/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "442ef4c56bd7fc5b371fa68530c472b12296c22bffbc556a698e6c33c832cacd"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.12/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      mirror "https://gitee.com/farfarfun/fundeploy/releases/download/v0.3.12/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "c96a484723e44114f38eb8fc97483ba603eeed6660eaa3ce9e5f95f69a33f97d"
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
