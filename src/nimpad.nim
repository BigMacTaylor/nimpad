# ========================================================================================
#
#                                   Nimpad
#                          version 0.1.5 by Mac_Taylor
#
# ========================================================================================

import nim2gtk/[gtk, glib, gtksource, pango]
import nim2gtk/[gdk, gobject, gio]
import std/[os, cmdline]
import std/[files, paths, parsecfg]
import strutils

type Pad = object
  save: SimpleAction
  window: ApplicationWindow
  label: Label
  textView: View
  buffer: Buffer
  isModified, matchCase: bool = false
  file, theme, fontCss, searchStr, replaceStr: string

var p: Pad

const
  newFileName = "Untitled"
  modCharacter = "*"
  defaultConfig =
    """
[Font]
name=Monospace
size=12
style=normal
weight=normal
[Theme]
name=nimpad
"""

# ----------------------------------------------------------------------------------------
#                                    Misc
# ----------------------------------------------------------------------------------------

proc initTextTags() =
  let foundTag = newTextTag("found")
  foundTag.setProperty("background", newValue("yellow"))
  foundTag.setProperty("foreground", newValue("black"))
  #foundTag.setProperty("background-set", toBoolVal(true))
  discard add(p.buffer.getTagTable, foundTag)

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

proc getFilePath(file: string): string =
  if file == "":
    result = os.getCurrentDir()
  else:
    result = parentDir(file.expandFilename())

proc getFileName(file: string): string =
  if file == "":
    return newFileName
  else:
    result = file.extractFilename()

proc updateTitle() =
  if not p.isModified:
    p.window.title = p.file.getFileName()
    p.label.setText(p.file.getFilePath())
    return
  if not p.window.title.startsWith(modCharacter):
    p.window.setTitle(modCharacter & p.window.title)

proc saveBuffer() =
  let startIter = p.buffer.getStartIter()
  let endIter = p.buffer.getEndIter()
  let text = p.buffer.getText(startIter, endIter, true)

  writeFile(p.file, text)

  # Gtk likes to eat data
  # Do this check to avoid that
  if text == readFile(p.file):
    echo "save successful"
  else:
    echo "error: text blank"
    sleep(500)
    writeFile(p.file, text)

  p.buffer.beginNotUndoableAction()
  p.buffer.endNotUndoableAction()
  p.isModified = false
  setEnabled(p.save, false)
  updateTitle()

proc saveAs() =
  let dialog = newFileChooserDialog("Save File", p.window, gtk.FileChooserAction.save)
  discard dialog.setCurrentFolder(p.file.getFilePath())
  dialog.setCurrentName(p.file.getFileName())
  discard dialog.addButton("Save", ResponseType.accept.ord)
  discard dialog.addButton("Cancel", ResponseType.cancel.ord)

  let response = dialog.run()

  if ResponseType(response) == ResponseType.accept:
    let input = dialog.getFilename()
    if fileExists(input):
      echo "error: file exists"

    if input.len > 0:
      p.file = input
      saveBuffer()

  dialog.destroy()
  p.window.setFocus(p.textView)

proc saveFile() =
  if not p.isModified:
    return
  if fileExists(p.file):
    saveBuffer()
    p.window.setFocus(p.textView)
  elif not fileExists(p.file):
    saveAs()

proc createNewFile(fileName, text: string) =
  try:
    writeFile(fileName, text)
  except:
    echo "Error: Failed to create file " & fileName

# ----------------------------------------------------------------------------------------
#                                    Messages
# ----------------------------------------------------------------------------------------

proc quitMsg(app: Application) =
  let dialog = newDialog()
  dialog.setModal(true)
  dialog.setTransientFor(p.window)
  dialog.defaultSize = (300, 100)
  dialog.setPosition(WindowPosition.center)

  let contentArea = getContentArea(dialog)

  let grid = newGrid()
  grid.setRowSpacing(15)
  grid.setColumnSpacing(10)
  grid.setMargin(10)
  grid.halign = Align.center

  let icon = newImageFromIconName("dialog-question-symbolic", IconSize.dialog.ord)
  grid.attach(icon, 0, 0, 1, 1)

  let label = newLabel("Save changes to '" & getFileName(p.file) & "'?")
  label.setMargin(10)
  grid.attach(label, 1, 0, 1, 1)

  contentArea.add(grid)

  discard dialog.addButton("No", 1)
  discard dialog.addButton("Cancel", 2)
  discard dialog.addButton("Yes", 3)
  dialog.defaultResponse = 3

  dialog.showAll()
  let response = dialog.run()
  dialog.destroy()

  case response
  of 1:
    #quit(app)
    p.window.destroy()
  of 3:
    #app.activateAction("save", nil)
    saveFile()
    if not p.isModified:
      #quit(app)
      p.window.destroy()
  else:
    return

proc newMessage(title: string, messageText: string) =
  let dialog = newDialog()
  dialog.title = title
  dialog.setModal(true)
  dialog.setTransientFor(p.window)
  dialog.defaultSize = (300, 100)
  dialog.setPosition(WindowPosition.center)

  let contentArea = getContentArea(dialog)

  let grid = newGrid()
  grid.setRowSpacing(10)
  grid.setColumnSpacing(10)
  grid.setMargin(10)
  grid.halign = Align.center

  let icon = newImageFromIconName("dialog-information-symbolic", IconSize.dialog.ord)
  grid.attach(icon, 0, 0, 1, 1)

  let label = newLabel(messageText)
  label.setMargin(20)
  grid.attach(label, 1, 0, 1, 1)

  contentArea.add(grid)

  discard dialog.addButton("OK", 1)
  dialog.defaultResponse = 1

  dialog.showAll()
  discard dialog.run()
  dialog.destroy()

# ----------------------------------------------------------------------------------------
#                                    Find String
# ----------------------------------------------------------------------------------------

proc hlightFound() =
  var startIter = p.buffer.getStartIter()
  let endIter = p.buffer.getEndIter()
  var matchStart, matchEnd: TextIter
  let tag = p.buffer.tagTable.lookup("found")
  let searchFlags =
    if p.matchCase:
      {TextSearchFlag.visibleOnly, TextSearchFlag.textOnly}
    else:
      {
        TextSearchFlag.visibleOnly, TextSearchFlag.textOnly,
        TextSearchFlag.caseInsensitive,
      }

  while startIter.forwardSearch(p.searchStr, searchFlags, matchStart, matchEnd, endIter):
    #while searchContext.forward(startIter, matchStart, matchEnd):
    p.buffer.applyTag(tag, matchStart, matchEnd)
    startIter = matchEnd

proc findString(forward: bool): bool =
  if p.searchStr.len == 0:
    # Return true to prevent showing 'not found' msg
    return true

  hlightFound()

  var result: bool
  var startIter, matchStart, matchEnd: TextIter
  let searchFlags =
    if p.matchCase:
      {TextSearchFlag.visibleOnly, TextSearchFlag.textOnly}
    else:
      {
        TextSearchFlag.visibleOnly, TextSearchFlag.textOnly,
        TextSearchFlag.caseInsensitive,
      }

  p.buffer.getIterAtMark(startIter, p.buffer.getInsert())

  # Start the search from the last found position
  if forward:
    result = startIter.forwardSearch(p.searchStr, searchFlags, matchStart, matchEnd)
  else:
    result = startIter.backwardSearch(p.searchStr, searchFlags, matchStart, matchEnd)
    if startIter.equal(matchEnd):
      result = matchStart.backwardSearch(p.searchStr, searchFlags, matchStart, matchEnd)

  # If not found after current position, wrap around
  if not result:
    if forward:
      startIter = p.buffer.getStartIter()
      result = startIter.forwardSearch(p.searchStr, searchFlags, matchStart, matchEnd)
    else:
      startIter = p.buffer.getEndIter()
      result = startIter.backwardSearch(p.searchStr, searchFlags, matchStart, matchEnd)

  if result:
    p.buffer.selectRange(matchStart, matchEnd)
    p.buffer.placeCursor(matchStart)
    p.buffer.moveMarkByName("insert", matchEnd)
    discard p.textView.scrollToIter(matchEnd, 0.1, true, 1.0, 0.5)
    return true
  else:
    #newMessage("", "Search string not found.")
    #p.searchStr = ""
    return false

# ----------------------------------------------------------------------------------------
#                                    Replace All/Next
# ----------------------------------------------------------------------------------------

proc replaceAll(replaceStr: string) =
  var startIter, matchStart, matchEnd: TextIter
  let searchFlags =
    if p.matchCase:
      {TextSearchFlag.visibleOnly, TextSearchFlag.textOnly}
    else:
      {
        TextSearchFlag.visibleOnly, TextSearchFlag.textOnly,
        TextSearchFlag.caseInsensitive,
      }

  startIter = p.buffer.getStartIter()
  p.buffer.placeCursor(startIter)

  while startIter.forwardSearch(p.searchStr, searchFlags, matchStart, matchEnd):
    p.buffer.placeCursor(matchEnd)
    p.buffer.delete(matchStart, matchEnd)
    p.buffer.insert(matchStart, replaceStr, -1)
    p.buffer.getIterAtMark(startIter, p.buffer.getInsert())

proc onReplaceNext(dialog: Dialog, responseId: int, replaceStr: string) =
  case responseId
  of 1: # Skip
    discard findString(forward = true)
  of 3: # Replace
    discard p.buffer.deleteSelection(true, true)
    p.buffer.insertAtCursor(replaceStr, -1)
    if not findString(forward = true):
      dialog.destroy()
      newMessage("", "No more matches.")
  else:
    dialog.destroy()
    return

proc replaceNextDlg(replaceStr: string) =
  let dialog = newDialog()
  dialog.title = ""
  dialog.setModal(true)
  dialog.setTransientFor(p.window)
  dialog.setPosition(WindowPosition.center)

  let contentArea = getContentArea(dialog)

  let grid = newGrid()
  grid.setRowSpacing(20)
  grid.setColumnSpacing(20)
  grid.setMargin(10)
  grid.halign = Align.center

  let icon = newImageFromIconName("dialog-question-symbolic", IconSize.dialog.ord)
  grid.attach(icon, 0, 0, 1, 1)

  let label = newLabel("Replace?")
  label.setMargin(20)
  grid.attach(label, 1, 0, 1, 1)

  contentArea.add(grid)

  discard dialog.addButton("Skip", 1)
  discard dialog.addButton("Cancel", 2)
  discard dialog.addButton("Yes", 3)
  dialog.defaultResponse = 3
  dialog.connect("response", onReplaceNext, replaceStr)

  if not findString(forward = true):
    dialog.destroy()
    newMessage("", "Search string not found.")
    return

  dialog.showAll()

# ----------------------------------------------------------------------------------------
#                                    Find/Replace Dialog
# ----------------------------------------------------------------------------------------

proc findDialog(replace: bool) =
  let dialog = newDialog()
  if replace:
    dialog.title = "Replace"
  else:
    dialog.title = "Find"
  dialog.setModal(true)
  dialog.setTransientFor(p.window)
  dialog.setPosition(WindowPosition.center)

  var replaceAll = false

  let contentArea = getContentArea(dialog)
  let grid = newGrid()
  grid.setRowSpacing(10)
  grid.setColumnSpacing(10)
  grid.setMargin(10)
  grid.halign = Align.center

  let searchLabel =
    if replace:
      newLabel("Replace:")
    else:
      newLabel("Find what:")
  searchLabel.halign = Align.end
  grid.attach(searchLabel, 0, 0, 1, 1)

  let searchEntry = newEntry()
  searchEntry.text = p.searchStr
  searchEntry.activatesDefault = true
  grid.attach(searchEntry, 1, 0, 1, 1)

  let replaceLabel = newLabel("With:")
  replaceLabel.halign = Align.end

  let replaceEntry = newEntry()
  replaceEntry.text = p.replaceStr
  replaceEntry.activatesDefault = true

  let caseButton = newCheckButton("Match case")
  caseButton.halign = Align.start

  let replaceAllButton = newCheckButton("Replace all")
  replaceAllButton.halign = Align.end

  if replace:
    grid.attach(replaceLabel, 0, 1, 1, 1)
    grid.attach(replaceEntry, 1, 1, 1, 1)
    grid.attach(caseButton, 0, 2, 2, 1)
    grid.attach(replaceAllButton, 0, 2, 2, 1)
  else:
    grid.attach(caseButton, 0, 1, 2, 1)

  let buttonLabel = if replace: "Replace" else: "Find"

  discard dialog.addButton("Cancel", ResponseType.cancel.ord)
  discard dialog.addButton(buttonLabel, ResponseType.accept.ord)
  dialog.defaultResponse = ResponseType.accept.ord

  contentArea.add(grid)
  dialog.showAll()

  let response = dialog.run()

  if ResponseType(response) == ResponseType.accept:
    p.searchStr = searchEntry.getText()
    p.matchCase = caseButton.getActive()
    p.replaceStr = replaceEntry.getText()
    replaceAll = replaceAllButton.getActive()
  else:
    dialog.destroy()
    return

  dialog.destroy()

  if p.searchStr.len == 0:
    return

  # Remove old tags
  let startIter = p.buffer.getStartIter()
  let endIter = p.buffer.getEndIter()
  let tag = p.buffer.tagTable.lookup("found")
  p.buffer.removeTag(tag, startIter, endIter)

  # Find string
  if not replace:
    if not findString(forward = true):
      newMessage("", "Search string not found.")
    return

  # Replace string
  if replaceAll:
    replaceAll(p.replaceStr)
  else:
    replaceNextDlg(p.replaceStr)

# ----------------------------------------------------------------------------------------
#                                    Config
# ----------------------------------------------------------------------------------------

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

  var config: Config

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

  p.fontCss =
    "textview {font: " & fStyle & " " & fWeight & " " & fSize & "pt" & " \"" & fName &
    "\";}"

  if config.getSectionValue("Theme", "name") != "":
    p.theme = config.getSectionValue("Theme", "name")
  else:
    p.theme = "nimpad"

# ----------------------------------------------------------------------------------------
#                                    Preferences
# ----------------------------------------------------------------------------------------

proc onThemeChange(themeButton: StyleSchemeChooserButton, param: ParamSpec) =
  let scheme = themeButton.getStyleScheme()
  let theme = scheme.getId()
  echo "Selected theme: ", theme

  p.buffer.setStyleScheme(scheme)

  var config = loadConfig(getConfigPath())
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

  let fontCss =
    "textview {font: " & fStyle & " " & fWeight & " " & fSize & "pt" & " \"" & fName &
    "\";}"

  let cssProvider = getDefaultCssProvider()
  discard cssProvider.loadFromData(fontCss)
  resetWidgets(getDefaultScreen())

  var config = loadConfig(getConfigPath())
  config.setSectionKey("Font", "name", fName)
  config.setSectionKey("Font", "size", fSize)
  config.setSectionKey("Font", "style", fStyle)
  config.setSectionKey("Font", "weight", fWeight)
  config.writeConfig(getConfigPath())

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
  let fontButton = newFontButtonWithFont(currentFont)
  fontButton.title = "Font"
  fontButton.connect("font-set", onFontSet)
  grid.attach(fontButton, 2, 0, 1, 1)

  # --- Theme Setting ---
  let themeLabel = newLabel("Theme:")
  themeLabel.halign = Align.end
  grid.attach(themeLabel, 0, 1, 2, 1)

  let styleManager = getDefaultStyleSchemeManager()
  let scheme = styleManager.getScheme(p.theme)
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
  saveFile()

proc onSaveAs(action: SimpleAction, parameter: glib.Variant) =
  saveAs()

proc onFind(action: SimpleAction, parameter: glib.Variant) =
  findDialog(replace = false)

proc onFindNext(action: SimpleAction, parameter: glib.Variant) =
  discard findString(forward = true)

proc onFindPrev(action: SimpleAction, parameter: glib.Variant) =
  discard findString(forward = false)

proc onReplace(action: SimpleAction, parameter: glib.Variant) =
  findDialog(replace = true)

proc onPreferences(action: SimpleAction, parameter: glib.Variant, app: Application) =
  app.preferences()

#proc onShortcuts(action: SimpleAction, parameter: glib.Variant) =
#  shortcutsDialog()

proc onQuit(action: SimpleAction, parameter: glib.Variant, app: Application) =
  if p.isModified:
    quitMsg(app)
  else:
    quit(app)

proc closeEvent(window: ApplicationWindow, event: Event, app: Application): bool =
  if p.isModified:
    quitMsg(app)
    return true
  else:
    quit(app)

proc onFileChange(buffer: Buffer) =
  # Remove old tags
  let startIter = p.buffer.getStartIter()
  let endIter = p.buffer.getEndIter()
  let tag = p.buffer.tagTable.lookup("found")
  p.buffer.removeTag(tag, startIter, endIter)

  if p.isModified:
    return
  else:
    p.isModified = true
    setEnabled(p.save, true)
    updateTitle()

# ----------------------------------------------------------------------------------------
#                                    Startup
# ----------------------------------------------------------------------------------------

proc appStartup(app: Application) =
  echo "appStartup"

  p.save = newSimpleAction("save")
  connect(p.save, "activate", onSave)
  app.addAction(p.save)
  app.setAccelsForAction("app.save", "<Control>S")

  let saveAs = newSimpleAction("saveAs")
  connect(saveAs, "activate", onSaveAs)
  app.addAction(saveAs)
  app.setAccelsForAction("app.saveAs", "<Control><Shift>S")

  let find = newSimpleAction("find")
  connect(find, "activate", onFind)
  app.addAction(find)
  app.setAccelsForAction("app.find", "<Control>F")

  let findNext = newSimpleAction("findNext")
  connect(findNext, "activate", onFindNext)
  app.addAction(findNext)
  app.setAccelsForAction("app.findNext", "<Control>G")

  let findPrev = newSimpleAction("findPrev")
  connect(findPrev, "activate", onFindPrev)
  app.addAction(findPrev)
  app.setAccelsForAction("app.findPrev", "<Control><Shift>G")

  let replace = newSimpleAction("replace")
  connect(replace, "activate", onReplace)
  app.addAction(replace)
  app.setAccelsForAction("app.replace", "<Control>R")

  let preferences = newSimpleAction("preferences")
  connect(preferences, "activate", onPreferences, app)
  app.addAction(preferences)

  #let shortcuts = newSimpleAction("shortcuts")
  #connect(shortcuts, "activate", onShortcuts)
  #app.addAction(shortcuts)

  let quit = newSimpleAction("quit")
  connect(quit, "activate", onQuit, app)
  app.addAction(quit)
  app.setAccelsForAction("app.quit", "<Control>Q")

# ----------------------------------------------------------------------------------------
#                                    Window
# ----------------------------------------------------------------------------------------

proc appActivate(app: Application) =
  p.window = newApplicationWindow(app)
  p.window.title = p.file.getFileName()
  p.window.defaultSize = (600, 450)

  let mainBox = newBox(Orientation.vertical)

  let headerBar = newBox(Orientation.horizontal)

  let saveButton = newButton()
  saveButton.setImage(newImageFromIconName("document-save", IconSize.menu.ord))
  #saveButton.connect("clicked", onButtonClick, textView)
  #saveButton.setSensitive(false)
  saveButton.setActionName("app.save")
  setEnabled(p.save, false)

  p.label = newLabel(getFilePath(p.file))
  p.label.setEllipsize(pango.EllipsizeMode.end)

  let menuButton = gtk.newMenuButton()
  menuButton.setImage(newImageFromIconName("open-menu", IconSize.menu.ord))

  let menu = gio.newMenu()
  menu.appendItem(newMenuItem("Save As", "app.saveAs"))
  menu.appendItem(newMenuItem("Find", "app.find"))
  #menu.appendItem(newMenuItem("Find Next", "app.findNext"))
  menu.appendItem(newMenuItem("Replace", "app.replace"))
  menu.appendItem(newMenuItem("Preferences", "app.preferences"))
  #menu.appendItem(newMenuItem("Shortcuts", "app.shortcuts"))
  menu.appendItem(newMenuItem("Quit", "app.quit"))

  menuButton.setMenuModel(menu)

  # Pack header bar (Widget; expand; fill; padding)
  headerBar.packStart(saveButton, false, false, 6)
  headerBar.packStart(p.label, true, false, 0)
  headerBar.packEnd(menuButton, false, false, 6)

  let scrollBox = newScrolledWindow()

  p.buffer = newBuffer() # source buffer
  if p.file == "":
    p.buffer.setText("", -1)
  else:
    p.buffer.beginNotUndoableAction()
    p.buffer.setText(readFile p.file, -1)
    p.buffer.endNotUndoableAction()
    p.buffer.placeCursor(p.buffer.getStartIter())
  p.buffer.connect("changed", onFileChange)

  initTextTags()

  let styleManager = getDefaultStyleSchemeManager()
  let scheme = styleManager.getScheme(p.theme)
  p.buffer.setStyleScheme(scheme)

  let langManager = getDefaultLanguageManager()
  if p.file != "":
    let lang = langManager.guessLanguage(p.file, nil)
    p.buffer.setLanguage(lang)

  let cssProvider = getDefaultCssProvider()
  discard cssProvider.loadFromData(p.fontCss)
  addProviderForScreen(
    getDefaultScreen(), cssProvider, STYLE_PROVIDER_PRIORITY_APPLICATION
  )

  p.textView = newViewWithBuffer(p.buffer) # source view
  p.textView.setShowLineNumbers(true)

  scrollBox.add(p.textView)

  mainBox.packStart(headerBar, false, false, 6)
  mainBox.packStart(scrollBox, true, true, 0)

  p.window.add(mainBox)
  p.window.setFocus(p.textView)
  p.window.connect("delete-event", closeEvent, app)

  p.window.showAll()

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
    p.file = paramStr(1)

  initConfig()

  let app = newApplication(
    "org.gtk.nimpad", {ApplicationFlag.handlesOpen, ApplicationFlag.nonUnique}
  )
  connect(app, "startup", appStartup)
  connect(app, "activate", appActivate)
  discard app.run()

when isMainModule:
  main()
