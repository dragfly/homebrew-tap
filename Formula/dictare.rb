class Dictare < Formula
  desc "Voice-first control for AI coding agents"
  homepage "https://github.com/dragfly/dictare"
  url "https://files.pythonhosted.org/packages/f5/dd/039e3a833e0a393c6f100fbabd8e413e16eeede1c6aebf1cb7485ce99b16/dictare-0.1.140rc1.tar.gz"
  sha256 "6a05f514d8e9d4fc823f954aadd569b461475ac7d167e9295a237b3d88de6be5"
  license "MIT"

  depends_on "portaudio"
  depends_on "uv"

  def install
    extras = Hardware::CPU.arm? ? "[mlx]" : ""
    dictare_pkg = "dictare#{extras}==0.1.140rc1"

    ENV["UV_TOOL_DIR"] = (libexec/"uv-tools").to_s
    ENV["UV_TOOL_BIN_DIR"] = (libexec/"bin").to_s
    ENV["UV_PYTHON_INSTALL_DIR"] = (libexec/"uv-python").to_s

    system "uv", "tool", "install",
           "--python", "3.11",
           "--prerelease=allow",
           dictare_pkg

    bin.install_symlink (libexec/"bin/dictare") => "dictare"
  end

  def post_install
    # Update ~/.dictare/python_path and restart the launchd service.
    # The signed .app bundle in ~/Applications stays untouched.
    system bin/"dictare", "service", "install"
  end

  def caveats
    <<~EOS
      On first launch, macOS will ask for Input Monitoring permission.
      A system dialog will appear — click "Open System Settings" and
      enable the toggle for Dictare. That's it.

      If you installed on Apple Silicon, the MLX backend is included
      for hardware-accelerated on-device speech recognition.
    EOS
  end

  test do
    assert_match "0.1.140rc1", shell_output("#{bin}/dictare --version")
  end
end
