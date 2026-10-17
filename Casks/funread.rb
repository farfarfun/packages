cask "funread" do
  arch arm: "arm64", intel: "amd64"

  version "1.1.126"
  sha256 arm:   "63905d17f9b1bbde60d0cac3c3fe793572f012091c29a926d72c215ac27288b6",
         intel: "43fad5f8b72b6b2f0368ddadfcfdd1ba4babf8f75edda4490715bc123227f8c9"

  url "https://github.com/farfarfun/funread-web/releases/download/v#{version}/funread-#{version}-macos-#{arch}.dmg"
  name "funread"
  desc "Self-hosted reader for novels and RSS feeds"
  homepage "https://github.com/farfarfun/funread-web"

  depends_on macos: :catalina

  app "funread.app"

  zap trash: [
    "~/Library/Application Support/com.farfarfun.funread",
    "~/Library/Caches/com.farfarfun.funread",
    "~/Library/Preferences/com.farfarfun.funread.plist",
    "~/Library/Saved Application State/com.farfarfun.funread.savedState",
  ]
end
