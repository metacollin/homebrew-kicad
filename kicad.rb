require "formula"

class Kicad < Formula
  homepage "http://kicad-pcb.org"
  url "https://github.com/KiCad/kicad-source-mirror.git", :using => :git 
  head "https://github.com/KiCad/kicad-source-mirror.git"

  depends_on "bzr" => :build
  depends_on "cmake" => :build
  depends_on "kicad-library" => :recommended
  depends_on "wxkicad" 
  depends_on "wxkython"
  depends_on "boost" => ["c++11"]
  
  # I'm not sure I really believe (my own) hypothesis that this is a minkowski patch, there are
  # Other differences and it may just come down to build flags.  The default ones for homebrew cause the
  # crash however.  To observe this behavior, rebuild kicad with the --without-kicad-boost flag
  # then open pcbnew and go nuts placing tracks with autoroute mode selected. Boost's coroutine will crash hard. 

  option "with-menu-icons", "Build with icons in all the menubar menus." 
  option "without-webkit", "Turns off the integrated WebKit browser."

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
      ENV.append_to_cflags "-stdlib=libc++"  # We probably don't need all of these. 
      ENV.append "LDFLAGS", "-stdlib=libc++" # But metacollin hasn't bothered to figure that out yet.

      args = %W[
        -DCMAKE_C_COMPILER=/usr/bin/clang
        -DCMAKE_CXX_COMPILER=/usr/bin/clang++
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

      if build.with? "kicadboost"
        args << "-DBOOST_ROOT=#{Formula["kicadboost"]}"
        args << "-DBOOST_INCLUDEDIR=#{Formula["kicadboost"]}/include"
        args << "-DBOOST_LIBRARYDIR=#{Formula["kicadboost"].lib}"
        args << "-DBoost_NO_SYSTEM_PATHS=ON"
      end

      # Boost is linked to kicadboost or boost depending on the build options.  All cmake boost buildery 
      # has been circumvented, this formula will hopefully not be effected if the product branch guts 
      # that part from the build procedure.  
        
      if build.with? "menu-icons"
        args << "-DUSE_IMAGES_IN_MENUS=ON"
      end

      unless build.without? "webkit"
        args << "-DKICAD_USE_WEBKIT=ON"
      end

        system "cmake", "../", *args
        system "make", "-j6"
        system "make install"
      end
    end

  def caveats
    unless build.without? "webkit" then <<-EOS.undent 
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