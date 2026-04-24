///|
/// JS FFI bindings for VS Code notebooks namespace.

///|
extern "js" fn notebooks_create_notebook_controller_ffi(
  id : String,
  notebook_type : String,
  label : String,
  handler : @v.JsValue,
) -> NotebookController =
  #| (id, notebookType, label, handler) => {
  #|   const notebooks = require("vscode").notebooks;
  #|   if (handler === undefined || handler === null) {
  #|     return notebooks.createNotebookController(id, notebookType, label);
  #|   }
  #|   return notebooks.createNotebookController(id, notebookType, label, handler);
  #| }

///|
extern "js" fn notebooks_status_bar_item_ffi(
  text : String,
  alignment : NotebookCellStatusBarAlignment,
) -> NotebookCellStatusBarItem =
  #| (text, alignment) =>
  #|   new (require("vscode").NotebookCellStatusBarItem)(text, alignment)

///|
extern "js" fn notebooks_status_bar_item_provider_ffi(
  provide_items : (NotebookCell, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  on_did_change_cell_status_bar_items : @v.JsValue,
) -> NotebookCellStatusBarItemProvider =
  #| (provideCellStatusBarItems, onDidChangeCellStatusBarItems) => {
  #|   const provider = { provideCellStatusBarItems };
  #|   if (onDidChangeCellStatusBarItems !== undefined && onDidChangeCellStatusBarItems !== null) {
  #|     provider.onDidChangeCellStatusBarItems = onDidChangeCellStatusBarItems;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn notebooks_register_notebook_cell_status_bar_item_provider_ffi(
  notebook_type : String,
  provider : NotebookCellStatusBarItemProvider,
) -> @vscode.Disposable =
  #| (notebookType, provider) =>
  #|   require("vscode").notebooks.registerNotebookCellStatusBarItemProvider(notebookType, provider)

///|
extern "js" fn notebooks_create_renderer_messaging_ffi(
  renderer_id : String,
) -> NotebookRendererMessaging =
  #| (rendererId) => require("vscode").notebooks.createRendererMessaging(rendererId)

///|
extern "js" fn notebooks_try_create_renderer_messaging_ffi(
  renderer_id : String,
) -> @v.JsValue =
  #| (rendererId) => {
  #|   try {
  #|     return require("vscode").notebooks.createRendererMessaging(rendererId);
  #|   } catch (_) {
  #|     return undefined;
  #|   }
  #| }

///|
extern "js" fn notebooks_renderer_messaging_post_message_ffi(
  messaging : NotebookRendererMessaging,
  message : @v.JsValue,
  editor : @v.JsValue,
) -> @js_async.Promise[Bool] =
  #| (messaging, message, editor) =>
  #|   messaging.postMessage(
  #|     message,
  #|     editor === undefined || editor === null ? undefined : editor
  #|   )

///|
extern "js" fn notebooks_renderer_message_event_message_raw(
  event : NotebookRendererMessageEvent,
) -> @v.JsValue =
  #| (event) => event.message

///|
extern "js" fn notebooks_controller_update_notebook_affinity_ffi(
  controller : NotebookController,
  notebook : NotebookDocument,
  affinity : NotebookControllerAffinity,
) -> Unit =
  #| (controller, notebook, affinity) =>
  #|   controller.updateNotebookAffinity(notebook, affinity)

///|
extern "js" fn notebooks_controller_create_notebook_cell_execution_ffi(
  controller : NotebookController,
  cell : NotebookCell,
) -> NotebookCellExecution =
  #| (controller, cell) => controller.createNotebookCellExecution(cell)

///|
extern "js" fn notebooks_cell_execution_start_ffi(
  execution : NotebookCellExecution,
  start_time : @v.JsValue,
) -> Unit =
  #| (execution, startTime) =>
  #|   startTime === undefined || startTime === null
  #|     ? execution.start()
  #|     : execution.start(startTime)

///|
extern "js" fn notebooks_cell_execution_end_ffi(
  execution : NotebookCellExecution,
  success : @v.JsValue,
  end_time : @v.JsValue,
) -> Unit =
  #| (execution, success, endTime) => {
  #|   const hasSuccess = success !== undefined && success !== null;
  #|   const hasEndTime = endTime !== undefined && endTime !== null;
  #|   if (!hasSuccess && !hasEndTime) {
  #|     execution.end(undefined);
  #|     return;
  #|   }
  #|   if (!hasSuccess && hasEndTime) {
  #|     execution.end(undefined, endTime);
  #|     return;
  #|   }
  #|   if (hasSuccess && !hasEndTime) {
  #|     execution.end(success);
  #|     return;
  #|   }
  #|   execution.end(success, endTime);
  #| }

///|
extern "js" fn notebooks_cell_execution_clear_output_ffi(
  execution : NotebookCellExecution,
  cell : @v.JsValue,
) -> @js_async.Promise[Unit] =
  #| (execution, cell) =>
  #|   cell === undefined || cell === null
  #|     ? execution.clearOutput()
  #|     : execution.clearOutput(cell)

///|
extern "js" fn notebooks_cell_execution_replace_output_ffi(
  execution : NotebookCellExecution,
  out : @v.JsValue,
  cell : @v.JsValue,
) -> @js_async.Promise[Unit] =
  #| (execution, out, cell) =>
  #|   cell === undefined || cell === null
  #|     ? execution.replaceOutput(out)
  #|     : execution.replaceOutput(out, cell)

///|
extern "js" fn notebooks_cell_execution_append_output_ffi(
  execution : NotebookCellExecution,
  out : @v.JsValue,
  cell : @v.JsValue,
) -> @js_async.Promise[Unit] =
  #| (execution, out, cell) =>
  #|   cell === undefined || cell === null
  #|     ? execution.appendOutput(out)
  #|     : execution.appendOutput(out, cell)

///|
extern "js" fn notebooks_cell_execution_replace_output_items_ffi(
  execution : NotebookCellExecution,
  items : @v.JsValue,
  output : NotebookCellOutput,
) -> @js_async.Promise[Unit] =
  #| (execution, items, output) => execution.replaceOutputItems(items, output)

///|
extern "js" fn notebooks_cell_execution_append_output_items_ffi(
  execution : NotebookCellExecution,
  items : @v.JsValue,
  output : NotebookCellOutput,
) -> @js_async.Promise[Unit] =
  #| (execution, items, output) => execution.appendOutputItems(items, output)
