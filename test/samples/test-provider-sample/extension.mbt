///|
/// MoonBit port of `test-provider-sample`.
priv struct MarkdownCase {
  item : @tests.TestItem
}

priv struct TestProviderState {
  mut root_items : Array[@tests.TestItem]
  mut cases : Array[MarkdownCase]
}

let test_provider_state : TestProviderState = {
  root_items: [],
  cases: [],
}

priv struct TestControllerDisposable {
  controller : @tests.TestController
}

impl @vscode.Disposable for TestControllerDisposable with dispose(self) {
  self.controller.dispose()
}

fn path_basename(path : String) -> String {
  let mut start = 0
  for i, ch in path {
    if ch == '/' || ch == '\\' {
      start = i + 1
    }
  }
  if start >= path.length() {
    path
  } else {
    path.unsafe_substring(start=start, end=path.length())
  }
}

async fn read_text_file(uri : @vscode.Uri) -> String {
  try {
    @workspace.decode(@workspace.fs().read_file(uri))
  } catch {
    _ => ""
  }
}

fn line_range(line_no : Int, line : String) -> @vscode.Range {
  @vscode.Range::new(
    @vscode.Position::new(line_no, 0),
    @vscode.Position::new(line_no, line.length()),
  )
}

fn clear_discovered_items(controller : @tests.TestController) -> Unit {
  for item in test_provider_state.root_items {
    controller.remove_root_item(item.id())
  }
  test_provider_state.root_items = []
  test_provider_state.cases = []
}

async fn discover_tests(controller : @tests.TestController) -> Unit {
  clear_discovered_items(controller)

  let uris = @workspace.find_files(@vscode.GlobPattern::Text("**/*.md"))
  for uri in uris {
    let file_id = uri.to_string()
    let file_item = controller.create_test_item(
      file_id,
      path_basename(uri.path()),
      uri=uri,
    )

    let content = read_text_file(uri)
    let file_cases : Array[@tests.TestItem] = []
    let mut line_no = 0
    for line_view in content.split("\n") {
      let line = line_view.to_string()
      if line != "" && line.find("=") is Some(_) {
        let case_id = "\{file_id}:\{line_no}"
        let case_item = controller.create_test_item(case_id, line, uri=uri)
        case_item.set_range(Some(line_range(line_no, line)))
        file_cases.push(case_item)
        test_provider_state.cases.push({ item: case_item, })
      }
      line_no = line_no + 1
    }

    if file_cases.length() == 0 {
      let placeholder = controller.create_test_item(
        "\{file_id}:placeholder",
        "No markdown math cases",
        uri=uri,
      )
      file_item.children().replace([placeholder])
    } else {
      file_item.children().replace(file_cases)
    }

    controller.add_root_item(file_item)
    test_provider_state.root_items.push(file_item)
  }
}

fn run_discovered_tests(
  controller : @tests.TestController,
  request : @tests.TestRunRequest,
) -> Unit {
  let run = controller.create_test_run(request)
  for value in test_provider_state.cases {
    let item = value.item
    run.enqueued(item)
    if run.token().is_cancellation_requested {
      run.skipped(item)
    } else {
      run.started(item)
      run.passed(item, duration=1)
    }
  }
  run.end()
}

fn schedule_discovery(controller : @tests.TestController) -> Unit {
  let _ = @js_async.Promise::from_async(async fn() {
    discover_tests(controller)
  })
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let controller = @tests.create_test_controller(
    "mathTestController",
    "Markdown Math",
  )
  subscriptions.push(TestControllerDisposable::{ controller, })

  ignore(controller.create_run_profile(
    "Run Tests",
    @tests.TestRunProfileKind::Run,
    fn(request, _token) {
      run_discovered_tests(controller, request)
    },
    is_default=true,
  ))

  controller.set_refresh_handler(fn(_token) {
    schedule_discovery(controller)
  })

  controller.set_resolve_handler(fn(_item) {
    schedule_discovery(controller)
  })

  subscriptions.push(@workspace.on_did_open_text_document().subscribe(fn(document) {
    if document.uri().path().has_suffix(".md") {
      schedule_discovery(controller)
    }
  }))

  subscriptions.push(
    @workspace.on_did_change_text_document().subscribe(fn(event) {
      if event.document.uri().path().has_suffix(".md") {
        schedule_discovery(controller)
      }
    }),
  )

  schedule_discovery(controller)
}

pub fn deactivate() -> Unit {
  ()
}
