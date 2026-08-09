///|
pub struct EditorInfo {
  text : String?
  tooltip : String?
  color : String?
}

///|
fn basename(path : String) -> String {
  let normalized = path.replace_all(old="\\", new="/")
  let parts = normalized.split("/").to_array()
  match parts.last() {
    Some(name) => name.to_owned()
    None => path
  }
}

///|
fn set_status(status : @vscode.StatusBarItem, info : EditorInfo?) -> Unit {
  match info {
    None => {
      status.hide()
    }
    Some(info) => {
      status.set_text(match info.text {
        Some(text) => text
        None => ""
      })
      match info.tooltip {
        Some(tooltip) => status.set_tooltip(@vscode.Tooltip::Text(tooltip))
        None => status.clear_tooltip()
      }
      match info.color {
        Some(color) => status.set_color(@vscode.ColorValue::Text(color))
        None => status.clear_color()
      }
      status.show()
    }
  }
}

///|
fn current_editor_info() -> EditorInfo? {
  let editor = @window.active_text_editor()
  let workspace_folders = @workspace.workspace_folders()
  match (editor, workspace_folders) {
    (Some(editor), Some(workspace_folders)) if workspace_folders.length() >= 2 => {
      let resource = editor.document().uri()
      if resource.scheme() != "file" {
        return Some(EditorInfo::{ text: None, tooltip: None, color: None })
      }
      let file_name = basename(resource.fs_path())
      match @workspace.get_workspace_folder(resource) {
        None =>
          Some(
            EditorInfo::{
              text: Some("$(alert) <outside workspace> → \{file_name}"),
              tooltip: None,
              color: None,
            },
          )
        Some(folder) => {
          let folder_name = basename(folder.uri().fs_path())
          let color = @workspace.get_configuration(
            section="multiRootSample",
            scope=@vscode.ConfigurationScope::Uri(resource),
          ).get_string_option("statusColor")
          Some(
            EditorInfo::{
              text: Some(
                "$(file-submodule) \{folder_name} (\{folder.index() + 1} of \{workspace_folders.length()}) → $(file-code) \{file_name}",
              ),
              tooltip: Some(resource.fs_path()),
              color,
            },
          )
        }
      }
    }
    _ => None
  }
}

///|
fn update_status(status : @vscode.StatusBarItem) -> Unit {
  set_status(status, current_editor_info())
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let status = @window.create_status_bar_item(
    alignment=@vscode.StatusBarAlignment::Left,
    priority=1000000,
  )
  ctx.subscribe(status)
  ctx.subscribe(@workspace.on_did_change_workspace_folders().subscribe(_ => {
    update_status(status)
  }))
  ctx.subscribe(@workspace.on_did_change_configuration().subscribe(_ => {
    update_status(status)
  }))
  ctx.subscribe(@window.on_did_change_active_text_editor().subscribe(_ => {
    update_status(status)
  }))
  ctx.subscribe(@window.on_did_change_text_editor_view_column().subscribe(_ => {
    update_status(status)
  }))
  ctx.subscribe(@workspace.on_did_open_text_document().subscribe(_ => {
    update_status(status)
  }))
  ctx.subscribe(@workspace.on_did_close_text_document().subscribe(_ => {
    update_status(status)
  }))
  update_status(status)
}
