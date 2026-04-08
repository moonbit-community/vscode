///|
/// VS Code scm namespace bindings for the JS backend.
using @vscode {type SourceControl, type SourceControlInputBox, type Uri}

///|
fn[T] option_to_js(value : T?) -> @v.JsValue {
  @v.option_to_js(value)
}

///|
/// The {@link SourceControlInputBox input box} for the last source control
/// created by the extension.
///
/// @deprecated Use SourceControl.inputBox instead
pub fn input_box() -> SourceControlInputBox? {
  let value = scm_input_box_ffi()
  if value.is_null_or_undefined() {
    None
  } else {
    Some(value.cast())
  }
}

///|
/// Creates a new {@link SourceControl source control} instance.
///
/// @param id An `id` for the source control. Something short, e.g.: `git`.
/// @param label A human-readable string for the source control. E.g.: `Git`.
/// @param rootUri An optional Uri of the root of the source control. E.g.: `Uri.parse(workspaceRoot)`.
/// @returns An instance of {@link SourceControl source control}.
pub fn create_source_control(
  id : String,
  label : String,
  root_uri? : Uri,
) -> SourceControl {
  scm_create_source_control_ffi(id, label, option_to_js(root_uri))
}
