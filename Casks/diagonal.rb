cask "diagonal" do
  # .github/workflows/diagonal.yml bumps version and sha256 whenever iko-soy/diagonal publishes a release,
  # so a plain `brew upgrade` picks it up.
  version "2026.09.24.2209"
  sha256 "9bae46892331c7616eca9e32f791a036dfa47bf53340e65e7a41b85108683620"

  url "https://github.com/iko-soy/diagonal/releases/download/#{version}/diagonal-extension-#{version}.zip",
      verified: "github.com/iko-soy/diagonal/"
  name "Diagonal"
  desc "Chromium browser extension that groups and names tabs with Apple's on-device model"
  homepage "https://github.com/iko-soy/diagonal"

  depends_on arch: :arm64

  # The unpacked extension lives at a fixed path so the browser keeps loading it across upgrades, and the
  # running extension reloads itself once the newer files are there;
  # install-host.command (shipped in the zip) installs the native host, registers it with every Chromium
  # browser on the Mac (Brave, Chrome, Edge, Arc, …) and,
  # if Apple's terms for fm are not accepted yet, runs `sudo fm license` so the user can read and
  # accept or decline them. Kernel.system keeps the terminal attached for that prompt.
  postflight do
    # Anything raised here makes brew roll back through uninstall_postflight, which would delete the
    # extension and the host it just installed, so report problems instead of raising.
    extension = Pathname("~/Library/Application Support/Diagonal/extension").expand_path
    begin
      # Copy next to the old folder, then swap it in with renames, so a browser that reads the folder
      # mid-upgrade sees either the old release or the new one, never a half-copied mix.
      incoming = Pathname("#{extension}.incoming")
      outgoing = Pathname("#{extension}.outgoing")
      FileUtils.rm_rf [incoming, outgoing]
      extension.dirname.mkpath
      FileUtils.cp_r "#{staged_path}/.", incoming
      Kernel.system "/usr/bin/xattr", "-cr", incoming.to_s
      File.rename(extension, outgoing) if extension.exist?
      File.rename(incoming, extension)
      FileUtils.rm_rf outgoing
      Kernel.system "/bin/bash", "#{extension}/install-host.command"
    rescue => e
      Kernel.warn "Diagonal: #{e.class}: #{e.message}"
    end
    manifests = Dir.glob(File.expand_path("~/Library/Application Support") +
                           "/{*,*/*,*/*/*}/NativeMessagingHosts/io.diagonal.host.json")
    if manifests.empty?
      Kernel.warn "Diagonal's native host was not registered with any browser. " \
                  "Run: bash '#{extension}/install-host.command' (log: ~/Library/Logs/Diagonal/install.log)"
    end
  end

  uninstall_postflight do
    # The host knows every browser folder it registered with; remove those manifests first.
    host = File.expand_path("~/.local/bin/diagonal-host")
    Kernel.system host, "--unregister" if File.exist?(host)
    FileUtils.rm_rf [
      File.expand_path("~/Library/Application Support/Diagonal/extension"),
      File.expand_path("~/.local/share/diagonal-host"),
      host,
    ]
  end

  zap trash: [
    "~/Library/Application Support/Diagonal",
    "~/Library/Logs/Diagonal",
  ]

  caveats <<~EOS
    Load the extension once in each Chromium browser you use:
      1. Open chrome://extensions and turn on Developer mode.
      2. Click "Load unpacked", press Cmd+Shift+G and paste:
           ~/Library/Application Support/Diagonal/extension

    If you declined Apple's terms for fm during install, Diagonal
    waits until you run: sudo fm license

    Updates come with brew upgrade. Diagonal reloads itself into the
    new version within a couple of minutes; nothing to click.
  EOS
end
