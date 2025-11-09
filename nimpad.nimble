# Package

version       = "0.1.4"
author        = "BigMacTaylor"
description   = "A simple text editor written in Nim"
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["nimpad"]


# Dependencies

requires "nim >= 2.2.4"
requires "https://github.com/BigMacTaylor/nim2gtk.git"
