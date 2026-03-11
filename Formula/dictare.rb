class Dictare < Formula
  desc "Voice-first control for AI coding agents"
  homepage "https://github.com/dragfly/dictare"
  url "https://files.pythonhosted.org/packages/05/2a/1ec1b96a7d32c25ca616b3772cb222b1023556a298d2ce0a807c3ec32fb4/dictare-0.1.140rc7.tar.gz"
  sha256 "23bffc09c08338d51f0bda0f9b5512a5c4f5af4888b5fa04676b2b3772074eaf"
  license "MIT"

  depends_on "portaudio"
  depends_on "uv"
  depends_on :macos

  resource "launcher" do
    url "https://github.com/dragfly/dictare/releases/download/launcher/Dictare-launcher-universal.zip"
    sha256 "d9602d07cc8d137a7260ef9d09a30a851fd0c68037b8a87059b967c04d3abf45"
  end

  def install
    extras = Hardware::CPU.arm? ? "[mlx]" : ""
    dictare_pkg = "dictare#{extras}==0.1.140rc7"

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
    assert_match "0.1.140rc7", shell_output("#{bin}/dictare --version")
  end
end
