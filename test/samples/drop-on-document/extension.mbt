///|
/// MoonBit port of `drop-on-document`.
fn reverse_text(value : String) -> String {
  value.rev()
}

///|
fn trim_trailing_cr(value : String) -> String {
  if value.has_suffix("\r") {
    value.unsafe_substring(start=0, end=value.length() - 1)
  } else {
    value
  }
}

fn path_basename(value : String) -> String {
  let mut start = 0
  for i, c in value {
    if c == '/' || c == '\\' {
      start = i + 1
    }
  }
  value.unsafe_substring(start=start, end=value.length())
}

fn uri_list_to_names(uri_list : String) -> Array[String] {
  let names : Array[String] = []
  for raw_line in uri_list.split("\n") {
    let raw = trim_trailing_cr(raw_line.to_string())
    if raw == "" {
      continue
    }
    if raw.has_prefix("file://") || raw.has_prefix("untitled:") {
      let parsed = @vscode.Uri::parse(raw)
      names.push(path_basename(parsed.path()))
    } else {
      names.push(raw)
    }
  }
  names
}

priv struct ReverseDropProvider {}

impl @vscode.DocumentDropEditProvider for ReverseDropProvider with provide_document_drop_edits(
  _self,
  _document,
  _position,
  data_transfer,
  token,
) {
  match data_transfer.get("text/plain") {
    None => None
    Some(item) => {
      let text = item.as_string()
      if token.is_cancellation_requested {
        None
      } else {
        Some(
          @vscode.DocumentDropEdit::new(
            @vscode.StringOrSnippetString::Text(reverse_text(text)),
          ),
        )
      }
    }
  }
}

impl @vscode.DocumentDropEditProvider for ReverseDropProvider with metadata(_self) {
  None
}

priv struct FilesDropProvider {}

impl @vscode.DocumentDropEditProvider for FilesDropProvider with provide_document_drop_edits(
  _self,
  _document,
  _position,
  data_transfer,
  token,
) {
  match data_transfer.get("text/uri-list") {
    None => None
    Some(item) => {
      let uri_list = item.as_string()
      if token.is_cancellation_requested {
        None
      } else {
        let names = uri_list_to_names(uri_list)
        if names.length() == 0 {
          None
        } else {
          let snippet = @vscode.SnippetString::new("")
          for i in 0..<names.length() {
            ignore(snippet.append_text("\{i + 1}. \{names[i]}"))
            ignore(snippet.append_tabstop())
            if names.length() > 1 && i < names.length() - 1 {
              ignore(snippet.append_text("\n"))
            }
          }
          Some(
            @vscode.DocumentDropEdit::new(
              @vscode.StringOrSnippetString::Snippet(snippet),
            ),
          )
        }
      }
    }
  }
}

impl @vscode.DocumentDropEditProvider for FilesDropProvider with metadata(_self) {
  Some(@vscode.DocumentDropEditProviderMetadata::new(["text/uri-list"]))
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let selector = @vscode.DocumentSelector::Language("plaintext")

  subscriptions.push(
    @languages.register_document_drop_edit_provider(selector, ReverseDropProvider::{}),
  )

  subscriptions.push(
    @languages.register_document_drop_edit_provider(
      selector,
      FilesDropProvider::{},
      metadata=@vscode.DocumentDropEditProviderMetadata::new(["text/uri-list"]),
    ),
  )
}

pub fn deactivate() -> Unit {
  ()
}
