# ========================================================================================
#
#                                   Nimpad
#                                    Jump
#
# ========================================================================================

proc jumpToLine(line: int) =
  var cursorIter: TextIter
  let totalLines = p.buffer.getLineCount()

  if (line > 0) and (line <= totalLines):
    p.lineNumber = line
    p.buffer.getIterAtLine(cursorIter, line - 1)
    p.buffer.placeCursor(cursorIter)
    discard p.textView.scrollToIter(cursorIter, 0.1, true, 1.0, 0.5)

proc jumpDialog() =
  let dialog = newDialog()
  dialog.setModal(true)
  dialog.setTransientFor(p.window)
  dialog.setPosition(WindowPosition.center)

  let contentArea = getContentArea(dialog)
  let grid = newGrid()
  grid.setRowSpacing(10)
  grid.setColumnSpacing(10)
  grid.setMargin(10)
  grid.halign = Align.center

  let label = newLabel("Jump:")
  label.halign = Align.end
  grid.attach(label, 0, 0, 1, 1)

  let searchEntry = newEntry()
  searchEntry.activatesDefault = true
  grid.attach(searchEntry, 1, 0, 1, 1)

  searchEntry.text = cstring($p.lineNumber)

  discard dialog.addButton("_Cancel", ResponseType.cancel.ord)
  discard dialog.addButton("_Jump", ResponseType.accept.ord)
  dialog.defaultResponse = ResponseType.accept.ord

  contentArea.add(grid)
  dialog.showAll()

  let response = dialog.run()

  if ResponseType(response) == ResponseType.cancel:
    dialog.destroy()
    return

  let input = try:
      parseInt(searchEntry.getText())
    except ValueError:
      echo "Invalid integer input!"
      -1 # Returns -1 if parsing fails

  dialog.destroy()

  jumpToLine(input)
