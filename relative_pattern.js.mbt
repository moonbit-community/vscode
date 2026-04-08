///|
/// Relative pattern constructors.

///|
pub fn RelativePattern::from_workspace_folder(
  base : WorkspaceFolder,
  pattern : String,
) -> RelativePattern {
  relative_pattern_from_workspace_folder_ffi(base, pattern)
}

///|
pub fn RelativePattern::from_uri(
  base : Uri,
  pattern : String,
) -> RelativePattern {
  relative_pattern_from_uri_ffi(base, pattern)
}

///|
pub fn RelativePattern::from_path(
  base : String,
  pattern : String,
) -> RelativePattern {
  relative_pattern_from_path_ffi(base, pattern)
}

///|
pub extern "js" fn RelativePattern::base_uri(self : RelativePattern) -> Uri =
  #| (value) => value.baseUri

///|
pub extern "js" fn RelativePattern::set_base_uri(
  self : RelativePattern,
  value : Uri,
) -> Unit =
  #| (item, value) => { item.baseUri = value; }

///|
pub extern "js" fn RelativePattern::base(self : RelativePattern) -> String =
  #| (value) => value.base

///|
pub extern "js" fn RelativePattern::set_base(
  self : RelativePattern,
  value : String,
) -> Unit =
  #| (item, value) => { item.base = value; }

///|
pub extern "js" fn RelativePattern::pattern(self : RelativePattern) -> String =
  #| (value) => value.pattern

///|
pub extern "js" fn RelativePattern::set_pattern(
  self : RelativePattern,
  value : String,
) -> Unit =
  #| (item, value) => { item.pattern = value; }

///|
extern "js" fn relative_pattern_from_workspace_folder_ffi(
  base : WorkspaceFolder,
  pattern : String,
) -> RelativePattern =
  #| (base, pattern) => new (require("vscode").RelativePattern)(base, pattern)

///|
extern "js" fn relative_pattern_from_uri_ffi(
  base : Uri,
  pattern : String,
) -> RelativePattern =
  #| (base, pattern) => new (require("vscode").RelativePattern)(base, pattern)

///|
extern "js" fn relative_pattern_from_path_ffi(
  base : String,
  pattern : String,
) -> RelativePattern =
  #| (base, pattern) => new (require("vscode").RelativePattern)(base, pattern)
