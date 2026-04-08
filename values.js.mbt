///|
/// Shared value helpers for JS union types.

///|
pub type Any

///|
pub type Date

///|
pub extern "js" fn Date::now() -> Date =
  #| () => new Date()

///|
pub extern "js" fn Date::from_millis(value : Float) -> Date =
  #| (value) => new Date(value)

///|
pub extern "js" fn Date::to_millis(self : Date) -> Float =
  #| (value) => value.getTime()

///|
pub type JsError

///|
pub type RegExp

///|
pub fn RegExp::new(pattern : String, flags? : String) -> RegExp {
  regex_ffi(pattern, option_to_js(flags))
}

///|
pub fn JsError::new(message : String) -> JsError {
  js_error_ffi(message)
}

///|
pub fn[T] Any::from(value : T) -> Any {
  JsValue::make(value).cast()
}

///|
pub fn Any::empty_object() -> Any {
  json_value_empty_object_ffi()
}

///|
pub fn Any::object_get_bool_or(
  self : Any,
  key : String,
  default_value : Bool,
) -> Bool {
  json_value_object_get_bool_or_ffi(self, key, default_value)
}

///|
pub fn Any::object_get_string(self : Any, key : String) -> String? {
  json_value_object_get_string_ffi(self, key)
}

///|
pub fn Any::object_with_bool(self : Any, key : String, value : Bool) -> Any {
  json_value_object_with_bool_ffi(self, key, value)
}

///|
pub fn Any::object_with_string(self : Any, key : String, value : String) -> Any {
  json_value_object_with_string_ffi(self, key, value)
}

///|
pub(all) enum ColorValue {
  Text(String)
  Theme(ThemeColor)
}

///|
fn ColorValue::to_js(self : ColorValue) -> JsValue {
  match self {
    Text(value) => JsValue::make(value)
    Theme(value) => JsValue::make(value)
  }
}

///|
fn ColorValue::from_js(value : JsValue) -> ColorValue? {
  match js_value_as_string_ffi(value) {
    Some(text) => Some(Text(text))
    None =>
      if value.is_null_or_undefined() {
        None
      } else {
        Some(Theme(value.cast()))
      }
  }
}

///|
fn option_color_value_to_js(value : ColorValue?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
}

///|
pub(all) enum Tooltip {
  Text(String)
  Markdown(MarkdownString)
}

///|
fn Tooltip::to_js(self : Tooltip) -> JsValue {
  match self {
    Text(value) => JsValue::make(value)
    Markdown(value) => JsValue::make(value)
  }
}

///|
fn Tooltip::from_js(value : JsValue) -> Tooltip? {
  match js_value_as_string_ffi(value) {
    Some(text) => Some(Text(text))
    None =>
      if value.is_null_or_undefined() {
        None
      } else {
        Some(Markdown(value.cast()))
      }
  }
}

///|
pub(all) enum CommandOrString {
  Id(String)
  CommandValue(Command)
}

///|
fn CommandOrString::to_js(self : CommandOrString) -> JsValue {
  match self {
    Id(value) => JsValue::make(value)
    CommandValue(value) => JsValue::make(value)
  }
}

///|
fn CommandOrString::from_js(value : JsValue) -> CommandOrString? {
  match js_value_as_string_ffi(value) {
    Some(text) => Some(Id(text))
    None =>
      if value.is_null_or_undefined() {
        None
      } else {
        Some(CommandValue(value.cast()))
      }
  }
}

///|
pub(all) enum StringOrUri {
  Text(String)
  UriValue(Uri)
}

///|
fn StringOrUri::to_js(self : StringOrUri) -> JsValue {
  match self {
    Text(value) => JsValue::make(value)
    UriValue(value) => JsValue::make(value)
  }
}

///|
pub(all) enum StringOrBool {
  Text(String)
  Boolean(Bool)
}

///|
fn StringOrBool::to_js(self : StringOrBool) -> JsValue {
  match self {
    Text(value) => JsValue::make(value)
    Boolean(value) => JsValue::make(value)
  }
}

///|
fn StringOrBool::from_js(value : JsValue) -> StringOrBool? {
  match js_value_as_string_ffi(value) {
    Some(text) => Some(Text(text))
    None =>
      match js_value_as_bool_ffi(value) {
        Some(value) => Some(Boolean(value))
        None => if value.is_null_or_undefined() { None } else { None }
      }
  }
}

///|
pub(all) enum MarkdownStringValue {
  Text(String)
  Markdown(MarkdownString)
}

///|
fn MarkdownStringValue::to_js(self : MarkdownStringValue) -> JsValue {
  match self {
    Text(value) => JsValue::make(value)
    Markdown(value) => JsValue::make(value)
  }
}

///|
fn MarkdownStringValue::from_js(value : JsValue) -> MarkdownStringValue? {
  match js_value_as_string_ffi(value) {
    Some(text) => Some(Text(text))
    None =>
      if value.is_null_or_undefined() {
        None
      } else {
        Some(Markdown(value.cast()))
      }
  }
}

///|
pub(all) enum MarkdownStringTrustedValue {
  BoolValue(Bool)
  EnabledCommands(Array[String])
}

///|
fn MarkdownStringTrustedValue::to_js(
  self : MarkdownStringTrustedValue,
) -> JsValue {
  match self {
    BoolValue(value) => JsValue::make(value)
    EnabledCommands(value) => JsValue::make(value)
  }
}

///|
pub(all) enum StringOrSnippetString {
  Text(String)
  Snippet(SnippetString)
}

///|
fn StringOrSnippetString::to_js(self : StringOrSnippetString) -> JsValue {
  match self {
    Text(value) => JsValue::make(value)
    Snippet(value) => JsValue::make(value)
  }
}

///|
fn StringOrSnippetString::from_js(value : JsValue) -> StringOrSnippetString? {
  match js_value_as_string_ffi(value) {
    Some(text) => Some(Text(text))
    None =>
      if value.is_null_or_undefined() {
        None
      } else {
        Some(Snippet(value.cast()))
      }
  }
}

///|
pub(all) enum CompletionItemLabelValue {
  Text(String)
  Label(CompletionItemLabel)
}

///|
fn CompletionItemLabelValue::to_js(self : CompletionItemLabelValue) -> JsValue {
  match self {
    Text(value) => JsValue::make(value)
    Label(value) =>
      values_completion_item_label_to_js_ffi(
        value.label,
        option_to_js(value.detail),
        option_to_js(value.description),
      )
  }
}

///|
fn CompletionItemLabelValue::from_js(
  value : JsValue,
) -> CompletionItemLabelValue? {
  match js_value_as_string_ffi(value) {
    Some(text) => Some(Text(text))
    None =>
      if value.is_null_or_undefined() {
        None
      } else {
        Some(Label(value.cast()))
      }
  }
}

///|
pub(all) enum InlayHintLabelValue {
  Text(String)
  Parts(Array[InlayHintLabelPart])
}

///|
fn InlayHintLabelValue::to_js(self : InlayHintLabelValue) -> JsValue {
  match self {
    Text(value) => JsValue::make(value)
    Parts(value) => JsValue::make(value)
  }
}

///|
fn InlayHintLabelValue::from_js(value : JsValue) -> InlayHintLabelValue? {
  match js_value_as_string_ffi(value) {
    Some(text) => Some(Text(text))
    None =>
      if value.is_null_or_undefined() {
        None
      } else if values_js_value_is_array_ffi(value) {
        Some(Parts(value.cast()))
      } else {
        None
      }
  }
}

///|
pub(all) enum ParameterLabel {
  Text(String)
  Range((Int, Int))
}

///|
fn ParameterLabel::to_js(self : ParameterLabel) -> JsValue {
  match self {
    Text(value) => JsValue::make(value)
    Range((start, end_)) => JsValue::make([start, end_])
  }
}

///|
fn ParameterLabel::from_js(value : JsValue) -> ParameterLabel? {
  match js_value_as_string_ffi(value) {
    Some(text) => Some(Text(text))
    None =>
      if values_js_value_is_array_ffi(value) {
        let raw : Array[Int] = value.cast()
        match raw {
          [start, end_] => Some(Range((start, end_)))
          _ => None
        }
      } else {
        None
      }
  }
}

///|
pub(all) enum HoverContent {
  Markdown(MarkdownString)
  Marked(MarkedString)
}

///|
pub(all) enum StringOrInt {
  Text(String)
  Numeric(Int)
}

///|
fn StringOrInt::to_js(self : StringOrInt) -> JsValue {
  match self {
    Text(value) => JsValue::make(value)
    Numeric(value) => JsValue::make(value)
  }
}

///|
extern "js" fn js_value_as_string_ffi(value : JsValue) -> String? =
  #| (value) => typeof value === "string" ? value : undefined

///|
extern "js" fn js_value_as_bool_ffi(value : JsValue) -> Bool? =
  #| (value) => typeof value === "boolean" ? value : undefined

///|
extern "js" fn js_value_as_int_ffi(value : JsValue) -> Int? =
  #| (value) => Number.isInteger(value) ? value : undefined

///|
extern "js" fn values_js_value_is_array_ffi(value : JsValue) -> Bool =
  #| (value) => Array.isArray(value)

///|
pub(all) enum UriOrString {
  Path(String)
  UriValue(Uri)
}

///|
fn UriOrString::to_js(self : UriOrString) -> JsValue {
  match self {
    Path(value) => JsValue::make(value)
    UriValue(value) => JsValue::make(value)
  }
}

///|
pub(all) enum ShellArgs {
  StringValue(String)
  ArrayValue(Array[String])
}

///|
fn ShellArgs::to_js(self : ShellArgs) -> JsValue {
  match self {
    StringValue(value) => JsValue::make(value)
    ArrayValue(value) => JsValue::make(value)
  }
}

///|
fn option_shell_args_to_js(value : ShellArgs?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
}

///|
pub(all) enum InputBoxValidationResult {
  Text(String)
  Message(InputBoxValidationMessage)
}

///|
fn InputBoxValidationResult::to_js(self : InputBoxValidationResult) -> JsValue {
  match self {
    Text(value) => JsValue::make(value)
    Message(value) =>
      values_input_box_validation_message_to_js_ffi(
        value.message,
        value.severity,
      )
  }
}

///|
fn InputBoxValidationResult::from_js(
  value : JsValue,
) -> InputBoxValidationResult? {
  match js_value_as_string_ffi(value) {
    Some(text) => Some(InputBoxValidationResult::Text(text))
    None =>
      match
        js_value_as_string_ffi(
          values_input_box_validation_message_message_raw(value),
        ) {
        Some(message) =>
          Some(
            InputBoxValidationResult::Message(InputBoxValidationMessage::{
              message,
              severity: values_input_box_validation_message_severity_raw(value).cast(),
            }),
          )
        None => None
      }
  }
}

///|
pub(all) enum ProgressLocationValue {
  Location(ProgressLocation)
  View(String)
}

///|
pub struct DialogFilters {
  pairs : Array[(String, Array[String])]
}

///|
pub fn DialogFilters::new(
  pairs : Array[(String, Array[String])],
) -> DialogFilters {
  DialogFilters::{ pairs, }
}

///|
pub(all) enum TreeItemLabelValue {
  Text(String)
  Label(TreeItemLabel)
}

///|
fn TreeItemLabelValue::to_js(self : TreeItemLabelValue) -> JsValue {
  match self {
    Text(value) => JsValue::make(value)
    Label(value) =>
      values_tree_item_label_to_js_ffi(
        value.label,
        option_to_js(value.highlights),
      )
  }
}

///|
fn TreeItemLabelValue::from_js(value : JsValue) -> TreeItemLabelValue? {
  match js_value_as_string_ffi(value) {
    Some(text) => Some(Text(text))
    None =>
      if value.is_null_or_undefined() {
        None
      } else {
        Some(Label(value.cast()))
      }
  }
}

///|
pub struct TreeItemCheckbox {
  state : TreeItemCheckboxState
  tooltip : String?
  accessibility_information : AccessibilityInformation?
}

///|
pub fn TreeItemCheckbox::new(
  state : TreeItemCheckboxState,
  tooltip? : String,
  accessibility_information? : AccessibilityInformation,
) -> TreeItemCheckbox {
  TreeItemCheckbox::{ state, tooltip, accessibility_information }
}

///|
fn TreeItemCheckbox::to_js(self : TreeItemCheckbox) -> JsValue {
  values_tree_item_checkbox_to_js_ffi(
    self.state,
    option_to_js(self.tooltip),
    match self.accessibility_information {
      None => JsValue::make(())
      Some(value) => accessibility_information_to_js(value)
    },
  )
}

///|
fn TreeItemCheckbox::from_js(value : JsValue) -> TreeItemCheckbox? {
  let state_raw = values_tree_item_checkbox_state_raw(value)
  if state_raw.is_null_or_undefined() {
    None
  } else {
    Some(TreeItemCheckbox::{
      state: state_raw.cast(),
      tooltip: js_value_as_string_ffi(
        values_tree_item_checkbox_tooltip_raw(value),
      ),
      accessibility_information: accessibility_information_from_js(
        values_tree_item_checkbox_accessibility_information_raw(value),
      ),
    })
  }
}

///|
pub(all) enum TreeItemCheckboxValue {
  State(TreeItemCheckboxState)
  Checkbox(TreeItemCheckbox)
}

///|
fn TreeItemCheckboxValue::to_js(self : TreeItemCheckboxValue) -> JsValue {
  match self {
    State(value) => JsValue::make(value)
    Checkbox(value) => value.to_js()
  }
}

///|
fn TreeItemCheckboxValue::from_js(value : JsValue) -> TreeItemCheckboxValue? {
  if value.is_null_or_undefined() {
    None
  } else {
    match TreeItemCheckbox::from_js(value) {
      Some(value) => Some(Checkbox(value))
      None => Some(State(value.cast()))
    }
  }
}

///|
pub(all) enum MarkdownStringOrMarkedString {
  Markdown(MarkdownString)
  Marked(MarkedString)
}

///|
fn MarkdownStringOrMarkedString::to_js(
  self : MarkdownStringOrMarkedString,
) -> JsValue {
  match self {
    Markdown(value) => JsValue::make(value)
    Marked(value) => JsValue::make(value)
  }
}

///|
pub(all) enum HoverMessage {
  Single(MarkdownStringOrMarkedString)
  Many(Array[MarkdownStringOrMarkedString])
}

///|
fn HoverMessage::to_js(self : HoverMessage) -> JsValue {
  match self {
    Single(value) => value.to_js()
    Many(values) => {
      let encoded : Array[JsValue] = []
      for value in values {
        encoded.push(value.to_js())
      }
      JsValue::make(encoded)
    }
  }
}

///|
fn option_hover_message_to_js(value : HoverMessage?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
}

///|
pub fn IconPath::light_dark(light : Uri, dark : Uri) -> IconPath {
  IconPath::LightDarkValue(IconPathLightDark::{ light, dark })
}

///|
pub fn IconPathLightDark::new(light : Uri, dark : Uri) -> IconPathLightDark {
  IconPathLightDark::{ light, dark }
}

///|

///|

///|
fn IconPath::to_js(self : IconPath) -> JsValue {
  match self {
    UriValue(value) => JsValue::make(value)
    LightDarkValue(value) =>
      icon_path_light_dark_to_js_ffi(value.light, value.dark)
    ThemeIconValue(value) => JsValue::make(value)
  }
}

///|
fn IconPath::from_js(value : JsValue) -> IconPath? {
  if value.is_null_or_undefined() {
    None
  } else {
    let light_raw = icon_path_light_raw(value)
    let dark_raw = icon_path_dark_raw(value)
    if !light_raw.is_null_or_undefined() && !dark_raw.is_null_or_undefined() {
      Some(
        LightDarkValue(IconPathLightDark::{
          light: light_raw.cast(),
          dark: dark_raw.cast(),
        }),
      )
    } else if icon_path_is_theme_icon_raw(value) {
      Some(ThemeIconValue(value.cast()))
    } else {
      Some(UriValue(value.cast()))
    }
  }
}

///|
fn option_icon_path_to_js(value : IconPath?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
}

///|
extern "js" fn values_completion_item_label_to_js_ffi(
  label : String,
  detail : JsValue,
  description : JsValue,
) -> JsValue =
  #| (label, detail, description) => {
  #|   const result = { label };
  #|   if (detail !== undefined && detail !== null) {
  #|     result.detail = detail;
  #|   }
  #|   if (description !== undefined && description !== null) {
  #|     result.description = description;
  #|   }
  #|   return result;
  #| }

///|
extern "js" fn values_tree_item_label_to_js_ffi(
  label : String,
  highlights : JsValue,
) -> JsValue =
  #| (label, highlights) => {
  #|   const result = { label };
  #|   if (highlights !== undefined && highlights !== null) {
  #|     result.highlights = highlights;
  #|   }
  #|   return result;
  #| }

///|
extern "js" fn values_tree_item_checkbox_to_js_ffi(
  state : TreeItemCheckboxState,
  tooltip : JsValue,
  accessibility_information : JsValue,
) -> JsValue =
  #| (state, tooltip, accessibilityInformation) => {
  #|   const result = { state };
  #|   if (tooltip !== undefined && tooltip !== null) {
  #|     result.tooltip = tooltip;
  #|   }
  #|   if (accessibilityInformation !== undefined && accessibilityInformation !== null) {
  #|     result.accessibilityInformation = accessibilityInformation;
  #|   }
  #|   return result;
  #| }

///|
extern "js" fn values_tree_item_checkbox_state_raw(value : JsValue) -> JsValue =
  #| (value) => value?.state

///|
extern "js" fn values_tree_item_checkbox_tooltip_raw(
  value : JsValue,
) -> JsValue =
  #| (value) => value?.tooltip

///|
extern "js" fn values_tree_item_checkbox_accessibility_information_raw(
  value : JsValue,
) -> JsValue =
  #| (value) => value?.accessibilityInformation

///|
extern "js" fn values_input_box_validation_message_to_js_ffi(
  message : String,
  severity : InputBoxValidationSeverity,
) -> JsValue =
  #| (message, severity) => ({ message, severity })

///|
extern "js" fn values_input_box_validation_message_message_raw(
  value : JsValue,
) -> JsValue =
  #| (value) => value?.message

///|
extern "js" fn values_input_box_validation_message_severity_raw(
  value : JsValue,
) -> JsValue =
  #| (value) => value?.severity

///|
extern "js" fn icon_path_light_dark_to_js_ffi(
  light : Uri,
  dark : Uri,
) -> JsValue =
  #| (light, dark) => ({ light, dark })

///|
extern "js" fn icon_path_light_raw(value : JsValue) -> JsValue =
  #| (value) => value?.light

///|
extern "js" fn icon_path_dark_raw(value : JsValue) -> JsValue =
  #| (value) => value?.dark

///|
extern "js" fn icon_path_is_theme_icon_raw(value : JsValue) -> Bool =
  #| (value) => value !== undefined && value !== null && typeof value.id === "string"

///|
extern "js" fn js_error_ffi(message : String) -> JsError =
  #| (message) => new Error(message)

///|
extern "js" fn regex_ffi(pattern : String, flags : JsValue) -> RegExp =
  #| (pattern, flags) => new RegExp(pattern, flags)

///|
extern "js" fn json_value_empty_object_ffi() -> Any =
  #| () => ({})

///|
extern "js" fn json_value_object_get_bool_or_ffi(
  value : Any,
  key : String,
  default_value : Bool,
) -> Bool =
  #| (value, key, defaultValue) => {
  #|   if (value === undefined || value === null || typeof value !== "object") {
  #|     return defaultValue;
  #|   }
  #|   const result = value[key];
  #|   return typeof result === "boolean" ? result : defaultValue;
  #| }

///|
extern "js" fn json_value_object_get_string_ffi(
  value : Any,
  key : String,
) -> String? =
  #| (value, key) => {
  #|   if (value === undefined || value === null || typeof value !== "object") {
  #|     return undefined;
  #|   }
  #|   const result = value[key];
  #|   return typeof result === "string" ? result : undefined;
  #| }

///|
extern "js" fn json_value_object_with_bool_ffi(
  value : Any,
  key : String,
  entry_value : Bool,
) -> Any =
  #| (value, key, entryValue) => {
  #|   const base = value && typeof value === "object" ? value : {};
  #|   return { ...base, [key]: entryValue };
  #| }

///|
extern "js" fn json_value_object_with_string_ffi(
  value : Any,
  key : String,
  entry_value : String,
) -> Any =
  #| (value, key, entryValue) => {
  #|   const base = value && typeof value === "object" ? value : {};
  #|   return { ...base, [key]: entryValue };
  #| }
