require "formula"

class Kicad < Formula
  homepage "http://kicad-pcb.org"
  head "https://code.launchpad.net/~kicad-product-committers/kicad/product", :using => :bzr

  resource 'wxPython' do
    url "http://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2"
    sha1 "5053f3fa04f4eb3a9d4bfd762d963deb7fa46866"
  end

  depends_on "bzr" => :build
  depends_on "cmake" => :build
  depends_on "cairo"
  depends_on "swig" 
  depends_on "pkg-config"
  depends_on "libpng"
  depends_on "pcre"
  depends_on "glew"
  depends_on "kicad-library" => :recommended

 # option 'without-library', 'Do not download the KiCad 3D models, templates, and library files. Handy if you are upgrading or already installed this earlier.'
  #option 'with-github-tables', 'Populates the library tables with github entries.  This will move aside any current tables.'
 # option 'with-local-tables', 'Populates the library tables with locally stored .pretty files. This will move aside any current tables.'
 # option 'without-kicad' , 'Do not build or install kicad, but only the library and, if selected, the library tables.'


patch :p0 do 
  url "https://gist.githubusercontent.com/metacollin/97b547034d144f483c0f/raw/8d7f4fc2b119b126bb76322e5c1461f61bf37ef7/boost.patch"
  sha1 "e3a5b58219123e69a569f4b68fa5ee1acf356b00"
end

  def install
      resource("wxPython").stage do
        (buildpath/"wx").install Dir["*"]
        cd buildpath/"wx" do
          system "patch", "-p0", "-i#{buildpath}/patches/wxwidgets-3.0.0_macosx.patch"
          system "patch", "-p0", "-i#{buildpath}/patches/wxwidgets-3.0.0_macosx_bug_15908.patch"
          system "patch", "-p0", "-i#{buildpath}/patches/wxwidgets-3.0.0_macosx_soname.patch"
          system "curl https://gist.githubusercontent.com/metacollin/c138f049e41d9cc42ef9/raw/0174436d883d5eebdbad18a8d98e8d318df59725/patch | patch -p0"

          ENV['CC'] = "/usr/bin/clang"
          ENV['CXX'] = "/usr/bin/clang++"
          unless MacOS.version < :mavericks
              ENV.append "CXXFLAGS", "-stdlib=libc++"
              ENV.append "ARCHFLAGS", "-Wno-error=unused-command-line-argument-hard-error-in-future"
          else
              ENV.append "CXXFLAGS", "-stdlib=libstdc++"
          end
          
          args = %W[
            --prefix=#{buildpath}/wx-bin
            --with-opengl
            --enable-aui
            --enable-utf8
            --enable-html
            --enable-stl
            --with-libjpeg=builtin
            --with-libpng=builtin
            --with-regex=builtin
            --with-libtiff=builtin
            --with-zlib=builtin
            --with-expat=builtin
            --without-liblzma
            --with-macosx-version-min=#{MacOS.version}
            --enable-universal-binary=i386,x86_64
            ]
          system "mkdir", "wx-build"
          cd "wx-build" do
          system "#{buildpath}/wx/configure", *args
          system "make", "-j8"
          system "make", "install"
        end
          #system "sleep 1000"
          cd "wxPython" do
            ENV['CC'] = "/usr/bin/clang"
            ENV['CXX'] = "/usr/bin/clang++"
            unless MacOS.version < :mavericks
              ENV.append "CXXFLAGS", "-stdlib=libc++"
              ENV.append "ARCHFLAGS", "-Wno-error=unused-command-line-argument-hard-error-in-future"
            else
              ENV.append "CXXFLAGS", "-stdlib=libstdc++"
            end

            system "/usr/bin/python", "setup.py", "build_ext", "WX_CONFIG=#{buildpath}/wx-bin/bin/wx-config", "UNICODE=1", "WXPORT=osx_cocoa", "BUILD_BASE=#{buildpath}/wx/wx-build"
            system "/usr/bin/python", "setup.py", "install", "--prefix=#{buildpath}/wx-bin", "WX_CONFIG=#{buildpath}/wx-bin/bin/wx-config", "UNICODE=1", "WXPORT=osx_cocoa", "BUILD_BASE=#{buildpath}/wx/wx-build"
          end
        end
      end

      mkdir "build" do
          ENV["CMAKE_C_COMPILER"] = "/usr/bin/clang"
          ENV["CMAKE_CXX_COMPILER"] = "/usr/bin/clang++"

          args = %W[
            -DCMAKE_INSTALL_PREFIX=#{prefix}
            -DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}
            -DwxWidgets_CONFIG_EXECUTABLE=#{buildpath}/wx-bin/bin/wx-config
            -DPYTHON_EXECUTABLE=/usr/bin/python
            -DPYTHON_LIBRARY=/usr/lib/libpython.dylib
            -DPYTHON_SITE_PACKAGE_PATH=#{buildpath}/wx-bin/lib/python2.7/site-packages
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
