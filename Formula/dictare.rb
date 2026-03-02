class Dictare < Formula
  desc "Voice-first control for AI coding agents"
  homepage "https://github.com/dragfly/dictare"
  url "file://PLACEHOLDER"
  sha256 "PLACEHOLDER"
  license "MIT"

  depends_on "portaudio"

  def install
    # uv is NOT a brew dependency — we find it in common locations to avoid
    # brew removing the user's uv on uninstall.
    uv_bin = [
      which("uv"),
      Pathname("#{Dir.home}/.local/bin/uv"),
      Pathname("#{Dir.home}/.cargo/bin/uv"),
    ].find { |p| p&.exist? }
    raise "uv not found. Install via: curl -LsSf https://astral.sh/uv/install.sh | sh" unless uv_bin

    dictare_tarball = "PLACEHOLDER_DICTARE"
    extras = Hardware::CPU.arm? ? "[mlx]" : ""

    ENV["UV_TOOL_DIR"] = (libexec/"uv-tools").to_s
    ENV["UV_TOOL_BIN_DIR"] = (libexec/"bin").to_s
    ENV["UV_PYTHON_INSTALL_DIR"] = (libexec/"uv-python").to_s

    # Install dictare from local tarball; openvip and all other deps from PyPI.
    system uv_bin.to_s, "tool", "install",
           "--python", "3.11",
           "--prerelease=allow",
           "#{dictare_tarball}#{extras}"

    bin.install_symlink (libexec/"bin/dictare") => "dictare"
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
    assert_match "PLACEHOLDER", shell_output("#{bin}/dictare --version")
  end
end
