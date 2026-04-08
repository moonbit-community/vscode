///|
/// Tab group helpers.

///|
pub(all) enum TabInput {
  Text(TabInputText)
  TextDiff(TabInputTextDiff)
  Custom(TabInputCustom)
  Webview(TabInputWebview)
  Notebook(TabInputNotebook)
  NotebookDiff(TabInputNotebookDiff)
  Terminal(TabInputTerminal)
}

///|
/// The tab represents a single text based resource.
pub type TabInputText

///|
/// The tab represents two text based resources
/// being rendered as a diff.
pub type TabInputTextDiff

///|
/// The tab represents a custom editor.
pub type TabInputCustom

///|
/// The tab represents a webview.
pub type TabInputWebview

///|
/// The tab represents a notebook.
pub type TabInputNotebook

///|
/// The tabs represents two notebooks in a diff configuration.
pub type TabInputNotebookDiff

///|
/// The tab represents a terminal in the editor area.
pub type TabInputTerminal

///|
pub fn TabInput::as_text(self : TabInput) -> TabInputText? {
  match self {
    Text(value) => Some(value)
    _ => None
  }
}

///|
pub fn TabInput::as_text_diff(self : TabInput) -> TabInputTextDiff? {
  match self {
    TextDiff(value) => Some(value)
    _ => None
  }
}

///|
pub fn TabInput::as_custom(self : TabInput) -> TabInputCustom? {
  match self {
    Custom(value) => Some(value)
    _ => None
  }
}

///|
pub fn TabInput::as_webview(self : TabInput) -> TabInputWebview? {
  match self {
    Webview(value) => Some(value)
    _ => None
  }
}

///|
pub fn TabInput::as_notebook(self : TabInput) -> TabInputNotebook? {
  match self {
    Notebook(value) => Some(value)
    _ => None
  }
}

///|
pub fn TabInput::as_notebook_diff(self : TabInput) -> TabInputNotebookDiff? {
  match self {
    NotebookDiff(value) => Some(value)
    _ => None
  }
}

///|
pub fn TabInput::as_terminal(self : TabInput) -> TabInputTerminal? {
  match self {
    Terminal(value) => Some(value)
    _ => None
  }
}

///|
/// Constructs a text tab input with the given URI.
/// @param uri The URI of the tab.
pub fn TabInputText::new(uri : Uri) -> TabInputText {
  tab_input_text_ffi(uri)
}

///|
/// The uri represented by the tab.
pub extern "js" fn TabInputText::uri(self : TabInputText) -> Uri =
  #| (value) => value.uri

///|
/// Constructs a new text diff tab input with the given URIs.
/// @param original The uri of the original text resource.
/// @param modified The uri of the modified text resource.
pub fn TabInputTextDiff::new(
  original : Uri,
  modified : Uri,
) -> TabInputTextDiff {
  tab_input_text_diff_ffi(original, modified)
}

///|
/// The uri of the original text resource.
pub extern "js" fn TabInputTextDiff::original(self : TabInputTextDiff) -> Uri =
  #| (value) => value.original

///|
/// The uri of the modified text resource.
pub extern "js" fn TabInputTextDiff::modified(self : TabInputTextDiff) -> Uri =
  #| (value) => value.modified

///|
/// Constructs a custom editor tab input.
/// @param uri The uri of the tab.
/// @param viewType The viewtype of the custom editor.
pub fn TabInputCustom::new(uri : Uri, view_type : String) -> TabInputCustom {
  tab_input_custom_ffi(uri, view_type)
}

///|
/// The uri that the tab is representing.
pub extern "js" fn TabInputCustom::uri(self : TabInputCustom) -> Uri =
  #| (value) => value.uri

///|
/// The type of custom editor.
pub extern "js" fn TabInputCustom::view_type(self : TabInputCustom) -> String =
  #| (value) => value.viewType

///|
/// Constructs a webview tab input with the given view type.
/// @param viewType The type of webview. Maps to {@linkcode WebviewPanel.viewType WebviewPanel's viewType}
pub fn TabInputWebview::new(view_type : String) -> TabInputWebview {
  tab_input_webview_ffi(view_type)
}

///|
/// The type of webview. Maps to {@linkcode WebviewPanel.viewType WebviewPanel's viewType}
pub extern "js" fn TabInputWebview::view_type(self : TabInputWebview) -> String =
  #| (value) => value.viewType

///|
/// Constructs a new tab input for a notebook.
/// @param uri The uri of the notebook.
/// @param notebookType The type of notebook. Maps to {@linkcode NotebookDocument.notebookType NotebookDocuments's notebookType}
pub fn TabInputNotebook::new(
  uri : Uri,
  notebook_type : String,
) -> TabInputNotebook {
  tab_input_notebook_ffi(uri, notebook_type)
}

///|
/// The uri that the tab is representing.
pub extern "js" fn TabInputNotebook::uri(self : TabInputNotebook) -> Uri =
  #| (value) => value.uri

///|
/// The type of notebook. Maps to {@linkcode NotebookDocument.notebookType NotebookDocuments's notebookType}
pub extern "js" fn TabInputNotebook::notebook_type(
  self : TabInputNotebook,
) -> String =
  #| (value) => value.notebookType

///|
/// Constructs a notebook diff tab input.
/// @param original The uri of the original unmodified notebook.
/// @param modified The uri of the modified notebook.
/// @param notebookType The type of notebook. Maps to {@linkcode NotebookDocument.notebookType NotebookDocuments's notebookType}
pub fn TabInputNotebookDiff::new(
  original : Uri,
  modified : Uri,
  notebook_type : String,
) -> TabInputNotebookDiff {
  tab_input_notebook_diff_ffi(original, modified, notebook_type)
}

///|
/// The uri of the original notebook.
pub extern "js" fn TabInputNotebookDiff::original(
  self : TabInputNotebookDiff,
) -> Uri =
  #| (value) => value.original

///|
/// The uri of the modified notebook.
pub extern "js" fn TabInputNotebookDiff::modified(
  self : TabInputNotebookDiff,
) -> Uri =
  #| (value) => value.modified

///|
/// The type of notebook. Maps to {@linkcode NotebookDocument.notebookType NotebookDocuments's notebookType}
pub extern "js" fn TabInputNotebookDiff::notebook_type(
  self : TabInputNotebookDiff,
) -> String =
  #| (value) => value.notebookType

///|
/// Constructs a terminal tab input.
pub fn TabInputTerminal::new() -> TabInputTerminal {
  tab_input_terminal_ffi()
}

///|
/// The text displayed on the tab.

///|
/// The group which the tab belongs to.

///|
/// Defines the structure of the tab i.e. text, notebook, custom, etc.
/// Resource and other useful properties are defined on the tab kind.

///|
/// Whether or not the tab is currently active.
/// This is dictated by being the selected tab in the group.

///|
/// Whether or not the dirty indicator is present on the tab.

///|
/// Whether or not the tab is pinned (pin icon is present).

///|
/// Whether or not the tab is in preview mode.

///|
/// The tabs that have been opened.
pub fn TabChangeEvent::new(
  opened? : Array[Tab] = [],
  closed? : Array[Tab] = [],
  changed? : Array[Tab] = [],
) -> TabChangeEvent {
  TabChangeEvent::{ opened, closed, changed }
}

///|
extern "js" fn tab_input_text_ffi(uri : Uri) -> TabInputText =
  #| (uri) => new (require("vscode").TabInputText)(uri)

///|
extern "js" fn tab_input_text_diff_ffi(
  original : Uri,
  modified : Uri,
) -> TabInputTextDiff =
  #| (original, modified) =>
  #|   new (require("vscode").TabInputTextDiff)(original, modified)

///|
extern "js" fn tab_input_custom_ffi(
  uri : Uri,
  view_type : String,
) -> TabInputCustom =
  #| (uri, viewType) => new (require("vscode").TabInputCustom)(uri, viewType)

///|
extern "js" fn tab_input_webview_ffi(view_type : String) -> TabInputWebview =
  #| (viewType) => new (require("vscode").TabInputWebview)(viewType)

///|
extern "js" fn tab_input_notebook_ffi(
  uri : Uri,
  notebook_type : String,
) -> TabInputNotebook =
  #| (uri, notebookType) =>
  #|   new (require("vscode").TabInputNotebook)(uri, notebookType)

///|
extern "js" fn tab_input_notebook_diff_ffi(
  original : Uri,
  modified : Uri,
  notebook_type : String,
) -> TabInputNotebookDiff =
  #| (original, modified, notebookType) =>
  #|   new (require("vscode").TabInputNotebookDiff)(
  #|     original,
  #|     modified,
  #|     notebookType,
  #|   )

///|
extern "js" fn tab_input_terminal_ffi() -> TabInputTerminal =
  #| () => new (require("vscode").TabInputTerminal)()

///|
/// The tabs that have been opened.

///|
/// The tabs that have been closed.

///|
/// Tabs that have changed, e.g have changed
/// their {@link Tab.isActive active} state.

///|
/// Tab groups that have been opened.
pub fn TabGroupChangeEvent::new(
  opened? : Array[TabGroup] = [],
  closed? : Array[TabGroup] = [],
  changed? : Array[TabGroup] = [],
) -> TabGroupChangeEvent {
  TabGroupChangeEvent::{ opened, closed, changed }
}

///|
/// Tab groups that have been opened.

///|
/// Tab groups that have been closed.

///|
/// Tab groups that have changed, e.g have changed
/// their {@link TabGroup.isActive active} state.

///|
/// Whether or not the group is currently active.
///
/// *Note* that only one tab group is active at a time, but that multiple tab
/// groups can have an {@link activeTab active tab}.
///
/// @see {@link Tab.isActive}

///|
/// The view column of the group.

///|
/// The active {@link Tab tab} in the group. This is the tab whose contents are currently
/// being rendered.
///
/// *Note* that there can be one active tab per group but there can only be one {@link TabGroups.activeTabGroup active group}.

///|
/// The list of tabs contained within the group.
/// This can be empty if the group has no tabs open.
