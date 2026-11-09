cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.17"
  sha256 arm:   "b320ef7e06fb16e62c14ce050db3a16fc2f2cd055657a3c6a4c1f8b3a45458b5",
         intel: "d905d578d54423a016eb8955877387ecf95aec689e45c7df070480bf38a2b310"

  url "https://github.com/farfarfun/funclash/releases/download/v#{version}/FunClash-#{version}-macos-#{arch}.dmg"
  name "FunClash"
  desc "Multi-platform proxy client based on mihomo (Clash.Meta)"
  homepage "https://github.com/farfarfun/funclash"

  depends_on macos: :monterey

  app "FunClash.app"

  zap trash: [
    "~/Library/Application Support/com.farfarfun.funclash",
    "~/Library/Caches/com.farfarfun.funclash",
    "~/Library/Preferences/com.farfarfun.funclash.plist",
    "~/Library/Saved Application State/com.farfarfun.funclash.savedState",
  ]
end
