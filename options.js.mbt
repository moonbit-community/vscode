///|
/// Option object builders for VS Code APIs.

///|
pub fn TextDocumentShowOptions::new(
  view_column? : ViewColumn,
  preserve_focus? : Bool,
  preview? : Bool,
  selection? : Range,
) -> TextDocumentShowOptions {
  TextDocumentShowOptions::{ view_column, preserve_focus, preview, selection }
}

///|
pub fn NotebookDocumentShowOptions::new(
  view_column? : ViewColumn,
  preserve_focus? : Bool,
  preview? : Bool,
  selections? : Array[NotebookRange],
) -> NotebookDocumentShowOptions {
  NotebookDocumentShowOptions::{
    view_column,
    preserve_focus,
    preview,
    selections,
  }
}

///|
pub fn WorkspaceFolderPickOptions::new(
  place_holder? : String,
  ignore_focus_out? : Bool,
) -> WorkspaceFolderPickOptions {
  WorkspaceFolderPickOptions::{ place_holder, ignore_focus_out }
}

///|
pub fn OpenDialogOptions::new(
  default_uri? : Uri,
  open_label? : String,
  can_select_files? : Bool,
  can_select_folders? : Bool,
  can_select_many? : Bool,
  filters? : DialogFilters,
  title? : String,
) -> OpenDialogOptions {
  OpenDialogOptions::{
    default_uri,
    open_label,
    can_select_files,
    can_select_folders,
    can_select_many,
    filters,
    title,
  }
}

///|
pub fn SaveDialogOptions::new(
  default_uri? : Uri,
  save_label? : String,
  filters? : DialogFilters,
  title? : String,
) -> SaveDialogOptions {
  SaveDialogOptions::{ default_uri, save_label, filters, title }
}

///|
pub fn MessageOptions::new(modal? : Bool, detail? : String) -> MessageOptions {
  MessageOptions::{ modal, detail }
}

///|
pub fn QuickPickOptions::new(
  title? : String,
  match_on_description? : Bool,
  match_on_detail? : Bool,
  place_holder? : String,
  prompt? : String,
  ignore_focus_out? : Bool,
  can_pick_many? : Bool,
  on_did_select_item? : (QuickPickItem) -> Unit,
) -> QuickPickOptions {
  let callback : QuickPickSelectItemCallback? = match on_did_select_item {
    None => None
    Some(callback) => Some(QuickPickSelectItemCallback::QuickPickItem(callback))
  }
  QuickPickOptions::{
    title,
    match_on_description,
    match_on_detail,
    place_holder,
    prompt,
    ignore_focus_out,
    can_pick_many,
    on_did_select_item: callback,
  }
}

///|
pub fn QuickPickOptions::from_strings(
  title? : String,
  match_on_description? : Bool,
  match_on_detail? : Bool,
  place_holder? : String,
  prompt? : String,
  ignore_focus_out? : Bool,
  can_pick_many? : Bool,
  on_did_select_item? : (String) -> Unit,
) -> QuickPickOptions {
  let callback : QuickPickSelectItemCallback? = match on_did_select_item {
    None => None
    Some(callback) => Some(QuickPickSelectItemCallback::StringItem(callback))
  }
  QuickPickOptions::{
    title,
    match_on_description,
    match_on_detail,
    place_holder,
    prompt,
    ignore_focus_out,
    can_pick_many,
    on_did_select_item: callback,
  }
}

///|
pub fn InputBoxOptions::new(
  title? : String,
  value? : String,
  value_selection? : Array[Int],
  prompt? : String,
  place_holder? : String,
  password? : Bool,
  ignore_focus_out? : Bool,
  validate_input? : (String) -> InputBoxValidationResult?,
) -> InputBoxOptions {
  let validator : InputBoxValidateInput? = match validate_input {
    None => None
    Some(callback) => Some(InputBoxValidateInput::Sync(callback))
  }
  InputBoxOptions::{
    title,
    value,
    value_selection,
    prompt,
    place_holder,
    password,
    ignore_focus_out,
    validate_input: validator,
  }
}

///|
pub fn InputBoxOptions::new_async(
  title? : String,
  value? : String,
  value_selection? : Array[Int],
  prompt? : String,
  place_holder? : String,
  password? : Bool,
  ignore_focus_out? : Bool,
  validate_input? : async (String) -> InputBoxValidationResult?,
) -> InputBoxOptions {
  let validator : InputBoxValidateInput? = match validate_input {
    None => None
    Some(callback) => Some(InputBoxValidateInput::Async(callback))
  }
  InputBoxOptions::{
    title,
    value,
    value_selection,
    prompt,
    place_holder,
    password,
    ignore_focus_out,
    validate_input: validator,
  }
}

///|
pub fn NotebookDocumentContentOptions::new(
  transient_outputs? : Bool,
  transient_cell_metadata? : Array[(String, Bool)],
  transient_document_metadata? : Array[(String, Bool)],
) -> NotebookDocumentContentOptions {
  NotebookDocumentContentOptions::{
    transient_outputs,
    transient_cell_metadata,
    transient_document_metadata,
  }
}

///|
pub fn CustomEditorProviderOptions::new(
  webview_options? : WebviewPanelOptions,
  supports_multiple_editors_per_document? : Bool,
) -> CustomEditorProviderOptions {
  CustomEditorProviderOptions::{
    webview_options,
    supports_multiple_editors_per_document,
  }
}

///|
pub fn ProgressOptions::new(
  location : ProgressLocationValue,
  title? : String,
  cancellable? : Bool,
) -> ProgressOptions {
  ProgressOptions::{ location, title, cancellable }
}

///|
pub fn TextEditorOptions::new(
  tab_size? : StringOrInt,
  indent_size? : StringOrInt,
  insert_spaces? : StringOrBool,
  cursor_style? : TextEditorCursorStyle,
  line_numbers? : TextEditorLineNumbersStyle,
) -> TextEditorOptions {
  let tab_size_js = match tab_size {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
  let indent_size_js = match indent_size {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
  let insert_spaces_js = match insert_spaces {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
  text_editor_options_ffi(
    tab_size_js,
    indent_size_js,
    insert_spaces_js,
    option_to_js(cursor_style),
    option_to_js(line_numbers),
  )
}

///|
pub fn TelemetryLoggerOptions::new(
  ignore_built_in_common_properties? : Bool,
  ignore_unhandled_errors? : Bool,
  additional_common_properties? : Array[(String, Any)],
) -> TelemetryLoggerOptions {
  TelemetryLoggerOptions::{
    ignore_built_in_common_properties,
    ignore_unhandled_errors,
    additional_common_properties,
  }
}

///|
extern "js" fn text_editor_options_ffi(
  tab_size : JsValue,
  indent_size : JsValue,
  insert_spaces : JsValue,
  cursor_style : JsValue,
  line_numbers : JsValue,
) -> TextEditorOptions =
  #| (tabSize, indentSize, insertSpaces, cursorStyle, lineNumbers) => {
  #|   const options = {};
  #|   if (tabSize !== undefined && tabSize !== null) options.tabSize = tabSize;
  #|   if (indentSize !== undefined && indentSize !== null) options.indentSize = indentSize;
  #|   if (insertSpaces !== undefined && insertSpaces !== null) options.insertSpaces = insertSpaces;
  #|   if (cursorStyle !== undefined && cursorStyle !== null) options.cursorStyle = cursorStyle;
  #|   if (lineNumbers !== undefined && lineNumbers !== null) options.lineNumbers = lineNumbers;
  #|   return options;
  #| }

///|
extern "js" fn string_json_map_ffi(pairs : Array[(String, Any)]) -> JsValue =
  #| (pairs) => {
  #|   const result = {};
  #|   for (const pair of pairs) {
  #|     const key = pair._0 ?? pair[0];
  #|     const value = pair._1 ?? pair[1];
  #|     result[key] = value;
  #|   }
  #|   return result;
  #| }
