cask "funread" do
  arch arm: "arm64", intel: "amd64"

  version "1.2.10"
  sha256 arm:   "7599ad20edeaffe24bc84be6d6af35ada7455c535ffe2ad706a12e0ecaac7033",
         intel: "5e92d485c8a4fb4f1b7e62a11d1fb0b30449a748334afb7c9a11e2bdbae39633"

  url "https://github.com/farfarfun-read/funread-web/releases/download/v#{version}/funread-#{version}-macos-#{arch}.dmg"
  name "funread"
  desc "Self-hosted reader for novels and RSS feeds"
  homepage "https://github.com/farfarfun-read/funread-web"

  app "funread.app"

  zap trash: [
    "~/Library/Application Support/com.farfarfun.funread",
    "~/Library/Caches/com.farfarfun.funread",
    "~/Library/Preferences/com.farfarfun.funread.plist",
    "~/Library/Saved Application State/com.farfarfun.funread.savedState",
  ]
end
