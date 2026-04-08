///|
/// MoonBit port of `lsp-log-streaming-sample`.
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  subscriptions.push(
    @commands.register_command_async(
      "languageServerExample.startStreaming",
      async fn(_args) {
        ignore(
          @window.show_information_message(
            "Log streaming sample command triggered. Configure languageServerExample.port and run the full JS client/server sample to stream LSP logs.",
          ),
        )
      },
    ),
  )
}

pub fn deactivate() -> Unit {
  ()
}
