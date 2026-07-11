cask "usage-menubar" do
  version :latest
  sha256 :no_check

  url "https://github.com/ilyakooo0/usage-menubar/releases/latest/download/UsageMenubar-latest.zip",
      verified: "github.com/ilyakooo0/usage-menubar/"
  name "UsageMenubar"
  desc "macOS menu bar app showing your Hyper credits and Claude Code usage limits"
  homepage "https://github.com/ilyakooo0/usage-menubar"

  app "UsageMenubar.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/UsageMenubar.app"],
                   sudo: false
  end
end
