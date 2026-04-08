///|
/// JS entrypoint for comments namespace binding checks.

///|
fn fixture_root() -> @vscode.Uri {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => folder.uri()
    _ => @vscode.Uri::file("/tmp/moonbit-comments-fixture")
  }
}

///|
fn fixture_uri(root : @vscode.Uri, name : String) -> @vscode.Uri {
  @vscode.Uri::join_path(root, [name])
}

///|
fn comment_thread_state_value(state : @vscode.CommentThreadState) -> Int {
  match state {
    @vscode.CommentThreadState::Unresolved => 0
    @vscode.CommentThreadState::Resolved => 1
  }
}

///|
async fn write_result(
  root : @vscode.Uri,
  name : String,
  content : String,
) -> Unit {
  let fs = @workspace.fs()
  fs.write_file(fixture_uri(root, name), @workspace.encode(content))
}

///|
async fn run_check_comments(root : @vscode.Uri) -> Unit {
  let controller = @comments.create_comment_controller(
    "moonbit-comments-controller",
    "MoonBit Comments Controller",
  )

  let author = @vscode.CommentAuthorInformation::new("MoonBit")
  let comment = @vscode.Comment::new(
    @vscode.MarkdownStringValue::Text("moonbit comments check"),
    @vscode.CommentMode::Preview,
    author,
  )

  let uri = @vscode.Uri::join_path(root, ["comments-file.txt"])
  let range = @vscode.Range::new(
    @vscode.Position::new(0, 0),
    @vscode.Position::new(0, 1),
  )

  let thread = controller.create_comment_thread(uri, range, [comment])
  thread.set_label("MoonBit Comment Thread")
  thread.set_context_value("moonbit-comments")
  thread.set_collapsible_state(@vscode.CommentThreadCollapsibleState::Expanded)
  thread.set_can_reply(@vscode.CommentThreadCanReply::BoolValue(true))

  let label = match thread.label() {
    Some(value) => value
    None => ""
  }

  let state_value = match thread.state() {
    Some(value) => comment_thread_state_value(value)
    None => -1
  }

  let comments_count = thread.comments().length()

  thread.dispose()
  controller.dispose()

  write_result(
    root,
    "comments-result.txt",
    "comments ok label=\{label} comments=\{comments_count} state=\{state_value}",
  )
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let root = fixture_root()
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "moonbit.comments.checkBindings",
    async fn(_args) {
      run_check_comments(root)
    },
  )
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
