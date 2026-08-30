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
  discard cssProvider.loadFromData(fontCss & "\n" & cssData)
  resetWidgets(getDefaultScreen())

  var config = loadConfig(getConfigDir() / "config")
  config.setSectionKey("Font", "name", fName)
  config.setSectionKey("Font", "size", fSize)
  config.setSectionKey("Font", "style", fStyle)
  config.setSectionKey("Font", "weight", fWeight)
  config.writeConfig(getConfigDir() / "config")

proc onTabSpinButton(spinButton: SpinButton) =
  p.tabWidth = spinButton.getValueAsInt()

  # Set the visual width of a tab character (e.g., 4 spaces wide)
  p.textView.setTabWidth(p.tabWidth)

  # Set the number of spaces used for indentation steps
  # A value of -1 will make it automatically match the tabWidth
  p.textView.setIndentWidth(-1)

  var config = loadConfig(getConfigDir() / "config")
  config.setSectionKey("Tabs", "width", $p.tabWidth)
  config.writeConfig(getConfigDir() / "config")

proc onTabSpaceToggle(button: CheckButton) =
  # Enable inserting space characters instead of literal '\t' tabs
  let state = button.active
  p.useSpaces = state
  p.textView.setInsertSpacesInsteadOfTabs(state)

  var config = loadConfig(getConfigDir() / "config")
  config.setSectionKey("Tabs", "spaces", $state)
  config.writeConfig(getConfigDir() / "config")

proc onAutoIndentToggle(button: CheckButton) =
  let state = button.active
  p.autoIndent = state
  p.textView.setAutoIndent(state)

  var config = loadConfig(getConfigDir() / "config")
  config.setSectionKey("General", "auto_indent", $state)
  config.writeConfig(getConfigDir() / "config")

proc onLineNumberToggle(button: CheckButton) =
  let state = button.active
  p.showLineNumbers = state
  p.textView.setShowLineNumbers(state)

  var config = loadConfig(getConfigDir() / "config")
  config.setSectionKey("General", "show_line_numbers", $state)
  config.writeConfig(getConfigDir() / "config")

proc onPrefKeyPress(window: ApplicationWindow; event: gdk.EventKey): bool =
  let key = event.getKeyval

  case key
  of KEY_Escape:
    window.close()
    return true # Event handled
  of KEY_Return, KEY_KP_Enter:
    # Return false to let the event propagate
    return false
  of KEY_Tab:
    return false
  of KEY_Up:
    return false
  of KEY_Down:
    return false
  of KEY_Left:
    return false
  of KEY_Right:
    return false
  else:
    return true

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

  # Main Container
  let grid = newGrid()
  grid.setRowSpacing(10)
  grid.setColumnSpacing(20)
  grid.setMargin(20)
  grid.halign = Align.center

  # Theme Settings
  let themeLabel = newLabel("Theme:")
  themeLabel.halign = Align.end
  grid.attach(themeLabel, 0, 0, 2, 1)

  let styleManager = getDefaultStyleSchemeManager()
  let themeButton = newStyleSchemeChooserButton()

  let scheme = styleManager.getScheme(cstring(p.theme))
  if scheme != nil:
    themeButton.setStyleScheme(scheme)
  else:
    echo "Warning: could not load style scheme"

  themeButton.connect("notify::style-scheme", onThemeChange)
  grid.attach(themeButton, 2, 0, 1, 1)

  # Font Settings
  let fontLabel = newLabel("Font:")
  fontLabel.halign = Align.end
  grid.attach(fontLabel, 0, 1, 2, 1)

  let currentFont = toString(getFont(getStyleContext(p.textView), StateFlags.normal))
  let fontButton = newFontButtonWithFont(cstring(currentFont))
  fontButton.title = "Font"
  fontButton.connect("font-set", onFontSet)
  grid.attach(fontButton, 2, 1, 1, 1)

  # Tab Settings
  let tabWidthLabel = newLabel("Tab width:")
  tabWidthLabel.halign = Align.end
  grid.attach(tabWidthLabel, 0, 2, 2, 1)

  # Define bounding restrictions using an Adjustment
  # Parameters: initial_value, lower_bound, upper_bound, step_increment, page_increment, page_size
  let adjustment = newAdjustment(float64(p.tabWidth), 0.0, 50.0, 1.0, 10.0, 0.0)

  let spinButton = newSpinButton(adjustment, 1.0, 0)
  spinButton.setHexpand(true)
  spinButton.connect("value-changed", onTabSpinButton)
  grid.attach(spinButton, 2, 2, 1, 1)

  let tabModeLabel = newLabel("Tab mode:")
  tabModeLabel.halign = Align.end
  grid.attach(tabModeLabel, 0, 3, 2, 1)

  let tabCheckBtn = newCheckButton("Insert spaces")
  tabCheckBtn.halign = Align.start
  tabCheckBtn.valign = Align.center
  tabCheckBtn.active = p.useSpaces
  tabCheckBtn.connect("toggled", onTabSpaceToggle)

  grid.attach(tabCheckBtn, 2, 3, 1, 1)

  let indentCheckBtn = newCheckButton("Auto-indent")
  indentCheckBtn.halign = Align.start
  indentCheckBtn.valign = Align.center
  indentCheckBtn.active = p.autoIndent
  indentCheckBtn.connect("toggled", onAutoIndentToggle)

  grid.attach(indentCheckBtn, 1, 4, 1, 1)

  let lineNumberCheckBtn = newCheckButton("Line numbers")
  lineNumberCheckBtn.halign = Align.start
  lineNumberCheckBtn.valign = Align.center
  lineNumberCheckBtn.active = p.showLineNumbers
  lineNumberCheckBtn.connect("toggled", onLineNumberToggle)

  grid.attach(lineNumberCheckBtn, 2, 4, 1, 1)

  frame.add(grid)
  prefWin.add(frame)
  prefWin.setTitlebar(headerBar)
  prefWin.connect("key-press-event", onPrefKeyPress)

  prefWin.showAll()
