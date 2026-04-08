///|
/// Shared JS utility helpers for internal vscode binding packages.

///|
pub type JsValue

///|
pub fn[X] JsValue::make(v : X) -> JsValue = "%identity"

///|
pub fn[X] JsValue::cast(v : JsValue) -> X = "%identity"

///|
pub extern "js" fn JsValue::is_null_or_undefined(self : JsValue) -> Bool =
  #| (value) => value === null || value === undefined

///|
pub fn[T] option_to_js(value : T?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => JsValue::make(value)
  }
}

///|
pub fn[T] js_to_option(value : JsValue) -> T? {
  if value.is_null_or_undefined() {
    None
  } else {
    Some(value.cast())
  }
}
