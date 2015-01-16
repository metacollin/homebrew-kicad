homebrew-kicad
==============

Delicious and foamy --HEAD only tap for KiCad, a complete and well-developed electronic design automation suite.

No setup, just a quick:
```sh
brew tap metacollin/kicad
brew install kicad --HEAD
```

It will automatically download the latest KiCad Library files and they will reside in your Cellar like any other homebrew formula, but presently, they will be naughtily symlinked into `~/Library/Application Support/kicad` and the library table into `~/Library/Preferences/kicad folder`.  

If you already have a library table there from another build of KiCad, it will be renamed to `fp-lib-table_old<random hex string>` and moved asside. If this behavior is unacceptable, before installing kicad, run:

```sh
brew install kicad-library --without-tables #do not symlink any table file into your kicad preferences
```

Your library tables will be automatically populated with all .pretty repos from github.  If you would rather use local .pretty tables without github functionallity, run:

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

**Warning:**
This build...is not short. You may see no activity for long stretches of time, this is normal and its just a very heavyweight build.  Be patient, go grab a sandwich or play some Battletoads on your NES, but after some patience, the build should finish.  

Unless it fails horribly instead. Should that happen please post the problem to this repo's issues page! 


Anyway, have fun!  Solder is the best programming language. :)
