class Dictare < Formula
  desc "Voice-first control for AI coding agents"
  homepage "https://github.com/dragfly/dictare"
  url "https://files.pythonhosted.org/packages/e4/f4/d8c960d00338c30574eff5e2f3df5187f1db4acbc140b2e7d5089a37ce82/dictare-0.1.140rc14.tar.gz"
  sha256 "5bd3be430a4b1e13af1f6f52db180361a62d680aae1f480f6f52902cbb297922"
  license "MIT"

  depends_on "portaudio"
  depends_on "uv"
  depends_on :macos

  resource "launcher" do
    url "https://github.com/dragfly/dictare/releases/download/launcher/Dictare-launcher-universal.zip"
    sha256 "34e2b112014f47e2f633fa7ef7a30158a30b4daeb9a901aca9de9d9650133658"
  end

  def install
    extras = Hardware::CPU.arm? ? "[mlx]" : ""
    dictare_pkg = "dictare#{extras}==0.1.140rc14"

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
    assert_match "0.1.140rc14", shell_output("#{bin}/dictare --version")
  end
end
