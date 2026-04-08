///|
/// MoonBit port of `welcome-view-content-sample`.
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let disposable = @commands.register_command_async(
    "welcome-view-content-sample.hello",
    async fn(_args) {
      ignore(@window.show_information_message("Hello world!"))
    },
  )
  subscriptions.push(disposable)
}

pub fn deactivate() -> Unit {
  ()
}
