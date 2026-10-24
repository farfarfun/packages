cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.9"
  sha256 arm:   "e936abe2cd1a40876e78c02dd57eaf1a96fa35acd9fa2b565e8dc5ff7acc6f4f",
         intel: "12ddf70ce44adfb6d6c7517b342a8e641e2f94ccc97363bb0105effc6a08ace6"

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
