///|
pub struct SelectionStatusBar {
  item : @vscode.StatusBarItem
}

///|
pub fn SelectionStatusBar::new() -> SelectionStatusBar {
  let item = @window.create_status_bar_item(
    alignment=@vscode.StatusBarAlignment::Right,
    priority=100,
  )
  item.set_command(@vscode.CommandOrString::Id("sample.showSelectionCount"))
  SelectionStatusBar::{ item }
}

///|
fn selected_line_count(editor : @vscode.TextEditor?) -> Int {
  match editor {
    None => 0
    Some(editor) =>
      editor.selections().fold(init=0, fn(acc, selection) {
        acc + selection_line_count(selection)
      })
  }
}

///|
fn selection_line_count(selection : @vscode.Selection) -> Int {
  let anchor_line = selection.anchor().line()
  let active_line = selection.active().line()
  if anchor_line > active_line {
    anchor_line - active_line
  } else {
    active_line - anchor_line
  }
}

///|
pub fn SelectionStatusBar::update(self : SelectionStatusBar) -> Unit {
  let count = selected_line_count(@window.active_text_editor())
  if count > 0 {
    self.item.set_text("$(megaphone) \{count} line(s) selected")
    self.item.show()
  } else {
    self.item.hide()
  }
}

///|
pub async fn show_selection_count() -> Unit {
  let count = selected_line_count(@window.active_text_editor())
  @window.show_information_message(
    "Yeah, \{count} line(s) selected... Keep going!",
  )
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let status = SelectionStatusBar::new()
  let subscriptions = ctx.subscriptions()
  subscriptions.push(status.item)
  subscriptions.push(@commands.register_command_async("sample.showSelectionCount", async fn(
    _args,
  ) {
    show_selection_count()
  }))
  subscriptions.push(@window.on_did_change_active_text_editor().subscribe(_ => {
    status.update()
  }))
  subscriptions.push(@window.on_did_change_text_editor_selection().subscribe(_ => {
    status.update()
  }))
  status.update()
}
