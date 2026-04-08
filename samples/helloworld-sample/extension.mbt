///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  println("Congratulations, your extension \"helloworld-sample\" is now active!")
  let subscriptions = ctx.subscriptions()
  subscriptions.push(@commands.register_command_async("extension.helloWorld", async fn(
    _args,
  ) {
    @window.show_information_message("Hello World!")
  }))
}
