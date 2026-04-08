///|
/// MoonBit port of `diagnostic-related-information-sample`.
fn path_basename(value : String) -> String {
  let mut start = 0
  for i, c in value {
    if c == '/' || c == '\\' {
      start = i + 1
    }
  }
  value.unsafe_substring(start=start, end=value.length())
}

fn update_diagnostics(
  document : @vscode.TextDocument,
  collection : @vscode.DiagnosticCollection,
) -> Unit {
  if path_basename(document.uri().fs_path()) == "sample-demo.rs" {
    let range = @vscode.Range::new(
      @vscode.Position::new(3, 4),
      @vscode.Position::new(3, 10),
    )
    let diagnostic = @vscode.Diagnostic::new(
      range,
      "cannot assign twice to immutable variable `x`",
      severity=@vscode.DiagnosticSeverity::Error,
    )
    diagnostic.set_related_information([
      @vscode.DiagnosticRelatedInformation::new(
        @vscode.Location::new(
          document.uri(),
          @vscode.Range::new(
            @vscode.Position::new(1, 8),
            @vscode.Position::new(1, 9),
          ),
        ),
        "first assignment to `x`",
      ),
    ])
    collection.set(document.uri(), [diagnostic])
  } else {
    collection.clear()
  }
}

pub fn activate(context : @vscode.ExtensionContext) -> Unit {
  let subscriptions = context.subscriptions()
  let collection = @languages.create_diagnostic_collection(name="test")

  match @window.active_text_editor() {
    Some(editor) => update_diagnostics(editor.document(), collection)
    None => ()
  }

  subscriptions.push(
    @window.on_did_change_active_text_editor().subscribe(fn(editor) {
      match editor {
        Some(active_editor) => update_diagnostics(active_editor.document(), collection)
        None => ()
      }
    }),
  )
}

pub fn deactivate() -> Unit {
  ()
}
