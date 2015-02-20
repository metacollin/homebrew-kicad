class Wxkicad < Formula
  url "https://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2"
  sha1 "5053f3fa04f4eb3a9d4bfd762d963deb7fa46866"

   depends_on "cairo" 
   depends_on "swig" => :build
   depends_on "pkg-config" => :build
   depends_on "pcre" 
   depends_on "glew" 

  keg_only "Custom patched version of wxWidgets, only for use by KiCad."

  patch :p1 do
     url "https://gist.githubusercontent.com/metacollin/2d5760743df73c939d53/raw/37c8f5f823c60f76ae30d6acf54ca03f1b11f4f9/wxp.patch"
     sha1 "00333265692b88d22be33c15220daeda6d5c3b28"
  end

   def install

    mkdir "wx-build" do
    ENV['MAC_OS_X_VERSION_MIN_REQUIRED'] = "#{MacOS.version}"
    ENV['ARCHFLAGS'] = "-Wunused-command-line-argument-hard-error-in-future"
    ENV.append_to_cflags "-stdlib=libc++"
    ENV.append "LDFLAGS", "-stdlib=libc++"

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

    system "../configure", *args
    system "make", "-j6"
    system "make", "install"
    end
    (prefix/"wx-build").install Dir["wx-build/*"]






    # ohai "Now building wxpython..."

    # cd "wxPython" do
    #  ENV['MAC_OS_X_VERSION_MIN_REQUIRED'] = "#{MacOS.version}"
    #  ENV.append_to_cflags "-stdlib=libc++"
    #  ENV['ARCHFLAGS'] = "-Wunused-command-line-argument-hard-error-in-future"
    #  ENV["WXWIN"] = buildpath

    #  blargs = [
    #   "WXPORT=osx_cocoa",
    #   "WX_CONFIG=#{bin}/wx-config",
    #   "UNICODE=1",
    #   "BUILD_BASE=#{buildpath}"
    #  ]
    #  system "CC=/usr/bin/clang CXX=/usr/bin/clang++ /usr/bin/python", "setup.py",
    #                  "build_ext",
    #                  *blargs

    #  system "CC=/usr/bin/clang CXX=/usr/bin/clang++ /usr/bin/python", "setup.py",
    #                  "install",
    #                  "--prefix=#{prefix}",
    #                  *blargs
    # end
  end
end
