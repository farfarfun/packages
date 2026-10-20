cask "fungame" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.2"
  sha256 arm:   "8af98bbd580023c5a446f372baa2041ec535853f58605c1e448b6a7ccc9f550f",
         intel: "c4565aec1060356e69a12df298e0dd5c5e7437caa524d12c79586dde9b603b1d"

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
