# Package

version       = "0.1.7"
author        = "BigMacTaylor"
description   = "A simple text editor written in Nim"
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["nimpad"]


# Dependencies
requires "nim >= 2.2.4"
requires "https://github.com/BigMacTaylor/nim2gtk.git"

# Foreign Dependencies
foreignDeps  = @["libgtk-3-0", "libgtksourceview-4-0"]

task release, "Build release":
    exec "nim c -d:release -d:strip --opt:size --threads:off -o:bin/nimpad src/nimpad.nim"
