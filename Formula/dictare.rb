class Dictare < Formula
  desc "Voice-first control for AI coding agents"
  homepage "https://github.com/dragfly/dictare"
  url "https://files.pythonhosted.org/packages/e9/01/88d32141bb49a4b7918a49bcb61be9aaa9ace8835064c48399e74d7fc2e9/dictare-0.2.1b1.tar.gz"
  sha256 "ab20df35067025ca0508c147347fc705be2aa91d1bfb81470c3475761fd547e1"
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
    dictare_pkg = "dictare#{extras}==0.2.1b1"

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
      (libexec/"bundle").install "Dictare.app"
    end
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
    assert_match "0.2.1b1", shell_output("#{bin}/dictare --version")
  end
end
