cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.14"
  sha256 arm:   "d094c86869048cd98973417c47e7ee30b01050a9eff2709e229507b3fc5b49e5",
         intel: "edbd9bd3f51d66cd5811106eee0ad017cb84df7ad69179b992853bb4da66834d"

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
