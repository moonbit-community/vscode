///|
/// VS Code l10n namespace bindings for the JS backend.
using @vscode {type Any, type Uri}

///|
/// The bundle of localized strings that have been loaded for the extension.
/// It's undefined if no bundle has been loaded. The bundle is typically not loaded if
/// there was no bundle found or when we are running with the default language.
pub fn bundle() -> Any? {
  let raw = l10n_bundle_ffi()
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The URI of the localization bundle that has been loaded for the extension.
/// It's undefined if no bundle has been loaded. The bundle is typically not loaded if
/// there was no bundle found or when we are running with the default language.
pub fn uri() -> Uri? {
  let raw = l10n_uri_ffi()
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Marks a string for localization. If a localized bundle is available for the language specified by
/// {@link env.language} and the bundle has a localized value for this message, then that localized
/// value will be returned (with injected {@link args} values for any templated values).
///
/// @param message - The message to localize. Supports index templating where strings like `{0}` and `{1}` are
/// replaced by the item at that index in the {@link args} array.
/// @param args - The arguments to be used in the localized string. The index of the argument is used to
/// match the template placeholder in the localized string.
/// @returns localized string with injected arguments.
///
/// @example
/// l10n.t('Hello {0}!', 'World');
pub fn t(message : String) -> String {
  l10n_t_ffi(message)
}

///|
/// Marks a string for localization. If a localized bundle is available for the language specified by
/// {@link env.language} and the bundle has a localized value for this message, then that localized
/// value will be returned (with injected {@link args} values for any templated values).
///
/// @param message - The message to localize. Supports index templating where strings like `{0}` and `{1}` are
/// replaced by the item at that index in the {@link args} array.
/// @param args - The arguments to be used in the localized string. The index of the argument is used to
/// match the template placeholder in the localized string.
/// @returns localized string with injected arguments.
///
/// @example
/// l10n.t('Hello {0}!', 'World');
pub fn t_args(message : String, args : Array[Any]) -> String {
  l10n_t_args_ffi(message, args)
}

///|
/// Marks a string for localization. If a localized bundle is available for the language specified by
/// {@link env.language} and the bundle has a localized value for this message, then that localized
/// value will be returned (with injected {@link args} values for any templated values).
///
/// @param message - The message to localize. Supports index templating where strings like `{0}` and `{1}` are
/// replaced by the item at that index in the {@link args} array.
/// @param args - The arguments to be used in the localized string. The index of the argument is used to
/// match the template placeholder in the localized string.
/// @returns localized string with injected arguments.
///
/// @example
/// l10n.t('Hello {0}!', 'World');
pub fn t_named(message : String, args : Array[(String, Any)]) -> String {
  l10n_t_named_ffi(message, args)
}
