cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.1"
  sha256 arm:   "0f38dbab027969aab31fa543a2fe96fa2f1f2e4cf435dc51f9627c9d070d65a0",
         intel: "8f11a3081277596c049b21c04d3fdfbb881d039b7d83b3fdb03eac77e333457e"

  url "https://github.com/farfarfun/funclash/releases/download/v#{version}/FunClash-#{version}-macos-#{arch}.dmg",
      verified: "github.com/farfarfun/funclash/"
  name "FunClash"
  desc "Multi-platform proxy client based on mihomo (Clash.Meta)"
  homepage "https://github.com/farfarfun/funclash"

  depends_on macos: ">= :monterey"

  app "FunClash.app"

  zap trash: [
    "~/Library/Application Support/com.farfarfun.funclash",
    "~/Library/Caches/com.farfarfun.funclash",
    "~/Library/Preferences/com.farfarfun.funclash.plist",
    "~/Library/Saved Application State/com.farfarfun.funclash.savedState",
  ]
end
