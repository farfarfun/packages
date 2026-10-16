cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.2"
  sha256 arm:   "87e07bf774164c3a56ca5656194f23e45273e0c1e48707df65b6441a79e6893d",
         intel: "1bf40dc260e600a37917bb07d9b7f0ac92aefec327668b279c0ba70d1f4f8e86"

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
