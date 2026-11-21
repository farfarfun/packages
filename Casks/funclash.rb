cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.19"
  sha256 arm:   "085eb2b550b024f2ce33ea523425c368b054b4e50998bacf18323551358684ce",
         intel: "512ee7e77a8a9f20a32389df58536d6312b329972d6aaa8a6012457ca6aa70bb"

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
