///|
/// MoonBit port of `jupyter-server-provider-sample`.
async fn warm_up_jupyter_extension() -> Unit {
  let extension : @vscode.Extension[@vscode.Any]? = @extensions.get_extension(
    "ms-toolsai.jupyter",
  )
  match extension {
    None => ()
    Some(extension) => {
      if !extension.is_active() {
        ignore(extension.activate())
      }
    }
  }
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  @vscode.activate_async(ctx, async fn(_context) {
    warm_up_jupyter_extension()
  })
}

pub fn deactivate() -> Unit {
  ()
}
