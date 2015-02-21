class Wxkython < Formula
  url "https://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2"
  sha1 "5053f3fa04f4eb3a9d4bfd762d963deb7fa46866"

  depends_on "swig" => :build
  depends_on "pkg-config" => :build
  depends_on "wxkicad"
  
  bottle do
    root_url "https://electropi.mp"
    sha1 "87734027803b0a08c5bc91530c2fbafb193d622d" => :yosemite
    sha1 "b5387a365ff61fca85ce54418781048c36a3ea75" => :mountain_lion
  end

  keg_only "Custom patched version of wxPython, only for use by KiCad."

  patch :p1 do
     url "https://gist.githubusercontent.com/metacollin/2d5760743df73c939d53/raw/37c8f5f823c60f76ae30d6acf54ca03f1b11f4f9/wxp.patch"
     sha1 "00333265692b88d22be33c15220daeda6d5c3b28"
  end

  def install
    ohai "Now building wxpython..."

    cd "wxPython" do
     ENV['MAC_OS_X_VERSION_MIN_REQUIRED'] = "#{MacOS.version}"
     ENV['ARCHFLAGS'] = "-Wunused-command-line-argument-hard-error-in-future" 
     ENV["WXWIN"] = buildpath
     ENV["CC"] = "/usr/bin/clang"
     ENV["CXX"] = "/usr/bin/clang++"
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