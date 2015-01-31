# Documentation: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Formula-Cookbook.md
#                /usr/local/Library/Contributions/example-formula.rb
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Wxkicad < Formula
  homepage ""
  url "http://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2"
  version "3.0.2.0"
  sha1 "5053f3fa04f4eb3a9d4bfd762d963deb7fa46866"

  depends_on "cairo"
  depends_on "swig" 
  depends_on "pkg-config"
  depends_on "libpng"
  depends_on "pcre"
  depends_on "glew"

 # option "without-wxpython", "Only build wx for kicad, but not wxpython for kicad.  wxpython is required for python scripting."

  keg_only "Custom patched version of wx and wxPython, only for use by KiCad."

  patch :p1 do
    url "https://gist.githubusercontent.com/metacollin/2d5760743df73c939d53/raw/362d83a32971bdc9d81243997ca4ddd6250f2004/wxp.patch"
    sha1 "147d38994c58d305b0b45b822fe2d18e7390c6c5"
  end



  def install
    ENV['CC'] = "/usr/bin/clang"
    ENV['CXX'] = "/usr/bin/clang++"
    unless MacOS.version < :mavericks
      ENV.append "CXXFLAGS", "-stdlib=libc++"
      ENV.append "ARCHFLAGS", "-Wno-error=unused-command-line-argument-hard-error-in-future"
    else
      ENV.append "CXXFLAGS", "-stdlib=libstdc++"
    end
    
    args = %W[
      --prefix=#{prefix}
      --with-opengl
      --enable-aui
      --enable-utf8
      --enable-html
      --enable-stl
      --with-libjpeg=builtin
      --with-libpng=builtin
      --with-regex=builtin
      --with-libtiff=builtin
      --with-zlib=builtin
      --with-expat=builtin
      --without-liblzma
      --with-macosx-version-min=#{MacOS.version}
      --enable-universal-binary=i386,x86_64
      ]
    
    
    system "./configure", *args
    system "make", "-j8"
    system "make", "install"

    ohai "The custom KiCad version of wx has built successfully. Woohoo!"

   # unless build.without? "wxpython"
    cd "wxPython" do
        ohai "...But we're not out of the woods yet.  Now building wxPython."
        opoo "In the words of Samuel L. Jackson, hold onto your butt."
        ENV['CC'] = "/usr/bin/clang"
        ENV['CXX'] = "/usr/bin/clang++"
        unless MacOS.version < :mavericks
          ENV.append "CXXFLAGS", "-stdlib=libc++"
          ENV.append "ARCHFLAGS", "-Wno-error=unused-command-line-argument-hard-error-in-future"
        else
          ENV.append "CXXFLAGS", "-stdlib=libstdc++"
        end

        system "/usr/bin/python", "setup.py", "build_ext", "WX_CONFIG=#{opt_prefix}/bin/wx-config", "UNICODE=1", "WXPORT=osx_cocoa", "BUILD_BASE=../"
        system "/usr/bin/python", "setup.py", "install", "--prefix=#{prefix}", "WX_CONFIG=#{opt_prefix}/bin/wx-config", "UNICODE=1", "WXPORT=osx_cocoa", "BUILD_BASE=../"
     # end
    end
  end
end
