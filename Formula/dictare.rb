class Dictare < Formula
  desc "Voice-first control for AI coding agents"
  homepage "https://github.com/dragfly/dictare"
  url "https://files.pythonhosted.org/packages/01/46/2aa555acc6570a2d1679d07e4c2f404b53eff16c55c69e1767b778477d98/dictare-0.4.0.tar.gz"
  sha256 "9c982710f82856d20f5c329174273e73b1b33d4c42ff6ffc2f6decfdff7ab25c"
  license "MIT"
  preserve_rpath

  depends_on "portaudio"
  depends_on "uv"
  depends_on :macos

  resource "launcher" do
    url "https://github.com/dragfly/dictare/releases/download/launcher/Dictare-launcher-universal.zip"
    sha256 "6b2873e70c73b81febbaf7b2efecab5ae1238a5bf70158bfdc7b23940bd9b3c0"
  end

  def install
    extras = Hardware::CPU.arm? ? "[mlx]" : ""
    dictare_pkg = "dictare#{extras}==0.4.0"

    ENV["UV_TOOL_DIR"] = (libexec/"uv-tools").to_s
    ENV["UV_TOOL_BIN_DIR"] = (libexec/"bin").to_s
    ENV["UV_PYTHON_INSTALL_DIR"] = (libexec/"uv-python").to_s

    system "uv", "tool", "install",
           "--python", "3.11",
           "--prerelease=allow",
           dictare_pkg

    # PyAV wheels vendor FFmpeg dylibs whose install IDs can be too
    # short for Homebrew's post-install opt-prefix rewrite. Normalize
    # those IDs to short @rpath names before Homebrew fixes linkage.
    dylib_dir = libexec/"uv-tools/dictare/lib/python3.11/site-packages/av/.dylibs"
    if dylib_dir.exist?
      dylib_dir.glob("*.dylib").each do |dylib|
        system "install_name_tool", "-id", "@rpath/#{dylib.basename}", dylib
      end
    end

    bin.install_symlink (libexec/"bin/dictare") => "dictare"

    # Store signed launcher bundle in Cellar
    resource("launcher").stage do
      target = libexec/"bundle/Dictare.app"
      target.mkpath
      system "cp", "-R", *Dir.glob("*"), target.to_s
    end
  end

  def post_install
    # The signed launcher reads this file before Python starts. Keep it
    # pinned to the stable Homebrew opt path so stale dev venvs cannot
    # demote a brew install from MLX to CPU.
    real_home = ENV["HOME"] || Pathname.new("~").expand_path.to_s
    dictare_dir = Pathname.new(real_home)/".dictare"
    dictare_dir.mkpath
    python_path = dictare_dir/"python_path"
    begin
      File.write python_path, "#{opt_libexec}/uv-tools/dictare/bin/python"
    rescue Errno::EACCES, Errno::EPERM => e
      opoo "Could not update #{python_path}: #{e.message}. Run  or  to repair it."
    end

    # Copy launcher to ~/Applications ONLY on first install.
    # Signed .app bundles can't be overwritten (macOS SIP).
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
    assert_match "0.4.0", shell_output("#{bin}/dictare --version")
  end
end
