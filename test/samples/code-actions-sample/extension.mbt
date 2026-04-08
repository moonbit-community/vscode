///|
/// MoonBit port of `code-actions-sample`.
let command_id = "code-actions-sample.command"
let emoji_mention_code = "emoji_mention"
let emoji_word = "emoji"

fn create_replace_action(
  document : @vscode.TextDocument,
  range : @vscode.Range,
  emoji : String,
  preferred : Bool,
) -> @vscode.CodeAction {
  let action = @vscode.CodeAction::new(
    "Convert to \{emoji}",
    kind=@vscode.CodeActionKind::QuickFix,
  )
  let edit = @vscode.WorkspaceEdit::new()
  edit.replace(document.uri(), range, emoji)
  action.set_edit(edit)
  action.set_is_preferred(preferred)
  action
}

fn create_learn_more_action(
  kind : @vscode.CodeActionKind,
) -> @vscode.CodeAction {
  let action = @vscode.CodeAction::new("Learn more...", kind=kind)
  action.set_command(@vscode.Command::new(
      command_id,
      "Learn more about emojis",
      tooltip="This will open the unicode emoji page.",
    ))
  action
}

fn diagnostic_has_emoji_mention_code(diagnostic : @vscode.Diagnostic) -> Bool {
  match diagnostic.code() {
    None => false
    Some(code) =>
      match code.as_text() {
        None => false
        Some(value) => value == emoji_mention_code
      }
  }
}

fn create_emoji_diagnostic(
  line_of_text : @vscode.TextLine,
  line_index : Int,
) -> @vscode.Diagnostic? {
  let line_text = line_of_text.text
  let index = match line_text.find(emoji_word) {
    None => return None
    Some(value) => value
  }

  let range = @vscode.Range::new(
    @vscode.Position::new(line_index, index),
    @vscode.Position::new(line_index, index + emoji_word.length()),
  )
  let diagnostic = @vscode.Diagnostic::new(
    range,
    "When you say 'emoji', do you want to find out more?",
    severity=@vscode.DiagnosticSeverity::Information,
  )
  diagnostic.set_code(@vscode.DiagnosticCode::Text(emoji_mention_code))
  Some(diagnostic)
}

fn refresh_diagnostics(
  document : @vscode.TextDocument,
  collection : @vscode.DiagnosticCollection,
) -> Unit {
  let diagnostics : Array[@vscode.Diagnostic] = []
  for line_index in 0..<document.line_count() {
    match create_emoji_diagnostic(document.line_at_line(line_index), line_index) {
      None => ()
      Some(diagnostic) => diagnostics.push(diagnostic)
    }
  }
  collection.set(document.uri(), diagnostics)
}

fn subscribe_to_document_changes(
  context : @vscode.ExtensionContext,
  collection : @vscode.DiagnosticCollection,
) -> Unit {
  match @window.active_text_editor() {
    None => ()
    Some(editor) => refresh_diagnostics(editor.document(), collection)
  }

  let subscriptions = context.subscriptions()
  subscriptions.push(
    @window.on_did_change_active_text_editor().subscribe(fn(editor) {
      match editor {
        None => ()
        Some(next_editor) => refresh_diagnostics(next_editor.document(), collection)
      }
    }),
  )
  subscriptions.push(
    @workspace.on_did_change_text_document().subscribe(fn(event) {
      refresh_diagnostics(event.document, collection)
    }),
  )
  subscriptions.push(
    @workspace.on_did_close_text_document().subscribe(fn(document) {
      collection.delete(document.uri())
    }),
  )
}

priv struct Emojizer {}

impl @vscode.CodeActionProvider for Emojizer with provide_code_actions(
  _self,
  document,
  range,
  _context,
  _token,
) {
  let start = range.start()
  let smile_range = @vscode.Range::new(
    start,
    start.translate(character_delta=2),
  )
  if document.get_text_range(smile_range) != ":)" {
    return None
  }

  Some([
    create_replace_action(document, smile_range, "😺", false),
    create_replace_action(document, smile_range, "😀", true),
    create_replace_action(document, smile_range, "💩", false),
    create_learn_more_action(@vscode.CodeActionKind::Empty),
  ])
}

impl @vscode.CodeActionProvider for Emojizer with resolve_code_action(
  _self,
  _action,
  _token,
) {
  None
}

priv struct Emojinfo {}

impl @vscode.CodeActionProvider for Emojinfo with provide_code_actions(
  _self,
  _document,
  _range,
  context,
  _token,
) {
  let actions : Array[@vscode.CodeAction] = []
  for diagnostic in context.diagnostics {
    if diagnostic_has_emoji_mention_code(diagnostic) {
      let action = create_learn_more_action(@vscode.CodeActionKind::QuickFix)
      action.set_diagnostics([diagnostic])
      action.set_is_preferred(true)
      actions.push(action)
    }
  }
  if actions.length() == 0 {
    None
  } else {
    Some(actions)
  }
}

impl @vscode.CodeActionProvider for Emojinfo with resolve_code_action(
  _self,
  _action,
  _token,
) {
  None
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  subscriptions.push(
    @languages.register_code_actions_provider(
      @vscode.DocumentSelector::Language("markdown"),
      Emojizer::{},
      metadata=@vscode.CodeActionProviderMetadata::new(
        provided_kinds=[@vscode.CodeActionKind::QuickFix],
      ),
    ),
  )

  let emoji_diagnostics = @languages.create_diagnostic_collection(name="emoji")
  subscriptions.push(emoji_diagnostics.as_disposable())
  subscribe_to_document_changes(ctx, emoji_diagnostics)

  subscriptions.push(
    @languages.register_code_actions_provider(
      @vscode.DocumentSelector::Language("markdown"),
      Emojinfo::{},
      metadata=@vscode.CodeActionProviderMetadata::new(
        provided_kinds=[@vscode.CodeActionKind::QuickFix],
      ),
    ),
  )

  subscriptions.push(
    @commands.register_command_async(command_id, async fn(_args) {
      ignore(
        @env.open_external(
          @vscode.Uri::parse(
            "https://unicode.org/emoji/charts-12.0/full-emoji-list.html",
          ),
        ),
      )
    }),
  )
}

pub fn deactivate() -> Unit {
  ()
}
