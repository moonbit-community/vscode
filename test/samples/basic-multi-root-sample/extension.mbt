///|
/// MoonBit port of `basic-multi-root-sample`.
fn basename(path : String) -> String {
  @path.Path::basename(path).to_string()
}

priv struct EditorInfo {
  text : String?
  tooltip : String?
  color : String?
}

fn get_editor_info() -> EditorInfo? {
  let editor = @window.active_text_editor()

  match editor {
    None => None
    Some(editor) =>
      match @workspace.workspace_folders() {
        Some(folders) if folders.length() >= 2 => {
          let mut text : String? = None
          let mut tooltip : String? = None
          let mut color : String? = None

          let resource = editor.document().uri()
          if resource.scheme() == "file" {
            match @workspace.get_workspace_folder(resource) {
              None => {
                text = Some(
                  "$(alert) <outside workspace> → \{basename(resource.fs_path())}",
                )
              }
              Some(folder) => {
                text = Some(
                  "$(file-submodule) \{basename(folder.uri().fs_path())} (\{folder.index() + 1} of \{folders.length()}) → $(file-code) \{basename(resource.fs_path())}",
                )
                tooltip = Some(resource.fs_path())

                let config = @workspace.get_configuration(
                  section="multiRootSample",
                  scope=@vscode.ConfigurationScope::Uri(resource),
                )
                color = config.get_string_option("statusColor")
              }
            }
          }

          Some({ text, tooltip, color, })
        }
        _ => None
      }
  }
}

fn update_status(status : @vscode.StatusBarItem) -> Unit {
  match get_editor_info() {
    None => {
      status.set_text("")
      status.clear_tooltip()
      status.clear_color()
      status.hide()
    }
    Some(info) => {
      match info.text {
        None => status.set_text("")
        Some(text) => status.set_text(text)
      }
      match info.tooltip {
        None => status.clear_tooltip()
        Some(tooltip) => status.set_tooltip(@vscode.Tooltip::Text(tooltip))
      }
      match info.color {
        None => status.clear_color()
        Some(color) => status.set_color(@vscode.ColorValue::Text(color))
      }
      status.show()
    }
  }
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let status = @window.create_status_bar_item(
    alignment=@vscode.StatusBarAlignment::Left,
    priority=1_000_000,
  )
  let subscriptions = ctx.subscriptions()

  subscriptions.push(
    @workspace.on_did_change_workspace_folders().subscribe(fn(_event) {
      update_status(status)
    }),
  )
  subscriptions.push(
    @workspace.on_did_change_configuration().subscribe(fn(_event) {
      update_status(status)
    }),
  )
  subscriptions.push(
    @window.on_did_change_active_text_editor().subscribe(fn(_event) {
      update_status(status)
    }),
  )
  subscriptions.push(
    @window.on_did_change_text_editor_view_column().subscribe(fn(_event) {
      update_status(status)
    }),
  )
  subscriptions.push(
    @workspace.on_did_open_text_document().subscribe(fn(_event) {
      update_status(status)
    }),
  )
  subscriptions.push(
    @workspace.on_did_close_text_document().subscribe(fn(_event) {
      update_status(status)
    }),
  )

  update_status(status)
}

pub fn deactivate() -> Unit {
  ()
}
