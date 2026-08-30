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

proc onDuplicate(action: SimpleAction, parameter: glib.Variant) =
  var startIter, endIter: TextIter

  # If nothing selected get current line
  if not p.buffer.getSelectionBounds(startIter, endIter):
    p.buffer.getIterAtMark(startIter, p.buffer.getInsert())
    startIter.setLineOffset(0)

    endIter = startIter
    if not endIter.endsLine():
      discard endIter.forwardToLineEnd()

  # Get text
  var textToDuplicate = p.buffer.getText(startIter, endIter, includeHiddenChars = false)

  # Create temporary mark to save position
  # Left gravity keeps the mark to the left of new text
  let startMark = p.buffer.createMark("selection-start", endIter, leftGravity = true)

  # Move endIter to a new/end of line
  if endIter.forwardLine():
    textToDuplicate = textToDuplicate & "\n"
  else:
    textToDuplicate = "\n" & textToDuplicate

  p.buffer.placeCursor(endIter)

  p.buffer.insertAtCursor(cstring(textToDuplicate), textToDuplicate.len.cint)

  # Get iters for new selection
  p.buffer.getIterAtMark(startIter, startMark)
  p.buffer.getIterAtMark(endIter, p.buffer.getInsert())
  discard startIter.forwardLine()

  let currentLine = endIter.getLine()
  let totalLines = p.buffer.getLineCount()

  if currentLine != totalLines - 1:
    discard endIter.backwardChar()

  p.buffer.selectRange(startIter, endIter)
  discard p.textView.scrollToIter(endIter, 0.1, true, 1.0, 0.5)

  # Clean up temporary mark
  p.buffer.deleteMark(startMark)

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
  jumpDialog()

proc onUnselectAll(action: SimpleAction, parameter: glib.Variant) =
  var cursorIter: TextIter
  p.buffer.getIterAtMark(cursorIter, p.buffer.getInsert())
  p.buffer.selectRange(cursorIter, cursorIter)

proc onSelectWord(action: SimpleAction, parameter: glib.Variant) =
  var startIter, endIter: TextIter
  p.buffer.getIterAtMark(startIter, p.buffer.getInsert())
  endIter = startIter

  if not startIter.startsWord():
    discard startIter.backwardWordStart()

  if not endIter.endsWord():
    discard endIter.forwardWordEnd()

  p.buffer.selectRange(startIter, endIter)

proc onSelectLine(action: SimpleAction, parameter: glib.Variant) =
  var startIter, endIter: TextIter

  # First press: Select the current line
  if not p.buffer.getSelectionBounds(startIter, endIter):
    p.buffer.getIterAtMark(startIter, p.buffer.getInsert())
    startIter.setLineOffset(0)

    endIter = startIter
    if not endIter.endsLine():
      discard endIter.forwardToLineEnd()

  # Subsequent presses: Keep the existing top selection,
  # move bottom iter down 1 line
  else:
    if not endIter.isEnd():
      # Move to the end of the next line
      discard endIter.forwardToLineEnd()
      if endIter.getLineOffset() == 0:
        discard endIter.forwardChar()

  p.buffer.selectRange(endIter, startIter)
  discard p.textView.scrollToIter(endIter, 0.1, true, 1.0, 0.5)

proc onUnselectLine(action: SimpleAction, parameter: glib.Variant) =
  var startIter, endIter: TextIter

  if p.buffer.getSelectionBounds(startIter, endIter):
    # Calculate how many lines are currently selected
    let startLine = startIter.getLine()
    var endLine = endIter.getLine()

    if endLine > startLine:
      # More than one line is selected.
      # Move endIter up to the end of the previous line.
      p.buffer.getIterAtLine(endIter, endLine - 1)

      if not endIter.endsLine():
        discard endIter.forwardToLineEnd()

      p.buffer.selectRange(endIter, startIter)
      discard p.textView.scrollToIter(endIter, 0.1, true, 1.0, 0.5)
    else:
      # Only a single line is left.
      p.buffer.selectRange(startIter, startIter)

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
