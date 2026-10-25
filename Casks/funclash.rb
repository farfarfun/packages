cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.13"
  sha256 arm:   "c6cadca86b71e9706f524498b1e764f880d7423391221b285b205b50e8ed200d",
         intel: "a185f9a0954f535a5f18b35b08a81c979817a43350cd16fa252d39492b2df4fa"

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
