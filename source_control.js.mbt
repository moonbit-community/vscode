///|
/// Source control helpers.

///|
/// Setter and getter for the contents of the input box.
pub extern "js" fn SourceControlInputBox::value(
  self : SourceControlInputBox,
) -> String =
  #| (input) => input.value

///|
/// Setter and getter for the contents of the input box.
pub extern "js" fn SourceControlInputBox::set_value(
  self : SourceControlInputBox,
  value : String,
) -> Unit =
  #| (input, value) => { input.value = value; }

///|
/// A string to show as placeholder in the input box to guide the user.
pub extern "js" fn SourceControlInputBox::placeholder(
  self : SourceControlInputBox,
) -> String =
  #| (input) => input.placeholder

///|
/// A string to show as placeholder in the input box to guide the user.
pub extern "js" fn SourceControlInputBox::set_placeholder(
  self : SourceControlInputBox,
  value : String,
) -> Unit =
  #| (input, value) => { input.placeholder = value; }

///|
/// Controls whether the input box is enabled (default is `true`).
pub extern "js" fn SourceControlInputBox::enabled(
  self : SourceControlInputBox,
) -> Bool =
  #| (input) => input.enabled

///|
/// Controls whether the input box is enabled (default is `true`).
pub extern "js" fn SourceControlInputBox::set_enabled(
  self : SourceControlInputBox,
  value : Bool,
) -> Unit =
  #| (input, value) => { input.enabled = value; }

///|
/// Controls whether the input box is visible (default is `true`).
pub extern "js" fn SourceControlInputBox::visible(
  self : SourceControlInputBox,
) -> Bool =
  #| (input) => input.visible

///|
/// Controls whether the input box is visible (default is `true`).
pub extern "js" fn SourceControlInputBox::set_visible(
  self : SourceControlInputBox,
  value : Bool,
) -> Unit =
  #| (input, value) => { input.visible = value; }

///|
pub fn SourceControlResourceThemableDecorations::new(
  icon_path? : IconPath,
) -> SourceControlResourceThemableDecorations {
  source_control_resource_themable_decorations_ffi(
    option_icon_path_to_js(icon_path),
  )
}

///|
/// The icon path for a specific
/// {@link SourceControlResourceState source control resource state}.

///|
pub fn SourceControlResourceDecorations::new(
  strike_through? : Bool,
  faded? : Bool,
  tooltip? : String,
  light? : SourceControlResourceThemableDecorations,
  dark? : SourceControlResourceThemableDecorations,
  icon_path? : IconPath,
) -> SourceControlResourceDecorations {
  source_control_resource_decorations_ffi(
    option_to_js(strike_through),
    option_to_js(faded),
    option_to_js(tooltip),
    option_source_control_resource_themable_decorations_to_js(light),
    option_source_control_resource_themable_decorations_to_js(dark),
    option_icon_path_to_js(icon_path),
  )
}

///|
/// Whether the {@link SourceControlResourceState source control resource state} should
/// be striked-through in the UI.

///|
/// Whether the {@link SourceControlResourceState source control resource state} should
/// be faded in the UI.

///|
/// The title for a specific
/// {@link SourceControlResourceState source control resource state}.

///|
/// The light theme decorations.

///|
/// The dark theme decorations.

///|

///|
pub fn SourceControlResourceState::new(
  resource_uri : Uri,
  command? : Command,
  decorations? : SourceControlResourceDecorations,
  context_value? : String,
) -> SourceControlResourceState {
  SourceControlResourceState::{
    resourceUri: resource_uri,
    command,
    decorations,
    contextValue: context_value,
  }
}

///|
/// The {@link Uri} of the underlying resource inside the workspace.

///|
/// The {@link Command} which should be run when the resource
/// state is open in the Source Control viewlet.

///|
/// The {@link SourceControlResourceDecorations decorations} for this source control
/// resource state.

///|
/// Context value of the resource state. This can be used to contribute resource specific actions.
/// For example, if a resource is given a context value as `diffable`. When contributing actions to `scm/resourceState/context`
/// using `menus` extension point, you can specify context value for key `scmResourceState` in `when` expressions, like `scmResourceState == diffable`.
/// ```json
/// "contributes": {
///   "menus": {
///     "scm/resourceState/context": [
///       {
///         "command": "extension.diff",
///         "when": "scmResourceState == diffable"
///       }
///     ]
///   }
/// }
/// ```
/// This will show action `extension.diff` only for resources with `contextValue` is `diffable`.

///|
/// The id of this source control resource group.
pub extern "js" fn SourceControlResourceGroup::id(
  self : SourceControlResourceGroup,
) -> String =
  #| (group) => group.id

///|
/// The label of this source control resource group.
pub extern "js" fn SourceControlResourceGroup::label(
  self : SourceControlResourceGroup,
) -> String =
  #| (group) => group.label

///|
/// The label of this source control resource group.
pub extern "js" fn SourceControlResourceGroup::set_label(
  self : SourceControlResourceGroup,
  value : String,
) -> Unit =
  #| (group, value) => { group.label = value; }

///|
/// Whether this source control resource group is hidden when it contains
/// no {@link SourceControlResourceState source control resource states}.
pub fn SourceControlResourceGroup::hide_when_empty(
  self : SourceControlResourceGroup,
) -> Bool? {
  let raw = source_control_resource_group_hide_when_empty_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Whether this source control resource group is hidden when it contains
/// no {@link SourceControlResourceState source control resource states}.
pub fn SourceControlResourceGroup::set_hide_when_empty(
  self : SourceControlResourceGroup,
  value : Bool?,
) -> Unit {
  source_control_resource_group_set_hide_when_empty_raw(
    self,
    option_to_js(value),
  )
}

///|
/// Whether this source control resource group is hidden when it contains
/// no {@link SourceControlResourceState source control resource states}.
pub fn SourceControlResourceGroup::clear_hide_when_empty(
  self : SourceControlResourceGroup,
) -> Unit {
  source_control_resource_group_set_hide_when_empty_raw(self, JsValue::make(()))
}

///|
/// Context value of the resource group. This can be used to contribute resource group specific actions.
/// For example, if a resource group is given a context value of `exportable`, when contributing actions to `scm/resourceGroup/context`
/// using `menus` extension point, you can specify context value for key `scmResourceGroupState` in `when` expressions, like `scmResourceGroupState == exportable`.
/// ```json
/// "contributes": {
///   "menus": {
///     "scm/resourceGroup/context": [
///       {
///         "command": "extension.export",
///         "when": "scmResourceGroupState == exportable"
///       }
///     ]
///   }
/// }
/// ```
/// This will show action `extension.export` only for resource groups with `contextValue` equal to `exportable`.
pub fn SourceControlResourceGroup::context_value(
  self : SourceControlResourceGroup,
) -> String? {
  let raw = source_control_resource_group_context_value_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Context value of the resource group. This can be used to contribute resource group specific actions.
/// For example, if a resource group is given a context value of `exportable`, when contributing actions to `scm/resourceGroup/context`
/// using `menus` extension point, you can specify context value for key `scmResourceGroupState` in `when` expressions, like `scmResourceGroupState == exportable`.
/// ```json
/// "contributes": {
///   "menus": {
///     "scm/resourceGroup/context": [
///       {
///         "command": "extension.export",
///         "when": "scmResourceGroupState == exportable"
///       }
///     ]
///   }
/// }
/// ```
/// This will show action `extension.export` only for resource groups with `contextValue` equal to `exportable`.
pub fn SourceControlResourceGroup::set_context_value(
  self : SourceControlResourceGroup,
  value : String?,
) -> Unit {
  source_control_resource_group_set_context_value_raw(self, option_to_js(value))
}

///|
/// Context value of the resource group. This can be used to contribute resource group specific actions.
/// For example, if a resource group is given a context value of `exportable`, when contributing actions to `scm/resourceGroup/context`
/// using `menus` extension point, you can specify context value for key `scmResourceGroupState` in `when` expressions, like `scmResourceGroupState == exportable`.
/// ```json
/// "contributes": {
///   "menus": {
///     "scm/resourceGroup/context": [
///       {
///         "command": "extension.export",
///         "when": "scmResourceGroupState == exportable"
///       }
///     ]
///   }
/// }
/// ```
/// This will show action `extension.export` only for resource groups with `contextValue` equal to `exportable`.
pub fn SourceControlResourceGroup::clear_context_value(
  self : SourceControlResourceGroup,
) -> Unit {
  source_control_resource_group_set_context_value_raw(self, JsValue::make(()))
}

///|
/// The source control resource states of this resource group.
pub extern "js" fn SourceControlResourceGroup::resource_states(
  self : SourceControlResourceGroup,
) -> Array[SourceControlResourceState] =
  #| (group) => group.resourceStates

///|
/// The source control resource states of this resource group.
pub extern "js" fn SourceControlResourceGroup::set_resource_states(
  self : SourceControlResourceGroup,
  value : Array[SourceControlResourceState],
) -> Unit =
  #| (group, value) => { group.resourceStates = value; }

///|
/// This group's collection of
/// {@link SourceControlResourceState source control resource states}.
extern "js" fn source_control_resource_group_hide_when_empty_raw(
  group : SourceControlResourceGroup,
) -> JsValue =
  #| (group) => group.hideWhenEmpty

///|
extern "js" fn source_control_resource_group_set_hide_when_empty_raw(
  group : SourceControlResourceGroup,
  value : JsValue,
) -> Unit =
  #| (group, value) => { group.hideWhenEmpty = value === undefined || value === null ? undefined : value; }

///|
/// This group's collection of
/// {@link SourceControlResourceState source control resource states}.
extern "js" fn source_control_resource_group_context_value_raw(
  group : SourceControlResourceGroup,
) -> JsValue =
  #| (group) => group.contextValue

///|
extern "js" fn source_control_resource_group_set_context_value_raw(
  group : SourceControlResourceGroup,
  value : JsValue,
) -> Unit =
  #| (group, value) => { group.contextValue = value === undefined || value === null ? undefined : value; }

///|
/// Dispose this source control resource group.
extern "js" fn source_control_resource_group_dispose_raw(
  group : SourceControlResourceGroup,
) -> Unit =
  #| (group) => group.dispose()

///|
pub fn SourceControlResourceGroup::dispose(
  self : SourceControlResourceGroup,
) -> Unit {
  source_control_resource_group_dispose_raw(self)
}

///|
pub impl AsDisposable for SourceControlResourceGroup with fn as_disposable(self) {
  disposable_from_js(self)
}

///|
/// The id of this source control.
pub extern "js" fn SourceControl::id(self : SourceControl) -> String =
  #| (source) => source.id

///|
/// The human-readable label of this source control.
pub extern "js" fn SourceControl::label(self : SourceControl) -> String =
  #| (source) => source.label

///|
/// The (optional) Uri of the root of this source control.
pub fn SourceControl::root_uri(self : SourceControl) -> Uri? {
  let raw = SourceControl::source_control_root_uri_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The {@link SourceControlInputBox input box} for this source control.
pub extern "js" fn SourceControl::input_box(
  self : SourceControl,
) -> SourceControlInputBox =
  #| (source) => source.inputBox

///|
/// The UI-visible count of {@link SourceControlResourceState resource states} of
/// this source control.
///
/// If undefined, this source control will
/// - display its UI-visible count as zero, and
/// - contribute the count of its {@link SourceControlResourceState resource states} to the UI-visible aggregated count for all source controls
pub fn SourceControl::count(self : SourceControl) -> Int? {
  let raw = SourceControl::source_control_count_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The UI-visible count of {@link SourceControlResourceState resource states} of
/// this source control.
///
/// If undefined, this source control will
/// - display its UI-visible count as zero, and
/// - contribute the count of its {@link SourceControlResourceState resource states} to the UI-visible aggregated count for all source controls
pub fn SourceControl::set_count(self : SourceControl, value : Int) -> Unit {
  SourceControl::source_control_set_count_raw(self, JsValue::make(value))
}

///|
/// The UI-visible count of {@link SourceControlResourceState resource states} of
/// this source control.
///
/// If undefined, this source control will
/// - display its UI-visible count as zero, and
/// - contribute the count of its {@link SourceControlResourceState resource states} to the UI-visible aggregated count for all source controls
pub fn SourceControl::clear_count(self : SourceControl) -> Unit {
  SourceControl::source_control_set_count_raw(self, JsValue::make(()))
}

///|
/// An optional {@link QuickDiffProvider quick diff provider}.
pub fn[T : QuickDiffProvider] SourceControl::set_quick_diff_provider(
  self : SourceControl,
  value : T,
) -> Unit {
  source_control_set_quick_diff_raw(
    self,
    quick_diff_provider_ffi((uri, token) => {
      @js_async.Promise::from_async(async fn() {
        option_to_js(value.provide_original_resource(uri, token))
      })
    }),
  )
}

///|
/// An optional {@link QuickDiffProvider quick diff provider}.
pub fn SourceControl::clear_quick_diff_provider(self : SourceControl) -> Unit {
  source_control_set_quick_diff_raw(self, JsValue::make(()))
}

///|
fn option_source_control_resource_themable_decorations_to_js(
  value : SourceControlResourceThemableDecorations?,
) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => source_control_resource_themable_decorations_to_js_ffi(value)
  }
}

///|
/// Optional commit template string.
///
/// The Source Control viewlet will populate the Source Control
/// input with this value when appropriate.
pub fn SourceControl::commit_template(self : SourceControl) -> String? {
  let raw = SourceControl::source_control_commit_template_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Optional commit template string.
///
/// The Source Control viewlet will populate the Source Control
/// input with this value when appropriate.
pub fn SourceControl::set_commit_template(
  self : SourceControl,
  value : String,
) -> Unit {
  SourceControl::source_control_set_commit_template_raw(
    self,
    JsValue::make(value),
  )
}

///|
/// Optional commit template string.
///
/// The Source Control viewlet will populate the Source Control
/// input with this value when appropriate.
pub fn SourceControl::clear_commit_template(self : SourceControl) -> Unit {
  SourceControl::source_control_set_commit_template_raw(self, JsValue::make(()))
}

///|
/// Optional accept input command.
///
/// This command will be invoked when the user accepts the value
/// in the Source Control input.
pub fn SourceControl::accept_input_command(self : SourceControl) -> Command? {
  let raw = SourceControl::source_control_accept_input_command_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Optional accept input command.
///
/// This command will be invoked when the user accepts the value
/// in the Source Control input.
pub fn SourceControl::set_accept_input_command(
  self : SourceControl,
  value : Command,
) -> Unit {
  SourceControl::source_control_set_accept_input_command_raw(
    self,
    JsValue::make(value),
  )
}

///|
/// Optional accept input command.
///
/// This command will be invoked when the user accepts the value
/// in the Source Control input.
pub fn SourceControl::clear_accept_input_command(self : SourceControl) -> Unit {
  SourceControl::source_control_set_accept_input_command_raw(
    self,
    JsValue::make(()),
  )
}

///|
/// Optional status bar commands.
///
/// These commands will be displayed in the editor's status bar.

///|
/// Optional status bar commands.
///
/// These commands will be displayed in the editor's status bar.

///|
/// Optional status bar commands.
///
/// These commands will be displayed in the editor's status bar.

///|
/// Create a new {@link SourceControlResourceGroup resource group}.
pub extern "js" fn SourceControl::create_resource_group(
  self : SourceControl,
  id : String,
  label : String,
) -> SourceControlResourceGroup =
  #| (source, id, label) => source.createResourceGroup(id, label)

///|
/// Dispose this source control.
extern "js" fn source_control_dispose_raw(source : SourceControl) -> Unit =
  #| (source) => source.dispose()

///|
pub fn SourceControl::dispose(self : SourceControl) -> Unit {
  source_control_dispose_raw(self)
}

///|
pub impl AsDisposable for SourceControl with fn as_disposable(self) {
  disposable_from_js(self)
}

///|
extern "js" fn source_control_set_quick_diff_raw(
  source : SourceControl,
  value : JsValue,
) -> Unit =
  #| (source, value) => { source.quickDiffProvider = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn SourceControl::source_control_root_uri_raw(
  self : SourceControl,
) -> JsValue =
  #| (source) => source.rootUri

///|
extern "js" fn SourceControl::source_control_count_raw(
  self : SourceControl,
) -> JsValue =
  #| (source) => source.count

///|
extern "js" fn SourceControl::source_control_set_count_raw(
  self : SourceControl,
  value : JsValue,
) -> Unit =
  #| (source, value) => { source.count = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn SourceControl::source_control_commit_template_raw(
  self : SourceControl,
) -> JsValue =
  #| (source) => source.commitTemplate

///|
extern "js" fn SourceControl::source_control_set_commit_template_raw(
  self : SourceControl,
  value : JsValue,
) -> Unit =
  #| (source, value) => { source.commitTemplate = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn SourceControl::source_control_accept_input_command_raw(
  self : SourceControl,
) -> JsValue =
  #| (source) => source.acceptInputCommand

///|
extern "js" fn SourceControl::source_control_set_accept_input_command_raw(
  self : SourceControl,
  value : JsValue,
) -> Unit =
  #| (source, value) => { source.acceptInputCommand = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn source_control_resource_themable_decorations_ffi(
  icon_path : JsValue,
) -> SourceControlResourceThemableDecorations =
  #| (iconPath) => {
  #|   const value = {};
  #|   if (iconPath !== undefined && iconPath !== null) value.iconPath = iconPath;
  #|   return value;
  #| }

///|
extern "js" fn source_control_resource_themable_decorations_to_js_ffi(
  value : SourceControlResourceThemableDecorations,
) -> JsValue =
  #| (value) => value

///|
extern "js" fn source_control_resource_decorations_ffi(
  strike_through : JsValue,
  faded : JsValue,
  tooltip : JsValue,
  light : JsValue,
  dark : JsValue,
  icon_path : JsValue,
) -> SourceControlResourceDecorations =
  #| (strikeThrough, faded, tooltip, light, dark, iconPath) => {
  #|   const value = {};
  #|   if (strikeThrough !== undefined && strikeThrough !== null) value.strikeThrough = strikeThrough;
  #|   if (faded !== undefined && faded !== null) value.faded = faded;
  #|   if (tooltip !== undefined && tooltip !== null) value.tooltip = tooltip;
  #|   if (light !== undefined && light !== null) value.light = light;
  #|   if (dark !== undefined && dark !== null) value.dark = dark;
  #|   if (iconPath !== undefined && iconPath !== null) value.iconPath = iconPath;
  #|   return value;
  #| }

///|
extern "js" fn quick_diff_provider_ffi(
  provide_original : (Uri, CancellationToken) -> @js_async.Promise[JsValue],
) -> JsValue =
  #| (provideOriginalResource) => ({ provideOriginalResource })
