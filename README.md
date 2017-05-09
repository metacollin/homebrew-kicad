# Homebrew KiCad EDA Suite
_Now building --HEAD and 4.0.6 stable!_

Delicious and foamy stable (and `--HEAD`!) [Homebrew](https://github.com/mxcl/homebrew) tap for [KiCad](http://www.kicad-pcb.org). This is intended for anyone who wants to customize their build of KiCad, build latest stable release optimized for their specific version of OS X and using the latest version of boost and other dependencies.

### Installation is simple...
```sh
brew tap metacollin/kicad
brew install kicad
```

### ...but it's good to have options...
```sh
--with-oce # Incorporates opencascade for native support several 3D model formats, including .STEP.
           # Requires building --HEAD
--with-libngspice # Enable SPICE simulation capabilities in eeschema using ngspice as the backend.
           # Requires building --HEAD
--without-python # If you're afraid of danger noodles.
--with-nice-curves # Quadruples number of polys or segments used for curves and circles visually
                   # and in plot files (gerbers).
--HEAD # Builds the latest development version of KiCad.
--debug # Build with debugging turned on
```

### Some things have changed

If you previously installed this tap, you should know that the included dependencies have been reworked and renamed.  You may want to perform the following:

```sh
brew remove wxkicad # (and wxkdebug if installed)
brew remove kicad
brew untap metacollin/kicad
brew tap metacollin/kicad
brew install kicad
```

The dependencies have been split into two new formula, kicad-wxwidgets and kicad-wxpython.  This is more robust and should be less error-prone than previous ways of dealing with the patched wx dependency.
