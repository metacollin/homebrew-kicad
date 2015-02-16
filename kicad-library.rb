# Documentation: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Formula-Cookbook.md
#                /usr/local/Library/Contributions/example-formula.rb
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
require 'securerandom'


class KicadLibrary < Formula
  homepage "http://kicad-pcb.org"
  url "https://github.com/KiCad/kicad-library.git"

  option 'without-tables', 'Does not touch the actual library tables, only installs or updates the library files.'
  option 'with-local-tables', 'Populates the library tables with locally stored .pretty files. This will move aside any current tables.'

  def install
    mewpath = Pathname.new(ENV['HOME'])
    unless build.with? "without-tables"
      if File.file?("#{mewpath}/Library/Preferences/kicad/fp-lib-table")
        system "echo", "mew"
       # newname = SecureRandom.hex 
        mv "#{mewpath}/Library/Preferences/kicad/fp-lib-table", "#{mewpath}/Library/Preferences/kicad/fp-lib-table_old_#{SecureRandom.hex(8)}"
      end
      if build.with? "local-tables"
        mv "template/fp-lib-table.for-pretty", "fp-lib-table"
      else
        mv "template/fp-lib-table.for-github", "fp-lib-table"
       # (mewpath/"Library/Preferences/kicad").install_symlink Dir["fp-lib-table"]
      end
      prefix.install Dir["./*"]
      (mewpath/"Library/Application\ Support/kicad").mkpath
      (mewpath/"Library/Application\ Support/kicad").install_symlink Dir["#{prefix}/*"]
      unless build.with? "without-tables"
        (mewpath/"Library/Preferences/kicad").mkpath
        (mewpath/"Library/Preferences/kicad").install_symlink Dir["#{prefix}/fp-lib-table"]
      end
    end
  end
end