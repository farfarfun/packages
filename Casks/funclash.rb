cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.3"
  sha256 arm:   "7d745be61116d988e1d28323db050855274f188759a022a53f855cc6c23f3f51",
         intel: "e9fb59b612191f6e12bdae594554b724747177af722652ce83eb1acf78f0c8b0"

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
