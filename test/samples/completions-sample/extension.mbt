///|
/// MoonBit port of `completions-sample`.
pub fn line_prefix(text : String, upto : Int) -> String {
  let end = if upto < 0 {
    0
  } else if upto > text.length() {
    text.length()
  } else {
    upto
  }
  text.unsafe_substring(start=0, end=end)
}

priv struct CompletionProviderOne {}

impl @vscode.CompletionItemProvider for CompletionProviderOne with provide_completion_items(
  _self,
  _document,
  _position,
  _token,
  _context,
) {
  let simple_completion = @vscode.CompletionItem::from_text("Hello World!")

  let snippet_completion = @vscode.CompletionItem::from_text("Good part of the day")
  snippet_completion.set_insert_text(
    @vscode.StringOrSnippetString::Snippet(
      @vscode.SnippetString::new(
        "Good ${1|morning,afternoon,evening|}. It is ${1}, right?",
      ),
    ),
  )
  let docs = @vscode.MarkdownString::new(
    value="Inserts a snippet that lets you select [link](x.ts).",
  )
  docs.set_base_uri(@vscode.Uri::parse("http://example.com/a/b/c/"))
  snippet_completion.set_documentation(@vscode.MarkdownStringValue::Markdown(docs))

  let commit_character_completion = @vscode.CompletionItem::from_text("console")
  commit_character_completion.set_commit_characters(["."])
  commit_character_completion.set_documentation(
    @vscode.MarkdownStringValue::Text("Press `.` to get `console.`"),
  )

  let command_completion = @vscode.CompletionItem::from_text("new")
  command_completion.set_kind(@vscode.CompletionItemKind::Keyword)
  command_completion.set_insert_text(@vscode.StringOrSnippetString::Text("new "))
  command_completion.set_command(@vscode.Command::new(
      "Re-trigger completions...",
      "editor.action.triggerSuggest",
    ))

  Some([
    simple_completion,
    snippet_completion,
    commit_character_completion,
    command_completion,
  ])
}

impl @vscode.CompletionItemProvider for CompletionProviderOne with resolve_completion_item(
  _self,
  _item,
  _token,
) {
  None
}

priv struct CompletionProviderTwo {}

impl @vscode.CompletionItemProvider for CompletionProviderTwo with provide_completion_items(
  _self,
  document,
  position,
  _token,
  _context,
) {
  let prefix = line_prefix(
    document.line_at_position(position).text,
    position.character(),
  )
  if !prefix.has_suffix("console.") {
    None
  } else {
    Some([
      @vscode.CompletionItem::from_text(
        "log",
        kind=@vscode.CompletionItemKind::Method,
      ),
      @vscode.CompletionItem::from_text(
        "warn",
        kind=@vscode.CompletionItemKind::Method,
      ),
      @vscode.CompletionItem::from_text(
        "error",
        kind=@vscode.CompletionItemKind::Method,
      ),
    ])
  }
}

impl @vscode.CompletionItemProvider for CompletionProviderTwo with resolve_completion_item(
  _self,
  _item,
  _token,
) {
  None
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let provider1 = @languages.register_completion_item_provider(
    @vscode.DocumentSelector::Language("plaintext"),
    CompletionProviderOne::{},
  )
  let provider2 = @languages.register_completion_item_provider(
    @vscode.DocumentSelector::Language("plaintext"),
    CompletionProviderTwo::{},
    trigger_characters=["."],
  )
  subscriptions.push(provider1)
  subscriptions.push(provider2)
}

pub fn deactivate() -> Unit {
  ()
}
