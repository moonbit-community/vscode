///|
/// MoonBit port of `chat-context-sample`.
fn path_basename(path : String) -> String {
  let mut start = 0
  for i, ch in path {
    if ch == '/' || ch == '\\' {
      start = i + 1
    }
  }
  if start >= path.length() {
    "unknown"
  } else {
    path.unsafe_substring(start=start, end=path.length())
  }
}

fn find_document(resource : @vscode.Uri) -> @vscode.TextDocument? {
  for document in @workspace.text_documents() {
    if document.uri().to_string() == resource.to_string() {
      return Some(document)
    }
  }
  None
}

pub fn activate(context : @vscode.ExtensionContext) -> Unit {
  let subscriptions = context.subscriptions()
  subscriptions.push(
    @chat.register_chat_context_provider(
      @vscode.DocumentSelector::from_filters([
        @vscode.DocumentFilter::new(language="json"),
        @vscode.DocumentFilter::new(language="jsonc"),
      ]),
      "chat-context-sample.jsonLineCount",
      fn(resource, _token) {
        match find_document(resource) {
          None => None
          Some(document) => {
            let line_count = document.line_count()
            let file_name = path_basename(resource.path())
            Some(
              @vscode.Any::empty_object()
                .object_with_string("label", "\{file_name}: \{line_count} lines")
                .object_with_string(
                  "modelDescription",
                  "The JSON file \"\{file_name}\" has \{line_count} lines.",
                )
                .object_with_string(
                  "value",
                  "File: \{file_name}\nLine count: \{line_count}",
                ),
            )
          }
        }
      },
      resolve_chat_context=fn(context, _token) { Some(context) },
    ),
  )
}

pub fn deactivate() -> Unit {
  ()
}
