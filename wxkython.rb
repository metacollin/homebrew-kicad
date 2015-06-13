class Wxkython < Formula
  url "https://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2"
  sha256 "d54129e5fbea4fb8091c87b2980760b72c22a386cb3b9dd2eebc928ef5e8df61"
  homepage "https://kicad-pcb.org"

  depends_on "swig" => :build
  depends_on "pkg-config" => :build
  depends_on "wxkicad"
  depends_on :python

  keg_only "Custom patched version of wxPython, only for use by KiCad."

  bottle do
    revision 2
    sha256 "4a57905072c3811dc5a81a618587ed84a5f86a3aef8ddc7c5962fb411db7b298" => :yosemite
  end

  patch :p1 do
     url "https://gist.githubusercontent.com/metacollin/2d5760743df73c939d53/raw/cfbaa7965a21cce5f63f0fa857187c5fd33cd65e/wxp.patch"
     sha256 "d863576addb3e958cd8780ebf70fd710f73477db6322efb2c65f670543ab6bab"
  end

  fails_with :gcc
  fails_with :llvm

  def install
    cd "wxPython" do
      ENV['MAC_OS_X_VERSION_MIN_REQUIRED'] = "#{MacOS.version}"
      ENV.append "ARCHFLAGS", "-Wunused-command-line-argument-hard-error-in-future"
      ENV["WXWIN"] = buildpath
      ENV.libcxx if ENV.compiler == :clang
      ENV.append "LDFLAGS", "-headerpad_max_install_names" # Need for building bottles.

      blargs = [
        "WXPORT=osx_cocoa",
        "WX_CONFIG=#{Formula["wxkicad"].bin}/wx-config",
        "UNICODE=1",
        "BUILD_BASE=#{Formula["wxkicad"].prefix}/wx-build"
      ]
     system "python", "setup.py",
                     "build_ext",
                     *blargs

     system "python", "setup.py",
                     "install",
                     "--prefix=#{prefix}",
                     *blargs
    end
  end
end
