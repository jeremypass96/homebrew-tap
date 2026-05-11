cask "betterbird" do
  arch intel: "x86_64"
  os linux: "linux"

  version "140.10.1esr-bb22"
  sha256 "66247166a6b22f2e7346b001576975b2c20788494e1cf084af43f9438840ff7e"
    
  url "https://www.betterbird.eu/downloads/LinuxArchive/betterbird-#{version}.en-US.linux-x86_64.tar.xz"
  name "Betterbird"
  desc "Fine-tuned version of Mozilla Thunderbird with additional features"
  homepage "https://betterbird.eu/"

  livecheck do
    url "https://www.betterbird.eu/downloads/"
    regex(/Current version:\s*Betterbird\s+(\d+(?:\.\d+)+\.\d+esr-bb\d+)/i)
  end

  auto_updates true
  depends_on formula: [
    "dbus-glib",
    "hunspell",
  ]

  binary "betterbird/betterbird"

  postflight do
    apps_dir  = "#{Dir.home}/.local/share/applications"
    icon_root = "#{Dir.home}/.local/share/icons/hicolor"
    desktop = "#{Dir.home}/.local/share/applications/betterbird.desktop"

    FileUtils.mkdir_p(apps_dir)

    # --- Find the best icon shipped in the extracted app dir. ---
    # Caskstaging path contains the extracted tarball content.
    staged = Pathname.new(staged_path)

    # Candidate icon paths (we'll pick the first that exists)
    candidates = [
      staged/"betterbird/chrome/icons/default/default256.png",
      staged/"betterbird/chrome/icons/default/default128.png",
      staged/"betterbird/chrome/icons/default/default64.png",
      staged/"betterbird/chrome/icons/default/default48.png",
      staged/"betterbird/chrome/icons/default/default32.png",
      staged/"betterbird/chrome/icons/default/default24.png",
      staged/"betterbird/chrome/icons/default/default22.png",
      staged/"betterbird/chrome/icons/default/default16.png",
    ]

    icon_src = candidates.find(&:exist?)

    if icon_src
      # infer size from filename
      size = icon_src.basename.to_s[/default(\d+)\.png/, 1]
      icon_dir = "#{icon_root}/#{size}x#{size}/apps"
      FileUtils.mkdir_p(icon_dir)
      FileUtils.cp(icon_src.to_s, "#{icon_dir}/betterbird.png")
    end

    File.write(desktop, <<~EOS)
      [Desktop Entry]
      Exec=#{HOMEBREW_PREFIX}/bin/betterbird %u
      Terminal=false
      Type=Application
      Icon=betterbird
      Categories=Network;Email;
      MimeType=message/rfc822;x-scheme-handler/mailto;application/x-xpinstall;application/x-extension-ics;text/calendar;text/vcard;text/x-vcard;x-scheme-handler/webcal;x-scheme-handler/webcals;x-scheme-handler/mid;
      StartupNotify=true
      StartupWMClass=betterbird
      Actions=ComposeMessage;OpenAddressBook;
      Name=Betterbird
      Comment=Send and receive mail with Betterbird
      GenericName=Mail Client
      Keywords=Email;E-mail;Newsgroup;Feed;RSS

      [Desktop Action ComposeMessage]
      Name=Write new message
      Exec=betterbird -compose

      [Desktop Action OpenAddressBook]
      Name=Open address book
      Exec=betterbird -addressbook
    EOS
  end

  uninstall_postflight do
    # delete desktop launcher
    FileUtils.rm_f("#{Dir.home}/.local/share/applications/betterbird.desktop")
    # delete icons
    %w[256 128 64 48 32 24 22 16].each do |sz|
    FileUtils.rm_rf("#{Dir.home}/.local/share/icons/hicolor/#{sz}x#{sz}/apps/betterbird.png")
    end
  end

  zap delete: [
    "~/.cache/thunderbird"
  ]
end
