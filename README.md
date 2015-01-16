homebrew-kicad
==============

Delicious and foamy --HEAD only tap for KiCad, a complete and well-developed electronic design automation suite.

No setup, just a quick 
`brew tap metacollin/kicad`
and then
`brew install kicad --HEAD`

It will automatically download the latest KiCad Library files and they will reside in your Cellar like any other homebrew formula, but presently, they will be naughtily symlinked into ~/Library/Application Support/kicad and the library table into ~/Library/Preferences/kicad folder.  

If you already have a library table there from another build of KiCad, it will be renamed to fp-lib-table_old<random hex string> and moved asside. If this behavior is unacceptable, before installing kicad, run

`brew install kicad-library --without-tables`.  Otherwise, your library tables will be automatically populated with all .pretty repos from github.  If you would rather use local .pretty tables without github functionallity, run

`brew install kicad-library --with-local-tables`.

Finally, if you prefer to manage the library manually and don't want anything touched and no naughty symlinking of stuff outside /usr/local, this is all limited to the kicad-library fomula and it is an optional dependency.  Install kicad with

`brew install kicad --without-kicad-library` and no non-standard behavior will be done.  

This build...is not short. You may see no activity for long stretches of time, this is normal and its just a very heavyweight build.  Be patient, go grab a sandwich or play some Battletoads on your NES, but after some patience, the build should finish.  
Unless it fails horribly instead. Should that happen please post the problem to this repo's issues page! 

Once it's installed, if you want the suite of .apps in your /Applications folder, you need to run `brew linkapps kicad` and you're good to go.  

Anyway, have fun!  Solder is the best programming language. :)
