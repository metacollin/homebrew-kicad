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

  bottle do
    revision 2
    sha256 "4403d4053a337349bdd5dd0f60ae348be46656d9462a7582237092756f9505af" => :yosemite
  end

  patch :p1 do
     url "https://gist.githubusercontent.com/metacollin/2d5760743df73c939d53/raw/cfbaa7965a21cce5f63f0fa857187c5fd33cd65e/wxp.patch"
     sha256 "d863576addb3e958cd8780ebf70fd710f73477db6322efb2c65f670543ab6bab"
  end

  fails_with :gcc
  fails_with :llvm

   def install
    mkdir "wx-build" do
      ENV['MAC_OS_X_VERSION_MIN_REQUIRED'] = "#{MacOS.version}"
      ENV.append "ARCHFLAGS", "-Wunused-command-line-argument-hard-error-in-future"
      ENV.append "LDFLAGS", "-headerpad_max_install_names" # Need for building bottles.
      ENV.libcxx if ENV.compiler == :clang

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
