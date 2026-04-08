///|
/// File decoration helpers.

///|
/// Creates a new decoration.
///
/// @param badge A letter that represents the decoration.
/// @param tooltip The tooltip of the decoration.
/// @param color The color of the decoration.
pub fn FileDecoration::new(
  badge? : String,
  tooltip? : String,
  color? : ThemeColor,
) -> FileDecoration {
  file_decoration_ffi(
    option_to_js(badge),
    option_to_js(tooltip),
    option_to_js(color),
  )
}

///|
/// A very short string that represents this decoration.
pub fn FileDecoration::badge(self : FileDecoration) -> String? {
  let raw = FileDecoration::file_decoration_badge_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// A very short string that represents this decoration.
pub fn FileDecoration::set_badge(self : FileDecoration, value : String) -> Unit {
  FileDecoration::file_decoration_set_badge_raw(self, JsValue::make(value))
}

///|
/// A very short string that represents this decoration.
pub fn FileDecoration::clear_badge(self : FileDecoration) -> Unit {
  FileDecoration::file_decoration_set_badge_raw(self, JsValue::make(()))
}

///|
/// A human-readable tooltip for this decoration.
pub fn FileDecoration::tooltip(self : FileDecoration) -> String? {
  let raw = FileDecoration::file_decoration_tooltip_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// A human-readable tooltip for this decoration.
pub fn FileDecoration::set_tooltip(
  self : FileDecoration,
  value : String,
) -> Unit {
  FileDecoration::file_decoration_set_tooltip_raw(self, JsValue::make(value))
}

///|
/// A human-readable tooltip for this decoration.
pub fn FileDecoration::clear_tooltip(self : FileDecoration) -> Unit {
  FileDecoration::file_decoration_set_tooltip_raw(self, JsValue::make(()))
}

///|
/// The color of this decoration.
pub fn FileDecoration::color(self : FileDecoration) -> ThemeColor? {
  let raw = FileDecoration::file_decoration_color_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The color of this decoration.
pub fn FileDecoration::set_color(
  self : FileDecoration,
  value : ThemeColor,
) -> Unit {
  FileDecoration::file_decoration_set_color_raw(self, JsValue::make(value))
}

///|
/// The color of this decoration.
pub fn FileDecoration::clear_color(self : FileDecoration) -> Unit {
  FileDecoration::file_decoration_set_color_raw(self, JsValue::make(()))
}

///|
/// A flag expressing that this decoration should be
/// propagated to its parents.
pub fn FileDecoration::propagate(self : FileDecoration) -> Bool? {
  let raw = FileDecoration::file_decoration_propagate_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// A flag expressing that this decoration should be
/// propagated to its parents.
pub fn FileDecoration::set_propagate(
  self : FileDecoration,
  value : Bool,
) -> Unit {
  FileDecoration::file_decoration_set_propagate_raw(self, JsValue::make(value))
}

///|
/// A flag expressing that this decoration should be
/// propagated to its parents.
pub fn FileDecoration::clear_propagate(self : FileDecoration) -> Unit {
  FileDecoration::file_decoration_set_propagate_raw(self, JsValue::make(()))
}

///|
extern "js" fn file_decoration_ffi(
  badge : JsValue,
  tooltip : JsValue,
  color : JsValue,
) -> FileDecoration =
  #| (badge, tooltip, color) =>
  #|   new (require("vscode").FileDecoration)(badge, tooltip, color)

///|
extern "js" fn FileDecoration::file_decoration_badge_raw(
  self : FileDecoration,
) -> JsValue =
  #| (value) => value.badge

///|
extern "js" fn FileDecoration::file_decoration_set_badge_raw(
  self : FileDecoration,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.badge = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn FileDecoration::file_decoration_tooltip_raw(
  self : FileDecoration,
) -> JsValue =
  #| (value) => value.tooltip

///|
extern "js" fn FileDecoration::file_decoration_set_tooltip_raw(
  self : FileDecoration,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.tooltip = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn FileDecoration::file_decoration_color_raw(
  self : FileDecoration,
) -> JsValue =
  #| (value) => value.color

///|
extern "js" fn FileDecoration::file_decoration_set_color_raw(
  self : FileDecoration,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.color = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn FileDecoration::file_decoration_propagate_raw(
  self : FileDecoration,
) -> JsValue =
  #| (value) => value.propagate

///|
extern "js" fn FileDecoration::file_decoration_set_propagate_raw(
  self : FileDecoration,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.propagate = value === undefined || value === null ? undefined : value; }
