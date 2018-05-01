class Kicad < Formula
  desc "Electronic Design Automation Suite"
  homepage "http://www.kicad-pcb.org"
  url "https://launchpad.net/kicad/4.0/4.0.7/+download/kicad-4.0.7.tar.xz"
  sha256 "09074c77c6097d0f2ae49711c6d6f6c4490f0c068bba69b17f5f07319255fdc1"
  head "https://git.launchpad.net/kicad", :using => :git

 # option "with-nice-curves", "Uses smoothness of curves in pcbnew visually and in plotted outputs (like gerbers). Most systems shouldn't see a meaningful performance impact."
  #option "with-mc-defaults", "Patch so new pcbnew files are created with metacollin's preferred defaults.  This is for metacollin's own use and is neither supported or recommended."
  

  conflicts_with "wxmac", :because => "pcbnew doesn't work correctly if it is installed.  Hopefully fixed soon."
  conflicts_with "wxpython", :because => "pcbnew doesn't work correctly if it is installed.  Hopefully fixed soon."

  depends_on :xcode => :build
  depends_on "boost"
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
  depends_on "python@2" => :recommended
  depends_on "swig" => :build if build.with? "python"
  depends_on "xz"
  depends_on "glm"
  depends_on "metacollin/kicad/kicad-wxwidgets"
  depends_on "oce" => :optional
  depends_on "libngspice" => :optional
  depends_on "metacollin/kicad/kicad-wxpython" if build.with? "python"
  #depends_on "metacollin/kicad/kicad-library" => :recommended

  if (build.with? "libngspice") && build.stable?
    odie "Sorry, ngspice functionality requires building --HEAD"
  end

  if (build.with? "oce") && build.stable?
    odie "Can't build stable if using --with-oce. Build --HEAD instead."
  end

  fails_with :gcc

  def install
    ENV["ARCHFLAGS"] = "-Wunused-command-line-argument-hard-error-in-future"
    ENV.append "LDFLAGS", "-headerpad_max_install_names"
    ENV["MAC_OS_X_VERSION_MIN_REQUIRED"] = MacOS.version

    if MacOS.version < :mavericks
      ENV.libstdcxx
    else
      ENV.libcxx
    end

     # if build.with? "kicad-library"
     #   inreplace "common/common.cpp", "/Library/Application Support/kicad", "#{etc}/kicad"



   #  if build.with? "nice-curves"
   #    if build.stable? 
   #      inreplace "gerbview/dcode.cpp", "define SEGS_CNT 32", "define SEGS_CNT 128"
   #      inreplace "gerbview/export_to_pcbnew.cpp", "SEG_COUNT_CIRCLE    16", "SEG_COUNT_CIRCLE    64"
   #      inreplace "gerbview/class_aperture_macro.cpp", "const int seg_per_circle = 64", "const int seg_per_circle = 256"
   #      inreplace "common/geometry/shape_poly_set.cpp", "define SEG_CNT_MAX 64", "define SEG_CNT_MAX 256"
   #      inreplace "pcbnew/pcbnew.h", "define ARC_APPROX_SEGMENTS_COUNT_LOW_DEF 16", "define ARC_APPROX_SEGMENTS_COUNT_LOW_DEF 60"
   #      inreplace "pcbnew/pcbnew.h", "define ARC_APPROX_SEGMENTS_COUNT_HIGHT_DEF 32", "define ARC_APPROX_SEGMENTS_COUNT_HIGHT_DEF 128"
   #      inreplace "pcbnew/pcbnew.h", "TEXTS_MIN_SIZE  Mils2iu( 5 )", "TEXTS_MIN_SIZE  Mils2iu( 3 )"
   #      inreplace "pcbnew/class_pad_draw_functions.cpp", "define SEGCOUNT 32", "define SEGCOUNT 128"
   #      inreplace "common/common_plotDXF_functions.cpp", "const int segmentToCircleCount = 64;", "const int segmentToCircleCount = 256;"
   #      inreplace "common/common_plotGERBER_functions.cpp", "const int segmentToCircleCount = 64;", "const int segmentToCircleCount = 256;"
   #      inreplace "common/common_plotHPGL_functions.cpp", "const int segmentToCircleCount = 32;", "const int segmentToCircleCount = 128;"
   #      inreplace "common/common_plotPS_functions.cpp", "const int segmentToCircleCount = 64;", "const int segmentToCircleCount = 256;"
   #      inreplace "include/gal/opengl/opengl_gal.h", "static const int    CIRCLE_POINTS   = 64;", "static const int    CIRCLE_POINTS   = 256;"
   #      inreplace "include/gal/opengl/opengl_gal.h", "static const int    CURVE_POINTS    = 32;", "static const int    CURVE_POINTS    = 128;"
   #      inreplace "common/class_plotter.cpp", "const int delta = 50;", "const int delta = 10;"
   #      inreplace "3d-viewer/3d_canvas/cinfo3d_visu.cpp", "#define MIN_SEG_PER_CIRCLE 12", "#define MIN_SEG_PER_CIRCLE 48"
   #      inreplace "3d-viewer/3d_canvas/cinfo3d_visu.cpp", "#define MAX_SEG_PER_CIRCLE 48", "#define MAX_SEG_PER_CIRCLE 300"
   # #   else  # HEAD
   #      inreplace "gerbview/dcode.cpp", "define SEGS_CNT 64", "define SEGS_CNT 128"
   #      inreplace "gerbview/export_to_pcbnew.cpp", "SEG_COUNT_CIRCLE    16", "SEG_COUNT_CIRCLE    64"
   #     # inreplace "gerbview/class_aperture_macro.cpp", "const int seg_per_circle = 64", "const int seg_per_circle = 256"
   #      inreplace "common/geometry/shape_poly_set.cpp", "define SEG_CNT_MAX 64", "define SEG_CNT_MAX 256"
   #      inreplace "pcbnew/pcbnew.h", "define ARC_APPROX_SEGMENTS_COUNT_LOW_DEF 16", "define ARC_APPROX_SEGMENTS_COUNT_LOW_DEF 60"
   #      inreplace "pcbnew/pcbnew.h", "define ARC_APPROX_SEGMENTS_COUNT_HIGHT_DEF 32", "define ARC_APPROX_SEGMENTS_COUNT_HIGHT_DEF 128"
   #      inreplace "pcbnew/pcbnew.h", "TEXTS_MIN_SIZE  Mils2iu( 5 )", "TEXTS_MIN_SIZE  Mils2iu( 3 )"
   #      #inreplace "pcbnew/class_pad_draw_functions.cpp", "define SEGCOUNT 32", "define SEGCOUNT 128"
   #      #inreplace "common/common_plotDXF_functions.cpp", "const int segmentToCircleCount = 64;", "const int segmentToCircleCount = 256;"
   #     # inreplace "common/common_plotGERBER_functions.cpp", "const int segmentToCircleCount = 64;", "const int segmentToCircleCount = 256;"
   #    #  inreplace "common/common_plotHPGL_functions.cpp", "const int segmentToCircleCount = 32;", "const int segmentToCircleCount = 128;"
   #   #   inreplace "common/common_plotPS_functions.cpp", "const int segmentToCircleCount = 64;", "const int segmentToCircleCount = 256;"
   #      inreplace "include/gal/opengl/opengl_gal.h", "static const int    CIRCLE_POINTS   = 64;", "static const int    CIRCLE_POINTS   = 256;"
   #      inreplace "include/gal/opengl/opengl_gal.h", "static const int    CURVE_POINTS    = 32;", "static const int    CURVE_POINTS    = 128;"
   #     # inreplace "common/class_plotter.cpp", "const int delta = 50;", "const int delta = 10;"
   #      inreplace "3d-viewer/3d_canvas/cinfo3d_visu.cpp", "#define MIN_SEG_PER_CIRCLE 12", "#define MIN_SEG_PER_CIRCLE 48"
   #      inreplace "3d-viewer/3d_canvas/cinfo3d_visu.cpp", "#define MAX_SEG_PER_CIRCLE 48", "#define MAX_SEG_PER_CIRCLE 300"
   #    end
   #  end

    mkdir "build" do
      ENV.prepend_create_path "PYTHONPATH", "#{Formula["metacollin/kicad/kicad-wxpython"].lib}/python2.7/site-packages" if build.with? "python"

      args = %W[
        -DCMAKE_INSTALL_PREFIX=#{prefix}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}
        -DwxWidgets_CONFIG_EXECUTABLE=#{Formula["metacollin/kicad/kicad-wxwidgets"].bin}/wx-config
        -DCMAKE_C_COMPILER=#{ENV.cc}
        -DCMAKE_CXX_COMPILER=#{ENV.cxx}
      ]

      if build.with? "debug"
        args << "-DCMAKE_BUILD_TYPE=Debug"
        args << "-DwxWidgets_USE_DEBUG=ON"
      else
        args << "-DCMAKE_BUILD_TYPE=Release"
      end

      if build.with? "python"
        args << "-DPYTHON_SITE_PACKAGE_PATH=#{Formula["metacollin/kicad/kicad-wxpython"].lib}/python2.7/site-packages"
        args << "-DKICAD_SCRIPTING=ON"
        args << "-DKICAD_SCRIPTING_MODULES=ON"
        args << "-DKICAD_SCRIPTING_WXPYTHON=ON"
        args << "-DKICAD_SCRIPTING_ACTION_MENU=ON"
        args << "-DPYTHON_EXECUTABLE=#{Formula["python@2"].bin}/python"
        args << "-DPYTHON_LIBRARY=#{Formula["python@2"].Frameworks}/Python.framework/Versions/2.7/lib/libpython2.7.dylib" # This feels wrong
      else
        args << "-DKICAD_SCRIPTING=OFF"
        args << "-DKICAD_SCRIPTING_MODULES=OFF"
        args << "-DKICAD_SCRIPTING_WXPYTHON=OFF"
      end

      if build.with? "oce"
        args << "-DKICAD_USE_OCE=ON"
        args << "-DOCE_DIR=#{Formula["oce"]}/OCE.framework/Versions/0.18/Resources" # Fix hardcoded version
      end

      args << "-DKICAD_SPICE=OFF" if build.without? "ngspice"

      if build.with? "ngspice"
        args << "-DNGSPICE_LIBRARY=/usr/local/opt/ngspice/lib/ngspice"
      end


      system "cmake", "../", *args
      system "make", "-j#{ENV.make_jobs}"
      system "make", "install"
    end
  end

  #def caveats
  #  s = <<-EOS.undent

#      KiCad component libraries must be installed manually in:
#        /Library/Application Support/kicad

#      This can be done with the following command:
#        sudo git clone https://github.com/KiCad/kicad-library.git \
#          /Library/Application\ Support/kicad
#      EOS

#    s
#  end

  test do
    assert File.exist? "#{prefix}/KiCad.app/Contents/MacOS/kicad"
  end
end