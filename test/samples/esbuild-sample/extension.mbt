///|
/// MoonBit port of `esbuild-sample`.
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let disposable = @commands.register_command_async(
    "esbuild-sample.hello-esbuild",
    async fn(_args) {
      ignore(@window.show_information_message("41 + 1 = 42"))
    },
  )
  subscriptions.push(disposable)
}

pub fn deactivate() -> Unit {
  ()
}
