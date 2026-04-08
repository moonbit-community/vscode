///|
/// Notebook-related helpers and types.

///|
/// Create a new notebook range. If `start` is not
/// before or equal to `end`, the values will be swapped.
///
/// @param start start index
/// @param end end index.
pub fn NotebookRange::new(start : Int, end : Int) -> NotebookRange {
  if start <= end {
    notebook_range_ffi(start, end)
  } else {
    notebook_range_ffi(end, start)
  }
}

///|
/// The zero-based start index of this range.
pub extern "js" fn NotebookRange::start(self : NotebookRange) -> Int =
  #| (range) => range.start

///|
/// The exclusive end index of this range (zero-based).
pub extern "js" fn NotebookRange::end(self : NotebookRange) -> Int =
  #| (range) => range.end

///|
/// `true` if `start` and `end` are equal.
pub fn NotebookRange::is_empty(self : NotebookRange) -> Bool {
  self.start() == self.end()
}

///|
/// Derive a new range for this range.
///
/// @param change An object that describes a change to this range.
/// @returns A range that reflects the given change. Will return `this` range if the change
/// is not changing anything.
pub fn NotebookRange::with_values(
  self : NotebookRange,
  start? : Int,
  end? : Int,
) -> NotebookRange {
  let new_start = match start {
    None => self.start()
    Some(value) => value
  }
  let new_end = match end {
    None => self.end()
    Some(value) => value
  }
  if new_start == self.start() && new_end == self.end() {
    self
  } else {
    NotebookRange::new(new_start, new_end)
  }
}

///|
extern "js" fn notebook_range_ffi(start : Int, end : Int) -> NotebookRange =
  #| (start, end) => new (require("vscode").NotebookRange)(start, end)

///|
/// The {@link NotebookDocument notebook document} associated with this notebook editor.
pub extern "js" fn NotebookEditor::notebook(
  self : NotebookEditor,
) -> NotebookDocument =
  #| (editor) => editor.notebook

///|
/// The primary selection in this notebook editor.
pub extern "js" fn NotebookEditor::selection(
  self : NotebookEditor,
) -> NotebookRange =
  #| (editor) => editor.selection

///|
/// The primary selection in this notebook editor.
pub extern "js" fn NotebookEditor::set_selection(
  self : NotebookEditor,
  value : NotebookRange,
) -> Unit =
  #| (editor, value) => { editor.selection = value; }

///|
/// All selections in this notebook editor.
///
/// The primary selection (or focused range) is `selections[0]`. When the document has no cells, the primary selection is empty `{ start: 0, end: 0 }`;
pub extern "js" fn NotebookEditor::selections(
  self : NotebookEditor,
) -> Array[NotebookRange] =
  #| (editor) => editor.selections

///|
/// All selections in this notebook editor.
///
/// The primary selection (or focused range) is `selections[0]`. When the document has no cells, the primary selection is empty `{ start: 0, end: 0 }`;
pub extern "js" fn NotebookEditor::set_selections(
  self : NotebookEditor,
  value : Array[NotebookRange],
) -> Unit =
  #| (editor, value) => { editor.selections = value; }

///|
/// The current visible ranges in the editor (vertically).
pub extern "js" fn NotebookEditor::visible_ranges(
  self : NotebookEditor,
) -> Array[NotebookRange] =
  #| (editor) => editor.visibleRanges

///|
/// The column in which this editor shows.
pub fn NotebookEditor::view_column(self : NotebookEditor) -> ViewColumn? {
  let raw = NotebookEditor::notebook_editor_view_column_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Scroll as indicated by `revealType` in order to reveal the given range.
///
/// @param range A range.
/// @param revealType The scrolling strategy for revealing `range`.
pub extern "js" fn NotebookEditor::reveal_range(
  self : NotebookEditor,
  range : NotebookRange,
  reveal_type? : NotebookEditorRevealType = JsValue::make(()).cast(),
) -> Unit =
  #| (editor, range, revealType) => editor.revealRange(range, revealType)

///|
extern "js" fn NotebookEditor::notebook_editor_view_column_raw(
  self : NotebookEditor,
) -> JsValue =
  #| (editor) => editor.viewColumn

///|
/// The index of this cell in its {@link NotebookDocument.cellAt containing notebook}. The
/// index is updated when a cell is moved within its notebook. The index is `-1`
/// when the cell has been removed from its notebook.
pub extern "js" fn NotebookCell::index(self : NotebookCell) -> Int =
  #| (cell) => cell.index

///|
/// The {@link NotebookDocument notebook} that contains this cell.
pub extern "js" fn NotebookCell::notebook(
  self : NotebookCell,
) -> NotebookDocument =
  #| (cell) => cell.notebook

///|
/// The kind of this cell.
pub extern "js" fn NotebookCell::kind(self : NotebookCell) -> NotebookCellKind =
  #| (cell) => cell.kind

///|
/// The {@link TextDocument text} of this cell, represented as text document.
pub extern "js" fn NotebookCell::document(self : NotebookCell) -> TextDocument =
  #| (cell) => cell.document

///|
/// The metadata of this cell. Can be anything but must be JSON-stringifyable.
pub extern "js" fn NotebookCell::metadata(self : NotebookCell) -> Any =
  #| (cell) => cell.metadata

///|
pub extern "js" fn NotebookCell::outputs(
  self : NotebookCell,
) -> Array[NotebookCellOutput] =
  #| (cell) => cell.outputs

///|
pub fn NotebookCell::execution_summary(
  self : NotebookCell,
) -> NotebookCellExecutionSummary? {
  let raw = NotebookCell::execution_summary_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
extern "js" fn NotebookCell::execution_summary_raw(
  self : NotebookCell,
) -> JsValue =
  #| (cell) => cell.executionSummary

///|
pub extern "js" fn NotebookDocument::uri(self : NotebookDocument) -> Uri =
  #| (document) => document.uri

///|
pub extern "js" fn NotebookDocument::notebook_type(
  self : NotebookDocument,
) -> String =
  #| (document) => document.notebookType

///|
pub extern "js" fn NotebookDocument::version(self : NotebookDocument) -> Int =
  #| (document) => document.version

///|
pub extern "js" fn NotebookDocument::is_dirty(self : NotebookDocument) -> Bool =
  #| (document) => document.isDirty

///|
pub extern "js" fn NotebookDocument::is_untitled(
  self : NotebookDocument,
) -> Bool =
  #| (document) => document.isUntitled

///|
pub extern "js" fn NotebookDocument::is_closed(self : NotebookDocument) -> Bool =
  #| (document) => document.isClosed

///|
pub extern "js" fn NotebookDocument::metadata(self : NotebookDocument) -> Any =
  #| (document) => document.metadata

///|
pub extern "js" fn NotebookDocument::cell_count(self : NotebookDocument) -> Int =
  #| (document) => document.cellCount
/// The outputs of this cell.

///|
/// The most recent {@link NotebookCellExecutionSummary execution summary} for this cell.

///|
/// The summary of a notebook cell execution.
pub struct NotebookCellExecutionSummary {
  executionOrder : Int?
  success : Bool?
  timing : NotebookCellExecutionTiming?
}

///|
pub struct NotebookCellExecutionTiming {
  startTime : Int
  endTime : Int
}

///|
/// The order in which the execution happened.
pub fn NotebookCellExecutionSummary::new(
  execution_order? : Int,
  success? : Bool,
  timing? : NotebookCellExecutionTiming,
) -> NotebookCellExecutionSummary {
  NotebookCellExecutionSummary::{
    executionOrder: execution_order,
    success,
    timing,
  }
}

///|
/// The order in which the execution happened.

///|
/// If the execution finished successfully.

///|
/// The times at which execution started and ended, as unix timestamps

///|
pub fn NotebookCellExecutionTiming::new(
  start_time : Int,
  end_time : Int,
) -> NotebookCellExecutionTiming {
  NotebookCellExecutionTiming::{ startTime: start_time, endTime: end_time }
}

///|

///|

///|
/// The associated uri for this notebook.
///
/// *Note* that most notebooks use the `file`-scheme, which means they are files on disk. However, **not** all notebooks are
/// saved on disk and therefore the `scheme` must be checked before trying to access the underlying file or siblings on disk.
///
/// @see {@link FileSystemProvider}

///|
/// The type of notebook.

///|
/// The version number of this notebook (it will strictly increase after each
/// change, including undo/redo).

///|
/// `true` if there are unpersisted changes.

///|
/// Is this notebook representing an untitled file which has not been saved yet.

///|
/// `true` if the notebook has been closed. A closed notebook isn't synchronized anymore
/// and won't be re-used when the same resource is opened again.

///|
/// Arbitrary metadata for this notebook. Can be anything but must be JSON-stringifyable.

///|
/// The number of cells in the notebook.

///|
/// Return the cell at the specified index. The index will be adjusted to the notebook.
///
/// @param index - The index of the cell to retrieve.
/// @returns A {@link NotebookCell cell}.
pub extern "js" fn NotebookDocument::cell_at(
  self : NotebookDocument,
  index : Int,
) -> NotebookCell =
  #| (doc, index) => doc.cellAt(index)

///|
/// Get the cells of this notebook. A subset can be retrieved by providing
/// a range. The range will be adjusted to the notebook.
///
/// @param range A notebook range.
/// @returns The cells contained by the range or all cells.
pub extern "js" fn NotebookDocument::get_cells(
  self : NotebookDocument,
  range? : NotebookRange = JsValue::make(()).cast(),
) -> Array[NotebookCell] =
  #| (doc, range) => doc.getCells(range)

///|
fn NotebookDocument::save_promise(
  self : NotebookDocument,
) -> @js_async.Promise[Bool] {
  notebook_document_save_ffi(self)
}

///|
/// Save the document. The saving will be handled by the corresponding {@link NotebookSerializer serializer}.
///
/// @returns A promise that will resolve to true when the document
/// has been saved. Will return false if the file was not dirty or when save failed.
pub async fn NotebookDocument::save(self : NotebookDocument) -> Bool {
  @js_async.Promise::wait(NotebookDocument::save_promise(self))
}

///|
/// The range at which cells have been either added or removed.
///
/// Note that no cells have been {@link NotebookDocumentContentChange.removedCells removed}
/// when this range is {@link NotebookRange.isEmpty empty}.
pub fn NotebookDocumentContentChange::new(
  range : NotebookRange,
  added_cells : Array[NotebookCell],
  removed_cells : Array[NotebookCell],
) -> NotebookDocumentContentChange {
  NotebookDocumentContentChange::{
    range,
    addedCells: added_cells,
    removedCells: removed_cells,
  }
}

///|
/// The range at which cells have been either added or removed.
///
/// Note that no cells have been {@link NotebookDocumentContentChange.removedCells removed}
/// when this range is {@link NotebookRange.isEmpty empty}.

///|
/// Cells that have been added to the document.

///|
/// Cells that have been removed from the document.

///|
/// The affected cell.
pub fn NotebookDocumentCellChange::new(
  cell : NotebookCell,
  document? : TextDocument,
  metadata? : Any,
  outputs? : Array[NotebookCellOutput],
  execution_summary? : NotebookCellExecutionSummary,
) -> NotebookDocumentCellChange {
  NotebookDocumentCellChange::{
    cell,
    document,
    metadata,
    outputs,
    executionSummary: execution_summary,
  }
}

///|
/// The affected cell.

///|
/// The document of the cell or `undefined` when it did not change.
///
/// *Note* that you should use the {@link workspace.onDidChangeTextDocument onDidChangeTextDocument}-event
/// for detailed change information, like what edits have been performed.

///|
/// The new metadata of the cell or `undefined` when it did not change.

///|
/// The new outputs of the cell or `undefined` when they did not change.

///|
/// The new execution summary of the cell or `undefined` when it did not change.

///|
/// The affected notebook.
pub fn NotebookDocumentChangeEvent::new(
  notebook : NotebookDocument,
  content_changes? : Array[NotebookDocumentContentChange] = [],
  cell_changes? : Array[NotebookDocumentCellChange] = [],
  metadata? : Any,
) -> NotebookDocumentChangeEvent {
  NotebookDocumentChangeEvent::{
    notebook,
    metadata,
    contentChanges: content_changes,
    cellChanges: cell_changes,
  }
}

///|
/// The affected notebook.

///|
/// The new metadata of the notebook or `undefined` when it did not change.

///|
/// An array of content changes describing added or removed {@link NotebookCell cells}.

///|
/// An array of {@link NotebookDocumentCellChange cell changes}.

///|
/// A cancellation token.

///|
/// The {@link NotebookDocument notebook document} that will be saved.

///|
/// The reason why save was triggered.

///|
extern "js" fn NotebookDocumentWillSaveEvent::wait_until_edit_raw(
  self : NotebookDocumentWillSaveEvent,
  thenable : @js_async.Promise[WorkspaceEdit],
) -> Unit =
  #| (event, thenable) => event.waitUntil(thenable)

///|
/// Allows to pause the event loop and to apply {@link WorkspaceEdit workspace edit}.
/// Edits of subsequent calls to this function will be applied in order. The
/// edits will be *ignored* if concurrent modifications of the notebook document happened.
///
/// *Note:* This function can only be called during event dispatch and not
/// in an asynchronous manner:
///
/// ```ts
/// workspace.onWillSaveNotebookDocument(event => {
/// 	// async, will *throw* an error
/// 	setTimeout(() => event.waitUntil(promise));
///
/// 	// sync, OK
/// 	event.waitUntil(promise);
/// })
/// ```
///
/// @param thenable A thenable that resolves to {@link WorkspaceEdit workspace edit}.
pub fn NotebookDocumentWillSaveEvent::wait_until_edit(
  self : NotebookDocumentWillSaveEvent,
  thenable : async () -> WorkspaceEdit,
) -> Unit {
  NotebookDocumentWillSaveEvent::wait_until_edit_raw(
    self,
    @js_async.Promise::from_async(thenable),
  )
}

///|
extern "js" fn NotebookDocumentWillSaveEvent::wait_until_raw(
  self : NotebookDocumentWillSaveEvent,
  thenable : @js_async.Promise[Unit],
) -> Unit =
  #| (event, thenable) => event.waitUntil(thenable)

///|
/// Allows to pause the event loop and to apply {@link WorkspaceEdit workspace edit}.
/// Edits of subsequent calls to this function will be applied in order. The
/// edits will be *ignored* if concurrent modifications of the notebook document happened.
///
/// *Note:* This function can only be called during event dispatch and not
/// in an asynchronous manner:
///
/// ```ts
/// workspace.onWillSaveNotebookDocument(event => {
/// 	// async, will *throw* an error
/// 	setTimeout(() => event.waitUntil(promise));
///
/// 	// sync, OK
/// 	event.waitUntil(promise);
/// })
/// ```
///
/// @param thenable A thenable that resolves to {@link WorkspaceEdit workspace edit}.
pub fn NotebookDocumentWillSaveEvent::wait_until(
  self : NotebookDocumentWillSaveEvent,
  thenable : async () -> Unit,
) -> Unit {
  NotebookDocumentWillSaveEvent::wait_until_raw(
    self,
    @js_async.Promise::from_async(thenable),
  )
}

///|
/// Factory function to create a `NotebookCellOutputItem` from a string.
///
/// *Note* that an UTF-8 encoder is used to create bytes for the string.
///
/// @param value A string.
/// @param mime Optional MIME type, defaults to `text/plain`.
/// @returns A new output item object.
pub fn NotebookCellOutputItem::text(
  value : String,
  mime? : String,
) -> NotebookCellOutputItem {
  notebook_cell_output_item_text_raw_ffi(value, option_to_js(mime)).cast()
}

///|
/// Factory function to create a `NotebookCellOutputItem` from
/// a JSON object.
///
/// *Note* that this function is not expecting "stringified JSON" but
/// an object that can be stringified. This function will throw an error
/// when the passed value cannot be JSON-stringified.
///
/// @param value A JSON-stringifyable value.
/// @param mime Optional MIME type, defaults to `application/json`
/// @returns A new output item object.
pub fn NotebookCellOutputItem::json(
  value : Any,
  mime? : String,
) -> NotebookCellOutputItem {
  notebook_cell_output_item_json_raw_ffi(
    JsValue::make(value),
    option_to_js(mime),
  ).cast()
}

///|
/// Factory function to create a `NotebookCellOutputItem` that uses
/// uses the `application/vnd.code.notebook.stdout` mime type.
///
/// @param value A string.
/// @returns A new output item object.
pub fn NotebookCellOutputItem::stdout(value : String) -> NotebookCellOutputItem {
  notebook_cell_output_item_stdout_raw_ffi(value).cast()
}

///|
/// Factory function to create a `NotebookCellOutputItem` that uses
/// uses the `application/vnd.code.notebook.stderr` mime type.
///
/// @param value A string.
/// @returns A new output item object.
pub fn NotebookCellOutputItem::stderr(value : String) -> NotebookCellOutputItem {
  notebook_cell_output_item_stderr_raw_ffi(value).cast()
}

///|
/// Factory function to create a `NotebookCellOutputItem` that uses
/// uses the `application/vnd.code.notebook.error` mime type.
///
/// @param value An error object.
/// @returns A new output item object.
pub fn NotebookCellOutputItem::error(value : JsError) -> NotebookCellOutputItem {
  notebook_cell_output_item_error_raw_ffi(value).cast()
}

///|
pub fn NotebookCellOutputItem::new(
  data : Bytes,
  mime : String,
) -> NotebookCellOutputItem {
  notebook_cell_output_item_ffi(bytes_to_uint8_array(data), mime)
}

///|
/// The mime type which determines how the {@linkcode NotebookCellOutputItem.data data}-property
/// is interpreted.
///
/// Notebooks have built-in support for certain mime-types, extensions can add support for new
/// types and override existing types.
pub extern "js" fn NotebookCellOutputItem::mime(
  self : NotebookCellOutputItem,
) -> String =
  #| (item) => item.mime

///|
/// The mime type which determines how the {@linkcode NotebookCellOutputItem.data data}-property
/// is interpreted.
///
/// Notebooks have built-in support for certain mime-types, extensions can add support for new
/// types and override existing types.
pub extern "js" fn NotebookCellOutputItem::set_mime(
  self : NotebookCellOutputItem,
  value : String,
) -> Unit =
  #| (item, value) => { item.mime = value; }

///|
/// The data of this output item. Must always be an array of unsigned 8-bit integers.
pub fn NotebookCellOutputItem::data(self : NotebookCellOutputItem) -> Bytes {
  bytes_from_uint8_array(
    notebook_cell_output_item_data_raw_ffi(JsValue::make(self)),
  )
}

///|
/// The data of this output item. Must always be an array of unsigned 8-bit integers.
pub fn NotebookCellOutputItem::set_data(
  self : NotebookCellOutputItem,
  value : Bytes,
) -> Unit {
  NotebookCellOutputItem::set_data_raw(self, bytes_to_uint8_array(value))
}

///|
/// Create new notebook output.
///
/// @param items Notebook output items.
/// @param metadata Optional metadata.
pub fn NotebookCellOutput::new(
  items : Array[NotebookCellOutputItem],
  metadata? : Any,
) -> NotebookCellOutput {
  notebook_cell_output_ffi(items, option_to_js(metadata))
}

///|
/// The output items of this output. Each item must represent the same result. _Note_ that repeated
/// MIME types per output is invalid and that the editor will just pick one of them.
///
/// ```ts
/// new vscode.NotebookCellOutput([
/// 	vscode.NotebookCellOutputItem.text('Hello', 'text/plain'),
/// 	vscode.NotebookCellOutputItem.text('<i>Hello</i>', 'text/html'),
/// 	vscode.NotebookCellOutputItem.text('_Hello_', 'text/markdown'),
/// 	vscode.NotebookCellOutputItem.text('Hey', 'text/plain'), // INVALID: repeated type, editor will pick just one
/// ])
/// ```
pub extern "js" fn NotebookCellOutput::items(
  self : NotebookCellOutput,
) -> Array[NotebookCellOutputItem] =
  #| (value) => value.items

///|
/// The output items of this output. Each item must represent the same result. _Note_ that repeated
/// MIME types per output is invalid and that the editor will just pick one of them.
///
/// ```ts
/// new vscode.NotebookCellOutput([
/// 	vscode.NotebookCellOutputItem.text('Hello', 'text/plain'),
/// 	vscode.NotebookCellOutputItem.text('<i>Hello</i>', 'text/html'),
/// 	vscode.NotebookCellOutputItem.text('_Hello_', 'text/markdown'),
/// 	vscode.NotebookCellOutputItem.text('Hey', 'text/plain'), // INVALID: repeated type, editor will pick just one
/// ])
/// ```
pub extern "js" fn NotebookCellOutput::set_items(
  self : NotebookCellOutput,
  value : Array[NotebookCellOutputItem],
) -> Unit =
  #| (item, value) => { item.items = value; }

///|
/// Arbitrary metadata for this cell output. Can be anything but must be JSON-stringifyable.
pub fn NotebookCellOutput::metadata(self : NotebookCellOutput) -> Any? {
  let raw = NotebookCellOutput::metadata_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Arbitrary metadata for this cell output. Can be anything but must be JSON-stringifyable.
pub fn NotebookCellOutput::set_metadata(
  self : NotebookCellOutput,
  value : Any,
) -> Unit {
  NotebookCellOutput::set_metadata_raw(self, JsValue::make(value))
}

///|
/// Arbitrary metadata for this cell output. Can be anything but must be JSON-stringifyable.
pub fn NotebookCellOutput::clear_metadata(self : NotebookCellOutput) -> Unit {
  NotebookCellOutput::set_metadata_raw(self, JsValue::make(()))
}

///|
/// Create new cell data. Minimal cell data specifies its kind, its source value, and the
/// language identifier of its source.
///
/// @param kind The kind.
/// @param value The source value.
/// @param languageId The language identifier of the source value.
pub fn NotebookCellData::new(
  kind : NotebookCellKind,
  value : String,
  language_id : String,
) -> NotebookCellData {
  notebook_cell_data_ffi(kind, value, language_id)
}

///|
/// The {@link NotebookCellKind kind} of this cell data.
pub extern "js" fn NotebookCellData::kind(
  self : NotebookCellData,
) -> NotebookCellKind =
  #| (cell) => cell.kind

///|
/// The {@link NotebookCellKind kind} of this cell data.
pub extern "js" fn NotebookCellData::set_kind(
  self : NotebookCellData,
  value : NotebookCellKind,
) -> Unit =
  #| (cell, value) => { cell.kind = value; }

///|
/// The source value of this cell data - either source code or formatted text.
pub extern "js" fn NotebookCellData::value(self : NotebookCellData) -> String =
  #| (cell) => cell.value

///|
/// The source value of this cell data - either source code or formatted text.
pub extern "js" fn NotebookCellData::set_value(
  self : NotebookCellData,
  next_value : String,
) -> Unit =
  #| (cell, value) => { cell.value = value; }

///|
/// The language identifier of the source value of this cell data. Any value from
/// {@linkcode languages.getLanguages getLanguages} is possible.
pub extern "js" fn NotebookCellData::language_id(
  self : NotebookCellData,
) -> String =
  #| (cell) => cell.languageId

///|
/// The language identifier of the source value of this cell data. Any value from
/// {@linkcode languages.getLanguages getLanguages} is possible.
pub extern "js" fn NotebookCellData::set_language_id(
  self : NotebookCellData,
  value : String,
) -> Unit =
  #| (cell, value) => { cell.languageId = value; }

///|
/// The outputs of this cell data.
pub fn NotebookCellData::outputs(
  self : NotebookCellData,
) -> Array[NotebookCellOutput]? {
  let raw = NotebookCellData::outputs_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The outputs of this cell data.
pub extern "js" fn NotebookCellData::set_outputs(
  self : NotebookCellData,
  value : Array[NotebookCellOutput],
) -> Unit =
  #| (cell, value) => { cell.outputs = value; }

///|
/// The outputs of this cell data.
pub fn NotebookCellData::clear_outputs(self : NotebookCellData) -> Unit {
  NotebookCellData::set_outputs_raw(self, JsValue::make(()))
}

///|
/// Arbitrary metadata of this cell data. Can be anything but must be JSON-stringifyable.
pub fn NotebookCellData::metadata(self : NotebookCellData) -> Any? {
  let raw = NotebookCellData::metadata_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Arbitrary metadata of this cell data. Can be anything but must be JSON-stringifyable.
pub fn NotebookCellData::set_metadata(
  self : NotebookCellData,
  value : Any,
) -> Unit {
  NotebookCellData::set_metadata_raw(self, JsValue::make(value))
}

///|
/// Arbitrary metadata of this cell data. Can be anything but must be JSON-stringifyable.
pub fn NotebookCellData::clear_metadata(self : NotebookCellData) -> Unit {
  NotebookCellData::set_metadata_raw(self, JsValue::make(()))
}

///|
/// The execution summary of this cell data.
pub fn NotebookCellData::execution_summary(
  self : NotebookCellData,
) -> NotebookCellExecutionSummary? {
  let raw = NotebookCellData::execution_summary_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The execution summary of this cell data.
pub extern "js" fn NotebookCellData::set_execution_summary(
  self : NotebookCellData,
  value : NotebookCellExecutionSummary,
) -> Unit =
  #| (cell, value) => { cell.executionSummary = value; }

///|
/// The execution summary of this cell data.
pub fn NotebookCellData::clear_execution_summary(
  self : NotebookCellData,
) -> Unit {
  NotebookCellData::set_execution_summary_raw(self, JsValue::make(()))
}

///|
/// Create new notebook data.
///
/// @param cells An array of cell data.
pub fn NotebookData::new(cells : Array[NotebookCellData]) -> NotebookData {
  notebook_data_ffi(cells)
}

///|
/// The cell data of this notebook data.
pub extern "js" fn NotebookData::cells(
  self : NotebookData,
) -> Array[NotebookCellData] =
  #| (value) => value.cells

///|
/// The cell data of this notebook data.
pub extern "js" fn NotebookData::set_cells(
  self : NotebookData,
  value : Array[NotebookCellData],
) -> Unit =
  #| (item, value) => { item.cells = value; }

///|
/// Arbitrary metadata of notebook data.
pub fn NotebookData::metadata(self : NotebookData) -> Any? {
  let raw = NotebookData::metadata_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Arbitrary metadata of notebook data.
pub fn NotebookData::set_metadata(self : NotebookData, value : Any) -> Unit {
  NotebookData::set_metadata_raw(self, JsValue::make(value))
}

///|
/// Arbitrary metadata of notebook data.
pub fn NotebookData::clear_metadata(self : NotebookData) -> Unit {
  NotebookData::set_metadata_raw(self, JsValue::make(()))
}

///|
pub fn NotebookSerializer::new(
  deserialize : async (Bytes, CancellationToken) -> NotebookData,
  serialize : async (NotebookData, CancellationToken) -> Bytes,
) -> NotebookSerializer {
  notebook_serializer_ffi(
    (content, token) => {
      @js_async.Promise::from_async(async fn() {
        deserialize(bytes_from_uint8_array(content), token)
      })
    },
    (data, token) => {
      @js_async.Promise::from_async(async fn() {
        bytes_to_uint8_array(serialize(data, token))
      })
    },
  )
}

///|
extern "js" fn notebook_document_save_ffi(
  doc : NotebookDocument,
) -> @js_async.Promise[Bool] =
  #| (doc) => doc.save()

///|
extern "js" fn notebook_cell_output_item_ffi(
  data : Uint8Array,
  mime : String,
) -> NotebookCellOutputItem =
  #| (data, mime) => new (require("vscode").NotebookCellOutputItem)(data, mime)

///|
extern "js" fn NotebookCellOutputItem::set_data_raw(
  self : NotebookCellOutputItem,
  value : Uint8Array,
) -> Unit =
  #| (item, value) => { item.data = value; }

///|
extern "js" fn notebook_cell_output_ffi(
  items : Array[NotebookCellOutputItem],
  metadata : JsValue,
) -> NotebookCellOutput =
  #| (items, metadata) =>
  #|   metadata === undefined || metadata === null
  #|     ? new (require("vscode").NotebookCellOutput)(items)
  #|     : new (require("vscode").NotebookCellOutput)(items, metadata)

///|
extern "js" fn NotebookCellOutput::metadata_raw(
  self : NotebookCellOutput,
) -> JsValue =
  #| (value) => value.metadata

///|
extern "js" fn NotebookCellOutput::set_metadata_raw(
  self : NotebookCellOutput,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.metadata = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn notebook_cell_data_ffi(
  kind : NotebookCellKind,
  value : String,
  language_id : String,
) -> NotebookCellData =
  #| (kind, value, languageId) => new (require("vscode").NotebookCellData)(kind, value, languageId)

///|
extern "js" fn NotebookCellData::outputs_raw(
  self : NotebookCellData,
) -> JsValue =
  #| (cell) => cell.outputs

///|
extern "js" fn NotebookCellData::set_outputs_raw(
  self : NotebookCellData,
  value : JsValue,
) -> Unit =
  #| (cell, value) => { cell.outputs = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn NotebookCellData::metadata_raw(
  self : NotebookCellData,
) -> JsValue =
  #| (cell) => cell.metadata

///|
extern "js" fn NotebookCellData::set_metadata_raw(
  self : NotebookCellData,
  value : JsValue,
) -> Unit =
  #| (cell, value) => { cell.metadata = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn NotebookCellData::execution_summary_raw(
  self : NotebookCellData,
) -> JsValue =
  #| (cell) => cell.executionSummary

///|
extern "js" fn NotebookCellData::set_execution_summary_raw(
  self : NotebookCellData,
  value : JsValue,
) -> Unit =
  #| (cell, value) => { cell.executionSummary = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn notebook_data_ffi(
  cells : Array[NotebookCellData],
) -> NotebookData =
  #| (cells) => new (require("vscode").NotebookData)(cells)

///|
extern "js" fn NotebookData::metadata_raw(self : NotebookData) -> JsValue =
  #| (value) => value.metadata

///|
extern "js" fn NotebookData::set_metadata_raw(
  self : NotebookData,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.metadata = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn notebook_cell_output_item_text_raw_ffi(
  value : String,
  mime : JsValue,
) -> JsValue =
  #| (value, mime) => require('vscode').NotebookCellOutputItem.text(value, mime)

///|
extern "js" fn notebook_cell_output_item_json_raw_ffi(
  value : JsValue,
  mime : JsValue,
) -> JsValue =
  #| (value, mime) => require('vscode').NotebookCellOutputItem.json(value, mime)

///|
extern "js" fn notebook_cell_output_item_stdout_raw_ffi(
  value : String,
) -> JsValue =
  #| (value) => require('vscode').NotebookCellOutputItem.stdout(value)

///|
extern "js" fn notebook_cell_output_item_stderr_raw_ffi(
  value : String,
) -> JsValue =
  #| (value) => require('vscode').NotebookCellOutputItem.stderr(value)

///|
extern "js" fn notebook_cell_output_item_error_raw_ffi(
  value : JsError,
) -> JsValue =
  #| (value) => require('vscode').NotebookCellOutputItem.error(value)

///|
extern "js" fn notebook_cell_output_item_data_raw_ffi(
  item : JsValue,
) -> Uint8Array =
  #| (item) => item.data

///|
extern "js" fn notebook_serializer_ffi(
  deserialize : (Uint8Array, CancellationToken) -> @js_async.Promise[
    NotebookData,
  ],
  serialize : (NotebookData, CancellationToken) -> @js_async.Promise[Uint8Array],
) -> NotebookSerializer =
  #| (deserialize, serialize) => ({
  #|   deserializeNotebook: (content, token) => deserialize(content, token),
  #|   serializeNotebook: (data, token) => serialize(data, token),
  #| })

///|
extern "js" fn notebook_edit_replace_cells_ffi(
  range : NotebookRange,
  new_cells : Array[NotebookCellData],
) -> NotebookEdit =
  #| (range, newCells) => require("vscode").NotebookEdit.replaceCells(range, newCells)

///|
extern "js" fn notebook_edit_insert_cells_ffi(
  index : Int,
  new_cells : Array[NotebookCellData],
) -> NotebookEdit =
  #| (index, newCells) => require("vscode").NotebookEdit.insertCells(index, newCells)

///|
extern "js" fn notebook_edit_delete_cells_ffi(
  range : NotebookRange,
) -> NotebookEdit =
  #| (range) => require("vscode").NotebookEdit.deleteCells(range)

///|
extern "js" fn notebook_edit_update_cell_metadata_ffi(
  index : Int,
  new_cell_metadata : JsValue,
) -> NotebookEdit =
  #| (index, newCellMetadata) =>
  #|   require("vscode").NotebookEdit.updateCellMetadata(index, newCellMetadata)

///|
extern "js" fn notebook_edit_update_notebook_metadata_ffi(
  new_notebook_metadata : JsValue,
) -> NotebookEdit =
  #| (newNotebookMetadata) =>
  #|   require("vscode").NotebookEdit.updateNotebookMetadata(newNotebookMetadata)

///|
extern "js" fn notebook_edit_ffi(
  range : NotebookRange,
  new_cells : Array[NotebookCellData],
) -> NotebookEdit =
  #| (range, newCells) => new (require("vscode").NotebookEdit)(range, newCells)

///|
pub extern "js" fn NotebookEdit::range(self : NotebookEdit) -> NotebookRange =
  #| (value) => value.range

///|
pub extern "js" fn NotebookEdit::set_range(
  self : NotebookEdit,
  value : NotebookRange,
) -> Unit =
  #| (item, value) => { item.range = value; }

///|
pub extern "js" fn NotebookEdit::new_cells(
  self : NotebookEdit,
) -> Array[NotebookCellData] =
  #| (value) => value.newCells

///|
pub extern "js" fn NotebookEdit::set_new_cells(
  self : NotebookEdit,
  value : Array[NotebookCellData],
) -> Unit =
  #| (item, value) => { item.newCells = value; }

///|
pub fn NotebookEdit::new_cell_metadata(self : NotebookEdit) -> Any? {
  let raw = NotebookEdit::new_cell_metadata_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn NotebookEdit::set_new_cell_metadata(
  self : NotebookEdit,
  value : Any,
) -> Unit {
  NotebookEdit::set_new_cell_metadata_raw(self, JsValue::make(value))
}

///|
pub fn NotebookEdit::clear_new_cell_metadata(self : NotebookEdit) -> Unit {
  NotebookEdit::set_new_cell_metadata_raw(self, JsValue::make(()))
}

///|
pub fn NotebookEdit::new_notebook_metadata(self : NotebookEdit) -> Any? {
  let raw = NotebookEdit::new_notebook_metadata_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn NotebookEdit::set_new_notebook_metadata(
  self : NotebookEdit,
  value : Any,
) -> Unit {
  NotebookEdit::set_new_notebook_metadata_raw(self, JsValue::make(value))
}

///|
pub fn NotebookEdit::clear_new_notebook_metadata(self : NotebookEdit) -> Unit {
  NotebookEdit::set_new_notebook_metadata_raw(self, JsValue::make(()))
}

///|
extern "js" fn NotebookEdit::new_cell_metadata_raw(
  self : NotebookEdit,
) -> JsValue =
  #| (value) => value.newCellMetadata

///|
extern "js" fn NotebookEdit::set_new_cell_metadata_raw(
  self : NotebookEdit,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.newCellMetadata = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn NotebookEdit::new_notebook_metadata_raw(
  self : NotebookEdit,
) -> JsValue =
  #| (value) => value.newNotebookMetadata

///|
extern "js" fn NotebookEdit::set_new_notebook_metadata_raw(
  self : NotebookEdit,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.newNotebookMetadata = value === undefined || value === null ? undefined : value; }

///|
/// Utility to create a edit that replaces cells in a notebook.
///
/// @param range The range of cells to replace
/// @param newCells The new notebook cells.
pub fn NotebookEdit::replace_cells(
  range : NotebookRange,
  new_cells : Array[NotebookCellData],
) -> NotebookEdit {
  notebook_edit_replace_cells_ffi(range, new_cells)
}

///|
/// Utility to create an edit that replaces cells in a notebook.
///
/// @param index The index to insert cells at.
/// @param newCells The new notebook cells.
pub fn NotebookEdit::insert_cells(
  index : Int,
  new_cells : Array[NotebookCellData],
) -> NotebookEdit {
  notebook_edit_insert_cells_ffi(index, new_cells)
}

///|
/// Utility to create an edit that deletes cells in a notebook.
///
/// @param range The range of cells to delete.
pub fn NotebookEdit::delete_cells(range : NotebookRange) -> NotebookEdit {
  notebook_edit_delete_cells_ffi(range)
}

///|
/// Utility to create an edit that update a cell's metadata.
///
/// @param index The index of the cell to update.
/// @param newCellMetadata The new metadata for the cell.
pub fn NotebookEdit::update_cell_metadata(
  index : Int,
  new_cell_metadata : Any,
) -> NotebookEdit {
  notebook_edit_update_cell_metadata_ffi(
    index,
    JsValue::make(new_cell_metadata),
  )
}

///|
/// Utility to create an edit that updates the notebook's metadata.
///
/// @param newNotebookMetadata The new metadata for the notebook.
pub fn NotebookEdit::update_notebook_metadata(
  new_notebook_metadata : Any,
) -> NotebookEdit {
  notebook_edit_update_notebook_metadata_ffi(
    JsValue::make(new_notebook_metadata),
  )
}

///|
/// Create a new notebook edit.
///
/// @param range A notebook range.
/// @param newCells An array of new cell data.
pub fn NotebookEdit::new(
  range : NotebookRange,
  new_cells : Array[NotebookCellData],
) -> NotebookEdit {
  notebook_edit_ffi(range, new_cells)
}

///|
/// Range of the cells being edited. May be empty.

///|
/// New cells being inserted. May be empty.

///|
/// Optional new metadata for the cells.

///|
/// Optional new metadata for the notebook.
