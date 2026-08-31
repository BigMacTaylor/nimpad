# ========================================================================================
#
#                                   Nimpad
#                                    Misc
#
# ========================================================================================

proc initTextTags() =
  let foundTag = newTextTag("found")
  foundTag.setProperty("background", newValue("yellow"))
  foundTag.setProperty("foreground", newValue("black"))
  #foundTag.setProperty("background-set", toBoolVal(true))
  discard add(p.buffer.getTagTable, foundTag)

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
    p.window.title = cstring(p.file.getFileName())
    p.label.text = cstring(p.file.getFilePath())
    return
  if not p.window.title.startsWith(modCharacter):
    p.window.title = cstring(modCharacter & p.window.title)

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
    newMessage("Error", "Failed to save file " & p.file)
    sleep(500)
    writeFile(p.file, text)

  p.buffer.beginNotUndoableAction()
  p.buffer.endNotUndoableAction()
  p.isModified = false
  setEnabled(p.save, false)
  updateTitle()

proc saveAs() =
  let dialog = newFileChooserDialog("Save File", p.window, gtk.FileChooserAction.save)
  discard dialog.setCurrentFolder(cstring(p.file.getFilePath()))
  dialog.setCurrentName(cstring(p.file.getFileName()))
  dialog.setDoOverwriteConfirmation(true)

  discard dialog.addButton("_Cancel", ResponseType.cancel.ord)
  discard dialog.addButton("_Save", ResponseType.accept.ord)

  let response = dialog.run()

  if ResponseType(response) == ResponseType.accept:
    let input = $dialog.getFilename()
    if input.len > 0:
      p.file = input
      saveBuffer()
    else:
      newMessage("Error", "Invalid file name.")

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
    newMessage("Error", "Failed to create file " & fileName)

