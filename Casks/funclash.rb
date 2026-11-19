cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.18"
  sha256 arm:   "ad4b50d148c10edcda32020b2c8d47b6147aa3896d5b3040024f930e9c219aba",
         intel: "0ee5cd77cb8d444289f4bd3f429d3230055236bba26c6451a1cce5993aa7715e"

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
