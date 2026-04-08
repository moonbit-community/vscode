///|
/// MoonBit port of `uri-handler-sample`.
fn uri_message(uri : @vscode.Uri) -> String {
  let query = uri.query()
  if query == "" {
    "Handled a Uri!"
  } else {
    "Handled a Uri! It came with this query: \{query}"
  }
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "uri-handler-sample.start",
    async fn(_args) {
      let handler = @vscode.UriHandler::new(async fn(uri) {
        ignore(@window.show_information_message(uri_message(uri)))
      })

      let handler_disposable = @window.register_uri_handler(handler)
      subscriptions.push(handler_disposable)

      let test_uri = @vscode.Uri::parse(
        "\{@env.uri_scheme()}://vscode-samples.uri-handler-sample",
      )
      let external_uri = @env.as_external_uri(test_uri)
      ignore(
        @window.show_information_message(
          "Starting to handle Uris. Open \{external_uri.to_string()} in your browser to test.",
        ),
      )
    },
  )

  subscriptions.push(disposable)
}

pub fn deactivate() -> Unit {
  ()
}
