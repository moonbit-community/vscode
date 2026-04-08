///|
/// Tree view helpers and types.

///|
/// Label describing the {@link TreeItem Tree item}
pub(all) struct TreeItemLabel {
  mut label : String
  mut highlights : Array[(Int, Int)]?
}

///|
pub(all) enum TreeItemCollapsibleState {
  None = 0
  Collapsed = 1
  Expanded = 2
} derive(Eq)

///|

///|

///|
pub fn TreeItemLabel::new(
  label : String,
  highlights? : Array[(Int, Int)],
) -> TreeItemLabel {
  TreeItemLabel::{ label, highlights }
}

///|
/// A human-readable string describing this item. When `falsy`, it is derived from {@link TreeItem.resourceUri resourceUri}.
pub fn TreeItem::from_label(
  label : TreeItemLabelValue,
  collapsible_state? : TreeItemCollapsibleState,
) -> TreeItem {
  tree_item_from_label_ffi(label.to_js(), option_to_js(collapsible_state))
}

///|
pub fn TreeItem::from_uri(
  resource_uri : Uri,
  collapsible_state? : TreeItemCollapsibleState,
) -> TreeItem {
  tree_item_from_uri_ffi(resource_uri, option_to_js(collapsible_state))
}

///|
pub fn TreeItem::label(self : TreeItem) -> TreeItemLabelValue? {
  TreeItemLabelValue::from_js(TreeItem::tree_item_label_raw(self))
}

///|
pub fn TreeItem::set_label(self : TreeItem, value : TreeItemLabelValue) -> Unit {
  TreeItem::tree_item_set_label_raw(self, value.to_js())
}

///|
pub fn TreeItem::clear_label(self : TreeItem) -> Unit {
  TreeItem::tree_item_set_label_raw(self, JsValue::make(()))
}

///|
pub fn TreeItem::id(self : TreeItem) -> String? {
  let raw = TreeItem::tree_item_id_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn TreeItem::set_id(self : TreeItem, value : String) -> Unit {
  TreeItem::tree_item_set_id_raw(self, JsValue::make(value))
}

///|
pub fn TreeItem::clear_id(self : TreeItem) -> Unit {
  TreeItem::tree_item_set_id_raw(self, JsValue::make(()))
}

///|
pub fn TreeItem::icon_path(self : TreeItem) -> IconPath? {
  IconPath::from_js(TreeItem::tree_item_icon_path_raw(self))
}

///|
pub fn TreeItem::set_icon_path(self : TreeItem, value : IconPath) -> Unit {
  TreeItem::tree_item_set_icon_path_raw(self, value.to_js())
}

///|
pub fn TreeItem::clear_icon_path(self : TreeItem) -> Unit {
  TreeItem::tree_item_set_icon_path_raw(self, JsValue::make(()))
}

///|
pub fn TreeItem::description(self : TreeItem) -> StringOrBool? {
  StringOrBool::from_js(TreeItem::tree_item_description_raw(self))
}

///|
pub fn TreeItem::set_description(self : TreeItem, value : StringOrBool) -> Unit {
  TreeItem::tree_item_set_description_raw(self, value.to_js())
}

///|
pub fn TreeItem::clear_description(self : TreeItem) -> Unit {
  TreeItem::tree_item_set_description_raw(self, JsValue::make(()))
}

///|
pub fn TreeItem::resource_uri(self : TreeItem) -> Uri? {
  let raw = TreeItem::tree_item_resource_uri_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn TreeItem::set_resource_uri(self : TreeItem, value : Uri) -> Unit {
  TreeItem::tree_item_set_resource_uri_raw(self, JsValue::make(value))
}

///|
pub fn TreeItem::clear_resource_uri(self : TreeItem) -> Unit {
  TreeItem::tree_item_set_resource_uri_raw(self, JsValue::make(()))
}

///|
pub fn TreeItem::tooltip(self : TreeItem) -> Tooltip? {
  Tooltip::from_js(TreeItem::tree_item_tooltip_raw(self))
}

///|
pub fn TreeItem::set_tooltip(self : TreeItem, value : Tooltip) -> Unit {
  TreeItem::tree_item_set_tooltip_raw(self, value.to_js())
}

///|
pub fn TreeItem::clear_tooltip(self : TreeItem) -> Unit {
  TreeItem::tree_item_set_tooltip_raw(self, JsValue::make(()))
}

///|
pub fn TreeItem::command(self : TreeItem) -> Command? {
  let raw = TreeItem::tree_item_command_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn TreeItem::set_command(self : TreeItem, value : Command) -> Unit {
  TreeItem::tree_item_set_command_raw(self, JsValue::make(value))
}

///|
pub fn TreeItem::clear_command(self : TreeItem) -> Unit {
  TreeItem::tree_item_set_command_raw(self, JsValue::make(()))
}

///|
pub fn TreeItem::collapsible_state(self : TreeItem) -> TreeItemCollapsibleState {
  let raw = TreeItem::tree_item_collapsible_state_raw(self)
  if raw.is_null_or_undefined() {
    TreeItemCollapsibleState::None
  } else {
    raw.cast()
  }
}

///|
pub fn TreeItem::set_collapsible_state(
  self : TreeItem,
  value : TreeItemCollapsibleState,
) -> Unit {
  TreeItem::tree_item_set_collapsible_state_raw(self, value)
}

///|
pub fn TreeItem::context_value(self : TreeItem) -> String? {
  let raw = TreeItem::tree_item_context_value_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn TreeItem::set_context_value(self : TreeItem, value : String) -> Unit {
  TreeItem::tree_item_set_context_value_raw(self, JsValue::make(value))
}

///|
pub fn TreeItem::clear_context_value(self : TreeItem) -> Unit {
  TreeItem::tree_item_set_context_value_raw(self, JsValue::make(()))
}

///|
pub fn TreeItem::accessibility_information(
  self : TreeItem,
) -> AccessibilityInformation? {
  accessibility_information_from_js(
    TreeItem::tree_item_accessibility_information_raw(self),
  )
}

///|
pub fn TreeItem::set_accessibility_information(
  self : TreeItem,
  value : AccessibilityInformation,
) -> Unit {
  TreeItem::tree_item_set_accessibility_information_raw(
    self,
    accessibility_information_to_js(value),
  )
}

///|
pub fn TreeItem::clear_accessibility_information(self : TreeItem) -> Unit {
  TreeItem::tree_item_set_accessibility_information_raw(self, JsValue::make(()))
}

///|
pub fn TreeItem::checkbox_state(self : TreeItem) -> TreeItemCheckboxValue? {
  TreeItemCheckboxValue::from_js(TreeItem::tree_item_checkbox_state_raw(self))
}

///|
pub fn TreeItem::set_checkbox_state(
  self : TreeItem,
  value : TreeItemCheckboxValue,
) -> Unit {
  TreeItem::tree_item_set_checkbox_state_raw(self, value.to_js())
}

///|
pub fn TreeItem::clear_checkbox_state(self : TreeItem) -> Unit {
  TreeItem::tree_item_set_checkbox_state_raw(self, JsValue::make(()))
}

///|
pub fn[T] TreeDragAndDropController::new(
  drop_mime_types? : Array[String],
  drag_mime_types? : Array[String],
  handle_drag? : async (Array[T], DataTransfer, CancellationToken) -> Unit,
  handle_drop? : async (T?, DataTransfer, CancellationToken) -> Unit,
) -> TreeDragAndDropController[T] {
  ignore(TreeDragAndDropController::{
    drop_mime_types,
    drag_mime_types,
    preview_item: (None : T?),
  })
  let handle_drag_value : ((Array[T], DataTransfer, CancellationToken) -> @js_async.Promise[
    Unit,
  ])? = match handle_drag {
    None => None
    Some(callback) =>
      Some((source, data_transfer, token) => {
        @js_async.Promise::from_async(async fn() {
          callback(source, data_transfer, token)
        })
      })
  }
  let handle_drop_value : ((JsValue, DataTransfer, CancellationToken) -> @js_async.Promise[
    Unit,
  ])? = match handle_drop {
    None => None
    Some(callback) =>
      Some((target, data_transfer, token) => {
        @js_async.Promise::from_async(async fn() {
          let value : T? = if target.is_null_or_undefined() {
            None
          } else {
            let casted : T = target.cast()
            Some(casted)
          }
          callback(value, data_transfer, token)
        })
      })
  }
  JsValue::make(
    tree_drag_and_drop_controller_ffi(
      option_to_js(drop_mime_types),
      option_to_js(drag_mime_types),
      option_to_js(handle_drag_value),
      option_to_js(handle_drop_value),
    ),
  ).cast()
}

///|
pub fn ViewBadge::new(value : Int, tooltip : String) -> ViewBadge {
  ViewBadge::{ value, tooltip }
}

///|
/// A human-readable string describing this item. When `falsy`, it is derived from {@link TreeItem.resourceUri resourceUri}.

///|
/// A human-readable string describing this item. When `falsy`, it is derived from {@link TreeItem.resourceUri resourceUri}.

///|
/// A human-readable string describing this item. When `falsy`, it is derived from {@link TreeItem.resourceUri resourceUri}.

///|
/// Optional id for the tree item that has to be unique across tree. The id is used to preserve the selection and expansion state of the tree item.
///
/// If not provided, an id is generated using the tree item's label. **Note** that when labels change, ids will change and that selection and expansion state cannot be kept stable anymore.

///|
/// Optional id for the tree item that has to be unique across tree. The id is used to preserve the selection and expansion state of the tree item.
///
/// If not provided, an id is generated using the tree item's label. **Note** that when labels change, ids will change and that selection and expansion state cannot be kept stable anymore.

///|
/// Optional id for the tree item that has to be unique across tree. The id is used to preserve the selection and expansion state of the tree item.
///
/// If not provided, an id is generated using the tree item's label. **Note** that when labels change, ids will change and that selection and expansion state cannot be kept stable anymore.

///|
/// The icon path or {@link ThemeIcon} for the tree item.
/// When `falsy`, {@link ThemeIcon.Folder Folder Theme Icon} is assigned, if item is collapsible otherwise {@link ThemeIcon.File File Theme Icon}.
/// When a file or folder {@link ThemeIcon} is specified, icon is derived from the current file icon theme for the specified theme icon using {@link TreeItem.resourceUri resourceUri} (if provided).

///|
/// The icon path or {@link ThemeIcon} for the tree item.
/// When `falsy`, {@link ThemeIcon.Folder Folder Theme Icon} is assigned, if item is collapsible otherwise {@link ThemeIcon.File File Theme Icon}.
/// When a file or folder {@link ThemeIcon} is specified, icon is derived from the current file icon theme for the specified theme icon using {@link TreeItem.resourceUri resourceUri} (if provided).

///|
/// The icon path or {@link ThemeIcon} for the tree item.
/// When `falsy`, {@link ThemeIcon.Folder Folder Theme Icon} is assigned, if item is collapsible otherwise {@link ThemeIcon.File File Theme Icon}.
/// When a file or folder {@link ThemeIcon} is specified, icon is derived from the current file icon theme for the specified theme icon using {@link TreeItem.resourceUri resourceUri} (if provided).

///|
/// A human-readable string which is rendered less prominent.
/// When `true`, it is derived from {@link TreeItem.resourceUri resourceUri} and when `falsy`, it is not shown.

///|
/// A human-readable string which is rendered less prominent.
/// When `true`, it is derived from {@link TreeItem.resourceUri resourceUri} and when `falsy`, it is not shown.

///|
/// A human-readable string which is rendered less prominent.
/// When `true`, it is derived from {@link TreeItem.resourceUri resourceUri} and when `falsy`, it is not shown.

///|
/// A {@link Uri} representing the resource associated with this item.
///
/// When set, this property is used to automatically derive several item properties if they are not explicitly provided:
/// - **Label**: Derived from the resource's file name when {@link TreeItem.label label} is not provided.
/// - **Description**: Derived from the resource's path when {@link TreeItem.description description} is set to `true`.
/// - **Icon**: Derived from the current file icon theme when {@link TreeItem.iconPath iconPath} is set to
///   {@link ThemeIcon.File} or {@link ThemeIcon.Folder}.

///|
/// A {@link Uri} representing the resource associated with this item.
///
/// When set, this property is used to automatically derive several item properties if they are not explicitly provided:
/// - **Label**: Derived from the resource's file name when {@link TreeItem.label label} is not provided.
/// - **Description**: Derived from the resource's path when {@link TreeItem.description description} is set to `true`.
/// - **Icon**: Derived from the current file icon theme when {@link TreeItem.iconPath iconPath} is set to
///   {@link ThemeIcon.File} or {@link ThemeIcon.Folder}.

///|
/// A {@link Uri} representing the resource associated with this item.
///
/// When set, this property is used to automatically derive several item properties if they are not explicitly provided:
/// - **Label**: Derived from the resource's file name when {@link TreeItem.label label} is not provided.
/// - **Description**: Derived from the resource's path when {@link TreeItem.description description} is set to `true`.
/// - **Icon**: Derived from the current file icon theme when {@link TreeItem.iconPath iconPath} is set to
///   {@link ThemeIcon.File} or {@link ThemeIcon.Folder}.

///|
/// The tooltip text when you hover over this item.

///|
/// The tooltip text when you hover over this item.

///|
/// The tooltip text when you hover over this item.

///|
/// The {@link Command} that should be executed when the tree item is selected.
///
/// Please use `vscode.open` or `vscode.diff` as command IDs when the tree item is opening
/// something in the editor. Using these commands ensures that the resulting editor will
/// appear consistent with how other built-in trees open editors.

///|
/// The {@link Command} that should be executed when the tree item is selected.
///
/// Please use `vscode.open` or `vscode.diff` as command IDs when the tree item is opening
/// something in the editor. Using these commands ensures that the resulting editor will
/// appear consistent with how other built-in trees open editors.

///|
/// The {@link Command} that should be executed when the tree item is selected.
///
/// Please use `vscode.open` or `vscode.diff` as command IDs when the tree item is opening
/// something in the editor. Using these commands ensures that the resulting editor will
/// appear consistent with how other built-in trees open editors.

///|
/// {@link TreeItemCollapsibleState} of the tree item.

///|
/// {@link TreeItemCollapsibleState} of the tree item.

///|
/// Context value of the tree item. This can be used to contribute item specific actions in the tree.
/// For example, a tree item is given a context value as `folder`. When contributing actions to `view/item/context`
/// using `menus` extension point, you can specify context value for key `viewItem` in `when` expression like `viewItem == folder`.
/// ```json
/// "contributes": {
///   "menus": {
///     "view/item/context": [
///       {
///         "command": "extension.deleteFolder",
///         "when": "viewItem == folder"
///       }
///     ]
///   }
/// }
/// ```
/// This will show action `extension.deleteFolder` only for items with `contextValue` is `folder`.

///|
/// Context value of the tree item. This can be used to contribute item specific actions in the tree.
/// For example, a tree item is given a context value as `folder`. When contributing actions to `view/item/context`
/// using `menus` extension point, you can specify context value for key `viewItem` in `when` expression like `viewItem == folder`.
/// ```json
/// "contributes": {
///   "menus": {
///     "view/item/context": [
///       {
///         "command": "extension.deleteFolder",
///         "when": "viewItem == folder"
///       }
///     ]
///   }
/// }
/// ```
/// This will show action `extension.deleteFolder` only for items with `contextValue` is `folder`.

///|
/// Context value of the tree item. This can be used to contribute item specific actions in the tree.
/// For example, a tree item is given a context value as `folder`. When contributing actions to `view/item/context`
/// using `menus` extension point, you can specify context value for key `viewItem` in `when` expression like `viewItem == folder`.
/// ```json
/// "contributes": {
///   "menus": {
///     "view/item/context": [
///       {
///         "command": "extension.deleteFolder",
///         "when": "viewItem == folder"
///       }
///     ]
///   }
/// }
/// ```
/// This will show action `extension.deleteFolder` only for items with `contextValue` is `folder`.

///|
/// Accessibility information used when screen reader interacts with this tree item.
/// Generally, a TreeItem has no need to set the `role` of the accessibilityInformation;
/// however, there are cases where a TreeItem is not displayed in a tree-like way where setting the `role` may make sense.

///|
/// Accessibility information used when screen reader interacts with this tree item.
/// Generally, a TreeItem has no need to set the `role` of the accessibilityInformation;
/// however, there are cases where a TreeItem is not displayed in a tree-like way where setting the `role` may make sense.

///|
/// Accessibility information used when screen reader interacts with this tree item.
/// Generally, a TreeItem has no need to set the `role` of the accessibilityInformation;
/// however, there are cases where a TreeItem is not displayed in a tree-like way where setting the `role` may make sense.

///|
/// {@link TreeItemCheckboxState TreeItemCheckboxState} of the tree item.
/// {@link TreeDataProvider.onDidChangeTreeData onDidChangeTreeData} should be fired when {@link TreeItem.checkboxState checkboxState} changes.

///|
/// {@link TreeItemCheckboxState TreeItemCheckboxState} of the tree item.
/// {@link TreeDataProvider.onDidChangeTreeData onDidChangeTreeData} should be fired when {@link TreeItem.checkboxState checkboxState} changes.

///|
/// {@link TreeItemCheckboxState TreeItemCheckboxState} of the tree item.
/// {@link TreeDataProvider.onDidChangeTreeData onDidChangeTreeData} should be fired when {@link TreeItem.checkboxState checkboxState} changes.

///|

///|
extern "js" fn tree_item_from_label_ffi(
  label : JsValue,
  collapsible_state : JsValue,
) -> TreeItem =
  #| (label, collapsibleState) => new (require('vscode').TreeItem)(label, collapsibleState)

///|
extern "js" fn tree_item_from_uri_ffi(
  resource_uri : Uri,
  collapsible_state : JsValue,
) -> TreeItem =
  #| (resourceUri, collapsibleState) => new (require('vscode').TreeItem)(resourceUri, collapsibleState)

///|
extern "js" fn TreeItem::tree_item_label_raw(self : TreeItem) -> JsValue =
  #| (item) => item.label

///|
extern "js" fn TreeItem::tree_item_set_label_raw(
  self : TreeItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.label = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn TreeItem::tree_item_id_raw(self : TreeItem) -> JsValue =
  #| (item) => item.id

///|
extern "js" fn TreeItem::tree_item_set_id_raw(
  self : TreeItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.id = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn TreeItem::tree_item_icon_path_raw(self : TreeItem) -> JsValue =
  #| (item) => item.iconPath

///|
extern "js" fn TreeItem::tree_item_set_icon_path_raw(
  self : TreeItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.iconPath = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn TreeItem::tree_item_description_raw(self : TreeItem) -> JsValue =
  #| (item) => item.description

///|
extern "js" fn TreeItem::tree_item_set_description_raw(
  self : TreeItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.description = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn TreeItem::tree_item_resource_uri_raw(self : TreeItem) -> JsValue =
  #| (item) => item.resourceUri

///|
extern "js" fn TreeItem::tree_item_set_resource_uri_raw(
  self : TreeItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.resourceUri = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn TreeItem::tree_item_tooltip_raw(self : TreeItem) -> JsValue =
  #| (item) => item.tooltip

///|
extern "js" fn TreeItem::tree_item_set_tooltip_raw(
  self : TreeItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.tooltip = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn TreeItem::tree_item_command_raw(self : TreeItem) -> JsValue =
  #| (item) => item.command

///|
extern "js" fn TreeItem::tree_item_set_command_raw(
  self : TreeItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.command = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn TreeItem::tree_item_collapsible_state_raw(
  self : TreeItem,
) -> JsValue =
  #| (item) => item.collapsibleState

///|
extern "js" fn TreeItem::tree_item_set_collapsible_state_raw(
  self : TreeItem,
  value : TreeItemCollapsibleState,
) -> Unit =
  #| (item, value) => { item.collapsibleState = value; }

///|
extern "js" fn TreeItem::tree_item_context_value_raw(
  self : TreeItem,
) -> JsValue =
  #| (item) => item.contextValue

///|
extern "js" fn TreeItem::tree_item_set_context_value_raw(
  self : TreeItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.contextValue = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn TreeItem::tree_item_accessibility_information_raw(
  self : TreeItem,
) -> JsValue =
  #| (item) => item.accessibilityInformation

///|
extern "js" fn TreeItem::tree_item_set_accessibility_information_raw(
  self : TreeItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.accessibilityInformation = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn TreeItem::tree_item_checkbox_state_raw(
  self : TreeItem,
) -> JsValue =
  #| (item) => item.checkboxState

///|
extern "js" fn TreeItem::tree_item_set_checkbox_state_raw(
  self : TreeItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.checkboxState = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn tree_drag_and_drop_controller_ffi(
  drop_mime_types : JsValue,
  drag_mime_types : JsValue,
  handle_drag : JsValue,
  handle_drop : JsValue,
) -> TreeDragAndDropController[JsValue] =
  #| (dropMimeTypes, dragMimeTypes, handleDrag, handleDrop) => {
  #|   const controller = {};
  #|   if (dropMimeTypes !== undefined && dropMimeTypes !== null) {
  #|     controller.dropMimeTypes = dropMimeTypes;
  #|   }
  #|   if (dragMimeTypes !== undefined && dragMimeTypes !== null) {
  #|     controller.dragMimeTypes = dragMimeTypes;
  #|   }
  #|   if (handleDrag !== undefined && handleDrag !== null) controller.handleDrag = handleDrag;
  #|   if (handleDrop !== undefined && handleDrop !== null) controller.handleDrop = handleDrop;
  #|   return controller;
  #| }
