cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.6"
  sha256 arm:   "d3aa012df50d4b8724e268450abff2025e617b4650457b1506ecdb14192f2b16",
         intel: "cf451002639a51e6aa95dc75f728690ef866d9ad844350463113df0c734f3442"

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
