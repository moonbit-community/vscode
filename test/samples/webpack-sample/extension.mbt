///|
/// MoonBit port of `webpack-sample`.
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let disposable = @commands.register_command_async(
    "extension.helloWebpack",
    async fn(_args) {
      ignore(@window.show_information_message("41 + 1 = 42"))
    },
  )
  ctx.subscriptions().push(disposable)
}

pub fn deactivate() -> Unit {
  ()
}
