# Homebrew KiCad EDA Suite 
_Now building 4.0.2 stable!_

Delicious and foamy ~~--HEAD  only~~ stable [Homebrew](https://github.com/mxcl/homebrew) tap for [KiCad](http://www.kicad-pcb.org) and it's library.  This is intended for anyone who wants to customize their build of KiCad, build latest stable release optimized for their specific version of OS X and using the latest version of boost and other dependencies.  

This tap also includes some OSX specific tweaks that presently are not part of the official stable and nightly builds (for now):

-  wxWidgets is patched so that 
â
Œ
˜-C correctly copies text instead of closing the current window.

### Installation is simple...
```sh
brew tap metacollin/kicad
brew install kicad
```

### ...but it's good to have options.
```sh
--without-menu-icons # Turn off menubar and contextual menu icons
--with-brewed-library # Use /usr/local for support files
--with-python # Turn on python scripting
--with-wx31 # Will build and link wxWidgets 3.1.0 instead of 3.0.2.
--HEAD # Builds the latest development version of KiCad.
--debug # Build with debugging turned on
```

Note: The `--with-python` and `--with-wx31` options are mutually exclusive for now.  This will likely change in the future.


### Notes on the library
By default, this formula doesn't handle the KiCad Library files.  However, you can tell the formula to download and install the latest KiCad support files for you by using the `--with-brewed-library` option.  This will "brew-ify" KiCad by changing its search paths to

`$(brew --preix)/etc/kicad`

for both library files and user preferences and, if necessary, installing files.  Existing files will not be overwritten.  

You can download the kicad support files from the [official OS X Nightlies](http://downloads.kicad-pcb.org/osx/).  Support files can be found on both KiCad and KiCad Extras .dmgs.

Note: wxkicad is no longer used, but remains in the tap as it is used as a dependency by Shane Burrell's tap of [homebrew-kicadlibrarian](https://github.com/shaneburrell/homebrew-kicadlibrarian).  It's an OS X port of  [KiCad Libriarian](http://www.compuphase.com/electronics/kicadlibrarian_en.htm), a separate tool for managing footprint libraries (one that I use and recommend!).

