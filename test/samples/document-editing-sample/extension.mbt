///|
/// MoonBit port of `document-editing-sample`.
fn reverse_text(value : String) -> String {
  value.rev()
}

pub fn activate(context : @vscode.ExtensionContext) -> Unit {
  let disposable = @commands.register_command_async(
    "extension.reverseWord",
    async fn(_args) {
      match @window.active_text_editor() {
        None => ()
        Some(editor) => {
          let selection = editor.selection()
          let word = editor.document().get_text_range(
            @vscode.Range::new(selection.anchor(), selection.active()),
          )
          let reversed = reverse_text(word)
          ignore(editor.edit(fn(edit_builder) { edit_builder.replace_selection(selection, reversed) }))
        }
      }
    },
  )

  context.subscriptions().push(disposable)
}

pub fn deactivate() -> Unit {
  ()
}
