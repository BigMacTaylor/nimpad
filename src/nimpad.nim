# ========================================================================================
#
#                                   Nimpad
#                                by Mac Taylor
#
# ========================================================================================

const version = "0.1.8"

import nim2gtk/[gtk, glib, gtksource, pango]
import nim2gtk/[gdk, gobject, gio]
import std/[os, cmdline, parsecfg]
import strutils

type Pad = object
  save: SimpleAction
  window: ApplicationWindow
  label: Label
  textView: View
  buffer: Buffer
  isModified, matchCase: bool = false
  lineNumber: int
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

const cssData =
  """

list {
    border-radius: 10px;
    border: 1px solid @borders;
}

row {
    border-radius: 10px;
    border: none;
    outline: none;
    box-shadow: none;
    margin: 0px;
    padding: 10px;
}

separator {
    background: #6A6872;
    min-height: 1px;
    margin: 2px 0; }

"""


include /[misc, config, messages, find, jump, preferences, shortcuts, callbacks]

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

  let duplicate = newSimpleAction("duplicate")
  connect(duplicate, "activate", onDuplicate)
  app.addAction(duplicate)
  app.setAccelsForAction("app.duplicate", "<Control>D")

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

  let jump = newSimpleAction("jump")
  connect(jump, "activate", onJump)
  app.addAction(jump)
  app.setAccelsForAction("app.jump", "<Control>J")

  let unselectAll = newSimpleAction("unselectAll")
  connect(unselectAll, "activate", onUnselectAll)
  app.addAction(unselectAll)
  app.setAccelsForAction("app.unselectAll", "<Control><Shift>A")

  let selectWord = newSimpleAction("selectWord")
  connect(selectWord, "activate", onSelectWord)
  app.addAction(selectWord)
  app.setAccelsForAction("app.selectWord", "<Control>W")

  let selectLine = newSimpleAction("selectLine")
  connect(selectLine, "activate", onSelectLine)
  app.addAction(selectLine)
  app.setAccelsForAction("app.selectLine", "<Control>L")

  let unselectLine = newSimpleAction("unselectLine")
  connect(unselectLine, "activate", onUnselectLine)
  app.addAction(unselectLine)
  app.setAccelsForAction("app.unselectLine", "<Control><Shift>L")

  let transform = newSimpleAction("transform")
  connect(transform, "activate", onTransform)
  app.addAction(transform)
  #app.setAccelsForAction("app.transform", "<Control>T")

  let preferences = newSimpleAction("preferences")
  connect(preferences, "activate", onPreferences, app)
  app.addAction(preferences)
  app.setAccelsForAction("app.preferences", "<Control>comma")

  let shortcuts = newSimpleAction("shortcuts")
  connect(shortcuts, "activate", onShortcuts, app)
  app.addAction(shortcuts)
  app.setAccelsForAction("app.shortcuts", "<Control>question")

  let quit = newSimpleAction("quit")
  connect(quit, "activate", onQuit, app)
  app.addAction(quit)
  app.setAccelsForAction("app.quit", "<Control>Q")

# ----------------------------------------------------------------------------------------
#                                    Main Window
# ----------------------------------------------------------------------------------------

proc appActivate(app: Application) =
  p.window = newApplicationWindow(app)
  p.window.title = cstring(p.file.getFileName())
  p.window.defaultSize = (600, 450)

  let mainBox = newBox(Orientation.vertical)

  let headerBar = newBox(Orientation.horizontal)

  let saveButton = newButton()
  saveButton.setImage(newImageFromIconName("document-save", IconSize.menu.ord))
  #saveButton.connect("clicked", onButtonClick, textView)
  #saveButton.setSensitive(false)
  saveButton.setActionName("app.save")
  setEnabled(p.save, false)

  p.label = newLabel(cstring(getFilePath(p.file)))
  p.label.setEllipsize(pango.EllipsizeMode.middle)

  let menuButton = gtk.newMenuButton()
  menuButton.setImage(newImageFromIconName("open-menu", IconSize.menu.ord))

  let toolMenu = gio.newMenu()
  toolMenu.append("Sub-item 1", "app.action1")
  toolMenu.append("Sub-item 2", "app.action2")

  let section_1 = gio.newMenu()
  section_1.appendItem(newMenuItem("Save", "app.save"))
  section_1.appendItem(newMenuItem("Save As...", "app.saveAs"))

  let section_2 = gio.newMenu()
  section_2.appendItem(newMenuItem("Find...", "app.find"))
  #section_2.appendItem(newMenuItem("Find Next", "app.findNext"))
  section_2.appendItem(newMenuItem("Replace...", "app.replace"))

  let section_3 = gio.newMenu()
  section_3.appendSubmenu("Tools", toolMenu)
  #section_4.appendItem(newMenuItem("Transform", "app.transform"))

  let section_4 = gio.newMenu()
  section_4.appendItem(newMenuItem("Preferences", "app.preferences"))
  section_4.appendItem(newMenuItem("Shortcuts", "app.shortcuts"))
  section_4.appendItem(newMenuItem("Quit", "app.quit"))

  let rootMenu = gio.newMenu()
  rootMenu.appendSection(nil, section_1)
  rootMenu.appendSection(nil, section_2)
  rootMenu.appendSection(nil, section_3)
  rootMenu.appendSection(nil, section_4)

  menuButton.setMenuModel(rootMenu)

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
    p.buffer.setText(cstring(readFile p.file), -1)
    p.buffer.endNotUndoableAction()
    p.buffer.placeCursor(p.buffer.getStartIter())
  p.buffer.connect("changed", onFileChange)

  initTextTags()

  let styleManager = getDefaultStyleSchemeManager()
  let scheme = styleManager.getScheme(cstring(p.theme))
  if scheme != nil:
    p.buffer.setStyleScheme(scheme)
  else:
    echo "Warning: could not load style scheme"
    echo "Useing fallback..."
    let scheme = styleManager.getScheme("classic")
    p.buffer.setStyleScheme(scheme)

  let langManager = getDefaultLanguageManager()
  if p.file != "":
    let lang = langManager.guessLanguage(cstring(p.file), nil)
    p.buffer.setLanguage(lang)

  let cssProvider = getDefaultCssProvider()
  discard cssProvider.loadFromData(p.fontCss & "\n" & cssData)
  addProviderForScreen(
    getDefaultScreen(), cssProvider, STYLE_PROVIDER_PRIORITY_APPLICATION
  )

  p.textView = newViewWithBuffer(p.buffer) # source view
  p.textView.setShowLineNumbers(true)
  p.textView.setRightMargin(20)
  p.textView.setBottomMargin(20)

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
    echo "Error: Too many paramters"
    quit(1)
  elif paramCount() == 1:
    if not fileExists(paramStr(1)):
      createNewFile(paramStr(1), "")
    p.file = paramStr(1)

  let config = initFile("config", defaultConfig)
  parseConfig(config)

  let app = newApplication(
    "org.gtk.nimpad", {ApplicationFlag.handlesOpen, ApplicationFlag.nonUnique}
  )
  connect(app, "startup", appStartup)
  connect(app, "activate", appActivate)
  discard app.run()

when isMainModule:
  main()
