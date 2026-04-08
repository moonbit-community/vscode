///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  println("Congratulations, your extension \"helloworld-minimal-sample\" is now active!")
  let subscriptions = ctx.subscriptions()
  let disposable = @commands.register_command_async("extension.helloWorld", async fn(
    _args,
  ) {
    @window.show_information_message("Hello World!")
  })
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
