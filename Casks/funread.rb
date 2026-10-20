cask "funread" do
  arch arm: "arm64", intel: "amd64"

  version "1.2.8"
  sha256 arm:   "96ab7c63733f5eeeddc375e6999de719e7dedf27701cac9437bd6bebf896811c",
         intel: "08cf26c5bcfbe6840abd088583d8558307b6b34967e47cf7dc6c174b59ad7abe"

  url "https://github.com/farfarfun/funread-web/releases/download/v#{version}/funread-#{version}-macos-#{arch}.dmg"
  name "funread"
  desc "Self-hosted reader for novels and RSS feeds"
  homepage "https://github.com/farfarfun/funread-web"

  app "funread.app"

  zap trash: [
    "~/Library/Application Support/com.farfarfun.funread",
    "~/Library/Caches/com.farfarfun.funread",
    "~/Library/Preferences/com.farfarfun.funread.plist",
    "~/Library/Saved Application State/com.farfarfun.funread.savedState",
  ]
end
