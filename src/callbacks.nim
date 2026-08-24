# ========================================================================================
#
#                                   Nimpad
#                                  Callbacks
#
# ========================================================================================

proc onSave(action: SimpleAction, parameter: glib.Variant) =
  saveFile()

proc onSaveAs(action: SimpleAction, parameter: glib.Variant) =
  saveAs()

proc onFind(action: SimpleAction, parameter: glib.Variant) =
  findDialog(replace = false)

#[
  var startIter, endIter: TextIter
  if p.buffer.getSelectionBounds(startIter, endIter):
    p.searchStr = p.buffer.getText(startIter, endIter, false)
    removeOldTags()
    hlightFound()
    discard findString(forward = true)
  else:
    findDialog(replace = false)
]#
proc onFindNext(action: SimpleAction, parameter: glib.Variant) =
  var startIter, endIter: TextIter
  if p.buffer.getSelectionBounds(startIter, endIter):
    #if p.buffer.getText(startIter, endIter, false) == p.searchStr:
    if cmpIgnoreCase(p.buffer.getText(startIter, endIter, false), p.searchStr) == 0:
      if hasTag(startIter, p.buffer.tagTable.lookup("found")):
        discard findString(forward = true)
        return
    p.searchStr = p.buffer.getText(startIter, endIter, false)
  hlightFound()
  discard findString(forward = true)

proc onFindPrev(action: SimpleAction, parameter: glib.Variant) =
  var startIter, endIter: TextIter
  if p.buffer.getSelectionBounds(startIter, endIter):
    if cmpIgnoreCase(p.buffer.getText(startIter, endIter, false), p.searchStr) == 0:
      if hasTag(startIter, p.buffer.tagTable.lookup("found")):
        discard findString(forward = false)
        return
    p.searchStr = p.buffer.getText(startIter, endIter, false)
  hlightFound()
  discard findString(forward = false)

proc onReplace(action: SimpleAction, parameter: glib.Variant) =
  findDialog(replace = true)

proc onJump(action: SimpleAction, parameter: glib.Variant) =
  echo "jump"

proc onUnselectAll(action: SimpleAction, parameter: glib.Variant) =
  echo "onUnselectAll"

proc onSelectLine(action: SimpleAction, parameter: glib.Variant) =
  echo "onSelectLine"

proc onTransform(action: SimpleAction, parameter: glib.Variant) =
  echo "onTransform"

proc onPreferences(action: SimpleAction, parameter: glib.Variant, app: Application) =
  preferences(app)

proc onShortcuts(action: SimpleAction, parameter: glib.Variant, app: Application) =
  shortcuts(app)

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
