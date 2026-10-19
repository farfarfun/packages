cask "funread" do
  arch arm: "arm64", intel: "amd64"

  version "1.2.4"
  sha256 arm:   "44d9254383caab2cbf2ec59410d66a53e0199e59f9b95cfcf6e60dba840c7f42",
         intel: "1a89af429173f3c305856c0c7b0f106a92503ec5e67b855ddfd2f6777b518ed3"

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
