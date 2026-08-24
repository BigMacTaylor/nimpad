# ========================================================================================
#
#                                   Nimpad
#                                 Preferences
#
# ========================================================================================

proc onThemeChange(themeButton: StyleSchemeChooserButton, param: ParamSpec) =
  let scheme = themeButton.getStyleScheme()
  p.theme = scheme.getId()
  echo "Selected theme: ", p.theme

  p.buffer.setStyleScheme(scheme)

  var config = loadConfig(getConfigDir() / "config")
  config.setSectionKey("Theme", "name", p.theme)
  config.writeConfig(getConfigDir() / "config")

proc onFontSet(fontButton: FontButton) =
  let font = fontButton.getFontName()
  echo "Selected font: ", font

  let fontDesc = newFontDescription(cstring(font))
  let fName = fontDesc.getFamily()
  let fWeight = $(fontDesc.getWeight())
  let fStyle = $(fontDesc.getStyle())
  let fSize = font.split(' ')[^1]

  let fontCss =
    "textview {font: " & fStyle & " " & fWeight & " " & fSize & "pt" & " \"" & fName &
    "\";}"

  let cssProvider = getDefaultCssProvider()
  discard cssProvider.loadFromData(fontCss)
  resetWidgets(getDefaultScreen())

  var config = loadConfig(getConfigDir() / "config")
  config.setSectionKey("Font", "name", fName)
  config.setSectionKey("Font", "size", fSize)
  config.setSectionKey("Font", "style", fStyle)
  config.setSectionKey("Font", "weight", fWeight)
  config.writeConfig(getConfigDir() / "config")

proc preferences(app: Application) =
  let prefWin = newApplicationWindow(app)
  prefWin.title = "Preferences"
  prefWin.defaultSize = (400, 200)
  prefWin.setModal(true)
  prefWin.setTransientFor(p.window)
  #prefWin.setBorderWidth(4)

  let headerBar = newHeaderBar()
  headerBar.title = "Preferences"
  headerBar.showCloseButton = true

  let frame = newFrame()
  #frame.setShadowType(ShadowType.etchedIn)

  # --- Main Container ---
  let grid = newGrid()
  grid.setRowSpacing(10)
  grid.setColumnSpacing(20)
  grid.setMargin(20)
  grid.halign = Align.center

  # --- Font Setting ---
  let fontLabel = newLabel("Font:")
  fontLabel.halign = Align.end
  grid.attach(fontLabel, 0, 0, 2, 1)

  let currentFont = toString(getFont(getStyleContext(p.textView), StateFlags.normal))
  let fontButton = newFontButtonWithFont(cstring(currentFont))
  fontButton.title = "Font"
  fontButton.connect("font-set", onFontSet)
  grid.attach(fontButton, 2, 0, 1, 1)

  # --- Theme Setting ---
  let themeLabel = newLabel("Theme:")
  themeLabel.halign = Align.end
  grid.attach(themeLabel, 0, 1, 2, 1)

  let styleManager = getDefaultStyleSchemeManager()
  let themeButton = newStyleSchemeChooserButton()

  let scheme = styleManager.getScheme(cstring(p.theme))
  if scheme != nil:
    themeButton.setStyleScheme(scheme)
  else:
    echo "Warning: could not load style scheme"

  themeButton.connect("notify::style-scheme", onThemeChange)
  grid.attach(themeButton, 2, 1, 1, 1)

  frame.add(grid)
  prefWin.add(frame)
  prefWin.setTitlebar(headerBar)

  prefWin.showAll()
