///|
/// MoonBit port of `custom-editor-sample`.
async fn create_paw_draw_document() -> Unit {
  let uri = @vscode.Uri::parse("untitled:cat-custom.pawdraw")
  let document = @workspace.open_text_document_uri(uri)
  ignore(@window.show_text_document(document))
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let disposable = @commands.register_command_async(
    "catCustoms.pawDraw.new",
    async fn(_args) {
      create_paw_draw_document()
    },
  )
  ctx.subscriptions().push(disposable)
}

pub fn deactivate() -> Unit {
  ()
}
