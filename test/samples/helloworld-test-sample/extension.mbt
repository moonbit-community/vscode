///|
/// MoonBit port of `helloworld-test-sample`.
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let disposable = @commands.register_command_async(
    "extension.helloWorld",
    async fn(_args) {
      ignore(@window.show_information_message("Hello World!"))
    },
  )
  subscriptions.push(disposable)
}

pub fn deactivate() -> Unit {
  ()
}
