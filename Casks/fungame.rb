cask "fungame" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.1"
  sha256 arm:   "4553ada54bcd9cf98743b7012d616e1875e969ddd9b6cf956626028fda69ea92",
         intel: "6ec6994d07e63d58e4f4b7616735c33f0d0cb5155c1d6c2769e0730a10874eb5"

  url "https://github.com/farfarfun-game/fungame-client/releases/download/v#{version}/FunGame-#{version}-macos-#{arch}.dmg"
  name "FunGame"
  desc "Desktop shell for FunGame that opens a configurable server address"
  homepage "https://github.com/farfarfun-game/fungame-client"

  depends_on macos: :monterey

  app "FunGame.app"

  zap trash: [
    "~/Library/Application Support/com.farfarfun.fungame",
    "~/Library/Caches/com.farfarfun.fungame",
    "~/Library/Preferences/com.farfarfun.fungame.plist",
    "~/Library/Saved Application State/com.farfarfun.fungame.savedState",
  ]
end
