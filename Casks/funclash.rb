cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.20"
  sha256 arm:   "6744e3f001def94cfe25ad029969746181b759bd44adb181ff800f7025e7ff32",
         intel: "a893ebfd870520159e01ed05c78f9ed009e47765b4e82cd88e62f9db8021a5e2"

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
