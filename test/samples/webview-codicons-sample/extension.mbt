///|
/// MoonBit port of `webview-codicons-sample`.
fn codicon_html() -> String {
  [
    "<!DOCTYPE html>",
    "<html lang=\"en\">",
    "<head>",
    "  <meta charset=\"UTF-8\" />",
    "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />",
    "  <style>",
    "    body { font-family: sans-serif; padding: 16px; }",
    "    .icon-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; }",
    "    .tile { border: 1px solid var(--vscode-editorWidget-border); padding: 12px; border-radius: 6px; text-align: center; }",
    "    .codicon { font-size: 24px; display: block; margin-bottom: 8px; }",
    "  </style>",
    "</head>",
    "<body>",
    "  <h2>Codicon Sample</h2>",
    "  <div class=\"icon-grid\">",
    "    <div class=\"tile\"><span class=\"codicon codicon-github\"></span>github</div>",
    "    <div class=\"tile\"><span class=\"codicon codicon-terminal\"></span>terminal</div>",
    "    <div class=\"tile\"><span class=\"codicon codicon-beaker\"></span>beaker</div>",
    "    <div class=\"tile\"><span class=\"codicon codicon-zap\"></span>zap</div>",
    "  </div>",
    "</body>",
    "</html>",
  ].join("\n")
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let show = @commands.register_command(
    "catCodicons.show",
    fn(_args) {
      let panel = @window.create_webview_panel(
        "catCodicons",
        "Cat Codicons",
        @vscode.ViewColumn::One,
      )
      let webview = panel.webview()
      webview.set_options(@vscode.WebviewOptions::new(enable_scripts=true))
      webview.set_html(codicon_html())
    },
  )
  subscriptions.push(show)
}

pub fn deactivate() -> Unit {
  ()
}
