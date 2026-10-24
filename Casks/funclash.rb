cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.11"
  sha256 arm:   "f215b1629ce7425876bf5567c0bc3c5c72b9f167f761b75123555fec1adb8245",
         intel: "7cee48db3cb548fc8d5221db65fb60442a831e4b84da5e8dfc894202854cda50"

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
