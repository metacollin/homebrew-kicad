class Wxkicad < Formula
  url "https://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2"
  sha1 "5053f3fa04f4eb3a9d4bfd762d963deb7fa46866"

  depends_on "cairo" => [:universal, "without-x11"] 
  depends_on "swig" => :build
  depends_on "pkg-config" => :build
  depends_on "pcre" => :universal
  depends_on "glew" => :universal
  depends_on "expat" => :universal

  keg_only "Custom patched version of wx and wxPython, only for use by KiCad."

  patch :p1 do
    url "https://gist.githubusercontent.com/metacollin/2d5760743df73c939d53/raw/362d83a32971bdc9d81243997ca4ddd6250f2004/wxp.patch"
    sha1 "147d38994c58d305b0b45b822fe2d18e7390c6c5"
  end

  def install
    ENV['MAC_OS_X_VERSION_MIN_REQUIRED'] = "#{MacOS.version}"
    ENV.libcxx

    args = [
      "--prefix=#{prefix}",
      "--with-opengl",
      "--enable-aui",
      "--enable-utf8",
      "--enable-html",
      "--enable-stl",
      "--with-libjpeg=builtin",
      "--with-libpng=builtin",
      "--with-regex=builtin",
      "--with-libtiff=builtin",
      "--with-zlib=builtin",
      "--with-expat=builtin",
      "--without-liblzma",
      "--with-macosx-version-min=#{MacOS.version}",
      "--enable-universal_binary=i386,x86_64",
      "CC=/usr/bin/clang",
      "CXX=/usr/bin/clang++"
      ]
     
    system "./configure", *args
    system "make", "-j6", "install"

    ohai ""
    ohai "*****"
    ohai "The custom KiCad version of wx has built successfully. Woohoo!"
    ohai "*****"
    ohai "But we're not done yet.  Hold onto your butts, now building wxpython."

    cd "wxPython" do
     ENV['MAC_OS_X_VERSION_MIN_REQUIRED'] = "#{MacOS.version}"
     ENV.libcxx
     ENV["WXWIN"] = buildpath

     blargs = [
      "WXPORT=osx_cocoa",
      "WX_CONFIG=#{bin}/wx-config",
      "UNICODE=1",
      "BUILD_BASE=#{buildpath}"
     ]
     system "/usr/local/python", "setup.py",
                     "build_ext",
                     *blargs

     system "/usr/local/python", "setup.py",
                     "install",
                     "--prefix=#{prefix}",
                     *blargs
    end
    system "chmod", "-R", "0744", "#{lib}"
  end
end
