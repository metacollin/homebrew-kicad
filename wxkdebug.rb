class Wxkdebug < Formula
  url "https://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2"
  sha256 "d54129e5fbea4fb8091c87b2980760b72c22a386cb3b9dd2eebc928ef5e8df61"
  homepage "https://kicad-pcb.org"
  depends_on "cairo"
  depends_on "swig" => :build
  depends_on "pkg-config" => :build
  depends_on "pcre"
  depends_on "glew"
  depends_on "llvm" => :build if build.with? "openmp"

  #bottle do
  #  root_url "https://electropi.mp/bottles"
   # cellar :any
   # sha256 "4448222f6add5aaaebf3b800528749d7cb59ec6fc04fae4c96e856d1edf06c3e" => :el_capitan
   # sha256 "ee5c73dbb6e9098384c273e71279848ef0698a7b80735e7cba96120e2b1209b9" => :sierra
   # sha256 "6d66edde8fa6eaed555e4f76fd29ebd42b818ed9f1f1cae5a80a2b93e72adac6" => :yosemite
 # end

  option "with-openmp", "Use OpenMP for multiprocessing support."

  keg_only "Custom patched version of wxWidgets with debug features enabled, only for use by KiCad."

  patch :p0 do
    url "https://gist.githubusercontent.com/metacollin/b6bbb5d54734bea3dcaca1ff22668016/raw/1bdf06a34efba3a67351b034bad27f97f7f712e0/wx_patch_unified.patch"
    sha256 "d94339ea67b3c0ecef61bcf9abf786627269465df1afa710fed828975602445f"
  end

  patch :p0 do
    url "https://gist.githubusercontent.com/anonymous/9b22d2b780f90c35d72a206f85478261/raw/85bdd19330fc04885ffaec41afcb86a8a1c26e34/wx_unicode.patch"
    sha256 "6daa6830f1d7ecc32a8bf18c51f4c4645e959fff252908e399a3e8aaefaeca56"
  end

  if MacOS.version >= :sierra
    patch :p1 do
      url "https://gist.githubusercontent.com/metacollin/232d39cdc5cfd3664a23b18efd50ec4f/raw/465b9368a8a4ad983992ec3842f56e2010d18f1b/wxwidgets-3.0.2_macosx_sierra.patch"
      sha256 "cf46d8b1ec6e90e8fef458a610ae1ecdc6607e2f4bbd6fb527e83e40c5b5fb24"
    end
  end

  fails_with :gcc
  fails_with :llvm
  #env :std if build.with? "openmp"

  def install
    inreplace "src/stc/scintilla/src/Editor.cxx", "#include <assert.h>", "#include <assert.h>\n#include <cmath>" if build.with? "openmp"
    inreplace "src/stc/scintilla/src/Editor.cxx", "if (abs(pt1.x - pt2.x) > 3)", "if (std::abs(pt1.x - pt2.x) > 3)" if build.with? "openmp"
    inreplace "src/stc/scintilla/src/Editor.cxx", "if (abs(pt1.y - pt2.y) > 3)", "if (std::abs(pt1.y - pt2.y) > 3)" if build.with? "openmp"

    mkdir "wx-build" do
      osx = MacOS.version
      osx = "10.11" if (build.with? "openmp") && (osx >= :sierra)

      ENV["ARCHFLAGS"] = "-Wunused-command-line-argument-hard-error-in-future"
      ENV.append "LDFLAGS", "-headerpad_max_install_names"
      ENV.append "LDFLAGS", "-L#{Formula["llvm"].lib} -Wl,-rpath,#{Formula["llvm"].lib}" if build.with? "openmp"
      ENV["CXXFLAGS"] = "-I#{Formula["llvm"].include}/c++/v1 -std=c++11 -stdlib=libc++" if build.with? "openmp"
      ENV['MAC_OS_X_VERSION_MIN_REQUIRED'] = osx
      if MacOS.version < :mavericks
        ENV.libstdcxx
      else
        ENV.libcxx
      end

      args = [
        "--prefix=#{prefix}",
        "--with-opengl",
        "--enable-debug",
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
        "--with-macosx-version-min=#{osx}"
      ]

      if MacOS.version >= :sierra
        args << "--disable-mediactrl"
        args << "--with-macosx-sdk=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX#{osx}.sdk" if build.with? "openmp"
      end

      if build.with? "openmp"
        args << "CC=#{Formula["llvm"].bin}/clang"
        args << "CXX=#{Formula["llvm"].bin}/clang++"
      else
        args << "CC=#{ENV.cc}"
        args << "CXX=#{ENV.cxx}"
        args << "--enable-universal_binary=i386,x86_64"
      end

      system "../configure", *args
      system "make", "-j#{ENV.make_jobs}"
      system "make", "install"
    end
    (prefix/"wx-build").install Dir["wx-build/*"]
  end
end
