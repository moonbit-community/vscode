///|
/// MoonBit port of `l10n-sample`.
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let hello = @commands.register_command_async(
    "extension.sayHello",
    async fn(_args) {
      ignore(@window.show_information_message(@l10n.t("Hello")))
      ignore(
        @window.show_information_message(
          @l10n.t_named(
            "Hello {done}",
            [("done", @vscode.Any::from("FINISHED"))],
          ),
        ),
      )
    },
  )
  subscriptions.push(hello)

  let bye = @commands.register_command_async(
    "extension.sayBye",
    async fn(_args) {
      ignore(@window.show_information_message(@l10n.t("Bye")))
    },
  )
  subscriptions.push(bye)
}

pub fn deactivate() -> Unit {
  ()
}
