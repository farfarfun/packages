cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.7"
  sha256 arm:   "06d483e56d13a993fd0f1c4c93e072f807d107acc781305bbfb9d8c4c1b3fc6d",
         intel: "21defa0f56c670fb80147dbd5686a0f4b2d8b0718e6feb77c319568ec74a5f60"

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
