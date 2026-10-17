cask "funread" do
  arch arm: "arm64", intel: "amd64"

  version "1.1.127"
  sha256 arm:   "c9c4f16661de11c564e5fc53d68b80ec30bdd10cf4125b81c99cf900741ed278",
         intel: "e3a22f347366fdc433ee1e4c2321b36e7e99177c7349012a2c8e30691e5eba87"

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
