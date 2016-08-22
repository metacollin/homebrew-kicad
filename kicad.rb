class Kicad < Formula
  desc "Electronic Design Automation Suite"
  homepage "http://www.kicad-pcb.org"
  url "https://launchpad.net/kicad/4.0/4.0.3/+download/kicad-4.0.3.tar.xz"
  sha256 "7f45ac77ed14953d8f8a4413db7ff6c283d8175e9a16460b1579a6a8ff917547"
  head "https://git.launchpad.net/kicad", :using => :git

  option "without-menu-icons", "Build without icons menus."
  option "with-brewed-library", "Use homebrew to manage KiCad\"s library files."
  option "with-wx31", "Use wxWidgets 3.1.0.  Cannot enable python support with this option."

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
  depends_on "python" => :optional
  depends_on "swig" => :build if build.with? "python"
  depends_on "xz"
  depends_on "glm"

  fails_with :gcc
  fails_with :llvm
  odie "Options --with-wx31 and --with-python are mutually exclusive." if (build.with? "python" == true) && (build.with? "wx31" == true)

  # KiCad requires wx to have several bugs fixed to function, but the patches have yet to be included with a wx release
  # so KiCad, as part of its build system, builds its own wx binaries with these fixes included.  It uses a bash script
  # for this, so I have simply concatenated all the patches into one patch to make it fit better into homebrew.  These
  # Patches are the ones that come from the stable release archive of KiCad under the patches directory.

  resource "wx31patch" do
    url "https://gist.githubusercontent.com/metacollin/710d4cb34a549532cbd33c5ab668eecc/raw/e8ca8cb496d778cb356c83b659dc5736e302b964/wx31.patch"
    sha256 "bbe4a15ebbb4b5b58d3a01ae36902672fe6fe579302b2635e6cb395116f65e3b"
  end

  resource "wxpatch" do
    url "https://gist.githubusercontent.com/metacollin/2d5760743df73c939d53/raw/341390839ecd70aba743da64624c90c5d1afcff3/wxp.patch"
    sha256 "25f40ddc68a182e7dd9f795066910d57e0c53dd4096b85797fbf8e3489685a77"
  end

  resource "glpatch" do
    url "https://gist.githubusercontent.com/metacollin/cae8c54d100574f0482b5735561fc08f/raw/dd2bb54eb5e2c77871949e1dc3e25d1ab49afa8f/glpatch.patch"
    sha256 "24e86101a164633db8354a66be6ec76599750b5d49bd1d3b60fa04ec0d7e66bf"
  end

  if build.without? "wx31"
    resource "wxk" do
      url "https://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2"
      sha256 "d54129e5fbea4fb8091c87b2980760b72c22a386cb3b9dd2eebc928ef5e8df61"
    end
  else
    resource "wxk" do
      url "https://github.com/wxWidgets/wxWidgets/releases/download/v3.1.0/wxWidgets-3.1.0.tar.bz2"
      sha256 "e082460fb6bf14b7dd6e8ac142598d1d3d0b08a7b5ba402fdbf8711da7e66da8"
    end
  end

  if build.with? "brewed-library"
    resource "kicad-library" do
      url "https://github.com/KiCad/kicad-library.git"
    end
  end

  def install
    ENV["MAC_OS_X_VERSION_MIN_REQUIRED"] = MacOS.version.to_s
    ENV.append "ARCHFLAGS", "-Wunused-command-line-argument-hard-error-in-future"
    ENV.append "LDFLAGS", "-headerpad_max_install_names"
    if MacOS.version < :mavericks
      ENV.libstdcxx
    else
      ENV.libcxx
    end

    if build.with? "brewed-library"
      inreplace "common/common.cpp", "/Library/Application Support/kicad", "#{etc}/kicad"
      inreplace "common/common.cpp", "wxStandardPaths::Get().GetUserConfigDir()", "wxT( \"#{etc}/kicad\" )"
      inreplace "common/pgm_base.cpp", "DEFAULT_INSTALL_PATH", "\"#{etc}/kicad\""
    end

    resource("wxk").stage do
      if build.with? "wx31"
        Pathname.pwd.install resource "wx31patch"
        safe_system "/usr/bin/patch", "-g", "0", "-f", "-d", Pathname.pwd, "-p1", "-i", "wx31.patch"
      else
        Pathname.pwd.install resource("wxpatch")
        safe_system "/usr/bin/patch", "-g", "0", "-f", "-d", Pathname.pwd, "-p0", "-i", "wxp.patch"
        Pathname.pwd.install resource("glpatch")
        safe_system "/usr/bin/patch", "-g", "0", "-f", "-d", Pathname.pwd, "-p0", "-i", "glpatch.patch"
      end

      mkdir "wx-build" do
        args = %W[
          --prefix=#{buildpath}/wxk
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
          --enable-universal_binary=i386,x86_64
          CC=#{ENV.cc}
          CXX=#{ENV.cxx}
        ]

        system "../configure", *args
        system "make", "-j8"
        system "make", "install"
      end

      if build.with? "python"
        cd "wxPython" do
          args = [
            "WXPORT=osx_cocoa",
            "WX_CONFIG=#{buildpath}/wxk/bin/wx-config",
            "UNICODE=1",
            "BUILD_BASE=#{buildpath}/wx-build",
          ]

          system "python", "setup.py", "build_ext", *args
          system "python", "setup.py", "install", "--prefix=#{buildpath}/py", *args
        end
      end
    end

    mkdir "build" do
      ENV.prepend_create_path "PYTHONPATH", "#{buildpath}/py/lib/python2.7/site-packages" if build.with? "python" == true

      args = %W[
        -DCMAKE_INSTALL_PREFIX=#{prefix}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}
        -DwxWidgets_CONFIG_EXECUTABLE=#{buildpath}/wxk/bin/wx-config
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

      if build.with? "python"
        args << "-DPYTHON_SITE_PACKAGE_PATH=#{buildpath}/py/lib/python2.7/site-packages"
        args << "-DKICAD_SCRIPTING=ON"
        args << "-DKICAD_SCRIPTING_MODULES=ON"
        args << "-DKICAD_SCRIPTING_WXPYTHON=ON"
        python_executable = `which python`.strip
        args << "-DPYTHON_EXECUTABLE=#{python_executable}"
      else
        args << "-DKICAD_SCRIPTING=OFF"
        args << "-DKICAD_SCRIPTING_MODULES=OFF"
        args << "-DKICAD_SCRIPTING_WXPYTHON=OFF"
      end
      args << "-DCMAKE_C_COMPILER=#{ENV.cc}"
      args << "-DCMAKE_CXX_COMPILER=#{ENV.cxx}"

      args << "-DUSE_IMAGES_IN_MENUS=ON" if build.with? "menu-icons" == true

      system "cmake", "../", *(std_cmake_args + args)
      system "make", "-j#{ENV.make_jobs}"
      system "make", "install"
    end
  end

  def post_install
    if build.with? "brewed-library"
      kicaddir.mkpath
      resource("kicad-library").stage do
        cp_r Dir["*"], kicaddir
      end
    end
  end

  def kicaddir
    etc / "kicad"
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