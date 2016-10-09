# Homebrew KiCad EDA Suite 
_Now building 4.0.4 stable!_

Delicious and foamy stable (and `--HEAD`!) [Homebrew](https://github.com/mxcl/homebrew) tap for [KiCad](http://www.kicad-pcb.org) and it's library.  This is intended for anyone who wants to customize their build of KiCad, build latest stable release optimized for their specific version of OS X and using the latest version of boost and other dependencies.  

This tap also includes some OSX specific tweaks that presently are not part of the official stable and nightly builds (for now):

-  wxWidgets is patched so that &#8984;-C correctly copies text instead of closing the current window.

### Installation is simple...
```sh
brew tap metacollin/kicad
brew install kicad
```

### ...but it's good to have options...
```sh
--without-menu-icons # Turn off menubar and contextual menu icons
--with-brewed-library # Use /usr/local for support files # Currently deprecated, rethinking library management
--with-python # Turn on python scripting
--HEAD # Builds the latest development version of KiCad.
--debug # Build with debugging turned on
```

### ...especially exciting ones...
These new options are now supported by this tap, *only when building `--HEAD`.*
```sh
--with-oce # Adds IGES and STEP 3D model support via homebrew/science/oce (a fork of opencascade)
--with-ngspice # Adds built-in spice netlist generation and simulation to Eeschema
```

### ...or outright dangerous ones.
These options are likely to break often, may only work on certain systems, and are unofficial.  The --with-openmp especially option his high potential for breakage.  But it'll make that ray tracer really chug along! It also requires rebuilding `metacollin/kicad/wxkicad` or `metacollin/kicad/wxkdebug` llvm 3.8.  This will be done automatically, just be prepared for a long build :).   

They likewise are only available when building `--HEAD`.
```sh
--with-openmp # Enables multiprocessor support via OpenMP.

# The following both increase the segment/poly count used for curves.  
# This is a pervasive change - both the actual renderer as well as the
# various plot file formats (noteably gerbers) will be effected.  

--with-nice-curves  # Doubles the poly/segment count used for curves in Pcbnew.
--with-nicer-curves # Same as above, only it quadruples the count.  Might make older machines sad.

# I have had a dozen boards made by various pcb fabs using these settings, no problems or complaints. 
# That said, if there are problems, I am not liable and make no assurances.  Consider yourself warned.
```

### Notes on the library

You can download the [kicad support files](http://downloads.kicad-pcb.org/osx/stable/kicad-extras-4.0.4.dmg) and [library](http://downloads.kicad-pcb.org/osx/stable/kicad-4.0.4.dmg), provided by KiCad's [official OS X Builds](http://downloads.kicad-pcb.org/osx/).

`--with-brewed-library` **is now deprecated, I am in the process of rethinking library management via homebrew.**

By default, this formula doesn't handle the KiCad Library files.  However, you can tell the formula to download and install the latest KiCad support files for you by using the `--with-brewed-library` option.  This will "brew-ify" KiCad by changing its search paths to

`$(brew --prefix)/etc/kicad`

for both library files and user preferences and, if necessary, installing files.  Existing files will not be overwritten.


Note: Also check out Shane Burrell's tap of [homebrew-kicadlibrarian](https://github.com/shaneburrell/homebrew-kicadlibrarian).  It's an OS X port of  [KiCad Libriarian](http://www.compuphase.com/electronics/kicadlibrarian_en.htm), a separate tool for managing footprint libraries (one that I use and recommend!).

