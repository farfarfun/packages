cask "funread" do
  arch arm: "arm64", intel: "amd64"

  version "1.2.5"
  sha256 arm:   "6dcb85f80758ffe61893ce8580cc894600f309d38d83f430e2869bfc63da5566",
         intel: "ed440e705d7490af52e9458a5cb246e1886c81a15418eff59ef7abb61818292f"

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
