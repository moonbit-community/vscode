///|
/// VS Code notebooks namespace bindings for the JS backend.
using @vscode {
  type CancellationToken,
  type Event,
  type NotebookCell,
  type NotebookCellOutput,
  type NotebookCellOutputItem,
  type NotebookDocument,
  type NotebookEditor,
}

///|
/// A notebook controller represents an entity that can execute notebook cells. This is often referred to as a kernel.
///
/// There can be multiple controllers and the editor will let users choose which controller to use for a certain notebook. The
/// {@linkcode NotebookController.notebookType notebookType}-property defines for what kind of notebooks a controller is for and
/// the {@linkcode NotebookController.updateNotebookAffinity updateNotebookAffinity}-function allows controllers to set a preference
/// for specific notebook documents. When a controller has been selected its
/// {@link NotebookController.onDidChangeSelectedNotebooks onDidChangeSelectedNotebooks}-event fires.
///
/// When a cell is being run the editor will invoke the {@linkcode NotebookController.executeHandler executeHandler} and a controller
/// is expected to create and finalize a {@link NotebookCellExecution notebook cell execution}. However, controllers are also free
/// to create executions by themselves.
pub type NotebookController

///|
/// A contribution to a cell's status bar
pub type NotebookCellStatusBarItem

///|
/// A provider that can contribute items to the status bar that appears below a cell's editor.
pub(all) struct NotebookCellStatusBarItemProvider {
  mut on_did_change_cell_status_bar_items : Event[Unit]?
}

///|
/// Renderer messaging is used to communicate with a single renderer. It's returned from {@link notebooks.createRendererMessaging}.
pub struct NotebookRendererMessaging {
  on_did_receive_message : Event[NotebookRendererMessageEvent]
}

///|
pub type NotebookRendererMessageEvent

///|
/// A NotebookCellExecution is how {@link NotebookController notebook controller} modify a notebook cell as
/// it is executing.
///
/// When a cell execution object is created, the cell enters the {@linkcode NotebookCellExecutionState.Pending Pending} state.
/// When {@linkcode NotebookCellExecution.start start(...)} is called on the execution task, it enters the {@linkcode NotebookCellExecutionState.Executing Executing} state. When
/// {@linkcode NotebookCellExecution.end end(...)} is called, it enters the {@linkcode NotebookCellExecutionState.Idle Idle} state.
pub type NotebookCellExecution

///|
pub(all) enum NotebookCellOutputOrMany {
  Single(NotebookCellOutput)
  Many(Array[NotebookCellOutput])
}

///|
pub(all) enum NotebookCellOutputItemOrMany {
  Single(NotebookCellOutputItem)
  Many(Array[NotebookCellOutputItem])
}

///|
pub(all) enum NotebookCellStatusBarAlignment {
  Left = 1
  Right = 2
} derive(Eq)

///|
pub(all) enum NotebookControllerAffinity {
  Default = 1
  Preferred = 2
} derive(Eq)

///|
fn[T] option_to_js(value : T?) -> @v.JsValue {
  @v.option_to_js(value)
}

///|
/// Creates a new notebook controller.
///
/// @param id Identifier of the controller. Must be unique per extension.
/// @param notebookType A notebook type for which this controller is for.
/// @param label The label of the controller.
/// @param handler The execute-handler of the controller.
/// @returns A new notebook controller.
pub fn create_notebook_controller(
  id : String,
  notebook_type : String,
  label : String,
) -> NotebookController {
  notebooks_create_notebook_controller_ffi(
    id,
    notebook_type,
    label,
    @v.JsValue::make(()),
  )
}

///|
/// Creates a new notebook controller.
///
/// @param id Identifier of the controller. Must be unique per extension.
/// @param notebookType A notebook type for which this controller is for.
/// @param label The label of the controller.
/// @param handler The execute-handler of the controller.
/// @returns A new notebook controller.
pub fn create_notebook_controller_with_handler(
  id : String,
  notebook_type : String,
  label : String,
  handler : async (Array[NotebookCell], NotebookDocument, NotebookController) -> Unit,
) -> NotebookController {
  notebooks_create_notebook_controller_ffi(
    id,
    notebook_type,
    label,
    @v.JsValue::make((cells, notebook, controller) => {
      @js_async.Promise::from_async(() => handler(cells, notebook, controller))
    }),
  )
}

///|
/// The identifier of this notebook controller.
///
/// _Note_ that controllers are remembered by their identifier and that extensions should use
/// stable identifiers across sessions.
pub extern "js" fn NotebookController::id(self : NotebookController) -> String =
  #| (controller) => controller.id

///|
/// The human-readable label of this notebook controller.
pub extern "js" fn NotebookController::label(
  self : NotebookController,
) -> String =
  #| (controller) => controller.label

///|
/// The notebook type this controller is for.
pub extern "js" fn NotebookController::notebook_type(
  self : NotebookController,
) -> String =
  #| (controller) => controller.notebookType

///|
/// Dispose and free associated resources.
extern "js" fn notebook_controller_dispose_raw(
  controller : NotebookController,
) -> Unit =
  #| (controller) => controller.dispose()

///|
pub impl @vscode.Disposable for NotebookController with dispose(self) {
  notebook_controller_dispose_raw(self)
}

///|
/// A controller can set affinities for specific notebook documents. This allows a controller
/// to be presented more prominent for some notebooks.
///
/// @param notebook The notebook for which a priority is set.
/// @param affinity A controller affinity
pub fn NotebookController::update_notebook_affinity(
  self : NotebookController,
  notebook : NotebookDocument,
  affinity : NotebookControllerAffinity,
) -> Unit {
  notebooks_controller_update_notebook_affinity_ffi(self, notebook, affinity)
}

///|
/// Create a cell execution task.
///
/// _Note_ that there can only be one execution per cell at a time and that an error is thrown if
/// a cell execution is created while another is still active.
///
/// This should be used in response to the {@link NotebookController.executeHandler execution handler}
/// being called or when cell execution has been started else, e.g when a cell was already
/// executing or when cell execution was triggered from another source.
///
/// @param cell The notebook cell for which to create the execution.
/// @returns A notebook cell execution.
pub fn NotebookController::create_notebook_cell_execution(
  self : NotebookController,
  cell : NotebookCell,
) -> NotebookCellExecution {
  notebooks_controller_create_notebook_cell_execution_ffi(self, cell)
}

///|
fn NotebookCellOutputOrMany::to_js(
  self : NotebookCellOutputOrMany,
) -> @v.JsValue {
  match self {
    Single(value) => @v.JsValue::make(value)
    Many(values) => @v.JsValue::make(values)
  }
}

///|
fn NotebookCellOutputItemOrMany::to_js(
  self : NotebookCellOutputItemOrMany,
) -> @v.JsValue {
  match self {
    Single(value) => @v.JsValue::make(value)
    Many(values) => @v.JsValue::make(values)
  }
}

///|
/// The {@link NotebookCell cell} for which this execution has been created.
pub extern "js" fn NotebookCellExecution::cell(
  self : NotebookCellExecution,
) -> NotebookCell =
  #| (execution) => execution.cell

///|
/// A cancellation token which will be triggered when the cell execution is canceled
/// from the UI.
///
/// _Note_ that the cancellation token will not be triggered when the {@link NotebookController controller}
/// that created this execution uses an {@link NotebookController.interruptHandler interrupt-handler}.
pub extern "js" fn NotebookCellExecution::token(
  self : NotebookCellExecution,
) -> CancellationToken =
  #| (execution) => execution.token

///|
/// Set and unset the order of this cell execution.
pub fn NotebookCellExecution::execution_order(
  self : NotebookCellExecution,
) -> Int? {
  let raw = NotebookCellExecution::execution_order_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Set and unset the order of this cell execution.
pub fn NotebookCellExecution::set_execution_order(
  self : NotebookCellExecution,
  value : Int,
) -> Unit {
  NotebookCellExecution::set_execution_order_raw(self, @v.JsValue::make(value))
}

///|
/// Set and unset the order of this cell execution.
pub fn NotebookCellExecution::clear_execution_order(
  self : NotebookCellExecution,
) -> Unit {
  NotebookCellExecution::set_execution_order_raw(self, @v.JsValue::make(()))
}

///|
/// Set and unset the order of this cell execution.
extern "js" fn NotebookCellExecution::execution_order_raw(
  self : NotebookCellExecution,
) -> @v.JsValue =
  #| (execution) => execution.executionOrder

///|
/// Set and unset the order of this cell execution.
extern "js" fn NotebookCellExecution::set_execution_order_raw(
  self : NotebookCellExecution,
  value : @v.JsValue,
) -> Unit =
  #| (execution, value) => { execution.executionOrder = value === undefined || value === null ? undefined : value; }

///|
/// Signal that the execution has begun.
///
/// @param startTime The time that execution began, in milliseconds in the Unix epoch. Used to drive the clock
/// that shows for how long a cell has been running. If not given, the clock won't be shown.
pub fn NotebookCellExecution::start(
  self : NotebookCellExecution,
  start_time? : Int,
) -> Unit {
  notebooks_cell_execution_start_ffi(self, option_to_js(start_time))
}

///|
/// Signal that execution has ended.
///
/// @param success If true, a green check is shown on the cell status bar.
/// If false, a red X is shown.
/// If undefined, no check or X icon is shown.
/// @param endTime The time that execution finished, in milliseconds in the Unix epoch.
pub fn NotebookCellExecution::end(
  self : NotebookCellExecution,
  success? : Bool,
  end_time? : Int,
) -> Unit {
  notebooks_cell_execution_end_ffi(
    self,
    option_to_js(success),
    option_to_js(end_time),
  )
}

///|
/// Clears the output of the cell that is executing or of another cell that is affected by this execution.
///
/// @param cell Cell for which output is cleared. Defaults to the {@link NotebookCellExecution.cell cell} of
/// this execution.
/// @returns A thenable that resolves when the operation finished.
pub async fn NotebookCellExecution::clear_output(
  self : NotebookCellExecution,
  cell? : NotebookCell,
) -> Unit {
  @js_async.Promise::wait(
    notebooks_cell_execution_clear_output_ffi(self, option_to_js(cell)),
  )
}

///|
/// Replace the output of the cell that is executing or of another cell that is affected by this execution.
///
/// @param out Output that replaces the current output.
/// @param cell Cell for which output is cleared. Defaults to the {@link NotebookCellExecution.cell cell} of
/// this execution.
/// @returns A thenable that resolves when the operation finished.
pub async fn NotebookCellExecution::replace_output(
  self : NotebookCellExecution,
  out : NotebookCellOutputOrMany,
  cell? : NotebookCell,
) -> Unit {
  @js_async.Promise::wait(
    notebooks_cell_execution_replace_output_ffi(
      self,
      out.to_js(),
      option_to_js(cell),
    ),
  )
}

///|
/// Append to the output of the cell that is executing or to another cell that is affected by this execution.
///
/// @param out Output that is appended to the current output.
/// @param cell Cell for which output is cleared. Defaults to the {@link NotebookCellExecution.cell cell} of
/// this execution.
/// @returns A thenable that resolves when the operation finished.
pub async fn NotebookCellExecution::append_output(
  self : NotebookCellExecution,
  out : NotebookCellOutputOrMany,
  cell? : NotebookCell,
) -> Unit {
  @js_async.Promise::wait(
    notebooks_cell_execution_append_output_ffi(
      self,
      out.to_js(),
      option_to_js(cell),
    ),
  )
}

///|
/// Replace all output items of existing cell output.
///
/// @param items Output items that replace the items of existing output.
/// @param output Output object that already exists.
/// @returns A thenable that resolves when the operation finished.
pub async fn NotebookCellExecution::replace_output_items(
  self : NotebookCellExecution,
  items : NotebookCellOutputItemOrMany,
  output : NotebookCellOutput,
) -> Unit {
  @js_async.Promise::wait(
    notebooks_cell_execution_replace_output_items_ffi(
      self,
      items.to_js(),
      output,
    ),
  )
}

///|
/// Append output items to existing cell output.
///
/// @param items Output items that are append to existing output.
/// @param output Output object that already exists.
/// @returns A thenable that resolves when the operation finished.
pub async fn NotebookCellExecution::append_output_items(
  self : NotebookCellExecution,
  items : NotebookCellOutputItemOrMany,
  output : NotebookCellOutput,
) -> Unit {
  @js_async.Promise::wait(
    notebooks_cell_execution_append_output_items_ffi(
      self,
      items.to_js(),
      output,
    ),
  )
}

///|
/// Creates a new NotebookCellStatusBarItem.
/// @param text The text to show for the item.
/// @param alignment Whether the item is aligned to the left or right.
pub fn NotebookCellStatusBarItem::new(
  text : String,
  alignment : NotebookCellStatusBarAlignment,
) -> NotebookCellStatusBarItem {
  notebooks_status_bar_item_ffi(text, alignment)
}

///|
/// The text to show for the item.
pub extern "js" fn NotebookCellStatusBarItem::text(
  self : NotebookCellStatusBarItem,
) -> String =
  #| (value) => value.text

///|
/// The text to show for the item.
pub extern "js" fn NotebookCellStatusBarItem::set_text(
  self : NotebookCellStatusBarItem,
  value : String,
) -> Unit =
  #| (item, value) => { item.text = value; }

///|
/// Whether the item is aligned to the left or right.
pub extern "js" fn NotebookCellStatusBarItem::alignment(
  self : NotebookCellStatusBarItem,
) -> NotebookCellStatusBarAlignment =
  #| (value) => value.alignment

///|
/// Whether the item is aligned to the left or right.
pub extern "js" fn NotebookCellStatusBarItem::set_alignment(
  self : NotebookCellStatusBarItem,
  value : NotebookCellStatusBarAlignment,
) -> Unit =
  #| (item, value) => { item.alignment = value; }

///|
/// A tooltip to show when the item is hovered.
pub fn NotebookCellStatusBarItem::tooltip(
  self : NotebookCellStatusBarItem,
) -> String? {
  let raw = notebook_cell_status_bar_item_tooltip_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// A tooltip to show when the item is hovered.
pub extern "js" fn NotebookCellStatusBarItem::set_tooltip(
  self : NotebookCellStatusBarItem,
  value : String,
) -> Unit =
  #| (item, value) => { item.tooltip = value; }

///|
/// A tooltip to show when the item is hovered.
pub extern "js" fn NotebookCellStatusBarItem::clear_tooltip(
  self : NotebookCellStatusBarItem,
) -> Unit =
  #| (item) => { item.tooltip = undefined; }

///|
extern "js" fn notebook_cell_status_bar_item_tooltip_raw(
  value : NotebookCellStatusBarItem,
) -> @v.JsValue =
  #| (value) => value.tooltip

///|
pub fn NotebookCellStatusBarItemProvider::new(
  provide_items : async (NotebookCell, CancellationToken) -> Array[
    NotebookCellStatusBarItem,
  ]?,
  on_did_change_cell_status_bar_items? : Event[Unit],
) -> NotebookCellStatusBarItemProvider {
  notebooks_status_bar_item_provider_ffi(
    (cell, token) => {
      @js_async.Promise::from_async(async fn() {
        option_to_js(provide_items(cell, token))
      })
    },
    option_to_js(on_did_change_cell_status_bar_items),
  )
}

///|
/// Register a {@link NotebookCellStatusBarItemProvider cell statusbar item provider} for the given notebook type.
///
/// @param notebookType The notebook type to register for.
/// @param provider A cell status bar provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn register_notebook_cell_status_bar_item_provider(
  notebook_type : String,
  provider : NotebookCellStatusBarItemProvider,
) -> &@vscode.Disposable {
  notebooks_register_notebook_cell_status_bar_item_provider_ffi(
    notebook_type, provider,
  )
}

///|
/// Creates a new messaging instance used to communicate with a specific renderer.
///
/// * *Note 1:* Extensions can only create renderer that they have defined in their `package.json`-file
/// * *Note 2:* A renderer only has access to messaging if `requiresMessaging` is set to `always` or `optional` in
/// its `notebookRenderer` contribution.
///
/// @param rendererId The renderer ID to communicate with
/// @returns A new notebook renderer messaging object.
pub fn create_renderer_messaging(
  renderer_id : String,
) -> NotebookRendererMessaging {
  notebooks_create_renderer_messaging_ffi(renderer_id)
}

///|
/// Creates a new messaging instance used to communicate with a specific renderer.
///
/// * *Note 1:* Extensions can only create renderer that they have defined in their `package.json`-file
/// * *Note 2:* A renderer only has access to messaging if `requiresMessaging` is set to `always` or `optional` in
/// its `notebookRenderer` contribution.
///
/// @param rendererId The renderer ID to communicate with
/// @returns A new notebook renderer messaging object.
pub fn try_create_renderer_messaging(
  renderer_id : String,
) -> NotebookRendererMessaging? {
  let raw = notebooks_try_create_renderer_messaging_ffi(renderer_id)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An event that fires when a message is received from a renderer.

///|
/// Send a message to one or all renderer.
///
/// @param message Message to send
/// @param editor Editor to target with the message. If not provided, the
/// message is sent to all renderers.
/// @returns a boolean indicating whether the message was successfully
/// delivered to any renderer.
pub async fn[T] NotebookRendererMessaging::post_message(
  self : NotebookRendererMessaging,
  message : T,
  editor? : NotebookEditor,
) -> Bool {
  @js_async.Promise::wait(
    notebooks_renderer_messaging_post_message_ffi(
      self,
      @v.JsValue::make(message),
      option_to_js(editor),
    ),
  )
}

///|
pub extern "js" fn NotebookRendererMessageEvent::editor(
  self : NotebookRendererMessageEvent,
) -> NotebookEditor =
  #| (event) => event.editor

///|
pub fn[T] NotebookRendererMessageEvent::message(
  self : NotebookRendererMessageEvent,
) -> T {
  @v.JsValue::make(notebooks_renderer_message_event_message_raw(self)).cast()
}
