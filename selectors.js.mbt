///|
/// Document selector and glob helpers.

///|
/// A document filter denotes a document by different properties like
/// the {@link TextDocument.languageId language}, the {@link Uri.scheme scheme} of
/// its resource, or a glob-pattern that is applied to the {@link TextDocument.fileName path}.
///
/// @example <caption>A language filter that applies to typescript files on disk</caption>
/// { language: 'typescript', scheme: 'file' }
///
/// @example <caption>A language filter that applies to all package.json paths</caption>
/// { language: 'json', pattern: '**​/package.json' }
pub struct DocumentFilter {
  language : String?
  notebook_type : String?
  scheme : String?
  pattern : GlobPattern?
}

///|
pub(all) enum DocumentSelectorEntry {
  Filter(DocumentFilter)
  Language(String)
}

///|
pub fn DocumentFilter::new(
  language? : String,
  notebook_type? : String,
  scheme? : String,
  pattern? : GlobPattern,
) -> DocumentFilter {
  DocumentFilter::{ language, notebook_type, scheme, pattern }
}

///|
fn[T] js_to_option(value : JsValue) -> T? {
  if value.is_null_or_undefined() {
    None
  } else {
    Some(value.cast())
  }
}

///|
pub fn DocumentSelector::from_filters(
  value : Array[DocumentFilter],
) -> DocumentSelector {
  let entries : Array[DocumentSelectorEntry] = []
  for item in value {
    entries.push(Filter(item))
  }
  Entries(entries)
}

///|
pub fn DocumentSelector::from_languages(
  value : Array[String],
) -> DocumentSelector {
  let entries : Array[DocumentSelectorEntry] = []
  for item in value {
    entries.push(Language(item))
  }
  Entries(entries)
}

///|
pub fn LanguageSelector::as_document_selector(
  value : LanguageSelector,
) -> DocumentSelector {
  match value {
    LanguageSelector::DocumentSelector(value) => value
  }
}

///|
fn GlobPattern::from_js(value : JsValue) -> GlobPattern {
  if js_value_is_string_ffi(value) {
    Text(value.cast())
  } else {
    Relative(value.cast())
  }
}

///|
fn option_glob_pattern_from_js(value : JsValue) -> GlobPattern? {
  if value.is_null_or_undefined() {
    None
  } else {
    Some(GlobPattern::from_js(value))
  }
}

///|
fn DocumentFilter::from_js(value : JsValue) -> DocumentFilter {
  DocumentFilter::{
    language: js_to_option(document_filter_language_raw(value)),
    notebook_type: js_to_option(document_filter_notebook_type_raw(value)),
    scheme: js_to_option(document_filter_scheme_raw(value)),
    pattern: option_glob_pattern_from_js(document_filter_pattern_raw(value)),
  }
}

///|
fn DocumentSelectorEntry::from_js(value : JsValue) -> DocumentSelectorEntry {
  if js_value_is_string_ffi(value) {
    Language(value.cast())
  } else {
    Filter(DocumentFilter::from_js(value))
  }
}

///|
fn DocumentSelector::from_js(value : JsValue) -> DocumentSelector {
  if js_value_is_string_ffi(value) {
    Language(value.cast())
  } else if document_selector_is_array_ffi(value) {
    let raw_entries : Array[JsValue] = value.cast()
    let entries : Array[DocumentSelectorEntry] = []
    for item in raw_entries {
      entries.push(DocumentSelectorEntry::from_js(item))
    }
    Entries(entries)
  } else {
    Filter(DocumentFilter::from_js(value))
  }
}

///|
extern "js" fn document_filter_language_raw(value : JsValue) -> JsValue =
  #| (value) => value?.language

///|
extern "js" fn document_filter_notebook_type_raw(value : JsValue) -> JsValue =
  #| (value) => value?.notebookType

///|
extern "js" fn document_filter_scheme_raw(value : JsValue) -> JsValue =
  #| (value) => value?.scheme

///|
extern "js" fn document_filter_pattern_raw(value : JsValue) -> JsValue =
  #| (value) => value?.pattern

///|
extern "js" fn js_value_is_string_ffi(value : JsValue) -> Bool =
  #| (value) => typeof value === "string"

///|
extern "js" fn document_selector_is_array_ffi(value : JsValue) -> Bool =
  #| (value) => Array.isArray(value)
