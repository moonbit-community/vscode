///|
/// MoonBit port of `notebook-serializer-sample`.
let notebook_type = "test-notebook-serializer"

fn serializer() -> @vscode.NotebookSerializer {
  @vscode.NotebookSerializer::new(
    async fn(content, _token) {
      let decoded = @workspace.decode(content)
      let value = if decoded.length() == 0 {
        "{ \"hello_world\": 123 }"
      } else {
        decoded
      }
      @vscode.NotebookData::new([
        @vscode.NotebookCellData::new(
          @vscode.NotebookCellKind::Code,
          value,
          "json",
        ),
      ])
    },
    async fn(data, _token) {
      let lines : Array[String] = []
      for cell in data.cells() {
        lines.push(cell.value())
      }
      @workspace.encode(lines.join("\n"))
    },
  )
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let create_notebook = @commands.register_command_async(
    "notebook-serializer-sample.createJsonNotebook",
    async fn(_args) {
      let data = @vscode.NotebookData::new([
        @vscode.NotebookCellData::new(
          @vscode.NotebookCellKind::Code,
          "{ \"hello_world\": 123 }",
          "json",
        ),
      ])
      let document = @workspace.open_notebook_document_type(
        notebook_type,
        content=data,
      )
      ignore(@window.show_notebook_document(document))
    },
  )
  subscriptions.push(create_notebook)

  let registration = @workspace.register_notebook_serializer(
    notebook_type,
    serializer(),
    options=@vscode.NotebookDocumentContentOptions::new(
      transient_outputs=true,
    ),
  )
  subscriptions.push(registration)
}

pub fn deactivate() -> Unit {
  ()
}
