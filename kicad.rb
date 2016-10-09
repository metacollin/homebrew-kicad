class Kicad < Formula
  desc "Electronic Design Automation Suite"
  homepage "http://www.kicad-pcb.org"
  url "https://launchpad.net/kicad/4.0/4.0.4/+download/kicad-4.0.4.tar.xz"
  sha256 "6da5d3f7bc63a9c5b4d0f5e4b954411b45d712168596b5af02957343c87eda00"
  head "https://git.launchpad.net/kicad", :using => :git

  option "without-menu-icons", "Build without icons menus."
  option "with-brewed-library", "Use homebrew to manage KiCad\"s library files"
  option "with-nice-curves", "Doubles the point/segment count used both in pcbnew, and plotted file formats"
  option "with-openmp", "Use OpenMP for multiprocessing support"
  option "with-nicer-curves", "Quadruples the point/segment count used both in pcbnew, and plotted file formats"
  option "with-ngspice", "Build eeschema with ngspice simulation functionality. --HEAD only."
  option "with-oce", "Build with open cascade support.  --HEAD only."

  head do
    depends_on "boost"
  end

  stable do
    depends_on "homebrew/versions/boost159"
  end

  depends_on "cairo"
  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gettext"
  depends_on "glew"
  depends_on "glib"
  depends_on "icu4c"
  depends_on "libffi"
  depends_on "libpng"
  depends_on "makedepend" => :build
  depends_on "openssl"
  depends_on "pcre"
  depends_on "pixman"
  depends_on "pkg-config" => :build
  depends_on "python" => :recommended
  depends_on "swig" => :build if build.with? "python"
  depends_on "xz"
  depends_on "glm"
  depends_on "llvm" => :build if build.with? "openmp"
  depends_on "homebrew/science/oce" if build.with? "oce"
  depends_on "libngspice" if build.with? "ngspice"

  if (build.with? "ngspice") && (build.stable?)
    odie "Sorry, ngspice functionality requires building --HEAD"
  end

  if (build.with? "oce") && (build.stable?)
    odie "Sorry, opencascade support requires building --HEAD"
  end

  if (build.with? "openmp") && (build.stable?)
    odie "Sorry, openmp support requies building --HEAD"
  end

  if build.with? "openmp"
    env :std # Necessary to switch to a different llvm toolchain.  Apple's clang *still* doesn't support OpenMP.
    # We need to make sure wx is built and linked against the new toolchain's standard librares.
    if build.with? "debug"
      depends_on "metacollin/kicad/wxkdebug" => ["with-openmp"]
    else
      depends_on "metacollin/kicad/wxkicad" => ["with-openmp"]
    end
  else
    if  build.with? "debug"
      depends_on "metacollin/kicad/wxdebug"
    else
      depends_on "metacollin/kicad/wxkicad"
    end
  end

  bottle do
    root_url "https://electropi.mp/bottles"
    cellar :any
    sha256 "0a3ab5427a0881ecceca9b11429a039109cf86adf942d0c2d3c36a557650df4e" => :sierra
  end

  fails_with :gcc
  fails_with :llvm

  if build.with? "python"
    resource "wxk" do
      url "https://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2"
      sha256 "d54129e5fbea4fb8091c87b2980760b72c22a386cb3b9dd2eebc928ef5e8df61"
    end
  end

  if build.with? "brewed-library"
    resource "kicad-library" do
      url "https://github.com/KiCad/kicad-library.git"
    end
  end

  def install
    if  build.with? "debug"
      chmod 0644, Dir["#{Formula['metacollin/kicad/wxdebug'].lib}/*.dylib"]
    else
      chmod 0644, Dir["#{Formula['metacollin/kicad/wxkicad'].lib}/*.dylib"]
    end

    osx = MacOS.version
    osx = "10.11" if (build.with? "openmp") && (osx >= :sierra)

    ENV["ARCHFLAGS"] = "-Wunused-command-line-argument-hard-error-in-future"
    ENV.append "LDFLAGS", "-headerpad_max_install_names"
    ENV.append "LDFLAGS", "-L#{Formula['llvm'].lib} -Wl,-rpath,#{Formula['llvm'].lib}" if build.with? "openmp"
    ENV["CXXFLAGS"] = "-I#{Formula['llvm'].include}/c++/v1 -std=c++11 -stdlib=libc++" if build.with? "openmp"
    ENV["CC"] = "#{Formula['llvm'].bin}/clang" if build.with? "openmp"
    ENV["CXX"] = "#{Formula['llvm'].bin}/clang++" if build.with? "openmp"
    ENV["MAC_OS_X_VERSION_MIN_REQUIRED"] = osx

    if MacOS.version < :mavericks
      ENV.libstdcxx
    else
      ENV.libcxx
    end

   # inreplace "include/tool/coroutine.h", "#include <boost/context/fcontext.hpp>", "#if BOOST_VERSION < 106100\n#include <boost/context/fcontext.hpp>\n#else\n#include <boost/context/detail/fcontext.hpp>\n#endif"
   # inreplace "include/tool/coroutine.h", "boost::context::", "boost::context::detail::"

    if build.with? "brewed-library"
      inreplace "common/common.cpp", "/Library/Application Support/kicad", "#{etc}/kicad"
      inreplace "common/common.cpp", "wxStandardPaths::Get().GetUserConfigDir()", "wxT( \"#{etc}/kicad\" )"
      inreplace "common/pgm_base.cpp", "DEFAULT_INSTALL_PATH", "\"#{etc}/kicad\""
    end

    ##!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!##
    ## Note: I have personally had several boards manufactured using gerbers generated with these settings, so these have been tested  ##
    ## in a production environment.                                                                                                    ##
    ##                                                                                                                                 ##
    ## Even certain overly picky manufacturers with old machines didn't have any problems with the increased file size.                ##
    ##                                                                                                                                 ##
    ## However, this is not an indication it will work for you or won't break or ruin your boards.  Use at your own risk and liability.##
    ## - metacollin #####################################################################################################################
    if build.with? "nice-curves"
      inreplace "gerbview/dcode.cpp", "define SEGS_CNT 32", "define SEGS_CNT 64"
      inreplace "gerbview/export_to_pcbnew.cpp", "SEG_COUNT_CIRCLE    16", "SEG_COUNT_CIRCLE    32"
      inreplace "gerbview/class_aperture_macro.cpp", "const int seg_per_circle = 64", "const int seg_per_circle = 128"
      inreplace "common/geometry/shape_poly_set.cpp", "define SEG_CNT_MAX 64", "define SEG_CNT_MAX 128"
      inreplace "pcbnew/pcbnew.h", "define ARC_APPROX_SEGMENTS_COUNT_LOW_DEF 16", "define ARC_APPROX_SEGMENTS_COUNT_LOW_DEF 30"
      inreplace "pcbnew/pcbnew.h", "define ARC_APPROX_SEGMENTS_COUNT_HIGHT_DEF 32", "define ARC_APPROX_SEGMENTS_COUNT_HIGHT_DEF 64"
      inreplace "pcbnew/pcbnew.h", "TEXTS_MIN_SIZE  Mils2iu( 5 )", "TEXTS_MIN_SIZE  Mils2iu( 3 )"
      inreplace "pcbnew/class_pad_draw_functions.cpp", "define SEGCOUNT 32", "define SEGCOUNT 64"
      inreplace "common/common_plotDXF_functions.cpp", "const int segmentToCircleCount = 64;", "const int segmentToCircleCount = 128;"
      inreplace "common/common_plotGERBER_functions.cpp", "const int segmentToCircleCount = 64;", "const int segmentToCircleCount = 128;"
      inreplace "common/common_plotHPGL_functions.cpp", "const int segmentToCircleCount = 32;", "const int segmentToCircleCount = 64;"
      inreplace "common/common_plotPS_functions.cpp", "const int segmentToCircleCount = 64;", "const int segmentToCircleCount = 128;"
      inreplace "include/gal/opengl/opengl_gal.h", "static const int    CIRCLE_POINTS   = 64;", "static const int    CIRCLE_POINTS   = 128;"
      inreplace "include/gal/opengl/opengl_gal.h", "static const int    CURVE_POINTS    = 32;", "static const int    CURVE_POINTS    = 64;"
      inreplace "common/class_plotter.cpp", "const int delta = 50;", "const int delta = 25;"
      inreplace "3d-viewer/3d_canvas/cinfo3d_visu.cpp", "#define MIN_SEG_PER_CIRCLE 12", "#define MIN_SEG_PER_CIRCLE 24"
      inreplace "3d-viewer/3d_canvas/cinfo3d_visu.cpp", "#define MAX_SEG_PER_CIRCLE 48", "#define MAX_SEG_PER_CIRCLE 96"
    end

    if build.with? "nicer-curves"
      inreplace "gerbview/dcode.cpp", "define SEGS_CNT 32", "define SEGS_CNT 128"
      inreplace "gerbview/export_to_pcbnew.cpp", "SEG_COUNT_CIRCLE    16", "SEG_COUNT_CIRCLE    64"
      inreplace "gerbview/class_aperture_macro.cpp", "const int seg_per_circle = 64", "const int seg_per_circle = 256"
      inreplace "common/geometry/shape_poly_set.cpp", "define SEG_CNT_MAX 64", "define SEG_CNT_MAX 256"
      inreplace "pcbnew/pcbnew.h", "define ARC_APPROX_SEGMENTS_COUNT_LOW_DEF 16", "define ARC_APPROX_SEGMENTS_COUNT_LOW_DEF 60"
      inreplace "pcbnew/pcbnew.h", "define ARC_APPROX_SEGMENTS_COUNT_HIGHT_DEF 32", "define ARC_APPROX_SEGMENTS_COUNT_HIGHT_DEF 128"
      inreplace "pcbnew/pcbnew.h", "TEXTS_MIN_SIZE  Mils2iu( 5 )", "TEXTS_MIN_SIZE  Mils2iu( 3 )"
      inreplace "pcbnew/class_pad_draw_functions.cpp", "define SEGCOUNT 32", "define SEGCOUNT 128"
      inreplace "common/common_plotDXF_functions.cpp", "const int segmentToCircleCount = 64;", "const int segmentToCircleCount = 256;"
      inreplace "common/common_plotGERBER_functions.cpp", "const int segmentToCircleCount = 64;", "const int segmentToCircleCount = 256;"
      inreplace "common/common_plotHPGL_functions.cpp", "const int segmentToCircleCount = 32;", "const int segmentToCircleCount = 128;"
      inreplace "common/common_plotPS_functions.cpp", "const int segmentToCircleCount = 64;", "const int segmentToCircleCount = 256;"
      inreplace "include/gal/opengl/opengl_gal.h", "static const int    CIRCLE_POINTS   = 64;", "static const int    CIRCLE_POINTS   = 256;"
      inreplace "include/gal/opengl/opengl_gal.h", "static const int    CURVE_POINTS    = 32;", "static const int    CURVE_POINTS    = 128;"
      inreplace "common/class_plotter.cpp", "const int delta = 50;", "const int delta = 10;"
      inreplace "3d-viewer/3d_canvas/cinfo3d_visu.cpp", "#define MIN_SEG_PER_CIRCLE 12", "#define MIN_SEG_PER_CIRCLE 48"
      inreplace "3d-viewer/3d_canvas/cinfo3d_visu.cpp", "#define MAX_SEG_PER_CIRCLE 48", "#define MAX_SEG_PER_CIRCLE 300"
    end

    if build.with? "python"
      resource("wxk").stage do
        cd "wxPython" do
          args = [
            "WXPORT=osx_cocoa",
            "UNICODE=1"
          ]

          if build.with? "debug"
            args << "WX_CONFIG=#{Formula['metacollin/kicad/wxkdebug'].bin}/wx-config"
            args << "BUILD_BASE=#{Formula['metacollin/kicad/wxkdebug']}/wx-build"
          else
            args << "WX_CONFIG=#{Formula['metacollin/kicad/wxkicad'].bin}/wx-config"
            args << "BUILD_BASE=#{Formula['metacollin/kicad/wxkicad']}/wx-build"
          end

          system "python", "setup.py", "build_ext", *args
          system "python", "setup.py", "install", "--prefix=#{buildpath}/py", *args
        end
      end
    end

    mkdir "build" do
      ENV.prepend_create_path "PYTHONPATH", "#{buildpath}/py/lib/python2.7/site-packages" if build.with? "python"

      args = %W[
        -DCMAKE_INSTALL_PREFIX=#{prefix}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=#{osx}
        -DKICAD_REPO_NAME=brewed_product
        -DKICAD_SKIP_BOOST=ON
        -DBoost_USE_STATIC_LIBS=ON
        -DKICAD_USE_SCH_IO_MANAGER=ON
      ]

      if build.with? "debug"
        args << "-DCMAKE_BUILD_TYPE=Debug"
        args << "-DwxWidgets_USE_DEBUG=ON"
        args << "-DwxWidgets_CONFIG_EXECUTABLE=#{Formula['metacollin/kicad/wxkdebug'].bin}/wx-config"
      else
        args << "-DCMAKE_BUILD_TYPE=Release"
        args << "-DwxWidgets_CONFIG_EXECUTABLE=#{Formula['metacollin/kicad/wxkicad'].bin}/wx-config"
      end

      if build.with? "python"
        args << "-DPYTHON_SITE_PACKAGE_PATH=#{buildpath}/py/lib/python2.7/site-packages"
        args << "-DKICAD_SCRIPTING=ON"
        args << "-DKICAD_SCRIPTING_MODULES=ON"
        args << "-DKICAD_SCRIPTING_WXPYTHON=ON"
        python_executable = `which python`.strip
        args << "-DPYTHON_EXECUTABLE=#{python_executable}"
      else
        args << "-DKICAD_SCRIPTING=OFF"
        args << "-DKICAD_SCRIPTING_MODULES=OFF"
        args << "-DKICAD_SCRIPTING_WXPYTHON=OFF"
      end

      if build.with? "openmp"
        args << "-DCMAKE_C_COMPILER=#{Formula['llvm'].bin}/clang"
        args << "-DCMAKE_CXX_COMPILER=#{Formula['llvm'].bin}/clang++"
      else
        args << "-DCMAKE_C_COMPILER=#{ENV.cc}"
        args << "-DCMAKE_CXX_COMPILER=#{ENV.cxx}"
      end

      args << "-DKICAD_USE_OCE=ON" if build.with? "oce"
      args << "-DKICAD_SPICE=ON" if build.with? "ngspice"

      if build.with? "menu-icons"
        args << "-DUSE_IMAGES_IN_MENUS=ON"
      end

      system "cmake", "../", *args
      system "make", "-j#{ENV.make_jobs}"
      system "make", "install"
    end
  end

  def kicaddir
    etc / "kicad"
  end

  def caveats
    s = <<-EOS.undent

      KiCad component libraries must be installed manually in:
        /Library/Application Support/kicad

      This can be done with the following command:
        sudo git clone https://github.com/KiCad/kicad-library.git \
          /Library/Application\ Support/kicad
      EOS

    s
  end

  test do
    assert File.exist? "#{prefix}/KiCad.app/Contents/MacOS/kicad"
  end
end
