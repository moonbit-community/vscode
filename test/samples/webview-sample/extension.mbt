///|
/// MoonBit port of `webview-sample`.
let coding_cat = "https://media.giphy.com/media/JIX9t2j0ZTN9S/giphy.gif"
let compiling_cat = "https://media.giphy.com/media/mlvseq9yvZhba/giphy.gif"
let testing_cat = "https://media.giphy.com/media/3oriO0OEd9QIDdllqo/giphy.gif"

priv struct CatState {
  mut current_panel : @vscode.WebviewPanel?
  mut extension_uri : @vscode.Uri?
}

let cat_state : CatState = {
  current_panel: None,
  extension_uri: None,
}

fn get_nonce() -> String {
  "moonbit-cat-coding-nonce"
}

fn message_command(value : @vscode.Any) -> String? {
  value.object_get_string("command")
}

fn message_text(value : @vscode.Any) -> String? {
  value.object_get_string("text")
}

fn refactor_message() -> @vscode.Any {
  @vscode.Any::empty_object().object_with_string("command", "refactor")
}

fn empty_message() -> @vscode.Any {
  @vscode.Any::empty_object()
}

fn show_error_message(message : String) -> Unit {
  let _ = @js_async.Promise::from_async(async fn() {
    @window.show_error_message(message)
  })
}

fn get_webview_options(extension_uri : @vscode.Uri) -> @vscode.WebviewOptions {
  @vscode.WebviewOptions::new(
    enable_scripts=true,
    local_resource_roots=[@vscode.Uri::join_path(extension_uri, ["media"])],
  )
}

fn view_column_value(column : @vscode.ViewColumn) -> Int {
  match column {
    @vscode.ViewColumn::Active => -1
    @vscode.ViewColumn::Beside => -2
    @vscode.ViewColumn::One => 1
    @vscode.ViewColumn::Two => 2
    @vscode.ViewColumn::Three => 3
    @vscode.ViewColumn::Four => 4
    @vscode.ViewColumn::Five => 5
    @vscode.ViewColumn::Six => 6
    @vscode.ViewColumn::Seven => 7
    @vscode.ViewColumn::Eight => 8
    @vscode.ViewColumn::Nine => 9
    @vscode.ViewColumn::Custom(value) => value
  }
}

fn cat_for_column(column : @vscode.ViewColumn?) -> (String, String) {
  match column {
    Some(value) =>
      match view_column_value(value) {
        2 => ("Compiling Cat", compiling_cat)
        3 => ("Testing Cat", testing_cat)
        _ => ("Coding Cat", coding_cat)
      }
    None => ("Coding Cat", coding_cat)
  }
}

fn webview_html(
  panel : @vscode.WebviewPanel,
  extension_uri : @vscode.Uri,
  cat_gif_path : String,
) -> String {
  let webview = panel.webview()
  let script_uri = webview.as_webview_uri(
    @vscode.Uri::join_path(extension_uri, ["media", "main.js"]),
  )
  let style_reset_uri = webview.as_webview_uri(
    @vscode.Uri::join_path(extension_uri, ["media", "reset.css"]),
  )
  let style_main_uri = webview.as_webview_uri(
    @vscode.Uri::join_path(extension_uri, ["media", "vscode.css"]),
  )
  let nonce = get_nonce()

  [
    "<!DOCTYPE html>",
    "<html lang=\"en\">",
    "<head>",
    "  <meta charset=\"UTF-8\">",
    "  <meta http-equiv=\"Content-Security-Policy\" content=\"default-src 'none'; style-src \{webview.csp_source()}; img-src \{webview.csp_source()} https:; script-src 'nonce-\{nonce}';\">",
    "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">",
    "  <link href=\"\{style_reset_uri.to_string()}\" rel=\"stylesheet\">",
    "  <link href=\"\{style_main_uri.to_string()}\" rel=\"stylesheet\">",
    "  <title>Cat Coding</title>",
    "</head>",
    "<body>",
    "  <img src=\"\{cat_gif_path}\" width=\"300\" />",
    "  <h1 id=\"lines-of-code-counter\">0</h1>",
    "  <script nonce=\"\{nonce}\" src=\"\{script_uri.to_string()}\"></script>",
    "</body>",
    "</html>",
  ].join("\n")
}

fn update_current_panel() -> Unit {
  match cat_state.current_panel {
    None => ()
    Some(panel) =>
      match cat_state.extension_uri {
        None => ()
        Some(extension_uri) => {
          let (cat_name, cat_path) = cat_for_column(panel.view_column())
          panel.set_title(cat_name)
          panel.webview().set_html(webview_html(panel, extension_uri, cat_path))
        }
      }
  }
}

fn wire_panel(panel : @vscode.WebviewPanel, extension_uri : @vscode.Uri) -> Unit {
  panel.webview().set_options(get_webview_options(extension_uri))
  cat_state.current_panel = Some(panel)
  cat_state.extension_uri = Some(extension_uri)
  update_current_panel()

  ignore(panel.on_did_dispose().subscribe(fn(_event) {
    cat_state.current_panel = None
  }))

  ignore(panel.on_did_change_view_state().subscribe(fn(_event) {
    if panel.visible() {
      update_current_panel()
    }
  }))

  ignore(panel.webview().on_did_receive_message().subscribe(fn(message) {
    match message_command(message) {
      Some("alert") =>
        match message_text(message) {
          Some(text) => show_error_message(text)
          None => ()
        }
      _ => ()
    }
  }))
}

fn create_or_show(extension_uri : @vscode.Uri) -> Unit {
  let target_column = match @window.active_text_editor() {
    None => @vscode.ViewColumn::One
    Some(editor) => match editor.view_column() {
      None => @vscode.ViewColumn::One
      Some(value) => value
    }
  }

  match cat_state.current_panel {
    Some(panel) => panel.reveal(view_column=target_column)
    None => {
      let panel = @window.create_webview_panel(
        "catCoding",
        "Cat Coding",
        target_column,
        options=@vscode.WebviewPanelOptions::new(),
      )
      wire_panel(panel, extension_uri)
    }
  }
}

async fn do_refactor() -> Unit {
  match cat_state.current_panel {
    None => ()
    Some(panel) => {
      ignore(panel.webview().post_message(refactor_message()))
    }
  }
}

pub fn activate(context : @vscode.ExtensionContext) -> Unit {
  let subscriptions = context.subscriptions()
  let extension_uri = context.extension_uri()

  subscriptions.push(
    @commands.register_command("catCoding.start", fn(_args) {
      create_or_show(extension_uri)
    }),
  )

  subscriptions.push(
    @commands.register_command_async("catCoding.doRefactor", async fn(_args) {
      do_refactor()
    }),
  )

  let serializer = @vscode.WebviewPanelSerializer::new(
    async fn(panel, _state) {
      wire_panel(panel, extension_uri)
      ignore(panel.webview().post_message(empty_message()))
    },
  )
  subscriptions.push(
    @window.register_webview_panel_serializer("catCoding", serializer),
  )
}

pub fn deactivate() -> Unit {
  ()
}
