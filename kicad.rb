require "formula"

class Kicad < Formula
  homepage "http://kicad-pcb.org"
  head "https://code.launchpad.net/~kicad-product-committers/kicad/product", :using => :bzr

  #`env :std
  
  depends_on "bzr" => :build
  depends_on "cmake" => :build
  depends_on "kicad-library" => :recommended
  depends_on "wxkicad" 
  #epends_on "wxkpython"
  depends_on "swig" => :build
  depends_on "pcre" => :build

  patch :p0 do
    url "https://gist.githubusercontent.com/metacollin/97b547034d144f483c0f/raw/8d7f4fc2b119b126bb76322e5c1461f61bf37ef7/boost.patch"
    sha1 "e3a5b58219123e69a569f4b68fa5ee1acf356b00"
  end


  def install
      mkdir "build" do
          #ENV["CMAKE_C_COMPILER"] = "/usr/bin/clang"
          #ENV["CMAKE_CXX_COMPILER"] = "/usr/bin/clang++"
         # ENV.append "CPPFLAGS", "-I/usr/local/opt/wxkicad/include"
         # ENV.append "LDFLAGS", " -L/usr/local/opt/wxkicad/lib"
         #ENV.delete "CPPFLAGS"
         #ENV.delete "LDFLAGS"
        # ENV.delete "CMAKE_PREFIX_PATH"
        # ENV.delete "ALOCAL_PATH"
        ENV.prepend_create_path "PYTHONPATH", "#{Formula["wxkicad"].lib}/python2.7/site-packages"
        ENV.libcxx
        
          args = %W[
            -DCMAKE_C_COMPILER=/usr/bin/clang
            -DCMAKE_CXX_COMPILER=/usr/bin/clang++
            -DCMAKE_INSTALL_PREFIX=#{prefix}
            -DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}
            -DwxWidgets_CONFIG_EXECUTABLE=#{Formula["wxkicad"].bin}/wx-config
            -DPYTHON_EXECUTABLE=/usr/bin/python
            -DPYTHON_LIBRARY=/usr/lib/libpython.dylib
            -DPYTHON_SITE_PACKAGE_PATH=#{Formula["wxkicad"].lib}/python2.7/site-packages
            -DKICAD_SCRIPTING=ON
            -DKICAD_SCRIPTING_MODULES=ON
            -DKICAD_SCRIPTING_WXPYTHON=ON
            -DCMAKE_BUILD_TYPE=Release
            -DCMAKE_CXX_FLAGS=-stdlib=libc++
            -DCMAKE_C_FLAGS=-stdlib=libc++
        ]

          system "cmake", "../", *args
          system "make", "-j8"
          system "make install"
        end
      end
    end
