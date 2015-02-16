# Homebrew-KiCad 

Delicious and foamy --HEAD only [Homebrew](https://github.com/mxcl/homebrew) tap for [KiCad](http://www.kicad-pcb.org) and it's library.  This is intended to make it easy for OS X users to try out the latest revision of the development branch, or to help handle installation of the model, footprint, and component libraries.  

## Installation

Installation is simple and much like any other tap, but please read the next section carefully first.  There are certain options you may wish to enable or disable.  Once you're sure, go head and:
```sh
brew tap metacollin/kicad
brew install kicad --HEAD
```

## Read this before installing!
The `kicad` formula will automatically download the latest KiCad Library files and they will reside in your Cellar like any other homebrew formula, but presently, they will be naughtily symlinked into `~/Library/Application Support/kicad` and the library table into `~/Library/Preferences/kicad folder`.  

If you already have a library table there from another build of KiCad, it will be renamed to `fp-lib-table_old<random hex string>` and moved asside. If this behavior is unacceptable, before installing kicad, run:

```sh
brew install kicad-library --without-tables #do not symlink any table file into your kicad preferences
```
and your tables will not be touched.  

If you don't care, the default behavior is to populate Your library tables with all the .pretty repos from github, and then use the github library plugin so that they will continually be updated from within KiCad itself.  If you would rather use local .pretty tables without github functionallity, run:

```sh
brew install kicad-library --with-local-tables #use local .pretty libraries
```

Finally, if you prefer to manage the library manually and don't want anything touched and no naughty symlinking of stuff outside `/usr/local`, this is all limited to the kicad-library fomula and it is an optional dependency.  Install kicad with:

```sh
brew install kicad --without-kicad-library #If you plan on managing the library manually
```

and no non-standard behavior will be done.  

Once it's installed, if you want the suite of .apps symlinked into your /Applications folder, you need to run: 
```sh
brew linkapps kicad  #link .app bundles into /Applications
```

You're all set!

## Notes on upgrading
KiCad is a very active project, with revisions coming out frequently (sometimes with less than 24 hours in between).  Homebrew will not detect this and it does not handle upgrading --HEAD only formulae.  If you want to stay on the bleeding edge, you can manually force an upgrade at any time using:
```sh
brew reinstall kicad --HEAD --without-kicad-library #the second flag is not necessary, but saves some build time
```


###Notes on the library
You do not have to use a version of KiCad built with this tap with the library in this tap.  You can use a binary from elsehwere and it will find and use the library installed with this formula.

If kicad library fails to install, you probably, at some point, manually put some files in `~/Library/Application Support/kicad`. Please move (or simply rename) the directory if you wish to use homebrew to install a fresh version.  Homebrew, by design, cannot overwrite files so you must manually move any conflicting files out of the way.



## Conlusion
This build...is not short. You may see no activity for long stretches of time, this is normal and its just a very heavyweight build. This will use 100% CPU even on 8+ core systems along with lots of disk I/O.  45 minutes is not an uncommon build time, not including dependencies. 

Anyway, have fun and I hope you enjoy using KiCad! :)
