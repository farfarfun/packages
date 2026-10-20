cask "funread" do
  arch arm: "arm64", intel: "amd64"

  version "1.2.9"
  sha256 arm:   "46781f96e30f6e543d2910e8260456010c3ed2831f81e3cbaefeabb09ff438f4",
         intel: "2a3ec87f202618b613511b93f8563d3bffe852dab8b44f80161cbc3430412044"

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
