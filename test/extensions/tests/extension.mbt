///|
/// JS entrypoint for tests namespace binding checks.

///|
fn fixture_root() -> @vscode.Uri {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => folder.uri()
    _ => @vscode.Uri::file("/tmp/moonbit-tests-fixture")
  }
}

///|
fn fixture_uri(root : @vscode.Uri, name : String) -> @vscode.Uri {
  @vscode.Uri::join_path(root, [name])
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
async fn run_check_tests(root : @vscode.Uri) -> Unit {
  let controller = @tests.create_test_controller(
    "moonbit-tests-controller",
    "MoonBit Tests Controller",
  )

  let before_size = controller.root_items_size()
  let item = controller.create_test_item(
    "moonbit-tests-item",
    "MoonBit Tests Item",
    uri=@vscode.Uri::join_path(root, ["tests-file.txt"]),
  )
  controller.add_root_item(item)
  let after_add_size = controller.root_items_size()

  let tag = @tests.TestTag::new("moonbit.tests.fast")
  item.set_tags([tag])
  item.set_can_resolve_children(true)
  item.set_busy(false)
  item.set_description(Some("MoonBit tests item description"))
  item.set_sort_text(Some("001"))
  item.set_range(Some(@vscode.Range::new(@vscode.Position::new(0, 0), @vscode.Position::new(0, 6))))
  item.set_error(Some(@vscode.MarkdownStringValue::Text("MoonBit test discovery warning")))

  let profile = controller.create_run_profile(
    "MoonBit Tests Run Profile",
    @tests.TestRunProfileKind::Run,
    fn(_request, _token) {
      ()
    },
    is_default=true,
    tag=tag,
    supports_continuous_run=true,
  )
  let default_changed = profile.on_did_change_default().subscribe(_ => ())
  default_changed.dispose()
  profile.set_configure_handler(fn() {
    ()
  })
  profile.clear_configure_handler()
  let profile_kind = match profile.kind() {
    @tests.TestRunProfileKind::Run => "run"
    @tests.TestRunProfileKind::Debug => "debug"
    @tests.TestRunProfileKind::Coverage => "coverage"
  }

  let request = @tests.TestRunRequest::new(
    included_items=[item],
    profile=profile,
    continuous=false,
    preserve_focus=true,
  )
  let request_preserve_focus = request.preserve_focus()

  let run = controller.create_test_run(
    request,
    name="MoonBit Test Run",
    persist=false,
  )
  let run_dispose = run.on_did_dispose().subscribe(_ => ())
  run_dispose.dispose()
  run.enqueued(item)
  run.started(item)

  let message = @tests.TestMessage::new(
    @vscode.MarkdownStringValue::Text("MoonBit test message"),
  )
  let stack = @tests.TestMessageStackFrame::new(
    "moonbit.tests.frame",
    uri=@vscode.Uri::join_path(root, ["tests-file.txt"]),
    position=@vscode.Position::new(0, 1),
  )
  message.set_stack_trace(Some([stack]))
  run.append_output("MoonBit tests output\\r\\n", test_item=item)
  run.failed(item, @tests.TestMessageOrMany::Single(message), duration=1)
  run.started(item)
  run.passed(item, duration=2)

  let statement = @tests.StatementCoverage::new(
    @tests.IntOrBool::Numeric(1),
    @tests.PositionOrRange::RangeValue(
      @vscode.Range::new(@vscode.Position::new(0, 0), @vscode.Position::new(0, 6)),
    ),
  )
  let declaration = @tests.DeclarationCoverage::new(
    "moonbit.tests.fn",
    @tests.IntOrBool::Boolean(true),
    @tests.PositionOrRange::PositionValue(@vscode.Position::new(0, 0)),
  )
  let file_coverage = @tests.FileCoverage::from_details(
    @vscode.Uri::join_path(root, ["tests-file.txt"]),
    [
      @tests.FileCoverageDetail::from_statement(statement),
      @tests.FileCoverageDetail::from_declaration(declaration),
    ],
  )
  run.add_coverage(file_coverage)
  run.end()

  controller.invalidate_test_results(
    items=@tests.TestItemOrMany::Single(item),
  )
  item.set_label("MoonBit Tests Item Updated")
  let updated_label = item.label()
  let item_description = match item.description() {
    None => "none"
    Some(value) => value
  }
  let item_sort_text = match item.sort_text() {
    None => "none"
    Some(value) => value
  }
  let item_error = match item.error() {
    None => "none"
    Some(_) => "some"
  }
  let item_tags = item.tags().length()
  let include_count = match request.included_items() {
    None => 0
    Some(value) => value.length()
  }
  let profile_tag = match profile.tag() {
    None => "none"
    Some(value) => value.id()
  }

  profile.dispose()
  controller.remove_root_item(item.id())
  let after_remove_size = controller.root_items_size()

  let id = controller.id()
  let label = controller.label()

  controller.dispose()

  write_result(
    root,
    "tests-result.txt",
    "tests ok id=\{id} label=\{label} before=\{before_size} after_add=\{after_add_size} after_remove=\{after_remove_size} item_label=\{updated_label} item_description=\{item_description} item_sort=\{item_sort_text} item_error=\{item_error} item_tags=\{item_tags} include_count=\{include_count} request_preserve_focus=\{request_preserve_focus} profile_kind=\{profile_kind} profile_tag=\{profile_tag} coverage_statements=\{file_coverage.statement_coverage().covered()}",
  )
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let root = fixture_root()
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "moonbit.tests.checkBindings",
    async fn(_args) {
      run_check_tests(root)
    },
  )
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
