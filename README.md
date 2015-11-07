# Homebrew KiCad EDA Suite 
_Now stable!_

Delicious and foamy ~~--HEAD  only~~ stable [Homebrew](https://github.com/mxcl/homebrew) tap for [KiCad](http://www.kicad-pcb.org) and it's library.  This is intended for anyone who wants to customize their build of KiCad, build latest stable release optimized for their specific version of OS X and using the latest version of boost and other dependencies.  

## Installation is simple...
```sh
brew tap metacollin/kicad
brew install kicad
```

## ...but it's good to have options.
Customizations:

```sh
--without-menu-icons # Turn off menubar and contextual menu icons
--without-default-paths # Use /usr/local for support files
--without-python # Turn off python scripting
--HEAD # Builds the latest development version of KiCad.
--debug # Build with debugging turned on
```

###Notes on the library
By default, this formula doesn't handle the KiCad Library files.  However, you can tell the formula to download and install the latest KiCad support files for you by using the `--without-default-paths` option.  This will "brew-ify" KiCad by changing its search paths to

`$(brew --preix)/etc/kicad`

for both library files and user preferences and, if necessary, installing files.  Existing files will not be overwritten.  

The exact paths will be confirmed and displayed at the end of the build as well.  

Pcbnew will prompt you to download the 3D models and footprints on first run, so using `--without-default-paths` is the most painless automated way to use this tap, but it is not default as it will not find files from existing installs (via homebrew or elsewhere).

If you want to install the support files in the default locations, please download the latest [OS X Nightlies](http://downloads.kicad-pcb.org/osx/) 
of KiCad and KiCad Extras, and drag the kicad and modules folders as instructed in the disk images. 

Note: wxkicad is deprecated and should be removed if you have it.  It remains in the tap as it is used as a dependency by Shane Burrell's tap of [homebrew-kicadlibrarian](https://github.com/shaneburrell/homebrew-kicadlibrarian).  It's an OS X port of  [KiCad Libriarian](http://www.compuphase.com/electronics/kicadlibrarian_en.htm), a separate tool for managing footprint libraries.  