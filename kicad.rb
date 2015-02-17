require "formula"

class Kicad < Formula
  homepage "http://kicad-pcb.org"
  head "https://code.launchpad.net/~kicad-product-committers/kicad/product", :using => :bzr

  depends_on "bzr" => :build
  depends_on "cmake" => :build
  depends_on "kicad-library" => :recommended
  depends_on "wxkicad" 
  depends_on "swig" => :build
  depends_on "pcre" => :build
  
  option "with-menu-icons", "Build with icons in all the menubar menus.  Recommended."

  patch :p0 do
    url "https://gist.githubusercontent.com/metacollin/97b547034d144f483c0f/raw/8d7f4fc2b119b126bb76322e5c1461f61bf37ef7/boost.patch"
    sha1 "e3a5b58219123e69a569f4b68fa5ee1acf356b00"
  end


  def install
      mkdir "build" do
        ENV.prepend_create_path "PYTHONPATH", "#{Formula["wxkicad"].lib}/python2.7/site-packages"
        ENV['ARCHFLAGS'] = "-Wunused-command-line-argument-hard-error-in-future"
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
            -DJUCAD_REPO_NAME="brewed product + metacollin patches"
        ]
        
        if build.with? "menu-bar-icons"
          args << "-DUSE_IMAGES_IN_MENUS=ON"
        end

          system "cmake", "../", *args
          system "make", "-j8"
          system "make install"
        end
      end
    end
