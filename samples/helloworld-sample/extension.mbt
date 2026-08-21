///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  println(
    "Congratulations, your extension \"helloworld-sample\" is now active!",
  )
  ctx.subscribe(
    @commands.register_command_async("extension.helloWorld", async fn(_args) {
      @window.show_information_message("Hello World!")
    }),
  )
}

///|
pub fn deactivate() -> Unit {
  ()
}
