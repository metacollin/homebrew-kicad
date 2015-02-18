require "formula"

class Kicad < Formula
  homepage "http://kicad-pcb.org"
  head "https://github.com/KiCad/kicad-source-mirror.git", :using => :git

  depends_on "bzr" => :build
  depends_on "cmake" => :build
  depends_on "kicad-library" => :recommended
  depends_on "wxkicad" 
  depends_on "swig" => :build
  depends_on "pcre" => :build
  
  option "with-menu-icons", "Build with icons in all the menubar menus." 
  option "without-webkit", "Turns off the integrated WebKit browser."

  #See comment at the bottom of the file for description of what this patch is for.
  patch :p0 do
    url "https://gist.githubusercontent.com/metacollin/97b547034d144f483c0f/raw/8af3be1224f100241e94d7ea3fd819d874885025/boost_new.patch"
    sha1 "a42531189e36e45893c854d83fce602050fdc193"
  end

  resource "boost" do
    url "http://ufpr.dl.sourceforge.net/project/boost/boost/1.57.0/boost_1_57_0.tar.bz2", :using => :nounzip
    sha1 "e151557ae47afd1b43dc3fac46f8b04a8fe51c12"
  end

  def install
    resource("boost").stage { (buildpath/".downloads-by-cmake").install Dir["*"] }
    chmod_R(0744, Dir.glob("#{Formula["wxkicad"].lib}/*")) # A bit hacky, but a little bit of hacky in your code makes it taste better.

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
        -DKICAD_REPO_NAME=brewed_product
      ]
        
        if build.with? "menu-icons"
          args << "-DUSE_IMAGES_IN_MENUS=ON"
        end

        if build.with? "webkit"
          args << "-DKICAD_USE_WEBKIT=ON"
        end

          system "cmake", "../", *args
          system "make", "-j6"
          system "make install"
        end
      end
  def caveats
    if build.with? "webkit" then <<-EOS.undent 
        With WebKit enabled, you are building a web viewer inside Kicad.
        
        Kicad developers cannot be sure the Web access does no open a security issue,
        when running a Web Viewer inside Kicad. The probability is low, but not zero.

        If you would like to turn this feature off, build with the "-without-webkit"
        flag set.
      EOS
    end

    <<-EOS.undent
      There is a bug in wx that causes certain dropdown menus to have all their 
      items unselectable.  Until it is fixed, you can use your keyboard's arrow 
      keys after clicking the dropdown menu to select the option you want.

      A workaround for the frustration this bug may cause is performing a 
      google image search for munchkin kittens.
    EOS
  end
end
  # ******************* PATCH DESCRIPTION *******************************************************************************************    
  # In the development of KiCad, the developers have discovered and fixed bugs in both wx and boost.  Boost 1.57 includes all but one 
  # of their fixes, and the cold reality of the matter is without this fix in place in boost, KiCad's push and shove auto router
  # will crash almost instantly. So KiCad patches boost.  It might be specific to clang, or be common to gcc as well, but the fix is 
  # simply commenting out two lines where a variable that is never used is set equal to a used pointer.  The lines serve no purpose
  # and cause -Wunused-variable warnings, but, serving no purpose, being present or not shouldn't matter.  But if present, we get 
  # consistant crashes.  This almost certainly means the actual mechanism lies in one of the compiler optimization techniqeus that os 
  # turned on.
  # 
  # This patch also forces the use of Boost 1.57, while the untouched repository uses Boost 1.54.  Boost 1.54 is known to work and 
  # and there is no reason to move to 1.57, as it would still need to be patched.  Unfortunately, Boost 1.54 is incompatible with 
  # Yosemite, so OS X specifically needs to use a newer version.  This is untested and highly experimental, but anyone using
  # this tap will be helping test if KiCad has any other unknown bugs with 1.57.  Thinking 1.57 works ok is a dangerous assumption.
  # But there is no choice.  So I guess we just test the crap out of it until it's not an assumption anymore :). 
  #*********************************************************************************************************************************