# Documentation: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Formula-Cookbook.md
#                /usr/local/Library/Contributions/example-formula.rb
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Kicadboost < Formula
  url "http://ufpr.dl.sourceforge.net/project/boost/boost/1.57.0/boost_1_57_0.tar.bz2"
  sha1 "e151557ae47afd1b43dc3fac46f8b04a8fe51c12"

  keg_only "This is a temporary bandaid package for kicad and will hopefully only be needed briefly."

  #patch :p0, :DATA


  def install
      open("user-config.jam", "a") do |file|
      file.write "using darwin : : #{ENV.cxx} ;\n"
    end
    bootstrap_args = ["--prefix=#{prefix}", "--libdir=#{lib}"]
    without_libraries = ["python", "mpi"]
    bootstrap_args << "--without-libraries=#{without_libraries.join(",")}"

    args = ["--prefix=#{prefix}",
            "--libdir=#{lib}",
            "-d2",
            "-j#{ENV.make_jobs}",
            "--layout=tagged",
            "--user-config=user-config.jam",
            "install"]
          ]

    args << "threading=multi,single"
    args << "link=shared,static"
    args << "cxxflags=-std=c++11"
    args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++"

    system "./bootstrap.sh", *bootstrap_args
    system "./b2", *args
  end
end
__END__
--- boost/polygon/detail/minkowski.hpp  2013-05-31 02:24:16 +0000
+++ boost/polygon/detail/minkowski.hpp  2013-05-31 02:26:26 +0000
@@ -30,13 +30,13 @@
   static void convolve_two_point_sequences(polygon_set& result, itrT1 ab, itrT1 ae, itrT2 bb, itrT2 be) {
     if(ab == ae || bb == be)
       return;
-    point first_a = *ab;
+    // point first_a = *ab;
     point prev_a = *ab;
     std::vector<point> vec;
     polygon poly;
     ++ab;
     for( ; ab != ae; ++ab) {
-      point first_b = *bb;
+      // point first_b = *bb;
       point prev_b = *bb;
       itrT2 tmpb = bb;
       ++tmpb;
