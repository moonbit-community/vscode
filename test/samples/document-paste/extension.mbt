///|
/// MoonBit port of `document-paste`.
let copy_count_mime_type = "application/vnd.code.copydemo-copy-count"

fn copy_count_kind() -> @vscode.DocumentDropOrPasteEditKind {
  @vscode.DocumentDropOrPasteEditKind::Empty.append("text").append("custom").append(
    "count",
  )
}

priv struct CopyCountPasteProvider {
  mut count : Int
  kind : @vscode.DocumentDropOrPasteEditKind
  count_mime_type : String
}

impl @vscode.DocumentPasteEditProvider for CopyCountPasteProvider with provide_document_paste_edits(
  self,
  _document,
  _ranges,
  data_transfer,
  _context,
  token,
) {
  let count_value = match data_transfer.get(self.count_mime_type) {
    None => {
      let value = self.count.to_string()
      self.count = self.count + 1
      value
    }
    Some(item) => {
      let value = item.as_string()
      if token.is_cancellation_requested {
        return None
      }
      value
    }
  }

  match data_transfer.get("text/plain") {
    None => None
    Some(item) => {
      let text_value = item.as_string()
      if token.is_cancellation_requested {
        None
      } else {
        let snippet = @vscode.SnippetString::new("")
        ignore(snippet.append_text("(copy #\{count_value}) \{text_value}"))
        Some(
          @vscode.DocumentPasteEdit::new(
            @vscode.StringOrSnippetString::Snippet(snippet),
            "Insert with copy count sample",
            self.kind,
          ),
        )
      }
    }
  }
}

impl @vscode.DocumentPasteEditProvider for CopyCountPasteProvider with metadata(_self) {
  None
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let selector = @vscode.DocumentSelector::Language("plaintext")
  let kind = copy_count_kind()
  let provider = CopyCountPasteProvider::{
    count: 0,
    kind,
    count_mime_type: copy_count_mime_type,
  }
  subscriptions.push(
    @languages.register_document_paste_edit_provider(
      selector,
      provider,
      @vscode.DocumentPasteProviderMetadata::new(
        [kind],
        copy_mime_types=[copy_count_mime_type],
        paste_mime_types=["text/plain", copy_count_mime_type],
      ),
    ),
  )
}

pub fn deactivate() -> Unit {
  ()
}
