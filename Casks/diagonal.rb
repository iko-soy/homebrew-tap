cask "diagonal" do
  version :latest
  sha256 :no_check

  url "https://github.com/iko-soy/diagonal/releases/latest/download/diagonal-extension.zip",
      verified: "github.com/iko-soy/diagonal/"
  name "Diagonal"
  desc "Brave extension that groups and names tabs with Apple's on-device model"
  homepage "https://github.com/iko-soy/diagonal"

  depends_on arch: :arm64

  # The unpacked extension lives at a fixed path so Brave keeps loading it across upgrades;
  # install-host.command (shipped in the zip) installs the native host, registers it with Brave and,
  # if Apple's terms for fm are not accepted yet, runs `sudo fm license` so the user can read and
  # accept or decline them. Kernel.system keeps the terminal attached for that prompt.
  postflight do
    extension = Pathname("~/Library/Application Support/Diagonal/extension").expand_path
    FileUtils.rm_rf extension
    extension.dirname.mkpath
    FileUtils.cp_r "#{staged_path}/.", extension
    system_command "/usr/bin/xattr", args: ["-cr", extension.to_s]
    Kernel.system "/bin/bash", "#{extension}/install-host.command"
  end

  uninstall_postflight do
    FileUtils.rm_rf [
      File.expand_path("~/Library/Application Support/Diagonal/extension"),
      File.expand_path("~/.local/share/diagonal-host"),
      File.expand_path("~/.local/bin/diagonal-host"),
      File.expand_path("~/Library/Application Support/BraveSoftware/Brave-Browser/NativeMessagingHosts/io.diagonal.host.json"),
    ]
  end

  zap trash: [
    "~/Library/Application Support/Diagonal",
    "~/Library/Logs/Diagonal",
  ]

  caveats <<~EOS
    Load the extension in Brave once:
      1. Open brave://extensions and turn on Developer mode.
      2. Click "Load unpacked", press Cmd+Shift+G and paste:
           ~/Library/Application Support/Diagonal/extension

    If you declined Apple's terms for fm during install, Diagonal
    waits until you run: sudo fm license

    To update: brew upgrade --cask --greedy diagonal
    then click reload on Diagonal in brave://extensions.
  EOS
end
