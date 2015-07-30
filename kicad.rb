class Kicad < Formula
  desc "Electronic Design CAD Suite"
  homepage "http://wwwkicad-pcb.org"
  head "https://github.com/KiCad/kicad-source-mirror.git"

  depends_on "bazaar" => :build
  depends_on "cmake" => :build
  depends_on "wxkicad"
  depends_on "wxkython" if build.with? "python-scripting"
  depends_on :python if build.with? "python-scripting"
  depends_on "boost"
  depends_on "libiomp" if build.with? "openmp"
  depends_on "clang-omp" => :build if build.with? "openmp"
  depends_on "openssl"

  option "with-menu-icons", "Build with icons in all the menubar menus."
  option "with-openmp", "Enables multicore performance enhancements using OpenMP 4.0.  Highly experimental."
  option "without-python-scripting", "Disables python scripting and python scripting modules for KiCad."

  fails_with :gcc
  fails_with :llvm

  if build.with? "openmp"
    patch :DATA
  end

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
        -DCMAKE_BUILD_TYPE=Release
        -DKICAD_REPO_NAME=brewed_product
        -DKICAD_SKIP_BOOST=ON
        -DBoost_USE_STATIC_LIBS=ON
      ]

      if build.with? "python-scripting"
        args << "-DPYTHON_SITE_PACKAGE_PATH=#{Formula["wxkython"].lib}/python2.7/site-packages"
        args << "-DKICAD_SCRIPTING=ON"
        args << "-DKICAD_SCRIPTING_MODULES=ON"
        args << "-DKICAD_SCRIPTING_WXPYTHON=ON"
      else
        args << "-DKICAD_SCRIPTING=OFF"
        args << "-DKICAD_SCRIPTING_MODULES=OFF"
        args << "-DKICAD_SCRIPTING_WXPYTHON="
      end

      if build.with? "openmp"
        args << "-DCMAKE_C_COMPILER=#{Formula["clang-omp"].libexec}/bin/clang"
        args << "-DCMAKE_CXX_COMPILER=#{Formula["clang-omp"].libexec}/bin/clang++"
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
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 154aaae..1e7dd07 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -179,6 +179,15 @@ if( CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang" )
         endif()
     endif()
 
+   if( APPLE )
+ set(OPENMP_FOUND ON)
+ set(OpenMP_C_FLAGS "-fopenmp" CACHE STRING "C compiler flags for OpenMP parallization" FORCE)
+ set(OpenMP_CXX_FLAGS "-fopenmp" CACHE STRING "C++ compiler flags for OpenMP parallization" FORCE)
+ include_directories(/usr/local/opt/libiomp/include/libiomp)
+ link_directories(/usr/local/opt/libiomp/lib)
+ execute_process(COMMAND ditto /usr/local/opt/libiomp/lib/libiomp5.dylib ${CMAKE_BINARY_DIR}/bin/libiomp5.dylib)
+    endif()
+
     if( MINGW )
         set( CMAKE_EXE_LINKER_FLAGS_RELEASE "-s" )
