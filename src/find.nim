# ========================================================================================
#
#                                   Nimpad
#                                Find/Replace
#
# ========================================================================================

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

  # Remove old tags
  p.buffer.removeTag(tag, startIter, endIter)

  while startIter.forwardSearch(
    cstring(p.searchStr), searchFlags, matchStart, matchEnd, endIter):
    #while searchContext.forward(startIter, matchStart, matchEnd):
    p.buffer.applyTag(tag, matchStart, matchEnd)
    startIter = matchEnd

proc findString(forward: bool): bool =
  if p.searchStr.len == 0:
    # Return true to prevent showing 'not found' msg
    return true

  var found: bool
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
    found =
      startIter.forwardSearch(cstring(p.searchStr), searchFlags, matchStart, matchEnd)
  else:
    found =
      startIter.backwardSearch(cstring(p.searchStr), searchFlags, matchStart, matchEnd)
    if startIter.equal(matchEnd):
      found = matchStart.backwardSearch(
        cstring(p.searchStr), searchFlags, matchStart, matchEnd
      )

  # If not found after current position, wrap around
  if not found:
    if forward:
      startIter = p.buffer.getStartIter()
      found =
        startIter.forwardSearch(cstring(p.searchStr), searchFlags, matchStart, matchEnd)
    else:
      startIter = p.buffer.getEndIter()
      found = startIter.backwardSearch(
        cstring(p.searchStr), searchFlags, matchStart, matchEnd
      )

  if found:
    p.buffer.selectRange(matchStart, matchEnd)
    p.buffer.placeCursor(matchStart)
    p.buffer.moveMarkByName("insert", matchEnd)
    discard p.textView.scrollToIter(matchEnd, 0.1, true, 1.0, 0.5)
    return true
  else:
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

  while startIter.forwardSearch(cstring(p.searchStr), searchFlags, matchStart, matchEnd):
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
    hlightFound()
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

  discard dialog.addButton("_Skip", 1)
  discard dialog.addButton("_Cancel", 2)
  discard dialog.addButton("_Yes", 3)
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
  searchEntry.activatesDefault = true
  grid.attach(searchEntry, 1, 0, 1, 1)

  var startIter, endIter: TextIter
  if p.buffer.getSelectionBounds(startIter, endIter):
    searchEntry.text = cstring(p.buffer.getText(startIter, endIter, false))
  else:
    searchEntry.text = cstring(p.searchStr)

  let replaceLabel = newLabel("With:")
  replaceLabel.halign = Align.end

  let replaceEntry = newEntry()
  replaceEntry.text = cstring(p.replaceStr)
  replaceEntry.activatesDefault = true

  let caseButton = newCheckButton("Match case")
  caseButton.active = p.matchCase
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

  let buttonLabel = if replace: "_Replace" else: "_Find"

  discard dialog.addButton("_Cancel", ResponseType.cancel.ord)
  discard dialog.addButton(cstring(buttonLabel), ResponseType.accept.ord)
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

  hlightFound()

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

