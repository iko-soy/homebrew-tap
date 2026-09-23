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
    # Anything raised here makes brew roll back through uninstall_postflight, which would delete the
    # extension and the host it just installed, so report problems instead of raising.
    extension = Pathname("~/Library/Application Support/Diagonal/extension").expand_path
    manifest = Pathname("~/Library/Application Support/BraveSoftware/Brave-Browser/NativeMessagingHosts/io.diagonal.host.json").expand_path
    begin
      FileUtils.rm_rf extension
      extension.dirname.mkpath
      FileUtils.cp_r "#{staged_path}/.", extension
      Kernel.system "/usr/bin/xattr", "-cr", extension.to_s
      Kernel.system "/bin/bash", "#{extension}/install-host.command"
    rescue => e
      Kernel.warn "Diagonal: #{e.class}: #{e.message}"
    end
    unless manifest.exist? && manifest.read.include?("io.diagonal.host")
      Kernel.warn "Diagonal's native host was not registered with Brave. " \
                  "Run: bash '#{extension}/install-host.command' (log: ~/Library/Logs/Diagonal/install.log)"
    end
  end

  uninstall_postflight do
    FileUtils.rm_rf [
      File.expand_path("~/Library/Application Support/Diagonal/extension"),
      File.expand_path("~/.local/share/diagonal-host"),
      File.expand_path("~/.local/bin/diagonal-host"),
      *%w[Brave-Browser Brave-Browser-Beta Brave-Browser-Nightly].map do |channel|
        File.expand_path("~/Library/Application Support/BraveSoftware/#{channel}/NativeMessagingHosts/io.diagonal.host.json")
      end,
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
