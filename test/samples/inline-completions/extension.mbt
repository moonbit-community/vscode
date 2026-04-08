///|
/// MoonBit port of `inline-completions`.
priv struct InlineCompletionsProvider {}

impl @vscode.InlineCompletionItemProvider for InlineCompletionsProvider with provide_inline_completion_items(
  _self,
  document,
  position,
  _context,
  _token,
) {
  if position.line() <= 0 {
    None
  } else {
    let previous = document.line_at_line(position.line() - 1).text
    if !previous.has_prefix("// [") {
      None
    } else {
      let line = document.line_at_line(position.line()).text
      let range = @vscode.Range::new(
        @vscode.Position::new(position.line(), position.character()),
        @vscode.Position::new(position.line(), line.length()),
      )
      let command = @vscode.Command::new(
        "demo-ext.command1",
        "Inline completion command",
        arguments=[
          @vscode.Any::from(1),
          @vscode.Any::from(2),
        ],
      )
      Some([
        @vscode.InlineCompletionItem::new(
          @vscode.StringOrSnippetString::Text("MoonBit inline completion"),
          range=range,
          command=command,
        ),
      ])
    }
  }
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let settings_command = @commands.register_command_async(
    "extension.inline-completion-settings",
    async fn(_args) {
      let _ : @vscode.Any = @commands.execute_command(
        "workbench.action.openSettings",
        args=@commands.command_args(),
      )
    },
  )
  subscriptions.push(settings_command)

  let demo_command = @commands.register_command_async(
    "demo-ext.command1",
    async fn(args) {
      ignore(
        @window.show_information_message(
          "Inline completion command invoked with \{args.length()} args",
        ),
      )
    },
  )
  subscriptions.push(demo_command)

  subscriptions.push(
    @languages.register_inline_completion_item_provider(
      @vscode.DocumentSelector::Filter(
        @vscode.DocumentFilter::new(
          pattern=@vscode.GlobPattern::Text("**"),
        ),
      ),
      InlineCompletionsProvider::{},
    ),
  )
}

pub fn deactivate() -> Unit {
  ()
}
