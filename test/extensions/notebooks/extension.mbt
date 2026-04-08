///|
/// JS entrypoint for notebooks namespace binding checks.

///|
priv struct NotebookKernelSelectOptions {
  notebookEditor : @vscode.NotebookEditor
  id : String
  extension : String
  skipIfAlreadySelected : Bool
}

///|
fn notebook_kernel_select_args(
  options : NotebookKernelSelectOptions,
) -> @commands.CommandArgs {
  ignore(options.notebookEditor)
  ignore(options.id)
  ignore(options.extension)
  ignore(options.skipIfAlreadySelected)
  @commands.command_args1(options)
}

///|
fn fixture_root() -> @vscode.Uri {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => folder.uri()
    _ => @vscode.Uri::file("/tmp/moonbit-notebooks-fixture")
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
async fn run_check_notebooks(root : @vscode.Uri) -> Unit {
  let notebook_type = "moonbit-notebook"
  let serializer = @vscode.NotebookSerializer::new(
    async fn(content, _token) {
      @vscode.NotebookData::new([
        @vscode.NotebookCellData::new(
          @vscode.NotebookCellKind::Code,
          @workspace.decode(content),
          "plaintext",
        ),
      ])
    },
    async fn(_data, _token) {
      @workspace.encode("")
    },
  )
  let serializer_registration = @workspace.register_notebook_serializer(
    notebook_type,
    serializer,
  )

  let controller = @notebooks.create_notebook_controller(
    "moonbit-notebooks-controller",
    notebook_type,
    "MoonBit Notebook Controller",
  )
  let controller_with_handler = @notebooks.create_notebook_controller_with_handler(
    "moonbit-notebooks-controller-handler",
    notebook_type,
    "MoonBit Notebook Controller Handler",
    fn(_cells, _notebook, _controller) {
      ()
    },
  )

  let item = @notebooks.NotebookCellStatusBarItem::new(
    "MoonBit Notebook Item",
    @notebooks.NotebookCellStatusBarAlignment::Left,
  )
  item.set_tooltip("MoonBit Notebook Item Tooltip")

  let provider = @notebooks.NotebookCellStatusBarItemProvider::new(
    fn(_cell, _token) {
      Some([item])
    },
  )
  let provider_registration = @notebooks.register_notebook_cell_status_bar_item_provider(
    notebook_type,
    provider,
  )

  let messaging_result = match @notebooks.try_create_renderer_messaging(
    "moonbit.notebooks.renderer",
  ) {
    Some(messaging) => {
      let message_event = messaging.on_did_receive_message.subscribe(_ => ())
      let posted = messaging.post_message("moonbit-notebooks-message")
      message_event.dispose()
      if posted {
        "some-true"
      } else {
        "some-false"
      }
    }
    None => "none"
  }

  if false {
    ignore(@notebooks.create_renderer_messaging("moonbit.notebooks.renderer.create"))
  }
  let messaging_create_result = "skipped_requires_contributed_renderer"

  let id = controller.id()
  let label = controller.label()
  let notebook_type = controller.notebook_type()
  let tooltip = match item.tooltip() {
    Some(value) => value
    None => ""
  }

  let notebook_uri = fixture_uri(root, "moonbit-notebook-fixture.moonbitnb")
  @workspace.fs().write_file(
    notebook_uri,
    @workspace.encode("moonbit notebook execution"),
  )
  let notebook_document = @workspace.open_notebook_document_uri(notebook_uri)
  controller.update_notebook_affinity(
    notebook_document,
    @notebooks.NotebookControllerAffinity::Preferred,
  )
  let notebook_editor = @window.show_notebook_document(notebook_document)
  let _ : Unit = @commands.execute_command(
    "notebook.selectKernel",
    args=notebook_kernel_select_args({
      notebookEditor: notebook_editor,
      id: controller.id(),
      extension: "moonbit.notebooks-test",
      skipIfAlreadySelected: true,
    }),
  )

  let execution_state = match notebook_document.get_cells() {
    [cell, ..] => {
      let execution = controller.create_notebook_cell_execution(cell)
      execution.start()
      execution.set_execution_order(1)
      let output = @vscode.NotebookCellOutput::new([
        @vscode.NotebookCellOutputItem::text("moonbit output"),
      ])
      execution.replace_output(
        @notebooks.NotebookCellOutputOrMany::Single(output),
      )
      execution.append_output_items(
        @notebooks.NotebookCellOutputItemOrMany::Single(
          @vscode.NotebookCellOutputItem::text("more output"),
        ),
        output,
      )
      execution.end(success=true)
      match execution.execution_order() {
        Some(order) => "\{order}"
        None => "none"
      }
    }
    [] => "none"
  }
  let saved = notebook_document.save()

  provider_registration.dispose()
  controller_with_handler.dispose()
  controller.dispose()
  serializer_registration.dispose()

  write_result(
    root,
    "notebooks-result.txt",
    "notebooks ok id=\{id} label=\{label} type=\{notebook_type} tooltip=\{tooltip} messaging=\{messaging_result} messaging_create=\{messaging_create_result} cells=\{notebook_document.cell_count()} execution=\{execution_state} saved=\{saved}",
  )
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let root = fixture_root()
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "moonbit.notebooks.checkBindings",
    async fn(_args) {
      run_check_notebooks(root)
    },
  )
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
