require "formula"

class Kicad < Formula
  homepage "http://kicad-pcb.org"
  head "https://code.launchpad.net/~kicad-product-committers/kicad/product", :using => :bzr

  depends_on "bzr" => :build
  depends_on "cmake" => :build
  depends_on "cairo"
  depends_on "swig" 
  depends_on "pkg-config"
  depends_on "libpng"
  depends_on "pcre"
  depends_on "glew"
  depends_on "kicad-library" => :recommended
  depends_on "wxkicad" 


  def install
      mkdir "build" do
          ENV["CMAKE_C_COMPILER"] = "/usr/bin/clang"
          ENV["CMAKE_CXX_COMPILER"] = "/usr/bin/clang++"

          args = %W[
            -DCMAKE_INSTALL_PREFIX=#{prefix}
            -DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}
            -DwxWidgets_CONFIG_EXECUTABLE=#{HOMEBREW_PREFIX}/opt/wxkicad/bin/wx-config
            -DPYTHON_EXECUTABLE=/usr/bin/python
            -DPYTHON_LIBRARY=/usr/lib/libpython.dylib
            -DPYTHON_SITE_PACKAGE_PATH=#{HOMEBREW_PREFIX}/opt/wxkicad/lib/python2.7/site-packages
            -DKICAD_SCRIPTING=ON
            -DKICAD_SCRIPTING_MODULES=ON
            -DKICAD_SCRIPTING_WXPYTHON=ON
            -DCMAKE_BUILD_TYPE=Release
        ]



          system "cmake", "../", *args
          system "make -j8"
          system "make install"
        end
      end
    end
