cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.21"
  sha256 arm:   "d31eb1922f01349e23524a8ca19ea17e5c22227b36de937e9f45d2636f25b26d",
         intel: "436a72f576ad2b4bc8b6c5f184232790d332beb05ca004b4d5264417a988530f"

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
