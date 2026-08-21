///|
/// VS Code Window API bindings for the JS backend.
using @vscode {
  type CancellationToken,
  type ColorTheme,
  type CustomEditorProviderOptions,
  type DecorationRenderOptions,
  type Event,
  type InputBox,
  type InputBoxOptions,
  type MessageOptions,
  type NotebookDocument,
  type NotebookDocumentShowOptions,
  type NotebookEditor,
  type NotebookEditorSelectionChangeEvent,
  type NotebookEditorVisibleRangesChangeEvent,
  type OpenDialogOptions,
  type OutputChannel,
  type LogOutputChannel,
  type Progress,
  type ProgressLocation,
  type ProgressLocationValue,
  type ProgressOptions,
  type QuickPick,
  type QuickPickItem,
  type QuickPickOptions,
  type SaveDialogOptions,
  type StatusBarAlignment,
  type StatusBarItem,
  type TabGroups,
  type Terminal,
  type ExtensionTerminalOptions,
  type TerminalOptions,
  type TerminalShellExecutionEndEvent,
  type TerminalShellExecutionStartEvent,
  type TerminalShellIntegrationChangeEvent,
  type TextDocument,
  type TextDocumentShowOptions,
  type TextEditor,
  type TextEditorDecorationType,
  type TextEditorOptionsChangeEvent,
  type TextEditorSelectionChangeEvent,
  type TextEditorViewColumnChangeEvent,
  type TextEditorVisibleRangesChangeEvent,
  type TreeView,
  type TreeViewOptions,
  type TreeItem,
  type Uri,
  type ViewColumn,
  type WebviewPanel,
  type WebviewPanelOptions,
  type WebviewViewOptions,
  type WindowState,
  type WorkspaceFolder,
  type WorkspaceFolderPickOptions,
}

///|
fn option_text_document_show_options_to_js(
  value : TextDocumentShowOptions?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => text_document_show_options_to_js(value)
  }
}

///|
fn option_notebook_document_show_options_to_js(
  value : NotebookDocumentShowOptions?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => notebook_document_show_options_to_js(value)
  }
}

///|
fn view_column_to_js(value : ViewColumn) -> @v.JsValue {
  let raw = match value {
    Active => -1
    Beside => -2
    One => 1
    Two => 2
    Three => 3
    Four => 4
    Five => 5
    Six => 6
    Seven => 7
    Eight => 8
    Nine => 9
    Custom(value) => value
  }
  @v.JsValue::make(raw)
}

///|
fn window_option_view_column_to_js(value : ViewColumn?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => view_column_to_js(value)
  }
}

///|
fn option_quick_pick_options_to_js(value : QuickPickOptions?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => quick_pick_options_to_js(value)
  }
}

///|
fn option_workspace_folder_pick_options_to_js(
  value : WorkspaceFolderPickOptions?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => workspace_folder_pick_options_to_js(value)
  }
}

///|
fn option_open_dialog_options_to_js(value : OpenDialogOptions?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => open_dialog_options_to_js(value)
  }
}

///|
fn option_save_dialog_options_to_js(value : SaveDialogOptions?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => save_dialog_options_to_js(value)
  }
}

///|
fn option_input_box_options_to_js(value : InputBoxOptions?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => input_box_options_to_js(value)
  }
}

///|
fn option_webview_panel_options_to_js(
  value : WebviewPanelOptions?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => webview_panel_options_to_js(value)
  }
}

///|
fn option_webview_view_options_to_js(value : WebviewViewOptions?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => webview_view_options_to_js(value)
  }
}

///|
fn option_custom_editor_provider_options_to_js(
  value : CustomEditorProviderOptions?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => custom_editor_provider_options_to_js(value)
  }
}

///|
fn text_document_show_options_to_js(
  value : TextDocumentShowOptions,
) -> @v.JsValue {
  window_text_document_show_options_to_js_ffi(
    window_option_view_column_to_js(value.view_column),
    @v.option_to_js(value.preserve_focus),
    @v.option_to_js(value.preview),
    @v.option_to_js(value.selection),
  )
}

///|
fn notebook_document_show_options_to_js(
  value : NotebookDocumentShowOptions,
) -> @v.JsValue {
  window_notebook_document_show_options_to_js_ffi(
    window_option_view_column_to_js(value.view_column),
    @v.option_to_js(value.preserve_focus),
    @v.option_to_js(value.preview),
    @v.option_to_js(value.selections),
  )
}

///|
fn workspace_folder_pick_options_to_js(
  value : WorkspaceFolderPickOptions,
) -> @v.JsValue {
  window_workspace_folder_pick_options_to_js_ffi(
    @v.option_to_js(value.place_holder),
    @v.option_to_js(value.ignore_focus_out),
  )
}

///|
fn open_dialog_options_to_js(value : OpenDialogOptions) -> @v.JsValue {
  window_open_dialog_options_to_js_ffi(
    @v.option_to_js(value.default_uri),
    @v.option_to_js(value.open_label),
    @v.option_to_js(value.can_select_files),
    @v.option_to_js(value.can_select_folders),
    @v.option_to_js(value.can_select_many),
    option_dialog_filters_to_js(value.filters),
    @v.option_to_js(value.title),
  )
}

///|
fn save_dialog_options_to_js(value : SaveDialogOptions) -> @v.JsValue {
  window_save_dialog_options_to_js_ffi(
    @v.option_to_js(value.default_uri),
    @v.option_to_js(value.save_label),
    option_dialog_filters_to_js(value.filters),
    @v.option_to_js(value.title),
  )
}

///|
fn option_dialog_filters_to_js(value : @vscode.DialogFilters?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => window_dialog_filters_to_js_ffi(value.pairs)
  }
}

///|
fn quick_pick_select_item_callback_to_js(
  value : @vscode.QuickPickSelectItemCallback?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(QuickPickItem(callback)) =>
      @v.JsValue::make((item : QuickPickItem) => callback(item))
    Some(StringItem(callback)) =>
      @v.JsValue::make((item : String) => callback(item))
  }
}

///|
fn quick_pick_options_to_js(value : QuickPickOptions) -> @v.JsValue {
  window_quick_pick_options_to_js_ffi(
    @v.option_to_js(value.title),
    @v.option_to_js(value.match_on_description),
    @v.option_to_js(value.match_on_detail),
    @v.option_to_js(value.place_holder),
    @v.option_to_js(value.prompt),
    @v.option_to_js(value.ignore_focus_out),
    @v.option_to_js(value.can_pick_many),
    quick_pick_select_item_callback_to_js(value.on_did_select_item),
  )
}

///|
fn option_input_box_validation_result_to_js(
  value : @vscode.InputBoxValidationResult?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => input_box_validation_result_to_js(value)
  }
}

///|
fn input_box_validation_result_to_js(
  value : @vscode.InputBoxValidationResult,
) -> @v.JsValue {
  match value {
    Text(value) => @v.JsValue::make(value)
    Message(value) =>
      window_input_box_validation_message_to_js_ffi(
        value.message,
        value.severity,
      )
  }
}

///|
fn input_box_validate_input_to_js(
  validate_input : @vscode.InputBoxValidateInput?,
) -> @v.JsValue {
  match validate_input {
    None => @v.JsValue::make(())
    Some(Sync(callback)) =>
      @v.JsValue::make((value : String) => {
        option_input_box_validation_result_to_js(callback(value))
      })
    Some(Async(callback)) =>
      @v.JsValue::make((value : String) => {
        @js_async.Promise::from_async(async fn() {
          option_input_box_validation_result_to_js(callback(value))
        })
      })
  }
}

///|
fn input_box_options_to_js(value : InputBoxOptions) -> @v.JsValue {
  window_input_box_options_to_js_ffi(
    @v.option_to_js(value.title),
    @v.option_to_js(value.value),
    @v.option_to_js(value.value_selection),
    @v.option_to_js(value.prompt),
    @v.option_to_js(value.place_holder),
    @v.option_to_js(value.password),
    @v.option_to_js(value.ignore_focus_out),
    input_box_validate_input_to_js(value.validate_input),
  )
}

///|
fn webview_panel_options_to_js(value : WebviewPanelOptions) -> @v.JsValue {
  window_webview_panel_options_to_js_ffi(
    @v.option_to_js(value.enable_find_widget),
    @v.option_to_js(value.retain_context_when_hidden),
  )
}

///|
fn webview_view_options_to_js(value : WebviewViewOptions) -> @v.JsValue {
  window_webview_view_options_to_js_ffi(
    @v.option_to_js(value.retain_context_when_hidden),
  )
}

///|
fn custom_editor_provider_options_to_js(
  value : CustomEditorProviderOptions,
) -> @v.JsValue {
  window_custom_editor_provider_options_to_js_ffi(
    option_webview_panel_options_to_js(value.webview_options),
    @v.option_to_js(value.supports_multiple_editors_per_document),
  )
}

///|
fn progress_location_value_to_js(value : ProgressLocationValue) -> @v.JsValue {
  match value {
    Location(value) => @v.JsValue::make(value)
    View(value) => window_progress_location_view_to_js_ffi(value)
  }
}

///|
fn progress_options_to_js(value : ProgressOptions) -> @v.JsValue {
  window_progress_options_to_js_ffi(
    progress_location_value_to_js(value.location),
    @v.option_to_js(value.title),
    @v.option_to_js(value.cancellable),
  )
}

///|
extern "js" fn window_text_document_show_options_to_js_ffi(
  view_column : @v.JsValue,
  preserve_focus : @v.JsValue,
  preview : @v.JsValue,
  selection : @v.JsValue,
) -> @v.JsValue =
  #| (viewColumn, preserveFocus, preview, selection) => {
  #|   const options = {};
  #|   if (viewColumn !== undefined && viewColumn !== null) options.viewColumn = viewColumn;
  #|   if (preserveFocus !== undefined && preserveFocus !== null) options.preserveFocus = preserveFocus;
  #|   if (preview !== undefined && preview !== null) options.preview = preview;
  #|   if (selection !== undefined && selection !== null) options.selection = selection;
  #|   return options;
  #| }

///|
extern "js" fn window_notebook_document_show_options_to_js_ffi(
  view_column : @v.JsValue,
  preserve_focus : @v.JsValue,
  preview : @v.JsValue,
  selections : @v.JsValue,
) -> @v.JsValue =
  #| (viewColumn, preserveFocus, preview, selections) => {
  #|   const options = {};
  #|   if (viewColumn !== undefined && viewColumn !== null) options.viewColumn = viewColumn;
  #|   if (preserveFocus !== undefined && preserveFocus !== null) options.preserveFocus = preserveFocus;
  #|   if (preview !== undefined && preview !== null) options.preview = preview;
  #|   if (selections !== undefined && selections !== null) options.selections = selections;
  #|   return options;
  #| }

///|
extern "js" fn window_workspace_folder_pick_options_to_js_ffi(
  place_holder : @v.JsValue,
  ignore_focus_out : @v.JsValue,
) -> @v.JsValue =
  #| (placeHolder, ignoreFocusOut) => {
  #|   const options = {};
  #|   if (placeHolder !== undefined && placeHolder !== null) options.placeHolder = placeHolder;
  #|   if (ignoreFocusOut !== undefined && ignoreFocusOut !== null) options.ignoreFocusOut = ignoreFocusOut;
  #|   return options;
  #| }

///|
extern "js" fn window_open_dialog_options_to_js_ffi(
  default_uri : @v.JsValue,
  open_label : @v.JsValue,
  can_select_files : @v.JsValue,
  can_select_folders : @v.JsValue,
  can_select_many : @v.JsValue,
  filters : @v.JsValue,
  title : @v.JsValue,
) -> @v.JsValue =
  #| (defaultUri, openLabel, canSelectFiles, canSelectFolders, canSelectMany, filters, title) => {
  #|   const options = {};
  #|   if (defaultUri !== undefined && defaultUri !== null) options.defaultUri = defaultUri;
  #|   if (openLabel !== undefined && openLabel !== null) options.openLabel = openLabel;
  #|   if (canSelectFiles !== undefined && canSelectFiles !== null) options.canSelectFiles = canSelectFiles;
  #|   if (canSelectFolders !== undefined && canSelectFolders !== null) options.canSelectFolders = canSelectFolders;
  #|   if (canSelectMany !== undefined && canSelectMany !== null) options.canSelectMany = canSelectMany;
  #|   if (filters !== undefined && filters !== null) options.filters = filters;
  #|   if (title !== undefined && title !== null) options.title = title;
  #|   return options;
  #| }

///|
extern "js" fn window_save_dialog_options_to_js_ffi(
  default_uri : @v.JsValue,
  save_label : @v.JsValue,
  filters : @v.JsValue,
  title : @v.JsValue,
) -> @v.JsValue =
  #| (defaultUri, saveLabel, filters, title) => {
  #|   const options = {};
  #|   if (defaultUri !== undefined && defaultUri !== null) options.defaultUri = defaultUri;
  #|   if (saveLabel !== undefined && saveLabel !== null) options.saveLabel = saveLabel;
  #|   if (filters !== undefined && filters !== null) options.filters = filters;
  #|   if (title !== undefined && title !== null) options.title = title;
  #|   return options;
  #| }

///|
extern "js" fn window_quick_pick_options_to_js_ffi(
  title : @v.JsValue,
  match_on_description : @v.JsValue,
  match_on_detail : @v.JsValue,
  place_holder : @v.JsValue,
  prompt : @v.JsValue,
  ignore_focus_out : @v.JsValue,
  can_pick_many : @v.JsValue,
  on_did_select_item : @v.JsValue,
) -> @v.JsValue =
  #| (title, matchOnDescription, matchOnDetail, placeHolder, prompt, ignoreFocusOut, canPickMany, onDidSelectItem) => {
  #|   const options = {};
  #|   if (title !== undefined && title !== null) options.title = title;
  #|   if (matchOnDescription !== undefined && matchOnDescription !== null) options.matchOnDescription = matchOnDescription;
  #|   if (matchOnDetail !== undefined && matchOnDetail !== null) options.matchOnDetail = matchOnDetail;
  #|   if (placeHolder !== undefined && placeHolder !== null) options.placeHolder = placeHolder;
  #|   if (prompt !== undefined && prompt !== null) options.prompt = prompt;
  #|   if (ignoreFocusOut !== undefined && ignoreFocusOut !== null) options.ignoreFocusOut = ignoreFocusOut;
  #|   if (canPickMany !== undefined && canPickMany !== null) options.canPickMany = canPickMany;
  #|   if (onDidSelectItem !== undefined && onDidSelectItem !== null) options.onDidSelectItem = onDidSelectItem;
  #|   return options;
  #| }

///|
extern "js" fn window_input_box_options_to_js_ffi(
  title : @v.JsValue,
  value : @v.JsValue,
  value_selection : @v.JsValue,
  prompt : @v.JsValue,
  place_holder : @v.JsValue,
  password : @v.JsValue,
  ignore_focus_out : @v.JsValue,
  validate_input : @v.JsValue,
) -> @v.JsValue =
  #| (title, value, valueSelection, prompt, placeHolder, password, ignoreFocusOut, validateInput) => {
  #|   const options = {};
  #|   if (title !== undefined && title !== null) options.title = title;
  #|   if (value !== undefined && value !== null) options.value = value;
  #|   if (valueSelection !== undefined && valueSelection !== null) options.valueSelection = valueSelection;
  #|   if (prompt !== undefined && prompt !== null) options.prompt = prompt;
  #|   if (placeHolder !== undefined && placeHolder !== null) options.placeHolder = placeHolder;
  #|   if (password !== undefined && password !== null) options.password = password;
  #|   if (ignoreFocusOut !== undefined && ignoreFocusOut !== null) options.ignoreFocusOut = ignoreFocusOut;
  #|   if (validateInput !== undefined && validateInput !== null) options.validateInput = validateInput;
  #|   return options;
  #| }

///|
extern "js" fn window_input_box_validation_message_to_js_ffi(
  message : String,
  severity : @vscode.InputBoxValidationSeverity,
) -> @v.JsValue =
  #| (message, severity) => ({ message, severity })

///|
extern "js" fn window_webview_panel_options_to_js_ffi(
  enable_find_widget : @v.JsValue,
  retain_context_when_hidden : @v.JsValue,
) -> @v.JsValue =
  #| (enableFindWidget, retainContextWhenHidden) => {
  #|   const options = {};
  #|   if (enableFindWidget !== undefined && enableFindWidget !== null) {
  #|     options.enableFindWidget = enableFindWidget;
  #|   }
  #|   if (retainContextWhenHidden !== undefined && retainContextWhenHidden !== null) {
  #|     options.retainContextWhenHidden = retainContextWhenHidden;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn window_webview_view_options_to_js_ffi(
  retain_context_when_hidden : @v.JsValue,
) -> @v.JsValue =
  #| (retainContextWhenHidden) => {
  #|   const options = {};
  #|   if (retainContextWhenHidden !== undefined && retainContextWhenHidden !== null) {
  #|     options.retainContextWhenHidden = retainContextWhenHidden;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn window_custom_editor_provider_options_to_js_ffi(
  webview_options : @v.JsValue,
  supports_multiple_editors_per_document : @v.JsValue,
) -> @v.JsValue =
  #| (webviewOptions, supportsMultipleEditorsPerDocument) => {
  #|   const options = {};
  #|   if (webviewOptions !== undefined && webviewOptions !== null) options.webviewOptions = webviewOptions;
  #|   if (supportsMultipleEditorsPerDocument !== undefined && supportsMultipleEditorsPerDocument !== null) {
  #|     options.supportsMultipleEditorsPerDocument = supportsMultipleEditorsPerDocument;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn window_progress_location_view_to_js_ffi(
  view_id : String,
) -> @v.JsValue =
  #| (viewId) => ({ viewId })

///|
extern "js" fn window_progress_options_to_js_ffi(
  location : @v.JsValue,
  title : @v.JsValue,
  cancellable : @v.JsValue,
) -> @v.JsValue =
  #| (location, title, cancellable) => {
  #|   const options = { location };
  #|   if (title !== undefined && title !== null) options.title = title;
  #|   if (cancellable !== undefined && cancellable !== null) options.cancellable = cancellable;
  #|   return options;
  #| }

///|
extern "js" fn window_dialog_filters_to_js_ffi(
  entries : Array[(String, Array[String])],
) -> @v.JsValue =
  #| (pairs) => {
  #|   const result = {};
  #|   for (const pair of pairs) {
  #|     const key = pair._0 ?? pair[0];
  #|     const value = pair._1 ?? pair[1];
  #|     result[key] = value;
  #|   }
  #|   return result;
  #| }

///|
/// Represents the grid widget within the main editor area
pub fn tab_groups() -> TabGroups {
  window_tab_groups_ffi()
}

///|
/// The currently active editor or `undefined`. The active editor is the one
/// that currently has focus or, when none has focus, the one that has changed
/// input most recently.
pub fn active_text_editor() -> TextEditor? {
  let raw = window_active_text_editor_ffi()
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The currently visible editors or an empty array.
pub fn visible_text_editors() -> Array[TextEditor] {
  window_visible_text_editors_ffi()
}

///|
/// An {@link Event} which fires when the {@link window.activeTextEditor active editor}
/// has changed. *Note* that the event also fires when the active editor changes
/// to `undefined`.
pub fn on_did_change_active_text_editor() -> Event[TextEditor?] {
  window_on_did_change_active_text_editor_ffi()
}

///|
/// An {@link Event} which fires when the array of {@link window.visibleTextEditors visible editors}
/// has changed.
pub fn on_did_change_visible_text_editors() -> Event[Array[TextEditor]] {
  window_on_did_change_visible_text_editors_ffi()
}

///|
/// An {@link Event} which fires when the selection in an editor has changed.
pub fn on_did_change_text_editor_selection() -> Event[
  TextEditorSelectionChangeEvent,
] {
  window_on_did_change_text_editor_selection_ffi()
}

///|
/// An {@link Event} which fires when the visible ranges of an editor has changed.
pub fn on_did_change_text_editor_visible_ranges() -> Event[
  TextEditorVisibleRangesChangeEvent,
] {
  window_on_did_change_text_editor_visible_ranges_ffi()
}

///|
/// An {@link Event} which fires when the options of an editor have changed.
pub fn on_did_change_text_editor_options() -> Event[
  TextEditorOptionsChangeEvent,
] {
  window_on_did_change_text_editor_options_ffi()
}

///|
/// An {@link Event} which fires when the view column of an editor has changed.
pub fn on_did_change_text_editor_view_column() -> Event[
  TextEditorViewColumnChangeEvent,
] {
  window_on_did_change_text_editor_view_column_ffi()
}

///|
/// The currently visible {@link NotebookEditor notebook editors} or an empty array.
pub fn visible_notebook_editors() -> Array[NotebookEditor] {
  window_visible_notebook_editors_ffi()
}

///|
/// An {@link Event} which fires when the {@link window.visibleNotebookEditors visible notebook editors}
/// has changed.
pub fn on_did_change_visible_notebook_editors() -> Event[Array[NotebookEditor]] {
  window_on_did_change_visible_notebook_editors_ffi()
}

///|
/// The currently active {@link NotebookEditor notebook editor} or `undefined`. The active editor is the one
/// that currently has focus or, when none has focus, the one that has changed
/// input most recently.
pub fn active_notebook_editor() -> NotebookEditor? {
  let raw = window_active_notebook_editor_ffi()
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An {@link Event} which fires when the {@link window.activeNotebookEditor active notebook editor}
/// has changed. *Note* that the event also fires when the active editor changes
/// to `undefined`.
pub fn on_did_change_active_notebook_editor() -> Event[NotebookEditor?] {
  window_on_did_change_active_notebook_editor_ffi()
}

///|
/// An {@link Event} which fires when the {@link NotebookEditor.selections notebook editor selections}
/// have changed.
pub fn on_did_change_notebook_editor_selection() -> Event[
  NotebookEditorSelectionChangeEvent,
] {
  window_on_did_change_notebook_editor_selection_ffi()
}

///|
/// An {@link Event} which fires when the {@link NotebookEditor.visibleRanges notebook editor visible ranges}
/// have changed.
pub fn on_did_change_notebook_editor_visible_ranges() -> Event[
  NotebookEditorVisibleRangesChangeEvent,
] {
  window_on_did_change_notebook_editor_visible_ranges_ffi()
}

///|
/// The currently opened terminals or an empty array.
pub fn terminals() -> Array[Terminal] {
  window_terminals_ffi()
}

///|
/// The currently active terminal or `undefined`. The active terminal is the one that
/// currently has focus or most recently had focus.
pub fn active_terminal() -> Terminal? {
  let raw = window_active_terminal_ffi()
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An {@link Event} which fires when the {@link window.activeTerminal active terminal}
/// has changed. *Note* that the event also fires when the active terminal changes
/// to `undefined`.
pub fn on_did_change_active_terminal() -> Event[Terminal?] {
  window_on_did_change_active_terminal_ffi()
}

///|
/// An {@link Event} which fires when a terminal has been created, either through the
/// {@link window.createTerminal createTerminal} API or commands.
pub fn on_did_open_terminal() -> Event[Terminal] {
  window_on_did_open_terminal_ffi()
}

///|
/// An {@link Event} which fires when a terminal is disposed.
pub fn on_did_close_terminal() -> Event[Terminal] {
  window_on_did_close_terminal_ffi()
}

///|
/// An {@link Event} which fires when a {@link Terminal.state terminal's state} has changed.
pub fn on_did_change_terminal_state() -> Event[Terminal] {
  window_on_did_change_terminal_state_ffi()
}

///|
/// Fires when shell integration activates or one of its properties changes in a terminal.
pub fn on_did_change_terminal_shell_integration() -> Event[
  TerminalShellIntegrationChangeEvent,
] {
  window_on_did_change_terminal_shell_integration_ffi()
}

///|
/// This will be fired when a terminal command is started. This event will fire only when
/// [shell integration](https://code.visualstudio.com/docs/terminal/shell-integration) is
/// activated for the terminal.
pub fn on_did_start_terminal_shell_execution() -> Event[
  TerminalShellExecutionStartEvent,
] {
  window_on_did_start_terminal_shell_execution_ffi()
}

///|
/// This will be fired when a terminal command is ended. This event will fire only when
/// [shell integration](https://code.visualstudio.com/docs/terminal/shell-integration) is
/// activated for the terminal.
pub fn on_did_end_terminal_shell_execution() -> Event[
  TerminalShellExecutionEndEvent,
] {
  window_on_did_end_terminal_shell_execution_ffi()
}

///|
/// Represents the current window's state.
pub fn state() -> WindowState {
  window_state_ffi()
}

///|
/// An {@link Event} which fires when the focus or activity state of the current window
/// changes. The value of the event represents whether the window is focused.
pub fn on_did_change_window_state() -> Event[WindowState] {
  window_on_did_change_window_state_ffi()
}

///|
/// The currently active color theme as configured in the settings. The active
/// theme can be changed via the `workbench.colorTheme` setting.
pub fn active_color_theme() -> ColorTheme {
  window_active_color_theme_ffi()
}

///|
/// An {@link Event} which fires when the active color theme is changed or has changes.
pub fn on_did_change_active_color_theme() -> Event[ColorTheme] {
  window_on_did_change_active_color_theme_ffi()
}

///|
/// Show documents/editors (raw JS promise).
fn window_show_text_document_raw_promise(
  document_or_uri : @v.JsValue,
  options : @v.JsValue,
) -> @js_async.Promise[TextEditor] {
  window_show_text_document_ffi(document_or_uri, options)
}

///|
/// Show documents/editors.
fn[T : @vscode.WebviewViewProvider] webview_view_provider_object(
  provider : T,
) -> @providers.WebviewViewProviderObject {
  @providers.WebviewViewProviderObject::new(async fn(view, context, token) {
    provider.resolve_webview_view(view, context, token)
  })
}

///|
fn[T : @vscode.TerminalLinkProvider] terminal_link_provider_object(
  provider : T,
) -> @providers.TerminalLinkProviderObject {
  @providers.TerminalLinkProviderObject::new(
    async fn(context, token) { provider.provide_terminal_links(context, token) },
    handle_link=async fn(link) { provider.handle_terminal_link(link) },
  )
}

///|
fn[T : @vscode.TerminalProfileProvider] terminal_profile_provider_object(
  provider : T,
) -> @providers.TerminalProfileProviderObject {
  @providers.TerminalProfileProviderObject::new(async fn(token) {
    provider.provide_terminal_profile(token)
  })
}

///|
fn[T : @vscode.FileDecorationProvider] file_decoration_provider_object(
  provider : T,
) -> @providers.FileDecorationProviderObject {
  match provider.on_did_change_file_decorations() {
    None =>
      @providers.FileDecorationProviderObject::new(async fn(uri, token) {
        provider.provide_file_decoration(uri, token)
      })
    Some(on_did_change) =>
      @providers.FileDecorationProviderObject::new(
        async fn(uri, token) { provider.provide_file_decoration(uri, token) },
        on_did_change~,
      )
  }
}

///|
fn[T : @vscode.CustomTextEditorProvider] custom_text_editor_provider_object(
  provider : T,
) -> @providers.CustomEditorProviderObject {
  @v.JsValue::make(
    @providers.CustomTextEditorProviderObject::new(async fn(
      document,
      panel,
      token,
    ) {
      provider.resolve_custom_text_editor(document, panel, token)
    }),
  ).cast()
}

///|
fn[T : @vscode.CustomReadonlyEditorProvider] custom_readonly_editor_provider_object(
  provider : T,
) -> @providers.CustomEditorProviderObject {
  @v.JsValue::make(
    @providers.CustomReadonlyEditorProviderObject::new(
      async fn(uri, context, token) {
        provider.open_custom_document(uri, context, token)
      },
      async fn(document, panel, token) {
        provider.resolve_custom_editor(document, panel, token)
      },
    ),
  ).cast()
}

///|
fn[T : @vscode.CustomEditorProvider] custom_editor_provider_object(
  provider : T,
) -> @providers.CustomEditorProviderObject {
  match provider.on_did_change_custom_document() {
    None =>
      @providers.CustomEditorProviderObject::new(
        async fn(uri, context, token) {
          provider.open_custom_document(uri, context, token)
        },
        async fn(document, panel, token) {
          provider.resolve_custom_editor(document, panel, token)
        },
        async fn(document, token) {
          provider.save_custom_document(document, token)
        },
        async fn(document, destination, token) {
          provider.save_custom_document_as(document, destination, token)
        },
        async fn(document, token) {
          provider.revert_custom_document(document, token)
        },
        async fn(document, context, token) {
          provider.backup_custom_document(document, context, token)
        },
      )
    Some(on_did_change_custom_document) =>
      @providers.CustomEditorProviderObject::new(
        async fn(uri, context, token) {
          provider.open_custom_document(uri, context, token)
        },
        async fn(document, panel, token) {
          provider.resolve_custom_editor(document, panel, token)
        },
        async fn(document, token) {
          provider.save_custom_document(document, token)
        },
        async fn(document, destination, token) {
          provider.save_custom_document_as(document, destination, token)
        },
        async fn(document, token) {
          provider.revert_custom_document(document, token)
        },
        async fn(document, context, token) {
          provider.backup_custom_document(document, context, token)
        },
        on_did_change_custom_document~,
      )
  }
}

///|
fn[T] tree_data_provider_object(
  get_tree_item : async (T) -> TreeItem,
  get_children : async (T?) -> Array[T]?,
  on_did_change_tree_data : Event[T?]?,
  get_parent : (async (T) -> T?)?,
  resolve_tree_item : (async (TreeItem, T, CancellationToken) -> TreeItem?)?,
) -> @providers.TreeDataProviderObject[T] {
  match on_did_change_tree_data {
    None =>
      match get_parent {
        None =>
          match resolve_tree_item {
            None =>
              @providers.TreeDataProviderObject::new(
                get_tree_item, get_children,
              )
            Some(resolve_tree_item) =>
              @providers.TreeDataProviderObject::new(
                get_tree_item,
                get_children,
                resolve_tree_item~,
              )
          }
        Some(get_parent) =>
          match resolve_tree_item {
            None =>
              @providers.TreeDataProviderObject::new(
                get_tree_item,
                get_children,
                get_parent~,
              )
            Some(resolve_tree_item) =>
              @providers.TreeDataProviderObject::new(
                get_tree_item,
                get_children,
                get_parent~,
                resolve_tree_item~,
              )
          }
      }
    Some(on_did_change_tree_data) =>
      match get_parent {
        None =>
          match resolve_tree_item {
            None =>
              @providers.TreeDataProviderObject::new(
                get_tree_item,
                get_children,
                on_did_change_tree_data~,
              )
            Some(resolve_tree_item) =>
              @providers.TreeDataProviderObject::new(
                get_tree_item,
                get_children,
                on_did_change_tree_data~,
                resolve_tree_item~,
              )
          }
        Some(get_parent) =>
          match resolve_tree_item {
            None =>
              @providers.TreeDataProviderObject::new(
                get_tree_item,
                get_children,
                on_did_change_tree_data~,
                get_parent~,
              )
            Some(resolve_tree_item) =>
              @providers.TreeDataProviderObject::new(
                get_tree_item,
                get_children,
                on_did_change_tree_data~,
                get_parent~,
                resolve_tree_item~,
              )
          }
      }
  }
}

///|
/// Show the given document in a text editor. A {@link ViewColumn column} can be provided
/// to control where the editor is being shown. Might change the {@link window.activeTextEditor active editor}.
///
/// @param document A text document to be shown.
/// @param column A view column in which the {@link TextEditor editor} should be shown. The default is the {@link ViewColumn.Active active}.
/// Columns that do not exist will be created as needed up to the maximum of {@linkcode ViewColumn.Nine}. Use {@linkcode ViewColumn.Beside}
/// to open the editor to the side of the currently active one.
/// @param preserveFocus When `true` the editor will not take focus.
/// @returns A promise that resolves to an {@link TextEditor editor}.
pub async fn show_text_document(
  document : TextDocument,
  options? : TextDocumentShowOptions,
) -> TextEditor {
  @js_async.Promise::wait(
    window_show_text_document_raw_promise(
      @v.JsValue::make(document),
      option_text_document_show_options_to_js(options),
    ),
  )
}

///|
/// Show the given document in a text editor. A {@link ViewColumn column} can be provided
/// to control where the editor is being shown. Might change the {@link window.activeTextEditor active editor}.
///
/// @param document A text document to be shown.
/// @param column A view column in which the {@link TextEditor editor} should be shown. The default is the {@link ViewColumn.Active active}.
/// Columns that do not exist will be created as needed up to the maximum of {@linkcode ViewColumn.Nine}. Use {@linkcode ViewColumn.Beside}
/// to open the editor to the side of the currently active one.
/// @param preserveFocus When `true` the editor will not take focus.
/// @returns A promise that resolves to an {@link TextEditor editor}.
pub async fn show_text_document_uri(
  uri : Uri,
  options? : TextDocumentShowOptions,
) -> TextEditor {
  @js_async.Promise::wait(
    window_show_text_document_raw_promise(
      @v.JsValue::make(uri),
      option_text_document_show_options_to_js(options),
    ),
  )
}

///|
fn window_show_notebook_document_promise(
  document : NotebookDocument,
  options : @v.JsValue,
) -> @js_async.Promise[NotebookEditor] {
  window_show_notebook_document_ffi(document, options)
}

///|
/// Show the given {@link NotebookDocument} in a {@link NotebookEditor notebook editor}.
///
/// @param document A text document to be shown.
/// @param options {@link NotebookDocumentShowOptions Editor options} to configure the behavior of showing the {@link NotebookEditor notebook editor}.
///
/// @returns A promise that resolves to an {@link NotebookEditor notebook editor}.
pub async fn show_notebook_document(
  document : NotebookDocument,
  options? : NotebookDocumentShowOptions,
) -> NotebookEditor {
  @js_async.Promise::wait(
    window_show_notebook_document_promise(
      document,
      option_notebook_document_show_options_to_js(options),
    ),
  )
}

///|
/// Create a TextEditorDecorationType that can be used to add decorations to text editors.
///
/// @param options Rendering options for the decoration type.
/// @returns A new decoration type instance.
pub fn create_text_editor_decoration_type(
  options : DecorationRenderOptions,
) -> TextEditorDecorationType {
  window_create_text_editor_decoration_type_ffi(options)
}

///|
/// Messages (raw JS promise).
fn window_show_information_message_promise(
  message : String,
  options : @v.JsValue,
  items : Array[@v.JsValue],
) -> @js_async.Promise[@v.JsValue] {
  window_show_information_message_ffi(message, options, items)
}

///|
fn[X] window_message_selection(selection : @v.JsValue) -> X? {
  if @v.JsValue::is_null_or_undefined(selection) {
    None
  } else {
    Some(selection.cast())
  }
}

///|
fn[X] window_message_items_to_js(items : Array[X]) -> Array[@v.JsValue] {
  items.map(item => @v.JsValue::make(item))
}

///|
/// Show an information message to users. Optionally provide an array of items which will be presented as
/// clickable buttons.
///
/// @param message The message to show.
/// @param items A set of items that will be rendered as actions in the message.
/// @returns A thenable that resolves to the selected item or `undefined` when being dismissed.
pub async fn show_information_message(
  message : String,
  options? : MessageOptions,
) -> Unit {
  ignore(
    @js_async.Promise::wait(
      window_show_information_message_promise(
        message,
        @v.option_to_js(options),
        [],
      ),
    ),
  )
}

///|
/// Show an information message to users. Optionally provide an array of items which will be presented as
/// clickable buttons.
///
/// @param message The message to show.
/// @param items A set of items that will be rendered as actions in the message.
/// @returns A thenable that resolves to the selected item or `undefined` when being dismissed.
pub async fn[X] show_information_message_items(
  message : String,
  items : Array[X],
  options? : MessageOptions,
) -> X? {
  window_message_selection(
    @js_async.Promise::wait(
      window_show_information_message_promise(
        message,
        @v.option_to_js(options),
        window_message_items_to_js(items),
      ),
    ),
  )
}

///|
fn window_show_warning_message_promise(
  message : String,
  options : @v.JsValue,
  items : Array[@v.JsValue],
) -> @js_async.Promise[@v.JsValue] {
  window_show_warning_message_ffi(message, options, items)
}

///|
/// Show a warning message.
///
/// @see {@link window.showInformationMessage showInformationMessage}
///
/// @param message The message to show.
/// @param items A set of items that will be rendered as actions in the message.
/// @returns A thenable that resolves to the selected item or `undefined` when being dismissed.
pub async fn show_warning_message(
  message : String,
  options? : MessageOptions,
) -> Unit {
  ignore(
    @js_async.Promise::wait(
      window_show_warning_message_promise(message, @v.option_to_js(options), []),
    ),
  )
}

///|
/// Show a warning message.
///
/// @see {@link window.showInformationMessage showInformationMessage}
///
/// @param message The message to show.
/// @param items A set of items that will be rendered as actions in the message.
/// @returns A thenable that resolves to the selected item or `undefined` when being dismissed.
pub async fn[X] show_warning_message_items(
  message : String,
  items : Array[X],
  options? : MessageOptions,
) -> X? {
  window_message_selection(
    @js_async.Promise::wait(
      window_show_warning_message_promise(
        message,
        @v.option_to_js(options),
        window_message_items_to_js(items),
      ),
    ),
  )
}

///|
fn window_show_error_message_promise(
  message : String,
  options : @v.JsValue,
  items : Array[@v.JsValue],
) -> @js_async.Promise[@v.JsValue] {
  window_show_error_message_ffi(message, options, items)
}

///|
/// Show an error message.
///
/// @see {@link window.showInformationMessage showInformationMessage}
///
/// @param message The message to show.
/// @param items A set of items that will be rendered as actions in the message.
/// @returns A thenable that resolves to the selected item or `undefined` when being dismissed.
pub async fn show_error_message(
  message : String,
  options? : MessageOptions,
) -> Unit {
  ignore(
    @js_async.Promise::wait(
      window_show_error_message_promise(message, @v.option_to_js(options), []),
    ),
  )
}

///|
/// Show an error message.
///
/// @see {@link window.showInformationMessage showInformationMessage}
///
/// @param message The message to show.
/// @param items A set of items that will be rendered as actions in the message.
/// @returns A thenable that resolves to the selected item or `undefined` when being dismissed.
pub async fn[X] show_error_message_items(
  message : String,
  items : Array[X],
  options? : MessageOptions,
) -> X? {
  window_message_selection(
    @js_async.Promise::wait(
      window_show_error_message_promise(
        message,
        @v.option_to_js(options),
        window_message_items_to_js(items),
      ),
    ),
  )
}

///|
/// Pickers and dialogs (raw JS promise).
fn window_show_quick_pick_raw_promise(
  items : @v.JsValue,
  options : @v.JsValue,
  token : @v.JsValue,
) -> @js_async.Promise[@v.JsValue] {
  window_show_quick_pick_ffi(items, options, token)
}

///|
fn window_quick_pick_options_single(options : QuickPickOptions?) -> @v.JsValue {
  window_quick_pick_options_single_ffi(option_quick_pick_options_to_js(options))
}

///|
fn window_quick_pick_options_many(options : QuickPickOptions?) -> @v.JsValue {
  window_quick_pick_options_many_ffi(option_quick_pick_options_to_js(options))
}

///|
fn[X] window_message_selection_many(selection : @v.JsValue) -> Array[X]? {
  if @v.JsValue::is_null_or_undefined(selection) {
    None
  } else {
    Some(selection.cast())
  }
}

///|
/// Shows a selection list allowing multiple selections.
///
/// @param items An array of strings, or a promise that resolves to an array of strings.
/// @param options Configures the behavior of the selection list.
/// @param token A token that can be used to signal cancellation.
/// @returns A thenable that resolves to the selected items or `undefined`.
pub async fn show_quick_pick(
  items : Array[QuickPickItem],
  options? : QuickPickOptions,
  token? : CancellationToken,
) -> QuickPickItem? {
  window_message_selection(
    @js_async.Promise::wait(
      window_show_quick_pick_raw_promise(
        @v.JsValue::make(items),
        window_quick_pick_options_single(options),
        @v.option_to_js(token),
      ),
    ),
  )
}

///|
/// Shows a selection list allowing multiple selections.
///
/// @param items An array of strings, or a promise that resolves to an array of strings.
/// @param options Configures the behavior of the selection list.
/// @param token A token that can be used to signal cancellation.
/// @returns A thenable that resolves to the selected items or `undefined`.
pub async fn show_quick_pick_many(
  items : Array[QuickPickItem],
  options? : QuickPickOptions,
  token? : CancellationToken,
) -> Array[QuickPickItem]? {
  window_message_selection_many(
    @js_async.Promise::wait(
      window_show_quick_pick_raw_promise(
        @v.JsValue::make(items),
        window_quick_pick_options_many(options),
        @v.option_to_js(token),
      ),
    ),
  )
}

///|
/// Show a quick pick for string items and return the selected label (if any).
fn window_show_quick_pick_strings_promise(
  items : Array[String],
  options : QuickPickOptions?,
  token : CancellationToken?,
) -> @js_async.Promise[String?] {
  @js_async.Promise::from_async(async fn() {
    let selection = @js_async.Promise::wait(
      window_show_quick_pick_raw_promise(
        @v.JsValue::make(items),
        window_quick_pick_options_single(options),
        @v.option_to_js(token),
      ),
    )
    if @v.JsValue::is_null_or_undefined(selection) {
      None
    } else {
      Some(selection.cast())
    }
  })
}

///|
/// Shows a selection list allowing multiple selections.
///
/// @param items An array of strings, or a promise that resolves to an array of strings.
/// @param options Configures the behavior of the selection list.
/// @param token A token that can be used to signal cancellation.
/// @returns A thenable that resolves to the selected items or `undefined`.
pub async fn show_quick_pick_strings(
  items : Array[String],
  options? : QuickPickOptions,
  token? : CancellationToken,
) -> String? {
  @js_async.Promise::wait(
    window_show_quick_pick_strings_promise(items, options, token),
  )
}

///|
fn window_show_quick_pick_strings_many_promise(
  items : Array[String],
  options : QuickPickOptions?,
  token : CancellationToken?,
) -> @js_async.Promise[Array[String]?] {
  @js_async.Promise::from_async(async fn() {
    window_message_selection_many(
      @js_async.Promise::wait(
        window_show_quick_pick_raw_promise(
          @v.JsValue::make(items),
          window_quick_pick_options_many(options),
          @v.option_to_js(token),
        ),
      ),
    )
  })
}

///|
/// Shows a selection list allowing multiple selections.
///
/// @param items An array of strings, or a promise that resolves to an array of strings.
/// @param options Configures the behavior of the selection list.
/// @param token A token that can be used to signal cancellation.
/// @returns A thenable that resolves to the selected items or `undefined`.
pub async fn show_quick_pick_strings_many(
  items : Array[String],
  options? : QuickPickOptions,
  token? : CancellationToken,
) -> Array[String]? {
  @js_async.Promise::wait(
    window_show_quick_pick_strings_many_promise(items, options, token),
  )
}

///|
fn window_show_workspace_folder_pick_promise(
  options : @v.JsValue,
) -> @js_async.Promise[WorkspaceFolder?] {
  window_show_workspace_folder_pick_ffi(options)
}

///|
/// Shows a selection list of {@link workspace.workspaceFolders workspace folders} to pick from.
/// Returns `undefined` if no folder is open.
///
/// @param options Configures the behavior of the workspace folder list.
/// @returns A promise that resolves to the workspace folder or `undefined`.
pub async fn show_workspace_folder_pick(
  options? : WorkspaceFolderPickOptions,
) -> WorkspaceFolder? {
  @js_async.Promise::wait(
    window_show_workspace_folder_pick_promise(
      option_workspace_folder_pick_options_to_js(options),
    ),
  )
}

///|
fn window_show_open_dialog_promise(
  options : @v.JsValue,
) -> @js_async.Promise[Array[Uri]?] {
  window_show_open_dialog_ffi(options)
}

///|
/// Shows a file open dialog to the user which allows to select a file
/// for opening-purposes.
///
/// @param options Options that control the dialog.
/// @returns A promise that resolves to the selected resources or `undefined`.
pub async fn show_open_dialog(options? : OpenDialogOptions) -> Array[Uri]? {
  @js_async.Promise::wait(
    window_show_open_dialog_promise(option_open_dialog_options_to_js(options)),
  )
}

///|
fn window_show_save_dialog_promise(
  options : @v.JsValue,
) -> @js_async.Promise[Uri?] {
  window_show_save_dialog_ffi(options)
}

///|
/// Shows a file save dialog to the user which allows to select a file
/// for saving-purposes.
///
/// @param options Options that control the dialog.
/// @returns A promise that resolves to the selected resource or `undefined`.
pub async fn show_save_dialog(options? : SaveDialogOptions) -> Uri? {
  @js_async.Promise::wait(
    window_show_save_dialog_promise(option_save_dialog_options_to_js(options)),
  )
}

///|
fn window_show_input_box_promise(
  options : @v.JsValue,
  token : CancellationToken,
) -> @js_async.Promise[String?] {
  window_show_input_box_ffi(options, token)
}

///|
/// Opens an input box to ask the user for input.
///
/// The returned value will be `undefined` if the input box was canceled (e.g., pressing ESC). Otherwise the
/// returned value will be the string typed by the user or an empty string if the user did not type
/// anything but dismissed the input box with OK.
///
/// @param options Configures the behavior of the input box.
/// @param token A token that can be used to signal cancellation.
/// @returns A thenable that resolves to a string the user provided or to `undefined` in case of dismissal.
pub async fn show_input_box(
  options? : InputBoxOptions,
  token? : CancellationToken,
) -> String? {
  @js_async.Promise::wait(
    window_show_input_box_promise(
      option_input_box_options_to_js(options),
      @v.option_to_js(token).cast(),
    ),
  )
}

///|
/// Creates a {@link QuickPick} to let the user pick an item from a list of items of type `T`.
///
/// Note that in many cases the more convenient {@link window.showQuickPick} is easier to use.
/// {@link window.createQuickPick} should be used when {@link window.showQuickPick} does not offer
/// the required flexibility.
///
/// @returns A new {@link QuickPick}.
pub fn create_quick_pick() -> QuickPick[QuickPickItem] {
  window_create_quick_pick_ffi()
}

///|
/// Creates a {@link InputBox} to let the user enter some text input.
///
/// Note that in many cases the more convenient {@link window.showInputBox} is easier to use.
/// {@link window.createInputBox} should be used when {@link window.showInputBox} does not offer
/// the required flexibility.
///
/// @returns A new {@link InputBox}.
pub fn create_input_box() -> InputBox {
  window_create_input_box_ffi()
}

///|
/// Creates a new {@link OutputChannel output channel} with the given name and language id
/// If language id is not provided, then **Log** is used as default language id.
///
/// You can access the visible or active output channel as a {@link TextDocument text document} from {@link window.visibleTextEditors visible editors} or {@link window.activeTextEditor active editor}
/// and use the language id to contribute language features like syntax coloring, code lens etc.,
///
/// @param name Human-readable string which will be used to represent the channel in the UI.
/// @param languageId The identifier of the language associated with the channel.
/// @returns A new output channel.
pub fn create_output_channel(
  name : String,
  language_id? : String,
) -> OutputChannel {
  window_create_output_channel_ffi(name, @v.option_to_js(language_id))
}

///|
/// Creates a new {@link OutputChannel output channel} with the given name and language id
/// If language id is not provided, then **Log** is used as default language id.
///
/// You can access the visible or active output channel as a {@link TextDocument text document} from {@link window.visibleTextEditors visible editors} or {@link window.activeTextEditor active editor}
/// and use the language id to contribute language features like syntax coloring, code lens etc.,
///
/// @param name Human-readable string which will be used to represent the channel in the UI.
/// @param languageId The identifier of the language associated with the channel.
/// @returns A new output channel.
pub fn create_log_output_channel(name : String) -> LogOutputChannel {
  window_create_log_output_channel_ffi(name)
}

///|
/// Create and show a new webview panel.
///
/// @param viewType Identifies the type of the webview panel.
/// @param title Title of the panel.
/// @param showOptions Where to show the webview in the editor. If preserveFocus is set, the new webview will not take focus.
/// @param options Settings for the new panel.
///
/// @returns New webview panel.
pub fn create_webview_panel(
  view_type : String,
  title : String,
  view_column : ViewColumn,
  options? : WebviewPanelOptions,
) -> WebviewPanel {
  window_create_webview_panel_ffi(
    view_type,
    title,
    view_column_to_js(view_column),
    option_webview_panel_options_to_js(options),
  )
}

///|
/// Create and show a new webview panel.
///
/// @param viewType Identifies the type of the webview panel.
/// @param title Title of the panel.
/// @param showOptions Where to show the webview in the editor. If preserveFocus is set, the new webview will not take focus.
/// @param options Settings for the new panel.
///
/// @returns New webview panel.
pub fn create_webview_panel_show_options(
  view_type : String,
  title : String,
  view_column? : ViewColumn,
  preserve_focus? : Bool,
  options? : WebviewPanelOptions,
) -> WebviewPanel {
  let show_options = webview_panel_show_options_ffi(
    window_option_view_column_to_js(view_column),
    @v.option_to_js(preserve_focus),
  )
  window_create_webview_panel_ffi(
    view_type,
    title,
    show_options,
    option_webview_panel_options_to_js(options),
  )
}

///|
/// Set a message to the status bar. This is a short hand for the more powerful
/// status bar {@link window.createStatusBarItem items}.
///
/// @param text The message to show, supports icon substitution as in status bar {@link StatusBarItem.text items}.
/// @param hideAfterTimeout Timeout in milliseconds after which the message will be disposed.
/// @returns A disposable which hides the status bar message.
pub fn set_status_bar_message(text : String) -> @vscode.Disposable {
  window_set_status_bar_message_ffi(text, @v.JsValue::make(()))
}

///|
/// Set a message to the status bar. This is a short hand for the more powerful
/// status bar {@link window.createStatusBarItem items}.
///
/// @param text The message to show, supports icon substitution as in status bar {@link StatusBarItem.text items}.
/// @param hideAfterTimeout Timeout in milliseconds after which the message will be disposed.
/// @returns A disposable which hides the status bar message.
pub fn set_status_bar_message_timeout(
  text : String,
  timeout_ms : Int,
) -> @vscode.Disposable {
  window_set_status_bar_message_ffi(text, @v.JsValue::make(timeout_ms))
}

///|
/// Set a message to the status bar. This is a short hand for the more powerful
/// status bar {@link window.createStatusBarItem items}.
///
/// @param text The message to show, supports icon substitution as in status bar {@link StatusBarItem.text items}.
/// @param hideAfterTimeout Timeout in milliseconds after which the message will be disposed.
/// @returns A disposable which hides the status bar message.
pub fn[X] set_status_bar_message_until(
  text : String,
  wait_until : async () -> X,
) -> @vscode.Disposable {
  let promise = @js_async.Promise::from_async(() => wait_until())
  window_set_status_bar_message_ffi(text, @v.JsValue::make(promise))
}

///|
fn window_with_scm_progress_promise(
  task : (Progress[Int]) -> @js_async.Promise[@v.JsValue],
) -> @js_async.Promise[@v.JsValue] {
  window_with_scm_progress_ffi(task)
}

///|
/// Show progress in the Source Control viewlet while running the given callback and while
/// its returned promise isn't resolve or rejected.
///
/// @deprecated Use `withProgress` instead.
///
/// @param task A callback returning a promise. Progress increments can be reported with
/// the provided {@link Progress}-object.
/// @returns The thenable the task did return.
pub async fn[T] with_scm_progress(task : async (Progress[Int]) -> T) -> T {
  let wrapped = (progress : Progress[Int]) => {
    @js_async.Promise::from_async(async fn() {
      let result = task(progress)
      @v.JsValue::make(result)
    })
  }
  let raw = @js_async.Promise::wait(window_with_scm_progress_promise(wrapped))
  raw.cast()
}

///|
fn window_with_progress_promise(
  options : @v.JsValue,
  task : (Progress[@v.JsValue], CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> @js_async.Promise[@v.JsValue] {
  window_with_progress_ffi(options, task)
}

///|
/// Show progress in the editor. Progress is shown while running the given callback
/// and while the promise it returned isn't resolved nor rejected. The location at which
/// progress should show (and other details) is defined via the passed {@linkcode ProgressOptions}.
///
/// @param options A {@linkcode ProgressOptions}-object describing the options to use for showing progress, like its location
/// @param task A callback returning a promise. Progress state can be reported with
/// the provided {@link Progress}-object.
///
/// To report discrete progress, use `increment` to indicate how much work has been completed. Each call with
/// a `increment` value will be summed up and reflected as overall progress until 100% is reached (a value of
/// e.g. `10` accounts for `10%` of work done).
/// Note that currently only `ProgressLocation.Notification` is capable of showing discrete progress.
///
/// To monitor if the operation has been cancelled by the user, use the provided {@linkcode CancellationToken}.
/// Note that currently only `ProgressLocation.Notification` is supporting to show a cancel button to cancel the
/// long running operation.
///
/// @returns The thenable the task-callback returned.
pub async fn[T] with_progress(
  options : ProgressOptions,
  task : async (Progress[T], CancellationToken) -> T,
) -> T {
  let wrapped = (progress : Progress[@v.JsValue], token : CancellationToken) => {
    @js_async.Promise::from_async(async fn() {
      let typed_progress : Progress[T] = @v.JsValue::make(progress).cast()
      let result = task(typed_progress, token)
      @v.JsValue::make(result)
    })
  }
  let raw = @js_async.Promise::wait(
    window_with_progress_promise(progress_options_to_js(options), wrapped),
  )
  raw.cast()
}

///|
pub fn progress_location_notification() -> ProgressLocationValue {
  ProgressLocationValue::Location(progress_location_notification_ffi())
}

///|
pub fn progress_location_window() -> ProgressLocationValue {
  ProgressLocationValue::Location(progress_location_window_ffi())
}

///|
pub fn progress_location_source_control() -> ProgressLocationValue {
  ProgressLocationValue::Location(progress_location_source_control_ffi())
}

///|
pub fn progress_options(
  location : ProgressLocationValue,
  title? : String,
  cancellable? : Bool,
) -> ProgressOptions {
  match (title, cancellable) {
    (None, None) => ProgressOptions::new(location)
    (Some(title), None) => ProgressOptions::new(location, title~)
    (None, Some(cancellable)) => ProgressOptions::new(location, cancellable~)
    (Some(title), Some(cancellable)) =>
      ProgressOptions::new(location, title~, cancellable~)
  }
}

///|
pub fn[T] progress_report_message_increment(
  progress : Progress[T],
  message : String,
  increment? : Int,
) -> Unit {
  let raw : Progress[@v.JsValue] = @v.JsValue::make(progress).cast()
  progress_report_message_increment_ffi(
    raw,
    message,
    @v.option_to_js(increment),
  )
}

///|
/// Creates a status bar {@link StatusBarItem item}.
///
/// @param id The identifier of the item. Must be unique within the extension.
/// @param alignment The alignment of the item.
/// @param priority The priority of the item. Higher values mean the item should be shown more to the left.
/// @returns A new status bar item.
pub fn create_status_bar_item(
  alignment? : StatusBarAlignment,
  priority? : Int,
) -> StatusBarItem {
  window_create_status_bar_item_ffi(
    @v.JsValue::make(()),
    @v.option_to_js(alignment),
    @v.option_to_js(priority),
  )
}

///|
/// Creates a status bar {@link StatusBarItem item}.
///
/// @param id The identifier of the item. Must be unique within the extension.
/// @param alignment The alignment of the item.
/// @param priority The priority of the item. Higher values mean the item should be shown more to the left.
/// @returns A new status bar item.
pub fn create_status_bar_item_with_id(
  id : String,
  alignment? : StatusBarAlignment,
  priority? : Int,
) -> StatusBarItem {
  window_create_status_bar_item_ffi(
    @v.JsValue::make(id),
    @v.option_to_js(alignment),
    @v.option_to_js(priority),
  )
}

///|
/// Creates a {@link Terminal} with a backing shell process. The cwd of the terminal will be the workspace
/// directory if it exists.
///
/// @param name Optional human-readable string which will be used to represent the terminal in the UI.
/// @param shellPath Optional path to a custom shell executable to be used in the terminal.
/// @param shellArgs Optional args for the custom shell executable. A string can be used on Windows only which
/// allows specifying shell args in
/// [command-line format](https://msdn.microsoft.com/en-au/08dfcab2-eb6e-49a4-80eb-87d4076c98c6).
/// @returns A new Terminal.
/// @throws When running in an environment where a new process cannot be started.
pub fn create_terminal() -> Terminal {
  window_create_terminal_ffi()
}

///|
/// Creates a {@link Terminal} with a backing shell process. The cwd of the terminal will be the workspace
/// directory if it exists.
///
/// @param name Optional human-readable string which will be used to represent the terminal in the UI.
/// @param shellPath Optional path to a custom shell executable to be used in the terminal.
/// @param shellArgs Optional args for the custom shell executable. A string can be used on Windows only which
/// allows specifying shell args in
/// [command-line format](https://msdn.microsoft.com/en-au/08dfcab2-eb6e-49a4-80eb-87d4076c98c6).
/// @returns A new Terminal.
/// @throws When running in an environment where a new process cannot be started.
pub fn create_terminal_named(name : String) -> Terminal {
  window_create_terminal_named_ffi(name)
}

///|
/// Creates a {@link Terminal} with a backing shell process. The cwd of the terminal will be the workspace
/// directory if it exists.
///
/// @param name Optional human-readable string which will be used to represent the terminal in the UI.
/// @param shellPath Optional path to a custom shell executable to be used in the terminal.
/// @param shellArgs Optional args for the custom shell executable. A string can be used on Windows only which
/// allows specifying shell args in
/// [command-line format](https://msdn.microsoft.com/en-au/08dfcab2-eb6e-49a4-80eb-87d4076c98c6).
/// @returns A new Terminal.
/// @throws When running in an environment where a new process cannot be started.
pub fn create_terminal_with_options(options : TerminalOptions) -> Terminal {
  window_create_terminal_with_options_ffi(options)
}

///|
/// Creates a {@link Terminal} with a backing shell process. The cwd of the terminal will be the workspace
/// directory if it exists.
///
/// @param name Optional human-readable string which will be used to represent the terminal in the UI.
/// @param shellPath Optional path to a custom shell executable to be used in the terminal.
/// @param shellArgs Optional args for the custom shell executable. A string can be used on Windows only which
/// allows specifying shell args in
/// [command-line format](https://msdn.microsoft.com/en-au/08dfcab2-eb6e-49a4-80eb-87d4076c98c6).
/// @returns A new Terminal.
/// @throws When running in an environment where a new process cannot be started.
pub fn create_terminal_with_extension_options(
  options : ExtensionTerminalOptions,
) -> Terminal {
  window_create_terminal_with_extension_options_ffi(options)
}

///|
/// Register a {@link TreeDataProvider} for the view contributed using the extension point `views`.
/// This will allow you to contribute data to the {@link TreeView} and update if the data changes.
///
/// **Note:** To get access to the {@link TreeView} and perform operations on it, use {@link window.createTreeView createTreeView}.
///
/// @param viewId Id of the view contributed using the extension point `views`.
/// @param treeDataProvider A {@link TreeDataProvider} that provides tree data for the view
/// @returns A {@link Disposable disposable} that unregisters the {@link TreeDataProvider}.
pub fn[T] register_tree_data_provider(
  view_id : String,
  get_tree_item : async (T) -> TreeItem,
  get_children : async (T?) -> Array[T]?,
  on_did_change_tree_data? : Event[T?],
  get_parent? : async (T) -> T?,
  resolve_tree_item? : async (TreeItem, T, CancellationToken) -> TreeItem?,
) -> @vscode.Disposable {
  let raw : @providers.TreeDataProviderObject[@v.JsValue] = @v.JsValue::make(
    tree_data_provider_object(
      get_tree_item, get_children, on_did_change_tree_data, get_parent, resolve_tree_item,
    ),
  ).cast()
  window_register_tree_data_provider_ffi(view_id, raw)
}

///|
/// Create a {@link TreeView} for the view contributed using the extension point `views`.
/// @param viewId Id of the view contributed using the extension point `views`.
/// @param options Options for creating the {@link TreeView}
/// @returns a {@link TreeView}.
pub fn[T] create_tree_view(
  view_id : String,
  options : TreeViewOptions[T],
) -> TreeView[T] {
  let raw : TreeViewOptions[@v.JsValue] = @v.JsValue::make(options).cast()
  let view : TreeView[@v.JsValue] = window_create_tree_view_ffi(view_id, raw)
  @v.JsValue::make(view).cast()
}

///|
/// Registers a {@link UriHandler uri handler} capable of handling system-wide {@link Uri uris}.
/// In case there are multiple windows open, the topmost window will handle the uri.
/// A uri handler is scoped to the extension it is contributed from; it will only
/// be able to handle uris which are directed to the extension itself. A uri must respect
/// the following rules:
///
/// - The uri-scheme must be `vscode.env.uriScheme`;
/// - The uri-authority must be the extension id (e.g. `my.extension`);
/// - The uri-path, -query and -fragment parts are arbitrary.
///
/// For example, if the `my.extension` extension registers a uri handler, it will only
/// be allowed to handle uris with the prefix `product-name://my.extension`.
///
/// An extension can only register a single uri handler in its entire activation lifetime.
///
/// * *Note:* There is an activation event `onUri` that fires when a uri directed for
/// the current extension is about to be handled.
///
/// @param handler The uri handler to register for this extension.
/// @returns A {@link Disposable disposable} that unregisters the handler.
pub fn register_uri_handler(handler : @vscode.UriHandler) -> @vscode.Disposable {
  window_register_uri_handler_ffi(handler)
}

///|
/// Registers a webview panel serializer.
///
/// Extensions that support reviving should have an `"onWebviewPanel:viewType"` activation event and
/// make sure that `registerWebviewPanelSerializer` is called during activation.
///
/// Only a single serializer may be registered at a time for a given `viewType`.
///
/// @param viewType Type of the webview panel that can be serialized.
/// @param serializer Webview serializer.
/// @returns A {@link Disposable disposable} that unregisters the serializer.
pub fn register_webview_panel_serializer(
  view_type : String,
  serializer : @vscode.WebviewPanelSerializer,
) -> @vscode.Disposable {
  window_register_webview_panel_serializer_ffi(view_type, serializer)
}

///|
/// Register a new provider for webview views.
///
/// @param viewId Unique id of the view. This should match the `id` from the
///   `views` contribution in the package.json.
/// @param provider Provider for the webview views.
///
/// @returns Disposable that unregisters the provider.
pub fn[T : @vscode.WebviewViewProvider] register_webview_view_provider(
  view_id : String,
  provider : T,
  options? : WebviewViewOptions,
) -> @vscode.Disposable {
  window_register_webview_view_provider_ffi(
    view_id,
    webview_view_provider_object(provider),
    option_webview_view_options_to_js(options),
  )
}

///|
/// Register a provider for custom editors for the `viewType` contributed by the `customEditors` extension point.
///
/// When a custom editor is opened, an `onCustomEditor:viewType` activation event is fired. Your extension
/// must register a {@linkcode CustomTextEditorProvider}, {@linkcode CustomReadonlyEditorProvider},
/// {@linkcode CustomEditorProvider}for `viewType` as part of activation.
///
/// @param viewType Unique identifier for the custom editor provider. This should match the `viewType` from the
///   `customEditors` contribution point.
/// @param provider Provider that resolves custom editors.
/// @param options Options for the provider.
///
/// @returns Disposable that unregisters the provider.
pub fn[T : @vscode.CustomEditorProvider] register_custom_editor_provider(
  view_type : String,
  provider : T,
  options? : CustomEditorProviderOptions,
) -> @vscode.Disposable {
  window_register_custom_editor_provider_ffi(
    view_type,
    custom_editor_provider_object(provider),
    option_custom_editor_provider_options_to_js(options),
  )
}

///|
pub fn[T : @vscode.CustomTextEditorProvider] register_custom_text_editor_provider(
  view_type : String,
  provider : T,
  options? : CustomEditorProviderOptions,
) -> @vscode.Disposable {
  window_register_custom_editor_provider_ffi(
    view_type,
    custom_text_editor_provider_object(provider),
    option_custom_editor_provider_options_to_js(options),
  )
}

///|
pub fn[T : @vscode.CustomReadonlyEditorProvider] register_custom_readonly_editor_provider(
  view_type : String,
  provider : T,
  options? : CustomEditorProviderOptions,
) -> @vscode.Disposable {
  window_register_custom_editor_provider_ffi(
    view_type,
    custom_readonly_editor_provider_object(provider),
    option_custom_editor_provider_options_to_js(options),
  )
}

///|
/// Register provider that enables the detection and handling of links within the terminal.
/// @param provider The provider that provides the terminal links.
/// @returns Disposable that unregisters the provider.
pub fn[T : @vscode.TerminalLinkProvider] register_terminal_link_provider(
  provider : T,
) -> @vscode.Disposable {
  window_register_terminal_link_provider_ffi(
    terminal_link_provider_object(provider),
  )
}

///|
/// Registers a provider for a contributed terminal profile.
///
/// @param id The ID of the contributed terminal profile.
/// @param provider The terminal profile provider.
/// @returns A {@link Disposable disposable} that unregisters the provider.
pub fn[T : @vscode.TerminalProfileProvider] register_terminal_profile_provider(
  id : String,
  provider : T,
) -> @vscode.Disposable {
  window_register_terminal_profile_provider_ffi(
    id,
    terminal_profile_provider_object(provider),
  )
}

///|
/// Register a file decoration provider.
///
/// @param provider A {@link FileDecorationProvider}.
/// @returns A {@link Disposable} that unregisters the provider.
pub fn[T : @vscode.FileDecorationProvider] register_file_decoration_provider(
  provider : T,
) -> @vscode.Disposable {
  window_register_file_decoration_provider_ffi(
    file_decoration_provider_object(provider),
  )
}

///|
pub fn[T] tree_view_options(
  get_tree_item : async (T) -> TreeItem,
  get_children : async (T?) -> Array[T]?,
  on_did_change_tree_data? : Event[T?],
  get_parent? : async (T) -> T?,
  resolve_tree_item? : async (TreeItem, T, CancellationToken) -> TreeItem?,
) -> TreeViewOptions[T] {
  let raw : @providers.TreeDataProviderObject[@v.JsValue] = @v.JsValue::make(
    tree_data_provider_object(
      get_tree_item, get_children, on_did_change_tree_data, get_parent, resolve_tree_item,
    ),
  ).cast()
  @v.JsValue::make(tree_view_options_ffi(raw)).cast()
}

///|
extern "js" fn tree_view_options_ffi(
  tree_data_provider : @providers.TreeDataProviderObject[@v.JsValue],
) -> TreeViewOptions[@v.JsValue] =
  #| (treeDataProvider) => ({ treeDataProvider })
