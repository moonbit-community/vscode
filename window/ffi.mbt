///|
/// JS FFI bindings for VS Code window.
extern "js" fn window_tab_groups_ffi() -> TabGroups =
  #| () => require("vscode").window.tabGroups

///|
extern "js" fn window_active_text_editor_ffi() -> @v.JsValue =
  #| () => require("vscode").window.activeTextEditor

///|
extern "js" fn window_visible_text_editors_ffi() -> Array[TextEditor] =
  #| () => require("vscode").window.visibleTextEditors

///|
extern "js" fn window_on_did_change_active_text_editor_ffi() -> Event[
  TextEditor?,
] =
  #| () => require("vscode").window.onDidChangeActiveTextEditor

///|
extern "js" fn window_on_did_change_visible_text_editors_ffi() -> Event[
  Array[TextEditor],
] =
  #| () => require("vscode").window.onDidChangeVisibleTextEditors

///|
extern "js" fn window_on_did_change_text_editor_selection_ffi() -> Event[
  TextEditorSelectionChangeEvent,
] =
  #| () => require("vscode").window.onDidChangeTextEditorSelection

///|
extern "js" fn window_on_did_change_text_editor_visible_ranges_ffi() -> Event[
  TextEditorVisibleRangesChangeEvent,
] =
  #| () => require("vscode").window.onDidChangeTextEditorVisibleRanges

///|
extern "js" fn window_on_did_change_text_editor_options_ffi() -> Event[
  TextEditorOptionsChangeEvent,
] =
  #| () => require("vscode").window.onDidChangeTextEditorOptions

///|
extern "js" fn window_on_did_change_text_editor_view_column_ffi() -> Event[
  TextEditorViewColumnChangeEvent,
] =
  #| () => require("vscode").window.onDidChangeTextEditorViewColumn

///|
extern "js" fn window_visible_notebook_editors_ffi() -> Array[NotebookEditor] =
  #| () => require("vscode").window.visibleNotebookEditors

///|
extern "js" fn window_on_did_change_visible_notebook_editors_ffi() -> Event[
  Array[NotebookEditor],
] =
  #| () => require("vscode").window.onDidChangeVisibleNotebookEditors

///|
extern "js" fn window_active_notebook_editor_ffi() -> @v.JsValue =
  #| () => require("vscode").window.activeNotebookEditor

///|
extern "js" fn window_on_did_change_active_notebook_editor_ffi() -> Event[
  NotebookEditor?,
] =
  #| () => require("vscode").window.onDidChangeActiveNotebookEditor

///|
extern "js" fn window_on_did_change_notebook_editor_selection_ffi() -> Event[
  NotebookEditorSelectionChangeEvent,
] =
  #| () => require("vscode").window.onDidChangeNotebookEditorSelection

///|
extern "js" fn window_on_did_change_notebook_editor_visible_ranges_ffi() -> Event[
  NotebookEditorVisibleRangesChangeEvent,
] =
  #| () => require("vscode").window.onDidChangeNotebookEditorVisibleRanges

///|
extern "js" fn window_terminals_ffi() -> Array[Terminal] =
  #| () => require("vscode").window.terminals

///|
extern "js" fn window_active_terminal_ffi() -> @v.JsValue =
  #| () => require("vscode").window.activeTerminal

///|
extern "js" fn window_on_did_change_active_terminal_ffi() -> Event[Terminal?] =
  #| () => require("vscode").window.onDidChangeActiveTerminal

///|
extern "js" fn window_on_did_open_terminal_ffi() -> Event[Terminal] =
  #| () => require("vscode").window.onDidOpenTerminal

///|
extern "js" fn window_on_did_close_terminal_ffi() -> Event[Terminal] =
  #| () => require("vscode").window.onDidCloseTerminal

///|
extern "js" fn window_on_did_change_terminal_state_ffi() -> Event[Terminal] =
  #| () => require("vscode").window.onDidChangeTerminalState

///|
extern "js" fn window_on_did_change_terminal_shell_integration_ffi() -> Event[
  TerminalShellIntegrationChangeEvent,
] =
  #| () => require("vscode").window.onDidChangeTerminalShellIntegration

///|
extern "js" fn window_on_did_start_terminal_shell_execution_ffi() -> Event[
  TerminalShellExecutionStartEvent,
] =
  #| () => require("vscode").window.onDidStartTerminalShellExecution

///|
extern "js" fn window_on_did_end_terminal_shell_execution_ffi() -> Event[
  TerminalShellExecutionEndEvent,
] =
  #| () => require("vscode").window.onDidEndTerminalShellExecution

///|
extern "js" fn window_state_ffi() -> WindowState =
  #| () => require("vscode").window.state

///|
extern "js" fn window_on_did_change_window_state_ffi() -> Event[WindowState] =
  #| () => require("vscode").window.onDidChangeWindowState

///|
extern "js" fn window_active_color_theme_ffi() -> ColorTheme =
  #| () => require("vscode").window.activeColorTheme

///|
extern "js" fn window_on_did_change_active_color_theme_ffi() -> Event[
  ColorTheme,
] =
  #| () => require("vscode").window.onDidChangeActiveColorTheme

///|
extern "js" fn window_show_text_document_ffi(
  document_or_uri : @v.JsValue,
  options : @v.JsValue,
) -> @js_async.Promise[TextEditor] =
  #| (docOrUri, options) => {
  #|   const vscode = require("vscode");
  #|   if (options === undefined || options === null) {
  #|     return vscode.window.showTextDocument(docOrUri);
  #|   }
  #|   return vscode.window.showTextDocument(docOrUri, options);
  #| }

///|
extern "js" fn window_show_notebook_document_ffi(
  document : NotebookDocument,
  options : @v.JsValue,
) -> @js_async.Promise[NotebookEditor] =
  #| (document, options) => require("vscode").window.showNotebookDocument(document, options)

///|
extern "js" fn window_create_text_editor_decoration_type_ffi(
  options : DecorationRenderOptions,
) -> TextEditorDecorationType =
  #| (options) => require("vscode").window.createTextEditorDecorationType(options)

///|
extern "js" fn window_show_information_message_ffi(
  message : String,
  options : @v.JsValue,
  items : Array[@v.JsValue],
) -> @js_async.Promise[@v.JsValue] =
  #| (message, options, items) => {
  #|   const vscode = require("vscode");
  #|   if (options === undefined || options === null) {
  #|     return vscode.window.showInformationMessage(message, ...items);
  #|   }
  #|   return vscode.window.showInformationMessage(message, options, ...items);
  #| }

///|
extern "js" fn window_show_warning_message_ffi(
  message : String,
  options : @v.JsValue,
  items : Array[@v.JsValue],
) -> @js_async.Promise[@v.JsValue] =
  #| (message, options, items) => {
  #|   const vscode = require("vscode");
  #|   if (options === undefined || options === null) {
  #|     return vscode.window.showWarningMessage(message, ...items);
  #|   }
  #|   return vscode.window.showWarningMessage(message, options, ...items);
  #| }

///|
extern "js" fn window_show_error_message_ffi(
  message : String,
  options : @v.JsValue,
  items : Array[@v.JsValue],
) -> @js_async.Promise[@v.JsValue] =
  #| (message, options, items) => {
  #|   const vscode = require("vscode");
  #|   if (options === undefined || options === null) {
  #|     return vscode.window.showErrorMessage(message, ...items);
  #|   }
  #|   return vscode.window.showErrorMessage(message, options, ...items);
  #| }

///|
extern "js" fn window_show_quick_pick_ffi(
  items : @v.JsValue,
  options : @v.JsValue,
  token : @v.JsValue,
) -> @js_async.Promise[@v.JsValue] =
  #| (items, options, token) => require("vscode").window.showQuickPick(items, options, token)

///|
extern "js" fn window_quick_pick_options_single_ffi(
  options : @v.JsValue,
) -> @v.JsValue =
  #| (options) => {
  #|   if (options === undefined || options === null) {
  #|     return { canPickMany: false };
  #|   }
  #|   return { ...options, canPickMany: false };
  #| }

///|
extern "js" fn window_quick_pick_options_many_ffi(
  options : @v.JsValue,
) -> @v.JsValue =
  #| (options) => {
  #|   if (options === undefined || options === null) {
  #|     return { canPickMany: true };
  #|   }
  #|   return { ...options, canPickMany: true };
  #| }

///|
extern "js" fn window_show_workspace_folder_pick_ffi(
  options : @v.JsValue,
) -> @js_async.Promise[WorkspaceFolder?] =
  #| (options) => require("vscode").window.showWorkspaceFolderPick(options)

///|
extern "js" fn window_show_open_dialog_ffi(
  options : @v.JsValue,
) -> @js_async.Promise[Array[Uri]?] =
  #| (options) => require("vscode").window.showOpenDialog(options)

///|
extern "js" fn window_show_save_dialog_ffi(
  options : @v.JsValue,
) -> @js_async.Promise[Uri?] =
  #| (options) => require("vscode").window.showSaveDialog(options)

///|
extern "js" fn window_show_input_box_ffi(
  options : @v.JsValue,
  token : CancellationToken,
) -> @js_async.Promise[String?] =
  #| (options, token) => require("vscode").window.showInputBox(options, token)

///|
extern "js" fn window_create_quick_pick_ffi() -> QuickPick[QuickPickItem] =
  #| () => require("vscode").window.createQuickPick()

///|
extern "js" fn window_create_input_box_ffi() -> InputBox =
  #| () => require("vscode").window.createInputBox()

///|
extern "js" fn window_create_output_channel_ffi(
  name : String,
  language_id : @v.JsValue,
) -> OutputChannel =
  #| (name, languageId) => {
  #|   const vscode = require("vscode");
  #|   return languageId === undefined || languageId === null
  #|     ? vscode.window.createOutputChannel(name)
  #|     : vscode.window.createOutputChannel(name, languageId);
  #| }

///|
extern "js" fn window_create_log_output_channel_ffi(
  name : String,
) -> LogOutputChannel =
  #| (name) => require("vscode").window.createOutputChannel(name, { log: true })

///|
extern "js" fn window_create_webview_panel_ffi(
  view_type : String,
  title : String,
  show_options : @v.JsValue,
  options : @v.JsValue,
) -> WebviewPanel =
  #| (viewType, title, showOptions, options) =>
  #|   require("vscode").window.createWebviewPanel(viewType, title, showOptions, options)

///|
extern "js" fn webview_panel_show_options_ffi(
  view_column : @v.JsValue,
  preserve_focus : @v.JsValue,
) -> @v.JsValue =
  #| (viewColumn, preserveFocus) => {
  #|   const options = {};
  #|   if (viewColumn !== undefined && viewColumn !== null) {
  #|     options.viewColumn = viewColumn;
  #|   }
  #|   if (preserveFocus !== undefined && preserveFocus !== null) {
  #|     options.preserveFocus = preserveFocus;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn window_set_status_bar_message_ffi(
  text : String,
  hide_after : @v.JsValue,
) -> @vscode.Disposable =
  #| (text, hideAfter) => {
  #|   const vscode = require("vscode");
  #|   if (hideAfter === undefined || hideAfter === null) {
  #|     return vscode.window.setStatusBarMessage(text);
  #|   }
  #|   return vscode.window.setStatusBarMessage(text, hideAfter);
  #| }

///|
extern "js" fn window_with_scm_progress_ffi(
  task : (Progress[Int]) -> @js_async.Promise[@v.JsValue],
) -> @js_async.Promise[@v.JsValue] =
  #| (task) => require("vscode").window.withScmProgress((progress) => task(progress))

///|
extern "js" fn window_with_progress_ffi(
  options : @v.JsValue,
  task : (Progress[@v.JsValue], CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> @js_async.Promise[@v.JsValue] =
  #| (options, task) => require("vscode").window.withProgress(
  #|   options,
  #|   (progress, token) => task(progress, token),
  #| )

///|
extern "js" fn progress_location_notification_ffi() -> ProgressLocation =
  #| () => require("vscode").ProgressLocation.Notification

///|
extern "js" fn progress_location_window_ffi() -> ProgressLocation =
  #| () => require("vscode").ProgressLocation.Window

///|
extern "js" fn progress_location_source_control_ffi() -> ProgressLocation =
  #| () => require("vscode").ProgressLocation.SourceControl

///|
extern "js" fn progress_report_message_increment_ffi(
  progress : Progress[@v.JsValue],
  message : String,
  increment : @v.JsValue,
) -> Unit =
  #| (progress, message, increment) => {
  #|   const value = { message };
  #|   if (increment !== undefined && increment !== null) value.increment = increment;
  #|   progress.report(value);
  #| }

///|
extern "js" fn window_create_status_bar_item_ffi(
  id : @v.JsValue,
  alignment : @v.JsValue,
  priority : @v.JsValue,
) -> StatusBarItem =
  #| (id, alignment, priority) => {
  #|   const vscode = require("vscode");
  #|   const hasId = id !== undefined && id !== null;
  #|   const hasAlignment = alignment !== undefined && alignment !== null;
  #|   const hasPriority = priority !== undefined && priority !== null;
  #|   if (hasId) {
  #|     return vscode.window.createStatusBarItem(
  #|       id,
  #|       hasAlignment ? alignment : undefined,
  #|       hasPriority ? priority : undefined,
  #|     );
  #|   }
  #|   return vscode.window.createStatusBarItem(
  #|     hasAlignment ? alignment : undefined,
  #|     hasPriority ? priority : undefined,
  #|   );
  #| }

///|
extern "js" fn window_create_terminal_ffi() -> Terminal =
  #| () => require("vscode").window.createTerminal()

///|
extern "js" fn window_create_terminal_named_ffi(name : String) -> Terminal =
  #| (name) => require("vscode").window.createTerminal(name)

///|
extern "js" fn window_create_terminal_with_options_ffi(
  options : TerminalOptions,
) -> Terminal =
  #| (options) => require("vscode").window.createTerminal(options)

///|
extern "js" fn window_create_terminal_with_extension_options_ffi(
  options : ExtensionTerminalOptions,
) -> Terminal =
  #| (options) => require("vscode").window.createTerminal(options)

///|
extern "js" fn window_register_tree_data_provider_ffi(
  view_id : String,
  provider : @providers.TreeDataProviderObject[@v.JsValue],
) -> @vscode.Disposable =
  #| (viewId, provider) => require("vscode").window.registerTreeDataProvider(viewId, provider)

///|
extern "js" fn window_create_tree_view_ffi(
  view_id : String,
  options : TreeViewOptions[@v.JsValue],
) -> TreeView[@v.JsValue] =
  #| (viewId, options) => require("vscode").window.createTreeView(viewId, options)

///|
extern "js" fn window_register_uri_handler_ffi(
  handler : @vscode.UriHandler,
) -> @vscode.Disposable =
  #| (handler) => require("vscode").window.registerUriHandler(handler)

///|
extern "js" fn window_register_webview_panel_serializer_ffi(
  view_type : String,
  serializer : @vscode.WebviewPanelSerializer,
) -> @vscode.Disposable =
  #| (viewType, serializer) =>
  #|   require("vscode").window.registerWebviewPanelSerializer(viewType, serializer)

///|
extern "js" fn window_register_webview_view_provider_ffi(
  view_id : String,
  provider : @providers.WebviewViewProviderObject,
  options : @v.JsValue,
) -> @vscode.Disposable =
  #| (viewId, provider, options) => require("vscode").window.registerWebviewViewProvider(viewId, provider, options)

///|
extern "js" fn window_register_custom_editor_provider_ffi(
  view_type : String,
  provider : @providers.CustomEditorProviderObject,
  options : @v.JsValue,
) -> @vscode.Disposable =
  #| (viewType, provider, options) =>
  #|   require("vscode").window.registerCustomEditorProvider(viewType, provider, options)

///|
extern "js" fn window_register_terminal_link_provider_ffi(
  provider : @providers.TerminalLinkProviderObject,
) -> @vscode.Disposable =
  #| (provider) => require("vscode").window.registerTerminalLinkProvider(provider)

///|
extern "js" fn window_register_terminal_profile_provider_ffi(
  id : String,
  provider : @providers.TerminalProfileProviderObject,
) -> @vscode.Disposable =
  #| (id, provider) => require("vscode").window.registerTerminalProfileProvider(id, provider)

///|
extern "js" fn window_register_file_decoration_provider_ffi(
  provider : @providers.FileDecorationProviderObject,
) -> @vscode.Disposable =
  #| (provider) => require("vscode").window.registerFileDecorationProvider(provider)
