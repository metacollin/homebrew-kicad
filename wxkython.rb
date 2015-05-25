class Wxkython < Formula
  url "https://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2"
  sha1 "5053f3fa04f4eb3a9d4bfd762d963deb7fa46866"
  homepage "https://kicad-pcb.org"

  depends_on "swig" => :build
  depends_on "pkg-config" => :build
  depends_on "wxkicad"

  bottle do
    root_url "https://electropi.mp"
    revision 1
    sha256 "8de0a3d6258cd8b82e94f162cb899c0573f3256edffea51493270371ca3018c7" => :yosemite
  end

  keg_only "Custom patched version of wxPython, only for use by KiCad."

  patch :p1 do
     url "https://gist.githubusercontent.com/metacollin/2d5760743df73c939d53/raw/cfbaa7965a21cce5f63f0fa857187c5fd33cd65e/wxp.patch"
     sha256 "d863576addb3e958cd8780ebf70fd710f73477db6322efb2c65f670543ab6bab"
  end

  def install
    ohai "Now building wxpython..."

    cd "wxPython" do
     ENV['MAC_OS_X_VERSION_MIN_REQUIRED'] = "#{MacOS.version}"
     ENV['ARCHFLAGS'] = "-Wunused-command-line-argument-hard-error-in-future"
     ENV["WXWIN"] = buildpath
     ENV["CC"] = "#{ENV.cc}"
     ENV["CXX"] = "#{ENV.cxx}"
     ENV.append_to_cflags "-stdlib=libc++"
     ENV.append "LDFLAGS", "-stdlib=libc++"  # We actually need all of these.
     ENV.append "LDFLAGS", "-headerpad_max_install_names" # Need for building bottles.

     blargs = [
      "WXPORT=osx_cocoa",
      "WX_CONFIG=#{Formula["wxkicad"].bin}/wx-config",
      "UNICODE=1",
      "BUILD_BASE=#{Formula["wxkicad"].prefix}/wx-build"
     ]
     system "/usr/bin/python", "setup.py",
                     "build_ext",
                     *blargs

     system "/usr/bin/python", "setup.py",
                     "install",
                     "--prefix=#{prefix}",
                     *blargs
    end
  end
end
