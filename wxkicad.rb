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

  patch :p0 do
     url "https://gist.githubusercontent.com/metacollin/2d5760743df73c939d53/raw/341390839ecd70aba743da64624c90c5d1afcff3/wxp.patch"
     sha256 "25f40ddc68a182e7dd9f795066910d57e0c53dd4096b85797fbf8e3489685a77"
  end

  patch :p0 do
    url "https://gist.githubusercontent.com/metacollin/cae8c54d100574f0482b5735561fc08f/raw/dd2bb54eb5e2c77871949e1dc3e25d1ab49afa8f/glpatch.patch"
    sha256 "24e86101a164633db8354a66be6ec76599750b5d49bd1d3b60fa04ec0d7e66bf"
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
      system "make", "-j#{ENV.make_jobs}"
      system "make", "install"
    end
    (prefix/"wx-build").install Dir["wx-build/*"]
  end
end
