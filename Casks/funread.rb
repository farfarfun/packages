cask "funread" do
  arch arm: "arm64", intel: "amd64"

  version "1.2.6"
  sha256 arm:   "d0245a8c576cdff693ef56a6db036e91132cc7c23bd9352ecae1d2bfda046e00",
         intel: "84b1b0aabef4e935c356a264e4946a87517d91b9bfef4dddc0b862b0035b7f83"

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
