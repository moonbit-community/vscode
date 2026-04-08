///|
/// JS FFI bindings for VS Code scm namespace.

///|
extern "js" fn scm_input_box_ffi() -> @v.JsValue =
  #| () => require("vscode").scm.inputBox

///|
extern "js" fn scm_create_source_control_ffi(
  id : String,
  label : String,
  root_uri : @v.JsValue,
) -> SourceControl =
  #| (id, label, rootUri) => {
  #|   const scm = require("vscode").scm;
  #|   return rootUri === undefined || rootUri === null
  #|     ? scm.createSourceControl(id, label)
  #|     : scm.createSourceControl(id, label, rootUri);
  #| }
