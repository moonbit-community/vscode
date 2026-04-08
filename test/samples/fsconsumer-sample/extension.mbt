///|
/// MoonBit port of `fsconsumer-sample`.
fn to_js_path(path : String) -> String {
  if path.has_suffix(".ts") {
    "\{path.unsafe_substring(start=0, end=path.length() - 3)}.js"
  } else {
    path
  }
}

fn first_workspace_folder_uri() -> @vscode.Uri? {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => Some(folder.uri())
    _ => None
  }
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let fs = @workspace.fs()

  let open_js = @commands.register_command_async(
    "fs/openJS",
    async fn(_args) {
      match @window.active_text_editor() {
        None => ignore(@window.show_information_message("Open a TypeScript file first"))
        Some(editor) => {
          let ts_uri = editor.document().uri()
          let js_uri = @vscode.Uri::file(to_js_path(ts_uri.fs_path()))
          try {
            ignore(fs.stat(js_uri))
            let doc = @workspace.open_text_document_uri(js_uri)
            ignore(@window.show_text_document(doc))
          } catch {
            _ => {
              ignore(
                @window.show_information_message(
                  "\{js_uri.to_string()} file does *not* exist",
                ),
              )
            }
          }
        }
      }
    },
  )
  subscriptions.push(open_js)

  let sum_sizes = @commands.register_command_async(
    "fs/sumSizes",
    async fn(_args) {
      match first_workspace_folder_uri() {
        None => ignore(@window.show_information_message("Open a folder first"))
        Some(root) => {
          let mut total = 0
          let entries = fs.read_directory(root)
          for entry in entries {
            let uri = @vscode.Uri::join_path(root, [entry.name])
            try {
              let stat = fs.stat(uri)
              total = total + stat.size
            } catch {
              _ => ()
            }
          }
          ignore(@window.show_information_message("Total size: \{total} bytes"))
        }
      }
    },
  )
  subscriptions.push(sum_sizes)

  let read_write = @commands.register_command_async(
    "fs/readWriteFile",
    async fn(_args) {
      match first_workspace_folder_uri() {
        None =>
          ignore(@window.show_information_message("No folder or workspace opened"))
        Some(root) => {
          let uri = @vscode.Uri::join_path(root, ["moonbit-fsconsumer.txt"])
          fs.write_file(uri, @workspace.encode("MoonBit fsconsumer sample"))
          let content = @workspace.decode(fs.read_file(uri))
          ignore(@window.show_information_message(content))
        }
      }
    },
  )
  subscriptions.push(read_write)
}

pub fn deactivate() -> Unit {
  ()
}
