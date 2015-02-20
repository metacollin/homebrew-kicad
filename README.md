# Homebrew-KiCad 

**EPIC FAIL UPDATE:** Please `brew remove wxkicad` if installed.  Then `untap metacollin/kicad` and retap with `tap metacollin/kicad`.  Finally, `brew install kicad --HEAD`.  It works on a clean install of 10.8.  For real.  I believe it works on 10.10 as well, but that is still being confirmed. I feel I owe everyone an explanation/apology, and I've put that at the bottom so as not to obstruct the actual documentation.

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

## It's good to have options
There are a few options available to further customize your build.  

```sh
--without-webkit
```
This will disable the integrated webkit browser for users who want to eliminate any security risks, however small, that including a web browser within kicad might pose.
```sh
--with-menu-icons
```
This will add icons to the menu bar items.  It's turned off by default because that is not seen very often on OS X and might be too out of place for many users.  Personally, I like them.  The difference is purely cosmetic, so use this according to personal preference.  

## Notes on upgrading
KiCad is a very active project, with revisions coming out frequently (sometimes with less than 24 hours in between).  Homebrew will not detect this and it does not handle upgrading --HEAD only formulae.  If you want to stay on the bleeding edge, you can manually force an upgrade at any time using:
```sh
brew reinstall kicad --HEAD --without-kicad-library #the second flag is not necessary, but saves some build time
```


###Notes on the library
You do not have to use a version of KiCad built with this tap with the library in this tap.  You can use a binary from elsehwere and it will find and use the library installed with this formula.

If kicad library fails to install, you probably, at some point, manually put some files in `~/Library/Application Support/kicad`. Please move (or simply rename) the directory if you wish to use homebrew to install a fresh version.  Homebrew, by design, cannot overwrite files so you must manually move any conflicting files out of the way.



## Whoops... :(
My laptop, which I had been using to test earlier OS X versions with (using a virtual machine on my desktop proved simply too slow, it took much too long to test if building worked after a change). I was using the install of 10.8 I'd had on my laptop for regular use, but I had forgotten about some of the modifications I had made to OS X on that machine.  I rediscovered these after much head-scratching and frustration. Ironically, these changes PREVENTED the numerous issues everyone else has been having from happening on that machine. Noteably, I had removed gcc and llvm-gcc entirely. After the wipe and clean install, I ran into all the same issues that everyone had been posting, and slowly fixed them one by one, until finally, it worked.  

Ultimately, a bad bit of judgement on my part made me believe (and describe) something I believed to work when it in fact worked for me and only me, because I didn't use a clean dev environment.  So that mistake is directly responsible for the hours a lot of users have wasted trying to get this to work.  I am sincerely sorry to everyone who tried to build this over the past few days. :(
