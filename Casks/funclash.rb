cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.8"
  sha256 arm:   "86e03240dfec1758d4a787b4dc0d4b53d0f311ab73c79a9ac28b8155ec3307c1",
         intel: "c26c9ad4472c6df6303929a37e107335fe1bbf89d2ac499b9d27161168c8056b"

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
