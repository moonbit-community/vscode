///|
/// MoonBit port of `wasm-language-server`.
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  subscriptions.push(
    @commands.register_command_async(
      "vscode-samples.wasm-language-server.countFiles",
      async fn(_args) {
        match @workspace.workspace_folders() {
          None =>
            ignore(@window.show_warning_message("Open a workspace folder first."))
          Some([]) =>
            ignore(@window.show_warning_message("Open a workspace folder first."))
          Some([folder, ..]) => {
            let pattern = @vscode.GlobPattern::Relative(
              @vscode.RelativePattern::from_path(folder.uri().fs_path(), "**/*"),
            )
            let files = @workspace.find_files_no_excludes(pattern, max_results=100000)
            ignore(
              @window.show_information_message(
                "The workspace contains \{files.length()} files.",
              ),
            )
          }
        }
      },
    ),
  )
}

pub fn deactivate() -> Unit {
  ()
}
