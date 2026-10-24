cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.12"
  sha256 arm:   "1465364cbe6e041b506af00f7e2d14b7d6e2c49ca9ac55d3a4cbfd14f8ae98db",
         intel: "092486a7bd2274e5a0e8b1fcf2b9c9b22ac40069730b5fba77b2971dbe3dbaae"

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
