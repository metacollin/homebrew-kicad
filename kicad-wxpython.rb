class KicadWxpython < Formula
  desc "Custom patched version of wxPython, only for use by KiCad."
  homepage "https://kicad-pcb.org"
  url "https://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2"
  version "3.0.2.0"
  sha256 "d54129e5fbea4fb8091c87b2980760b72c22a386cb3b9dd2eebc928ef5e8df61"

  depends_on "metacollin/kicad/wxkicad"

  keg_only "Custom patched version of wxPython, only for use by KiCad."

  def install
    ENV["ARCHFLAGS"] = "-Wunused-command-line-argument-hard-error-in-future"
    ENV.append "LDFLAGS", "-headerpad_max_install_names"
    ENV["MAC_OS_X_VERSION_MIN_REQUIRED"] = MacOS.version
    ENV["WXWIN"] = buildpath
    ENV.append_to_cflags "-arch #{MacOS.preferred_arch}"

    inreplace %w[wxPython/config.py wxPython/wx/build/config.py],
      "WXPREFIX +", "'#{prefix}' +"

    args = [
      "WXPORT=osx_cocoa",
      "UNICODE=1",
      "WX_CONFIG=#{Formula['metacollin/kicad/wxkicad'].opt_bin}/wx-config",
      "BUILD_BASE=#{Formula['metacollin/kicad/wxkicad']}/wx-build"
    ]

    cd "wxPython" do
      system "python", "setup.py", "build_ext", *args
      system "python", "setup.py", "install", "--prefix=#{prefix}", *args
    end
  end

  test do
    ENV.prepend_create_path "PYTHONPATH", "#{buildpath}/py/lib/python2.7/site-packages"
    output = shell_output("python -c 'import wx ; print wx.version()'")
    assert_match version.to_s, output
  end
end
