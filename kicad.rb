class Kicad < Formula
  desc "Electronic Design Automation Suite"
  homepage "http://www.kicad-pcb.org"
  url "https://launchpad.net/kicad/4.0/4.0.6/+download/kicad-4.0.6.tar.xz"
  sha256 "e97cacc179839e65f2afa14d8830a3bed549aaa9ed234c988851971bf2a42298"
  head "https://git.launchpad.net/kicad", :using => :git

  option "with-nice-curves", "Uses smoothness of curves in pcbnew visually and in plotted outputs (like gerbers). Most systems shouldn't see a meaningful performance impact."
  option "with-mc-defaults", "Patch so new pcbnew files are created with metacollin's preferred defaults.  This is for metacollin's own use and is neither supported or recommended."

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
  depends_on "python" => :recommended
  depends_on "swig" => :build if build.with? "python"
  depends_on "xz"
  depends_on "glm"
  depends_on "metacollin/kicad/kicad-wxwidgets"
  depends_on "homebrew/science/oce" => :optional
  depends_on "libngspice" => :optional
  depends_on "metacollin/kicad/kicad-wxpython" if build.with? "python"

  if (build.with? "libngspice") && build.stable?
    odie "Sorry, ngspice functionality requires building --HEAD"
  end

  if (build.with? "oce") && build.stable?
    odie "Can't build stable if using --with-oce. Build --HEAD instead."
  end

  fails_with :gcc

  patch :DATA if build.with? "mc-defaults"

  def install
    ENV["ARCHFLAGS"] = "-Wunused-command-line-argument-hard-error-in-future"
    ENV.append "LDFLAGS", "-headerpad_max_install_names"
    ENV["MAC_OS_X_VERSION_MIN_REQUIRED"] = MacOS.version

    if MacOS.version < :mavericks
      ENV.libstdcxx
    else
      ENV.libcxx
    end

    # #!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#
    ## Note: I have personally had several boards manufactured using gerbers generated with these settings, so these have been tested  ##
    ## in a production environment.                                                                                                    ##
    ##                                                                                                                                 ##
    ## Even certain overly picky manufacturers with old machines didn't have any problems with the increased file size.                ##
    ##                                                                                                                                 ##
    ## However, this is not an indication it will work for you or won't break or ruin your boards.  Use at your own risk and liability.##
    ## - metacollin #####################################################################################################################

    if build.with? "nice-curves"
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

    mkdir "build" do
      ENV.prepend_create_path "PYTHONPATH", "#{Formula["metacollin/kicad/kicad-wxpython"].lib}/python2.7/site-packages" if build.with? "python"

      args = %W[
        -DCMAKE_INSTALL_PREFIX=#{prefix}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}
        -DKICAD_REPO_NAME=brewed_product
        -DKICAD_SKIP_BOOST=ON
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
        python_executable = `which python`.strip
        args << "-DPYTHON_EXECUTABLE=#{python_executable}"
      else
        args << "-DKICAD_SCRIPTING=OFF"
        args << "-DKICAD_SCRIPTING_MODULES=OFF"
        args << "-DKICAD_SCRIPTING_WXPYTHON=OFF"
      end

      if build.with? "oce"
        args << "-DKICAD_USE_OCE=ON"
        args << "-DOCE_DIR=#{Formula["oce"]}/OCE.framework/Versions/0.18/Resources" # Fix hardcoded version
      end

      args << "-DKICAD_SPICE=ON" if build.with? "ngspice"

      system "cmake", "../", *args
      system "make", "-j#{ENV.make_jobs}"
      system "make", "install"
    end
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

__END__
diff --git a/common/project.cpp b/common/project.cpp
index ebf8f13..9a706a0 100644
--- a/common/project.cpp
+++ b/common/project.cpp
@@ -227,6 +227,7 @@ static bool copy_pro_file_template( const SEARCH_STACK& aSearchS, const wxString
     }

     wxString templateFile = wxT( "kicad." ) + ProjectFileExtension;
+    wxString pcbFile = wxT( "kicad." ) + KiCadPcbFileExtension;

     wxString kicad_pro_template = aSearchS.FindValidPath( templateFile );

@@ -253,6 +254,9 @@ static bool copy_pro_file_template( const SEARCH_STACK& aSearchS, const wxString

     DBG( printf( "%s: using template file '%s' as project file.\n", __func__, TO_UTF8( kicad_pro_template ) );)

+
+    wxString kicad_pcb_template = aSearchS.FindValidPath( pcbFile );
+
     // Verify aDestination can be created. if this is not the case, wxCopyFile
     // will generate a crappy log error message, and we *do not want* this kind
     // of stupid message
@@ -260,7 +264,20 @@ static bool copy_pro_file_template( const SEARCH_STACK& aSearchS, const wxString
     bool success = true;

     if( fn.IsOk() && fn.IsDirWritable() )
+    {
         success = wxCopyFile( kicad_pro_template, aDestination );
+        if ( !kicad_pcb_template )
+        {
+        }
+        else
+        {
+
+            wxString aDest = aDestination;
+            aDest.Replace(ProjectFileExtension, KiCadPcbFileExtension);
+            wxCopyFile( kicad_pcb_template, aDest);
+        }
+
+    }
     else
     {
         wxLogMessage( _( "Cannot create prj file '%s' (Directory not writable)" ),
diff --git a/template/CMakeLists.txt b/template/CMakeLists.txt
index a804e9e..c3e128d 100644
--- a/template/CMakeLists.txt
+++ b/template/CMakeLists.txt
@@ -1,5 +1,6 @@
 install( FILES
     kicad.pro
+    kicad.kicad_pcb
     gost_landscape.kicad_wks
     gost_portrait.kicad_wks
     pagelayout_default.kicad_wks
diff --git a/template/kicad.pro b/template/kicad.pro
index 804cf83..9f7194d 100644
--- a/template/kicad.pro
+++ b/template/kicad.pro
@@ -13,13 +13,13 @@
 PadDrillOvalY=0.600000000000
 PadSizeH=1.500000000000
 PadSizeV=1.500000000000
-PcbTextSizeV=1.500000000000
-PcbTextSizeH=1.500000000000
-PcbTextThickness=0.300000000000
-ModuleTextSizeV=1.000000000000
-ModuleTextSizeH=1.000000000000
-ModuleTextSizeThickness=0.150000000000
-SolderMaskClearance=0.000000000000
+PcbTextSizeV=0.800000000000
+PcbTextSizeH=0.800000000000
+PcbTextThickness=0.1250000000000
+ModuleTextSizeV=0.800000000000
+ModuleTextSizeH=0.800000000000
+ModuleTextSizeThickness=0.125000000000
+SolderMaskClearance=0.1012000000000
 SolderMaskMinWidth=0.000000000000
 DrawSegmentWidth=0.200000000000
 BoardOutlineThickness=0.100000000000
@@ -60,3 +60,4 @@
 LibName27=atmel
 LibName28=contrib
 LibName29=valves
+LibName30=collieparts
diff --git a/template/kicad.kicad_pcb b/template/kicad.kicad_pcb
index e69de29..8ef89d4 100644
--- a/template/kicad.kicad_pcb
+++ b/template/kicad.kicad_pcb
@@ -0,0 +1,123 @@
+(kicad_pcb (version 4) (host pcbnew "(2014-09-28 BZR 5153)-product")
+
+  (general
+    (links 0)
+    (no_connects 0)
+    (area 0 0 0 0)
+    (thickness 1.6)
+    (drawings 0)
+    (tracks 0)
+    (zones 0)
+    (modules 0)
+    (nets 1)
+  )
+
+  (page A4)
+  (layers
+    (0 F.Cu signal)
+    (31 B.Cu signal)
+    (32 B.Adhes user)
+    (33 F.Adhes user)
+    (34 B.Paste user)
+    (35 F.Paste user)
+    (36 B.SilkS user)
+    (37 F.SilkS user)
+    (38 B.Mask user)
+    (39 F.Mask user)
+    (40 Dwgs.User user)
+    (41 Cmts.User user)
+    (42 Eco1.User user)
+    (43 Eco2.User user)
+    (44 Edge.Cuts user)
+    (45 Margin user)
+    (46 B.CrtYd user)
+    (47 F.CrtYd user)
+    (48 B.Fab user)
+    (49 F.Fab user)
+  )
+
+  (setup
+    (last_trace_width 0.254)
+    (user_trace_width 0.1524)
+    (user_trace_width 0.2032)
+    (user_trace_width 0.254)
+    (user_trace_width 0.3048)
+    (user_trace_width 0.381)
+    (user_trace_width 0.4572)
+    (user_trace_width 0.508)
+    (user_trace_width 0.635)
+    (user_trace_width 0.7112)
+    (user_trace_width 0.8128)
+    (user_trace_width 0.9144)
+    (user_trace_width 1.27)
+    (trace_clearance 0.1524)
+    (zone_clearance 0.1524)
+    (zone_45_only yes)
+    (trace_min 0.1524)
+    (segment_width 0.127)
+    (edge_width 0.127)
+    (via_size 0.6858)
+    (via_drill 0.3302)
+    (via_min_size 0.6858)
+    (via_min_drill 0.3302)
+    (user_via 0.8636 0.508)
+    (user_via 0.9906 0.635)
+    (user_via 1.0922 0.7366)
+    (user_via 1.2446 0.889)
+    (user_via 1.3716 1.016)
+    (uvia_size 0.6858)
+    (uvia_drill 0.3302)
+    (uvias_allowed no)
+    (uvia_min_size 0.6858)
+    (uvia_min_drill 0.3302)
+    (pcb_text_width 0.127)
+    (pcb_text_size 0.8 0.8)
+    (mod_edge_width 0.127)
+    (mod_text_size 0.8 0.8)
+    (mod_text_width 0.127)
+    (pad_size 1.524 1.524)
+    (pad_drill 0.762)
+    (pad_to_mask_clearance 0.05)
+    (pad_to_paste_clearance -0.04)
+    (aux_axis_origin 0 0)
+    (visible_elements FFFFFF7F)
+    (pcbplotparams
+      (layerselection 0x010f0_ffffffff)
+      (usegerberextensions false)
+      (usegerberattributes true)
+      (excludeedgelayer true)
+      (linewidth 0.127000)
+      (plotframeref false)
+      (viasonmask false)
+      (mode 1)
+      (useauxorigin false)
+      (hpglpennumber 1)
+      (hpglpenspeed 20)
+      (hpglpendiameter 15)
+      (hpglpenoverlay 2)
+      (psnegative false)
+      (psa4output false)
+      (plotreference true)
+      (plotvalue true)
+      (plotinvisibletext false)
+      (padsonsilk false)
+      (subtractmaskfromsilk false)
+      (outputformat 1)
+      (mirror false)
+      (drillshape 0)
+      (scaleselection 1)
+      (outputdirectory CAM/))
+  )
+
+  (net 0 "")
+
+  (net_class Default "This is the standard class."
+    (clearance 0.1524)
+    (trace_width 0.1524)
+    (via_dia 0.6858)
+    (via_drill 0.3302)
+    (uvia_dia 0.6858)
+    (uvia_drill 0.3302)
+  )
+
+)
