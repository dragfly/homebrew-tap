class Dictare < Formula
  desc "Voice-first control for AI coding agents"
  homepage "https://github.com/dragfly/dictare"
  url "https://files.pythonhosted.org/packages/4c/67/bae789525e22669ee207cfa1af315c8d9f0562623040acbeb16261fb3206/dictare-0.3.0.tar.gz"
  sha256 "9a56b945c92dfd54e35891a92a7f77f27bf952d8f8a988972488b817262559d9"
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
    dictare_pkg = "dictare#{extras}==0.3.0"

    ENV["UV_TOOL_DIR"] = (libexec/"uv-tools").to_s
    ENV["UV_TOOL_BIN_DIR"] = (libexec/"bin").to_s
    ENV["UV_PYTHON_INSTALL_DIR"] = (libexec/"uv-python").to_s

    system "uv", "tool", "install",
           "--python", "3.11",
           "--prerelease=allow",
           dictare_pkg

    bin.install_symlink (libexec/"bin/dictare") => "dictare"

    # Store signed launcher bundle in Cellar
    resource("launcher").stage do
      target = libexec/"bundle/Dictare.app"
      target.mkpath
      system "cp", "-R", *Dir.glob("*"), target.to_s
    end
  end

  def post_install
    # Copy launcher to ~/Applications ONLY on first install.
    # Signed .app bundles can't be overwritten (macOS SIP).
    real_home = ENV["HOME"] || Pathname.new("~").expand_path.to_s
    app_dest = Pathname.new(real_home)/"Applications/Dictare.app"
    launcher_src = libexec/"bundle/Dictare.app"
    if launcher_src.exist? && !app_dest.exist?
      system "ditto", launcher_src.to_s, app_dest.to_s
    end
  end

  def caveats
    <<~EOS
      First install:

        dictare service install

      After upgrade:

        dictare service restart

      On first launch, macOS will ask for Input Monitoring permission.
      Grant it in System Settings > Privacy & Security > Input Monitoring.

      Apple Silicon: MLX backend included for hardware-accelerated STT.
    EOS
  end

  test do
    assert_match "0.3.0", shell_output("#{bin}/dictare --version")
  end
end
