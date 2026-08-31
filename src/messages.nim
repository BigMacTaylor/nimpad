# ========================================================================================
#
#                                   Nimpad
#                                  Messages
#
# ========================================================================================

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

  let label = newLabel(cstring("Save changes to '" & getFileName(p.file) & "'?"))
  label.setMargin(10)
  grid.attach(label, 1, 0, 1, 1)

  contentArea.add(grid)

  discard dialog.addButton("_No", 1)
  discard dialog.addButton("_Cancel", 2)
  discard dialog.addButton("_Yes", 3)
  dialog.defaultResponse = 2

  dialog.showAll()
  let response = dialog.run()
  dialog.destroy()

  case response
  of 1:
    quit(app)
    #p.window.destroy()
  of 3:
    #app.activateAction("save", nil)
    saveFile()
    if not p.isModified:
      quit(app)
      #p.window.destroy()
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

  discard dialog.addButton("_OK", 1)
  dialog.defaultResponse = 1

  dialog.showAll()
  discard dialog.run()
  dialog.destroy()
