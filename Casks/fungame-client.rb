cask "fungame-client" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.0"
  sha256 arm:   "b67337293127d26530b104ca8de2deeed6c5289542854614227a273ce25ab70b",
         intel: "3d19f955b609cc06d52b812cfc3b83a98e8d7a09859009afba11c17e6cbf1c19"

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
