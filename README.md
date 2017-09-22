# Homebrew KiCad EDA Suite
_Now building --HEAD and 4.0.7 stable!_

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

--with-nice-curves    # Quadruples number of polys or segments used for curves and circles visually
                      # and in plot files (gerbers).

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

There is a bit of an annoyance that comes with linking .apps as aliases into your Application folder.  You may have noticed that macOS's dock does not allow you to drag an alias of an app on to the dock.  It only supports the real deal.
Of course, you can just add it to the dock once it is launched by right clicking on the KiCad.app in the dock, going to Options, and selecting 'Keep in Dock'.  
This is a perfectly adequate solution, unless you are tracking KiCad development and frequently update to the latest --HEAD version.  This could happen several times a day, potentially.  And, in the rare occurance when a new stable release is released, this problem will also effect stable uses.  The problem is that the actual location of the KiCad.app changes when the version changes.  This means that after an upgrade, your KiCad dock entry will no longer work.  

This is a rare and minor annoyance for stable users, but if you are upgrading to the latest HEAD very frequently, this will slowly eat away at your soul until you're little more than a husk of your former self.  Here's how to fix it:

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

This is going to be our 'pretend' Kicad.app.  I like to save it as KiCad.app in my `/Applications` folder, but it is really up to you. 

I also like to get info on the apple script app (KiCad.app) as well as the true KiCad.app, or alias to it, or whatever, anything with the KiCad icon, and click it's icon near the top, copy it, then paste it into the get info window for the applescript.  Now it even looks like KiCad.

This is simply telling the Finder to open /usr/local/opt/kicad/kicad.app.  This is an alias which is always relinked to the installed version by homebrew, but the path doesn't change for this alias, unlike the actual .app.  And, since the applescript is a full-fledged application, we can add it to our dock.  And while it isn't actually KiCad, what it will do is always launch KiCad correctly, even when the path changes.  

The only downside is a second KiCad icon will appear at the end of your dock, as it is a seperate program from our launcher.  *C'est la vie*
