cask "betterbird" do
  arch intel: "x86_64"
  os linux: "linux"

  version "140.9.0esr-bb20"

  language "en", default: true do
    sha256 "62d040cb5bf3e7d35ece4d26700f9324f3e17367648421e5e177c7d19a393024"
    "en-US"
  end
  language "de" do
    sha256 "b19faf762b6efe471dfb8ae8791503d78af1cc2fe423912b0d8ccd63ba96dafc"
    "de"
  end
  language "nl" do
    sha256 "264d2d98f14d1923858dbe6169ed35b9ff0de32bbb3b5155b0910d320e9b2063"
    "nl"
  end
  language "fr" do
    sha256 "8c340caeb1fd336b6ee10a048032855b472f456eaf7adde6e74e57fb781b70fe"
    "fr"
  end
  language "it" do
    sha256 "3bd985796485145ccb704a258f22f5cafe130fdbce25cabbfc9587e12f4cfbf0"
    "it"
  end
  language "ja" do
    sha256 "aa11400f78b0ad219dc33996325a764c814871934472cbb8b94723f32722e88a"
    "ja"
  end
  language "es" do
    sha256 "e700d9852c9e41a4e50af436b0e6ffd0ec88b55187a3e6fe3f5655d557f45f7e"
    "es-ES"
  end
  language "pt" do
    sha256 "8aefb9ef7fc8bb75cea76a073ed2982f477b1f9c6e91e00fd3fc9fcfacf21c2c"
    "pt-BR"
  end
  language "ru" do
    sha256 "6d3da54701b9c28fe8f41fdffb5bde6c2daab7563ec9c9af1f12ccf0294c14b6"
    "ru"
  end

  url "https://www.betterbird.eu/downloads/LinuxArchive/betterbird-#{version}.#{language}.linux-x86_64.tar.xz"
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
    "~/.cache/thunderbird",
    "~/.thunderbird",
  ]
end
