require "formula"

class Kicad < Formula
  homepage "http://kicad-pcb.org"
  head "https://github.com/KiCad/kicad-source-mirror.git"

  depends_on "bazaar" => :build
  depends_on "cmake" => :build
  #depends_on "kicad-library" => :recommended
  depends_on "wxkicad"
  depends_on "wxkython"
  depends_on "boost" => ["c++11"]
  depends_on "libiomp" if build.with? "openmp"
  depends_on "clang-omp" => :build if build.with? "openmp"
  depends_on "openssl"

  option "with-menu-icons", "Build with icons in all the menubar menus."
 # option "without-webkit", "Turns off the integrated WebKit browser."
  option "with-openmp", "Enables multicore performance enhancements using OpenMP 4.0.  Highly experimental."

  if build.with? "openmp"
    patch :DATA
  end

  def install
    # Homebrew insists on chmoding _everything_ 0444, and install_name_tool will be unable to properly bundle them in the .app.
    # Without these two lines, you get the delightful behavior of the formula failing at the very last possible moment,
    # ensuring the maximum possible time will be wasted before the build failes and the output erased. ಠ_ಠ Homebrew.
    chmod_R(0744, Dir.glob("#{Formula["wxkython"].lib}/python2.7/site-packages/*"))
    chmod_R(0744, Dir.glob("#{Formula["wxkicad"].lib}/*"))

    mkdir "build" do
      ENV.prepend_create_path "PYTHONPATH", "#{Formula["wxkython"].lib}/python2.7/site-packages" # Need this to find wxpython.
      ENV['ARCHFLAGS'] = "-Wunused-command-line-argument-hard-error-in-future" # Need this for 10.7 and 10.8.
      ENV.libcxx
      ENV.append_to_cflags "-stdlib=libc++  -std=cxx11"  # We probably don't need all of these.
      ENV.append "CXXFLAGS", "-stdlib=libc++ -std=cxx11"
      ENV.append "LDFLAGS", "-stdlib=libc++  -std=cxx11" # But metacollin hasn't bothered to figure that out yet.

      args = %W[
        -DCMAKE_INSTALL_PREFIX=#{prefix}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}
        -DwxWidgets_CONFIG_EXECUTABLE=#{Formula["wxkicad"].bin}/wx-config
        -DPYTHON_EXECUTABLE=/usr/bin/python
        -DPYTHON_LIBRARY=/usr/lib/libpython.dylib
        -DPYTHON_SITE_PACKAGE_PATH=#{Formula["wxkython"].lib}/python2.7/site-packages
        -DKICAD_SCRIPTING=ON
        -DKICAD_SCRIPTING_MODULES=ON
        -DKICAD_SCRIPTING_WXPYTHON=ON
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_CXX_FLAGS=-stdlib=libc++
        -DCMAKE_C_FLAGS=-stdlib=libc++
        -DKICAD_REPO_NAME=brewed_product
        -DKICAD_SKIP_BOOST=ON
      ]

      if build.with? "openmp"
        args << "-DCMAKE_C_COMPILER=#{Formula["clang-omp"].libexec}/bin/clang"
        args << "-DCMAKE_CXX_COMPILER=#{Formula["clang-omp"].libexec}/bin/clang++"
      else
        args << "-DCMAKE_C_COMPILER=/usr/bin/clang"
        args << "-DCMAKE_CXX_COMPILER=/usr/bin/clang++"
      end

        system "cmake", "../", *args
        system "make", "-j6"
        system "make install"
      end
    end

  def caveats
    <<-EOS.undent
      There is a bug in wx that causes certain dropdown menus to have all their
      items unselectable.  Until it is fixed, you can use your keyboard's arrow
      keys after clicking the dropdown menu to select the option you want.

      Sorry :(.
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
 
