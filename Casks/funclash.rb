cask "funclash" do
  arch arm: "arm64", intel: "amd64"

  version "1.0.15"
  sha256 arm:   "fa592d471335d426eb8612fadcc38dc3e950ff42e713321e47d5a45724410848",
         intel: "f7a3886fe1bad6cf588935af9f1145e11128530a8959c8cb4d9e345005eeb060"

  url "https://github.com/farfarfun/funclash/releases/download/v#{version}/FunClash-#{version}-macos-#{arch}.dmg"
  name "FunClash"
  desc "Multi-platform proxy client based on mihomo (Clash.Meta)"
  homepage "https://github.com/farfarfun/funclash"

  depends_on macos: :monterey

  app "FunClash.app"

  zap trash: [
    "~/Library/Application Support/com.farfarfun.funclash",
    "~/Library/Caches/com.farfarfun.funclash",
    "~/Library/Preferences/com.farfarfun.funclash.plist",
    "~/Library/Saved Application State/com.farfarfun.funclash.savedState",
  ]
end
