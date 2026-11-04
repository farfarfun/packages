cask "fungame" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.68"
  sha256 arm:   "65d2f03c85a3549d2c26be86a0fc37ad83dd3daa009ed4fb31ecdb08b75c8766",
         intel: "00bd751d8370d438d8f2f52497d300dc78434ff141c8d25faef1eb916d73eb9f"

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
