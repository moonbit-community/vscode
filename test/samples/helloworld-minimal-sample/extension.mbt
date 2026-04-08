///|
/// MoonBit port of `helloworld-minimal-sample`.
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let disposable = @commands.register_command_async("extension.helloWorld", async fn(
    _args,
  ) {
    ignore(@window.show_information_message("Hello World!"))
  })
  ctx.subscriptions().push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
