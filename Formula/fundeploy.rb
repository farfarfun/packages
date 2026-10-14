class Fundeploy < Formula
  desc "Manage development toolchains, local services and package mirrors from one CLI"
  homepage "https://github.com/farfarfun/fundeploy"
  version "0.3.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.4/fundeploy-aarch64-apple-darwin.tar.gz"
      sha256 "a329506dd1444340562dc124a4f7ef16e81bf215c0696b6df29f58593c1438cf"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.4/fundeploy-x86_64-apple-darwin.tar.gz"
      sha256 "7adb2d75444e2494ca59e896d2cb3de56323f32c988d1d18f8fe66e0a9b820cf"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.4/fundeploy-aarch64-unknown-linux-musl.tar.gz"
      sha256 "3d3e17bb8ca129d73fe2d4ca73befd9f326847210e784a0726056802801fc302"
    end
    on_intel do
      url "https://github.com/farfarfun/fundeploy/releases/download/v0.3.4/fundeploy-x86_64-unknown-linux-musl.tar.gz"
      sha256 "b2534f4c52569c6d3cf027fa50502eb9435a21b84e5b496315c365d2a6a08980"
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
