///|
/// MoonBit port of `statusbar-sample`.

priv struct State {
  mut status : @vscode.StatusBarItem?
  mut active_listener : &@vscode.Disposable?
  mut selection_listener : &@vscode.Disposable?
}

let state : State = {
  status: None,
  active_listener: None,
  selection_listener: None,
}

fn selection_line_count(selection : @vscode.Selection) -> Int {
  let first = selection.anchor().line()
  let second = selection.active().line()
  if first <= second {
    second - first
  } else {
    first - second
  }
}

fn selected_line_total(
  selections : Array[@vscode.Selection],
  index : Int,
  acc : Int,
) -> Int {
  if index >= selections.length() {
    acc
  } else {
    selected_line_total(
      selections,
      index + 1,
      acc + selection_line_count(selections[index]),
    )
  }
}

fn get_number_of_selected_lines(editor : @vscode.TextEditor?) -> Int {
  match editor {
    None => 0
    Some(text_editor) => selected_line_total(text_editor.selections(), 0, 0)
  }
}

fn update_status_bar_item() -> Unit {
  match state.status {
    None => ()
    Some(item) => {
      let count = get_number_of_selected_lines(@window.active_text_editor())
      if count > 0 {
        item.set_text("$(megaphone) \{count} line(s) selected")
        item.show()
      } else {
        item.hide()
      }
    }
  }
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let command_id = "sample.showSelectionCount"

  let command_disposable = @commands.register_command_async(
    command_id,
    async fn(_args) {
      let count = get_number_of_selected_lines(@window.active_text_editor())
      ignore(
        @window.show_information_message(
          "Yeah, \{count} line(s) selected... Keep going!",
        ),
      )
    },
  )
  subscriptions.push(command_disposable)

  let status_item = @window.create_status_bar_item(
    alignment=@vscode.StatusBarAlignment::Right,
    priority=100,
  )
  status_item.set_command(@vscode.CommandOrString::Id(command_id))
  state.status = Some(status_item)

  let on_active = @window.on_did_change_active_text_editor().subscribe(fn(_event) {
    update_status_bar_item()
  })
  let on_selection = @window.on_did_change_text_editor_selection().subscribe(
    fn(_event) {
      update_status_bar_item()
    },
  )

  state.active_listener = Some(on_active)
  state.selection_listener = Some(on_selection)

  subscriptions.push(on_active)
  subscriptions.push(on_selection)

  update_status_bar_item()
}

pub fn deactivate() -> Unit {
  match state.active_listener {
    None => ()
    Some(disposable) => {
      disposable.dispose()
      state.active_listener = None
    }
  }

  match state.selection_listener {
    None => ()
    Some(disposable) => {
      disposable.dispose()
      state.selection_listener = None
    }
  }

  match state.status {
    None => ()
    Some(item) => {
      item.dispose()
      state.status = None
    }
  }
}
