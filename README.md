# Homebrew KiCad EDA Suite
KiCad 5 prerelease and KiCad stable supported.

Delicious and foamy stable (and `--HEAD`!) [Homebrew](https://github.com/mxcl/homebrew) tap for [KiCad](http://www.kicad-pcb.org). This is intended for anyone who wants to customize their build of KiCad, build latest stable release optimized for their specific version of OS X and using the latest version of boost and other dependencies.

### Installation is simple...
```sh
brew tap metacollin/kicad
brew install kicad
```
Or the more adventurous, install the latest development version:
```sh
brew install kicad --HEAD
# And to automatically check for more recent revisions of any --HEAD formulae:
brew upgrade --fetch-HEAD
# or just upgrade kicad:
brew upgrade --fetch-HEAD kicad
```


### ...but it's good to have options...
```sh
--with-oce            # Use OC for native support several 3D model formats, including .STEP.
                      # Requires building --HEAD

--with-libngspice     # Enable SPICE simulation capabilities in eeschema using ngspice as the backend.
                      # Requires building --HEAD

--without-python      # If you're afraid of danger noodles.

--HEAD                # Builds the latest development version of KiCad.

--debug               # Build with debugging turned on
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


### How to add KiCad.app to the dock and continue to work through upgrades

If you are following --HEAD, you might be upgrading KiCad every couple of days, or even several times a day. If you have it in your dock, I'm sure you've noticed that with every upgrade, it will no longer be able to find KiCad.app.  

Here is a quick and dirty hack to give yourself a Kicad.app dock icon that will always work even across ugprades:

Launch Script Editor (located in `/Applications/Utilities`), create a new script, and paste this into the script editor:

```
on run
  set p to "/usr/local/opt/kicad/kicad.app"
  set a to POSIX file p
  tell application "Finder"
    open application file a
  end tell
end run
```

Now goto `File->Export` and change the File Format to Application. 

This is going to be our 'proxy' Kicad.app.  It tells the finder to launch an alias that always points to KiCad.app, automatically linked by homebrew. How you chose to do this is up to you, but I like to disguise it by naming it KiCad.app, putting it in my `/Applications` folder, and even pasting KiCad's icon as its icon.  

Regardless, you now have a .app you can plop into your dock and it will always launch KiCad.  It will not, however, remain running as if it really was KiCad - a second KiCad.app will appear at the end of your dock, while the icon you clicked will have already quit itself.  
*C'est la vie*
