cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.0"
  sha256 arm:   "b7c966fb649a6994b5da20254d77d15934985b22b95537a8387bc11fad52a522",
         intel: "a4b9ed0c3cfe0c539c1fdda313d4cfaf1b25f41c1e12e974d77074276327421b"

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
