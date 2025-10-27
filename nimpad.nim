# ========================================================================================
#
#                                   Nimpad
#                          version 0.1.2 by Mac_Taylor
#
# ========================================================================================

import nim2gtk/[gtk, glib, gdk, gobject, gio, gtksource, pango]
import std/os
import std/[cmdline, files, paths, parsecfg]
import strutils

var
  file, theme, cssString: string
  buffer: Buffer
  isModified: bool = false
  window: ApplicationWindow
  textView: View
  label: Label
  save: SimpleAction
  config: Config

const
  newFileName = "Untitled"
  modCharacter = "*"
  defaultConfig =
    """
[Font]
name=Monospace
size=12
style=italic
weight=normal
[Theme]
name=nimpad
"""

# ----------------------------------------------------------------------------------------
#                                    Misc
# ----------------------------------------------------------------------------------------

proc findDialog() =
  let dialog = newDialog()
  dialog.title = "Find"
  dialog.setModal(true)
  setTransientFor(dialog, window)
  dialog.setPosition(WindowPosition.center)

  let contentArea = getContentArea(dialog)
  let label = newLabel("Find what:")
  contentArea.add(label)

  discard dialog.addButton("Cancel", ResponseType.cancel.ord)
  discard dialog.addButton("Find", ResponseType.accept.ord)

  dialog.showAll()
  let response = dialog.run()
  dialog.destroy()

proc createNewFile2(): string =
  var filename = "new_file"
  var i = 1
  echo "create new file"
  echo filename
  while fileExists(Path(filename)):
    filename = "new_file_" & $i
    i = i + 1

  echo "new filefilename is:"
  echo filename
  return filename

proc getFilePath(): string =
  if file == "":
    result = os.getCurrentDir()
  else:
    result = parentDir(file.expandFilename())

proc getFileName(): string =
  if file == "":
    return newFileName
  else:
    result = file.extractFilename()

proc updateTitle(window: ApplicationWindow) =
  if not isModified:
    window.title = getFileName()
    label.setText(getFilePath())
    return
  if not window.title.startsWith(modCharacter):
    window.setTitle(modCharacter & window.title)

proc saveBuffer(window: ApplicationWindow) =
  var startIter = buffer.getStartIter()
  var endIter = buffer.getEndIter()
  let text = buffer.getText(startIter, endIter, true)

  writeFile(file, text)

  # Gtk likes to eat data
  # Do this check to avoid that
  if text == readFile(file):
    echo "save successful"
  else:
    echo "error: text blank"
    sleep(500)
    writeFile(file, text)

  isModified = false
  setEnabled(save, false)
  updateTitle(window)

proc saveAs(window: ApplicationWindow) =
  let dialog = newFileChooserDialog("Save File", window, gtk.FileChooserAction.save)
  discard dialog.setCurrentFolder(getFilePath())
  dialog.setCurrentName(getFileName())
  discard dialog.addButton("Save", ResponseType.accept.ord)
  discard dialog.addButton("Cancel", ResponseType.cancel.ord)

  let response = dialog.run()

  if ResponseType(response) == ResponseType.accept:
    let input = dialog.getFilename()
    if fileExists(input):
      echo "error: file exists"

    if input.len > 0:
      file = input
      window.saveBuffer()

  dialog.destroy()
  window.setFocus(textView)

proc saveFile(window: ApplicationWindow) =
  if not isModified:
    return
  if fileExists(file):
    window.saveBuffer()
    window.setFocus(textView)
  elif not fileExists(file):
    window.saveAs()

proc createNewFile(fileName, text: string) =
  try:
    writeFile(fileName, text)
  except:
    echo "Error: Failed to create file " & fileName

proc getConfigPath(): string =
  let configDir = getEnv("XDG_CONFIG_HOME")
  if not configDir.isEmptyOrWhitespace():
    result = configDir / "nimpad" / "config"
  else:
    result = os.getHomeDir() / ".config" / "nimpad" / "config"

proc initConfig() =
  if not fileExists(getConfigPath()):
    let configDir = parentDir(getConfigPath())
    if not dirExists(configDir):
      createDir(configDir)
    createNewFile(getConfigPath(), defaultConfig)

  echo "reading config"
  try:
    config = loadConfig(getConfigPath())
  except:
    echo "Error: Failed to parse configuration file"

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

  cssString =
    "textview {font: " & fStyle & " " & fWeight & " " & fSize & "pt" & " \"" & fName &
    "\";}"

  if config.getSectionValue("Theme", "name") != "":
    theme = config.getSectionValue("Theme", "name")
  else:
    theme = "nimpad"

proc quitMsg(app: Application) =
  let dialog = newDialog()
  dialog.setModal(true)
  setTransientFor(dialog, window)
  dialog.setPosition(WindowPosition.center)

  let contentArea = getContentArea(dialog)
  let label = newLabel("\nSave changes to " & getFileName() & "?\n")
  contentArea.add(label)

  discard dialog.addButton("no", 1)
  discard dialog.addButton("cancel", 2)
  discard dialog.addButton("yes", 3)

  dialog.showAll()
  let response = dialog.run()
  dialog.destroy()

  case response
  of 1:
    quit(app)
  of 3:
    #app.activateAction("save", nil)
    window.saveFile()
    if not isModified:
      quit(app)
  else:
    return

proc onThemeChange(themeButton: StyleSchemeChooserButton, param: ParamSpec) =
  let scheme = themeButton.getStyleScheme()
  theme = scheme.getId()
  echo "Selected theme: ", theme

  buffer.setStyleScheme(scheme)

  config.setSectionKey("Theme", "name", theme)
  config.writeConfig(getConfigPath())

proc onFontSet(fontButton: FontButton) =
  let font = fontButton.getFontName()
  echo "Selected font: ", font

  let fontDesc = newFontDescription(font)
  let fName = fontDesc.getFamily()
  let fWeight = $(fontDesc.getWeight())
  let fStyle = $(fontDesc.getStyle())
  let fSize = font.split(' ')[^1]

  cssString =
    "textview {font: " & fStyle & " " & fWeight & " " & fSize & "pt" & " \"" & fName &
    "\";}"

  let cssProvider = getDefaultCssProvider()
  discard cssProvider.loadFromData(cssString)
  resetWidgets(getDefaultScreen())

  config.setSectionKey("Font", "name", fName)
  config.setSectionKey("Font", "size", fSize)
  config.setSectionKey("Font", "style", fStyle)
  config.setSectionKey("Font", "weight", fWeight)
  config.writeConfig(getConfigPath())

# ----------------------------------------------------------------------------------------
#                                    Preferences
# ----------------------------------------------------------------------------------------

proc preferences(app: Application) =
  let prefWin = newApplicationWindow(app)
  prefWin.title = "Preferences"
  prefWin.defaultSize = (400, 200)
  prefWin.setModal(true)
  prefWin.setTransientFor(window)
  #prefWin.setBorderWidth(4)

  let headerBar = newHeaderBar()
  headerBar.setShowCloseButton
  headerBar.setTitle("Preferences")

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

  let currentFont = toString(getFont(getStyleContext(textView), StateFlags.normal))
  let fontButton = newFontButtonWithFont(currentFont)
  fontButton.title = "Font"
  fontButton.connect("font-set", onFontSet)
  grid.attach(fontButton, 2, 0, 1, 1)

  # --- Theme Setting ---
  let themeLabel = newLabel("Theme:")
  themeLabel.halign = Align.end
  grid.attach(themeLabel, 0, 1, 2, 1)

  let styleManager = getDefaultStyleSchemeManager()
  let scheme = styleManager.getScheme(theme)
  let themeButton = newStyleSchemeChooserButton()
  themeButton.setStyleScheme(scheme)
  themeButton.connect("notify::style-scheme", onThemeChange)
  grid.attach(themeButton, 2, 1, 1, 1)

  frame.add(grid)
  prefWin.add(frame)
  prefWin.setTitlebar(headerBar)

  prefWin.showAll()

# ----------------------------------------------------------------------------------------
#                                    Callbacks
# ----------------------------------------------------------------------------------------

proc onSave(action: SimpleAction, parameter: glib.Variant) =
  window.saveFile()

proc onSaveAs(action: SimpleAction, parameter: glib.Variant) =
  window.saveAs()

proc onFind(action: SimpleAction, parameter: glib.Variant) =
  findDialog()

proc onReplace(action: SimpleAction, parameter: glib.Variant) =
  window.saveFile()

proc onPreferences(action: SimpleAction, parameter: glib.Variant, app: Application) =
  app.preferences()

proc onShortcuts(action: SimpleAction, parameter: glib.Variant) =
  window.saveFile()

proc onQuit(action: SimpleAction, parameter: glib.Variant, app: Application) =
  if isModified:
    quitMsg(app)
  else:
    quit(app)

proc closeEvent(window: ApplicationWindow, event: Event, app: Application): bool =
  if isModified:
    quitMsg(app)
    return true
  else:
    quit(app)

proc onFileChange(buffer: Buffer, app: Application) =
  if isModified:
    return
  else:
    isModified = true
    setEnabled(save, true)
    updateTitle(window)

# ----------------------------------------------------------------------------------------
#                                    Startup
# ----------------------------------------------------------------------------------------

proc appStartup(app: Application) =
  echo "appStartup"
  save = newSimpleAction("save")
  connect(save, "activate", onSave)
  app.addAction(save)
  let saveAs = newSimpleAction("saveAs")
  connect(saveAs, "activate", onSaveAs)
  app.addAction(saveAs)
  let find = newSimpleAction("find")
  connect(find, "activate", onFind)
  app.addAction(find)
  let replace = newSimpleAction("replace")
  connect(replace, "activate", onReplace)
  app.addAction(replace)
  let preferences = newSimpleAction("preferences")
  connect(preferences, "activate", onPreferences, app)
  app.addAction(preferences)
  let shortcuts = newSimpleAction("shortcuts")
  connect(shortcuts, "activate", onShortcuts)
  app.addAction(shortcuts)
  let quit = newSimpleAction("quit")
  connect(quit, "activate", onQuit, app)
  app.addAction(quit)

# ----------------------------------------------------------------------------------------
#                                    Window
# ----------------------------------------------------------------------------------------

proc appActivate(app: Application) =
  window = newApplicationWindow(app)
  window.title = getFileName()
  window.defaultSize = (600, 450)

  let mainBox = newBox(Orientation.vertical)

  let headerBar = newBox(Orientation.horizontal)

  let saveButton = newButton()
  saveButton.setImage(newImageFromIconName("document-save", IconSize.menu.ord))
  #saveButton.connect("clicked", onButtonClick, textView)
  #saveButton.setSensitive(false)
  saveButton.setActionName("app.save")
  setEnabled(save, false)

  label = newLabel(getFilePath())
  label.setEllipsize(pango.EllipsizeMode.end)

  let menuButton = gtk.newMenuButton()
  menuButton.setImage(newImageFromIconName("open-menu", IconSize.menu.ord))

  let menu = gio.newMenu()
  menu.appendItem(newMenuItem("Save As", "app.saveAs"))
  menu.appendItem(newMenuItem("Find", "app.find"))
  menu.appendItem(newMenuItem("Replace", "app.replace"))
  menu.appendItem(newMenuItem("Preferences", "app.preferences"))
  menu.appendItem(newMenuItem("Shortcuts", "app.shortcuts"))
  menu.appendItem(newMenuItem("Quit", "app.quit"))

  menuButton.setMenuModel(menu)

  # Pack header bar (Widget; expand; fill; padding)
  headerBar.packStart(saveButton, false, false, 6)
  headerBar.packStart(label, true, false, 0)
  headerBar.packEnd(menuButton, false, false, 6)

  let scrollBox = newScrolledWindow()

  buffer = newBuffer() # source buffer
  if file == "":
    buffer.setText("", -1)
  else:
    buffer.setText(readFile file, -1)
  buffer.connect("changed", onFileChange, app)

  let styleManager = getDefaultStyleSchemeManager()
  let scheme = styleManager.getScheme(theme)
  buffer.setStyleScheme(scheme)

  let langManager = getDefaultLanguageManager()
  if file != "":
    let lang = langManager.guessLanguage(file, nil)
    buffer.setLanguage(lang)

  let cssProvider = getDefaultCssProvider()
  discard cssProvider.loadFromData(cssString)
  addProviderForScreen(
    getDefaultScreen(), cssProvider, STYLE_PROVIDER_PRIORITY_APPLICATION
  )

  textView = newViewWithBuffer(buffer) # source view
  textView.setShowLineNumbers(true)

  scrollBox.add(textView)

  mainBox.packStart(headerBar, false, false, 6)
  mainBox.packStart(scrollBox, true, true, 0)

  window.add(mainBox)
  window.setFocus(textView)
  window.connect("delete-event", closeEvent, app)

  window.showAll()

# ----------------------------------------------------------------------------------------
#                                    Main
# ----------------------------------------------------------------------------------------

proc main() =
  if paramCount() > 1:
    echo "error: too many paramters"
    quit(0)
  elif paramCount() == 1:
    if not fileExists(paramStr(1)):
      createNewFile(paramStr(1), "")
    file = paramStr(1)

  initConfig()

  let app = newApplication(
    "org.gtk.nimpad", {ApplicationFlag.handlesOpen, ApplicationFlag.nonUnique}
  )
  connect(app, "startup", appStartup)
  connect(app, "activate", appActivate)
  discard app.run()

when isMainModule:
  main()
