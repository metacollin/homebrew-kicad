# Homebrew-KiCad 

Delicious and foamy --HEAD only [Homebrew](https://github.com/mxcl/homebrew) tap for [KiCad](http://www.kicad-pcb.org) and it's library.  This is intended to make it easy for OS X developers and users to build KiCad more conveniently and test or customize builds in ways outside the scope of the official nightly builds. 
In other words, here be dragons.

**Regular Users should look here:** Download the [official OS X nightly builds](http://downloads.kicad-pcb.org/osx/) provided by Adam Wolf (thank you!). 

Also, check out Shane Burrell's tap of [homebrew-kicadlibrarian](https://github.com/shaneburrell/homebrew-kicadlibrarian).  It's an OS X port of  [KiCad Libriarian](http://www.compuphase.com/electronics/kicadlibrarian_en.htm), a separate tool for managing footprint libraries.  

## Installation

Installation is simple and much like any other tap, but please read the next section carefully first.  There are certain options you may wish to enable or disable.  Once you're sure, go head and:
```sh
brew tap metacollin/kicad
brew install kicad --HEAD
```

## It's good to have options
There are a few options available to further customize your build.  

```sh
--with-menu-icons
```
This will add icons to the menu bar items.

```sh
--with-openmp
```
Using this flag will enable KiCad's OpenMP performance enhancements and bundle Intel's OpenMP 4.0 runtime library within the Kicad .app bundle.  This is highly experimental, but so far has not caused me a single issue.  

OpenMP is an opensource multicore/multiprocessing library for speeding up CPU intensive tasks by better utalizing multiple processor cores.  The bad news is as of this writing (April 2015), neither Apple's clang nor the latest official release have OpenMP support.

The good news is there is the [OpenMP®/Clang](https://clang-omp.github.io) project! And it's now part of the official homebrew repository.  

This otherwise heavy-weight dependency, being part of the main homebrew repository, will make use of bottles.  I hope this will aid users and developers in testing and developing OpenMP enhancements to KiCad on OS X as clang gets closer to incorporating full OpenMP support in an official release. 

## Notes on upgrading
KiCad is a very active project, with revisions coming out frequently (sometimes with less than 24 hours in between).  Homebrew will not detect this and it does not handle upgrading --HEAD only formulae.  If you want to stay on the bleeding edge, you can manually force an upgrade at any time using:
```sh
brew reinstall kicad --HEAD
```


###Notes on the library
Library management is no longer supported with this tap.  Please see Adam Wolf's [OS X Nightlies](http://downloads.kicad-pcb.org/osx/) and download the latest kicad-extras.dmg and follow the included instructions to install the Kicad Library.  You should only need to do this once, not every time you update to new build of KiCad.  
