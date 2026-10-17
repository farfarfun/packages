cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.5"
  sha256 arm:   "9a443aec4394885a5a6ef83b0a72b34b4c30238df57456c588a5aa1eac40223d",
         intel: "d5df5f1e178b787e2a65ccfe1647d74afde64b11ed81f7734fc4675281f70842"

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
