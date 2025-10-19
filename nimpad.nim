# ========================================================================================
#
#                                   Nimpad
#                          version 0.1.0 by Mac_Taylor
#
# ========================================================================================

import nim2gtk/[gtk, glib, gdk, gobject, gio, gtksource, pango]
import std/os
import std/[cmdline, files, paths, parsecfg]
import strutils

var
  file: string
  buffer: Buffer
  isNewFile: bool = true
  isModified: bool = false
  window: ApplicationWindow
  save: SimpleAction
  textView: View
  config: Config
  cssString: string = "textview {font-family: 'Monospace'; font-size: 12pt;}"

const
  newFileName = "Untitled"
  modCharacter = "*"
  defaultConfig =
    """
# Nimpad 0.0.1 default config
# change as you like

[CSS]
Font = "textview {font-family: 'Monospace'; font-size: 12pt;}"
"""

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
  if isNewFile:
    result = os.getCurrentDir()
  else:
    result = parentDir(file.expandFilename())

proc getFileName(): string =
  if isNewFile:
    return newFileName
  else:
    result = file.extractFilename()

proc updateTitle(window: ApplicationWindow) =
  let currentTitle = window.title
  if not isModified:
    window.title = getFileName()
    return
  elif isModified and not currentTitle.startsWith(modCharacter):
    window.setTitle(modCharacter & currentTitle)

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
    file = dialog.getFilename()
    if file.len > 0:
      window.saveBuffer()

  dialog.destroy()

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

  try:
    config = loadConfig(getConfigPath())
  except:
    echo "Error: Failed to parse configuration file"

  if config.getSectionValue("CSS", "Font") != "":
    cssString = config.getSectionValue("CSS", "Font")

proc quitMsg(app: Application) =
  let dialog = newDialog()
  dialog.setModal(true)
  setTransientFor(dialog, window)

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

# ----------------------------------------------------------------------------------------
#                                    Callbacks
# ----------------------------------------------------------------------------------------

proc onSaveAs(action: SimpleAction, parameter: glib.Variant) =
  window.saveAs()

proc onSave(action: SimpleAction, parameter: glib.Variant) =
  window.saveFile()

proc onClose(action: SimpleAction, parameter: glib.Variant, app: Application) =
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

proc onFileChanged(buffer: Buffer, app: Application) =
  if isModified:
    return
  else:
    isModified = true
    updateTitle(window)
    setEnabled(save, true)

proc appStartup(app: Application) =
  echo "appStartup"
  let quit = newSimpleAction("quit")
  connect(quit, "activate", onClose, app)
  app.addAction(quit)
  save = newSimpleAction("save")
  connect(save, "activate", onSave)
  app.addAction(save)
  let saveAs = newSimpleAction("saveAs")
  connect(saveAs, "activate", onSaveAs)
  app.addAction(saveAs)

# ----------------------------------------------------------------------------------------
#                                    Window
# ----------------------------------------------------------------------------------------

proc appActivate(app: Application) =
  window = newApplicationWindow(app)
  window.title = getFileName()
  window.defaultSize = (250, 350)

  let mainBox = newBox(Orientation.vertical)

  let headerBar = newBox(Orientation.horizontal)

  let saveButton = newButton()
  saveButton.setImage(newImageFromIconName("document-save", IconSize.menu.ord))
  #saveButton.connect("clicked", onButtonClick, textView)
  #saveButton.setSensitive(false)
  saveButton.setActionName("app.save")
  setEnabled(save, false)

  let label = newLabel(getFilePath())
  label.setEllipsize(pango.EllipsizeMode.end)

  let menuButton = gtk.newMenuButton()
  menuButton.setImage(newImageFromIconName("open-menu", IconSize.menu.ord))

  let menu = gio.newMenu()
  menu.appendItem(newMenuItem("Save As", "app.saveAs"))
  menu.appendItem(newMenuItem("Find", "app.find"))
  menu.appendItem(newMenuItem("Replace", "app.replace"))
  menu.appendItem(newMenuItem("Quit", "app.quit"))

  menuButton.setMenuModel(menu)

  # Pack header bar (Widget; expand; fill; padding)
  headerBar.packStart(saveButton, false, false, 6)
  headerBar.packStart(label, true, false, 0)
  headerBar.packEnd(menuButton, false, false, 6)

  let scrollBox = newScrolledWindow()

  buffer = newBuffer() # source buffer
  if isNewFile:
    buffer.setText("", -1)
  else:
    buffer.setText(readFile file, -1)
  buffer.connect("changed", onFileChanged, app)

  let styleManager = getDefaultStyleSchemeManager()
  let scheme = styleManager.getScheme("nimpad")
  buffer.setStyleScheme(scheme)

  let langManager = getDefaultLanguageManager()
  let lang = langManager.guessLanguage(file, nil)
  buffer.setLanguage(lang)

  let cssProvider = newCssProvider()
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
    isNewFile = false

  initConfig()

  let app = newApplication(
    "org.gtk.nimpad", {ApplicationFlag.handlesOpen, ApplicationFlag.nonUnique}
  )
  connect(app, "startup", appStartup)
  connect(app, "activate", appActivate)
  discard app.run()

when isMainModule:
  main()
