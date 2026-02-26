class Dictare < Formula
  desc "Voice-first control for AI coding agents"
  homepage "https://github.com/dragfly/dictare"
  url "file://PLACEHOLDER"
  sha256 "PLACEHOLDER"
  license "MIT"

  depends_on "portaudio"
  depends_on "uv"

  def install
    openvip_tarball = "PLACEHOLDER"

    # Determine extras based on architecture
    pkg_spec = Hardware::CPU.arm? ? "dictare[mlx]" : "dictare"

    ENV["UV_TOOL_DIR"] = (libexec/"uv-tools").to_s
    ENV["UV_TOOL_BIN_DIR"] = (libexec/"bin").to_s
    ENV["UV_PYTHON_INSTALL_DIR"] = (libexec/"uv-python").to_s

    # --no-sources ignores [tool.uv.sources] dev overrides (local editable paths)
    # --find-links provides openvip from local tarball until it's on PyPI
    system "uv", "tool", "install",
           "--python", "3.11",
           "--no-sources",
           "--find-links", File.dirname(openvip_tarball),
           pkg_spec

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
