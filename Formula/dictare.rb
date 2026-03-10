class Dictare < Formula
  desc "Voice-first control for AI coding agents"
  homepage "https://github.com/dragfly/dictare"
  url "https://files.pythonhosted.org/packages/0e/8a/b26546a327ea42cca64209227b5e48cadbe7a59aed12922be209fb1a9f90/dictare-0.1.140rc3.tar.gz"
  sha256 "f33b6e310543e81aebef821a0ef1b25c4c1b9b5b2d7ba5878d6e838d8a84f7f3"
  license "MIT"

  depends_on "portaudio"
  depends_on "uv"

  def install
    extras = Hardware::CPU.arm? ? "[mlx]" : ""
    dictare_pkg = "dictare#{extras}==0.1.140rc3"

    ENV["UV_TOOL_DIR"] = (libexec/"uv-tools").to_s
    ENV["UV_TOOL_BIN_DIR"] = (libexec/"bin").to_s
    ENV["UV_PYTHON_INSTALL_DIR"] = (libexec/"uv-python").to_s

    system "uv", "tool", "install",
           "--python", "3.11",
           "--prerelease=allow",
           dictare_pkg

    bin.install_symlink (libexec/"bin/dictare") => "dictare"
  end

  def caveats
    <<~EOS
      After install, start the service:

        dictare service install

      On first launch, macOS will ask for Input Monitoring permission.
      A system dialog will appear — click "Open System Settings" and
      enable the toggle for Dictare. That's it.

      If you installed on Apple Silicon, the MLX backend is included
      for hardware-accelerated on-device speech recognition.
    EOS
  end

  test do
    assert_match "0.1.140rc3", shell_output("#{bin}/dictare --version")
  end
end
