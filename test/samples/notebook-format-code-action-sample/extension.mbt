///|
/// MoonBit port of `notebook-format-code-action-sample`.
fn notebook_action_kind() -> @vscode.CodeActionKind {
  @vscode.CodeActionKind::Notebook.append("format.extensionName")
}

priv struct ImportExtraction {
  import_statements : Array[String]
  non_import_text : String
  has_imports : Bool
  has_non_import_text : Bool
}

fn extract_imports_from_cell(cell_text : String) -> ImportExtraction {
  let import_statements : Array[String] = []
  let non_import_lines : Array[String] = []

  for line_view in cell_text.split("\n") {
    let line = line_view.to_string()
    if line.has_prefix("import") || line.has_prefix("from") {
      import_statements.push(line)
    } else {
      non_import_lines.push(line)
    }
  }

  let non_import_text_lines : Array[String] = []
  for line in non_import_lines {
    non_import_text_lines.push("\{line}\n")
  }
  let non_import_text = non_import_text_lines.join("")

  {
    import_statements,
    non_import_text,
    has_imports: import_statements.length() > 0,
    has_non_import_text: !non_import_text.trim().is_empty(),
  }
}

fn find_notebook(document : @vscode.TextDocument) -> @vscode.NotebookDocument? {
  for notebook in @workspace.notebook_documents() {
    if notebook.uri().path() == document.uri().path() {
      return Some(notebook)
    }
  }
  None
}

fn extract_import_edits(
  notebook_document : @vscode.NotebookDocument,
) -> (Array[@vscode.NotebookEdit], Array[(@vscode.Uri, @vscode.TextEdit)])? {
  let notebook_edits : Array[@vscode.NotebookEdit] = []
  let text_edits : Array[(@vscode.Uri, @vscode.TextEdit)] = []
  let import_statements : Array[String] = []

  for index in 0..<notebook_document.cell_count() {
    let cell = notebook_document.cell_at(index)
    if cell.kind() != @vscode.NotebookCellKind::Code {
      continue
    }

    let extraction = extract_imports_from_cell(cell.document().get_text())
    for statement in extraction.import_statements {
      import_statements.push(statement)
    }

    if extraction.has_imports {
      if extraction.has_non_import_text {
        let range = @vscode.Range::new(
          @vscode.Position::new(0, 0),
          @vscode.Position::new(cell.document().line_count(), 0),
        )
        text_edits.push(
          (
            cell.document().uri(),
            @vscode.TextEdit::new(range, extraction.non_import_text),
          ),
        )
      } else {
        notebook_edits.push(
          @vscode.NotebookEdit::replace_cells(
            @vscode.NotebookRange::new(index, index + 1),
            [],
          ),
        )
      }
    }
  }

  if import_statements.length() == 0 {
    None
  } else {
    let imports_text = import_statements.join("\n")
    let import_cell = @vscode.NotebookCellData::new(
      @vscode.NotebookCellKind::Code,
      "\{imports_text}\n",
      "python",
    )
    notebook_edits.push(@vscode.NotebookEdit::insert_cells(0, [import_cell]))
    Some(
      (
        notebook_edits,
        text_edits,
      ),
    )
  }
}

priv struct ExtractNotebookImports {}

impl @vscode.CodeActionProvider for ExtractNotebookImports with provide_code_actions(
  _self,
  document,
  _range,
  _context,
  _token,
) {
  match find_notebook(document) {
    None => None
    Some(notebook_document) => {
      match extract_import_edits(notebook_document) {
        None => None
        Some((notebook_edits, text_edits)) => {
          let fix = @vscode.CodeAction::new(
            "Extract cell level imports to single cell.",
            kind=notebook_action_kind(),
          )
          let workspace_edit = @vscode.WorkspaceEdit::new()
          workspace_edit.set_notebook_edits(notebook_document.uri(), notebook_edits)
          for text_edit_entry in text_edits {
            let (uri, text_edit) = text_edit_entry
            workspace_edit.set_text_edits(uri, [text_edit])
          }
          fix.set_edit(workspace_edit)
          Some([fix])
        }
      }
    }
  }
}

impl @vscode.CodeActionProvider for ExtractNotebookImports with resolve_code_action(
  _self,
  _action,
  _token,
) {
  None
}

pub fn activate(context : @vscode.ExtensionContext) -> Unit {
  let subscriptions = context.subscriptions()
  subscriptions.push(
    @languages.register_code_actions_provider(
      @vscode.DocumentSelector::Filter(
        @vscode.DocumentFilter::new(notebook_type="jupyter-notebook"),
      ),
      ExtractNotebookImports::{},
      metadata=@vscode.CodeActionProviderMetadata::new(
        provided_kinds=[notebook_action_kind()],
      ),
    ),
  )
}

pub fn deactivate() -> Unit {
  ()
}
