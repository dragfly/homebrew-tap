class Dictare < Formula
  desc "Voice-first control for AI coding agents"
  homepage "https://github.com/dragfly/dictare"
  url "https://files.pythonhosted.org/packages/ae/4a/2ce33e1512b9874495b4b5ae7c5c04e25f61de0e3b6f61cbc66be23c1f6a/dictare-0.2.1b2.tar.gz"
  sha256 "4e4146be3790169c27b73e922dda652dde465131d9e5d7bec1210196795cb8e6"
  license "MIT"

  depends_on "portaudio"
  depends_on "uv"
  depends_on :macos

  resource "launcher" do
    url "https://github.com/dragfly/dictare/releases/download/launcher/Dictare-launcher-universal.zip"
    sha256 "6b2873e70c73b81febbaf7b2efecab5ae1238a5bf70158bfdc7b23940bd9b3c0"
  end

  def install
    extras = Hardware::CPU.arm? ? "[mlx]" : ""
    dictare_pkg = "dictare#{extras}==#{version}"

    ENV["UV_TOOL_DIR"] = (libexec/"uv-tools").to_s
    ENV["UV_TOOL_BIN_DIR"] = (libexec/"bin").to_s
    ENV["UV_PYTHON_INSTALL_DIR"] = (libexec/"uv-python").to_s

    system "uv", "tool", "install",
           "--python", "3.11",
           "--prerelease=allow",
           dictare_pkg

    bin.install_symlink (libexec/"bin/dictare") => "dictare"

    # Install signed launcher bundle
    resource("launcher").stage do
      target = libexec/"bundle/Dictare.app"
      target.mkpath
      system "cp", "-R", *Dir.glob("*"), target.to_s
    end

  end

  def post_install
    # Copy launcher to ~/Applications (runs outside sandbox)
    real_home = ENV["HOME"] || Pathname.new("~").expand_path.to_s
    app_dest = Pathname.new(real_home)/"Applications/Dictare.app"
    launcher_src = libexec/"bundle/Dictare.app"
    if launcher_src.exist?
      system "rm", "-rf", app_dest.to_s if app_dest.exist?
      system "cp", "-R", launcher_src.to_s, app_dest.to_s
    end

    # Restart service if already installed
    dictare_bin = bin/"dictare"
    if File.exist?(dictare_bin)
      plist = Pathname.new(real_home)/"Library/LaunchAgents/dev.dragfly.dictare.plist"
      if plist.exist?
        system "launchctl", "unload", plist.to_s rescue nil
        system dictare_bin, "service", "install"
      end
    end
  end

  def caveats
    <<~EOS
      After first install, start the service:

        dictare service install

      On first launch, macOS will ask for Input Monitoring permission.
      A system dialog will appear — click "Open System Settings" and
      enable the toggle for Dictare. That's it.

      If you installed on Apple Silicon, the MLX backend is included
      for hardware-accelerated on-device speech recognition.

      After upgrades, the service restarts automatically.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dictare --version")
  end
end
