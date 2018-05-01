class KicadWxpython < Formula
  desc "Custom patched version of wxPython, only for use by KiCad."
  homepage "https://kicad-pcb.org"
  url "https://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2"
  sha256 "d54129e5fbea4fb8091c87b2980760b72c22a386cb3b9dd2eebc928ef5e8df61"

  bottle do
    root_url "https://electropi.mp/bottles"
    sha256 "e9ef38197f2b31aca8d9d8dda7f55b5ea1c7ef10a398f0602b4d4883439b2c89" => :sierra
  end

  keg_only "custom patched version of wxPython, only for use by KiCad"

  depends_on "metacollin/kicad/kicad-wxwidgets"
  depends_on "python@2"

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
      "WX_CONFIG=#{Formula["metacollin/kicad/kicad-wxwidgets"].opt_bin}/wx-config",
      "BUILD_BASE=#{Formula["metacollin/kicad/kicad-wxwidgets"]}/wx-build"
    ]

    cd "wxPython" do
      system "#{Formula["python@2"].bin}/python", "setup.py", "build_ext", *args
      system "#{Formula["python@2"].bin}/python", "setup.py", "install", "--prefix=#{prefix}", *args
    end

    include.install_symlink include/"wx-3.0"/"wx"
  end

  test do
    ENV.prepend_create_path "PYTHONPATH", "#{buildpath}/py/lib/python2.7/site-packages"
    output = shell_output("python -c 'import wx ; print wx.version()'")
    assert_match version.to_s, output
  end
end
