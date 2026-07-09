cask "hyper-credits-menubar" do
  version :latest
  sha256 :no_check

  url "https://github.com/ilyakooo0/hyper-credits-menubar/releases/latest/download/HyperCreditsMenubar-latest.zip",
      verified: "github.com/ilyakooo0/hyper-credits-menubar/"
  name "HyperCreditsMenubar"
  desc "macOS menu bar app showing your Hyper (Charm) credit balance"
  homepage "https://github.com/ilyakooo0/hyper-credits-menubar"

  app "HyperCreditsMenubar.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/HyperCreditsMenubar.app"],
                   sudo: false
  end
end
