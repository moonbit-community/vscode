///|
/// MoonBit port of `helloworld-web-sample`.
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let disposable = @commands.register_command_async(
    "helloworld-web-sample.helloWorld",
    async fn(_args) {
      ignore(
        @window.show_information_message(
          "Hello World from helloworld-web-sample in a web extension host!",
        ),
      )
    },
  )
  subscriptions.push(disposable)
}

pub fn deactivate() -> Unit {
  ()
}
