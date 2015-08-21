class Wxkicad < Formula
  url "https://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2"
  sha256 "d54129e5fbea4fb8091c87b2980760b72c22a386cb3b9dd2eebc928ef5e8df61"
  homepage "https://kicad-pcb.org"

  depends_on "cairo"
  depends_on "swig" => :build
  depends_on "pkg-config" => :build
  depends_on "pcre"
  depends_on "glew"

  keg_only "Custom patched version of wxWidgets, only for use by KiCad."


 # bottle do
 #   root_url "https://electropi.mp"
 #   revision 3
 #   sha256 "c9e92d9a896e3558a684345e4ce20d123b265487965c3cfd29673ea64381cee7" => :yosemite
 #   sha256 "3553e767d5aa30bbd43004316a755e736f694775de8b12b58b0ecc5157a97654" => :lion
 # end

  patch :p1 do
     url "https://gist.githubusercontent.com/metacollin/2d5760743df73c939d53/raw/b25008a92c8f518df582ad88d266dcf2d75f9d12/wxp.patch"
     sha256 "0a19c475ded29186683a9e7f7d9316e4cbea4db7b342f599cee0e116fa019f3e"
  end

  fails_with :gcc
  fails_with :llvm

   def install
    mkdir "wx-build" do
      ENV['MAC_OS_X_VERSION_MIN_REQUIRED'] = "#{MacOS.version}"
      ENV.append "ARCHFLAGS", "-Wunused-command-line-argument-hard-error-in-future"
      ENV.append "LDFLAGS", "-headerpad_max_install_names" # Need for building bottles.

      if MacOS.version < :mavericks
        ENV.libstdcxx
      else
        ENV.libcxx
      end

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
        "CC=#{ENV.cc}",
        "CXX=#{ENV.cxx}"
      ]

      system "../configure", *args
      system "make", "-j6"
      system "make", "install"
    end
    (prefix/"wx-build").install Dir["wx-build/*"]
  end
end
