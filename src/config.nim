# ========================================================================================
#
#                                   Nimpad
#                                   Config
#
# ========================================================================================

proc getConfigDir(): string =
  let home = getEnv("XDG_CONFIG_HOME")
  if not home.isEmptyOrWhitespace():
    result = home / "nimpad"
  else:
    result = os.getHomeDir() / ".config" / "nimpad"

proc initFile(fileName: string, defaultData: string): string =
  let path = getConfigDir()
  if not fileExists(path / fileName):
    if not dirExists(path):
      createDir(path)
    createNewFile(path / fileName, defaultData)

  return path / fileName

proc parseConfig(configFile: string) =
  let config =
    try:
      loadConfig(configFile)
    except:
      echo "Error: Failed to parse configuration file"
      return

  # Theme Settings
  if config.getSectionValue("Theme", "name") != "":
    p.theme = config.getSectionValue("Theme", "name")
  else:
    p.theme = "nimpad"

  # Font Settings
  let fName =
    if config.getSectionValue("Font", "name") != "":
      config.getSectionValue("Font", "name")
    else:
      "Monospace"
  let fSize =
    if config.getSectionValue("Font", "size") != "":
      config.getSectionValue("Font", "size")
    else:
      "12"
  let fStyle =
    if config.getSectionValue("Font", "style") != "":
      config.getSectionValue("Font", "style")
    else:
      "normal"
  let fWeight =
    if config.getSectionValue("Font", "weight") != "":
      config.getSectionValue("Font", "weight")
    else:
      "normal"

  p.fontCss =
    "textview {font: " & fStyle & " " & fWeight & " " & fSize & "pt" & " \"" & fName &
    "\";}"

  # Tab Settings
  if config.getSectionValue("Tabs", "width") != "":
    try:
      p.tabWidth = parseInt(config.getSectionValue("Tabs", "width"))
    except ValueError:
      p.tabWidth = 4
  else:
    p.tabWidth = 4

  if config.getSectionValue("Tabs", "spaces") != "":
    try:
      p.useSpaces = parseBool(config.getSectionValue("Tabs", "spaces"))
    except ValueError:
      p.useSpaces = true
  else:
    p.useSpaces = true

  if config.getSectionValue("General", "auto_indent") != "":
    try:
      p.autoIndent = parseBool(config.getSectionValue("General", "auto_indent"))
    except ValueError:
      p.autoIndent = true
  else:
    p.autoIndent = true

  if config.getSectionValue("General", "show_line_numbers") != "":
    try:
      p.showLineNumbers = parseBool(config.getSectionValue("General", "show_line_numbers"))
    except ValueError:
      p.showLineNumbers = true
  else:
    p.showLineNumbers = true
