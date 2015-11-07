  class Kicad < Formula
  desc "Electronic Design CAD Suite"
  homepage "http://www.kicad-pcb.org"
  head "https://github.com/KiCad/kicad-source-mirror.git"

  depends_on "bazaar" => :build
  depends_on "cmake" => :build
  depends_on "wxkicad"
  depends_on "wxkython" if build.with? "python-scripting"
  depends_on :python if build.with? "python-scripting"
  depends_on "boost"
  depends_on "libiomp" if build.with? "openmp"
  depends_on "clang-omp"
  depends_on "openssl"

  option "without-menu-icons", "Build without icons menus."
  option "with-openmp", "Enables multicore performance enhancements using OpenMP 4.0.  Highly experimental."
  option "with-python-scripting", "Enables python scripting and python scripting modules for KiCad."

  fails_with :gcc
  fails_with :llvm
  #needs :cxx11


    patch :DATA

  def install
    # Homebrew insists on chmoding _everything_ 0444, and install_name_tool will be unable to properly bundle them in the .app.
    if build.with? "python-scripting"
      chmod_R(0744, Dir.glob("#{Formula["wxkython"].lib}/python2.7/site-packages/*"))
    end
    chmod_R(0744, Dir.glob("#{Formula["wxkicad"].lib}/*"))

    mkdir "build" do
      if build.with? "python-scripting"
        ENV.prepend_create_path "PYTHONPATH", "#{Formula["wxkython"].lib}/python2.7/site-packages" # Need this to find wxpython.
      end
      ENV['ARCHFLAGS'] = "-Wunused-command-line-argument-hard-error-in-future" # Need this for 10.7 and 10.8.

      if MacOS.version < :mavericks
        ENV.libstdcxx
      else
        ENV.libcxx
      end

      args = %W[
        -DCMAKE_INSTALL_PREFIX=#{prefix}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}
        -DwxWidgets_CONFIG_EXECUTABLE=#{Formula["wxkicad"].bin}/wx-config
        -DKICAD_REPO_NAME=brewed_product
        -DKICAD_SKIP_BOOST=ON
        -DBoost_USE_STATIC_LIBS=ON
      ]

      if build.with? "debug"
        args << "-DCMAKE_BUILD_TYPE=Debug"
        args << "-DwxWidgets_USE_DEBUG=ON"
      else
        args << "-DCMAKE_BUILD_TYPE=Release"
      end

      if build.with? "python-scripting"
        args << "-DPYTHON_SITE_PACKAGE_PATH=#{Formula["wxkython"].lib}/python2.7/site-packages"
        args << "-DKICAD_SCRIPTING=ON"
        args << "-DKICAD_SCRIPTING_MODULES=ON"
        args << "-DKICAD_SCRIPTING_WXPYTHON=ON"
        ENV["PYTHON_EX"] = which "python"
        args << "-DPYTHON_EXECUTABLE=#{ENV["PYTHON_EX"]}"
      else
        args << "-DKICAD_SCRIPTING=OFF"
        args << "-DKICAD_SCRIPTING_MODULES=OFF"
        args << "-DKICAD_SCRIPTING_WXPYTHON=OFF"
      end

      if build.with? "openmp"
        args << "-DCMAKE_C_COMPILER=#{HOMEBREW_PREFIX}/bin/clang-omp"
        args << "-DCMAKE_CXX_COMPILER=#{HOMEBREW_PREFIX}/bin/clang-omp++"
      else
        args << "-DCMAKE_C_COMPILER=#{ENV.cc}"
        args << "-DCMAKE_CXX_COMPILER=#{ENV.cxx}"
      end

      if build.with? "menu-icons"
        args << "-DUSE_IMAGES_IN_MENUS=ON"
      end

        system "cmake", "../", *(std_cmake_args + args)
        system "make"
        system "make install"
      end
    end

  def caveats
    <<-EOS.undent
    Kicad Extras can be found at http://downloads.kicad-pcb.org/osx/
    EOS
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
index 804cf83..5cef6e8 100644
--- a/template/kicad.pro
+++ b/template/kicad.pro
@@ -60,3 +60,15 @@ LibName26=opto
 LibName27=atmel
 LibName28=contrib
 LibName29=valves
+LibName30=w_analog
+LibName31=w_connectors
+LibName32=w_device
+LibName33=w_logic
+LibName34=w_memory
+LibName35=w_microcontrollers
+LibName36=w_opto
+LibName37=w_relay
+LibName38=w_rtx
+LibName39=w_transistor
+LibName40=w_vacuum
+LibName41=collieparts
diff --git a/template/kicad.kicad_pcb b/template/kicad.kicad_pcb
index e69de29..8ef89d4 100644
--- a/template/kicad.kicad_pcb
+++ b/template/kicad.kicad_pcb
@@ -0,0 +1,118 @@
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
+    (user_trace_width 0.2)
+    (user_trace_width 0.25)
+    (user_trace_width 0.3)
+    (user_trace_width 0.4)
+    (user_trace_width 0.5)
+    (user_trace_width 0.6)
+    (user_trace_width 0.8)
+    (user_trace_width 1)
+    (user_trace_width 1.2)
+    (user_trace_width 1.5)
+    (user_trace_width 2)
+    (trace_clearance 0.1524)
+    (zone_clearance 0.1524)
+    (zone_45_only yes)
+    (trace_min 0.1524)
+    (segment_width 0.127)
+    (edge_width 0.127)
+    (via_size 0.6096)
+    (via_drill 0.3302)
+    (via_min_size 0.6096)
+    (via_min_drill 0.3302)
+    (uvia_size 0.6096)
+    (uvia_drill 0.3302)
+    (uvias_allowed no)
+    (uvia_min_size 0.6096)
+    (uvia_min_drill 0.3302)
+    (pcb_text_width 0.127)
+    (pcb_text_size 0.6 0.6)
+    (mod_edge_width 0.127)
+    (mod_text_size 0.6 0.6)
+    (mod_text_width 0.127)
+    (pad_size 1.524 1.524)
+    (pad_drill 0.762)
+    (pad_to_mask_clearance 0.05)
+    (pad_to_paste_clearance -0.04)
+    (aux_axis_origin 0 0)
+    (visible_elements FFFFFF7F)
+    (pcbplotparams
+      (layerselection 0x3ffff_80000001)
+      (usegerberextensions true)
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
+  (net_class Default "This is the standaard class."
+    (clearance 0.1524)
+    (trace_width 0.1524)
+    (via_dia 0.6096)
+    (via_drill 0.3302)
+    (uvia_dia 0.6096)
+    (uvia_drill 0.3302)
+  )
+
+)
