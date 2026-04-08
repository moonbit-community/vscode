///|
/// VS Code Uri helpers for the JS backend.

///|
/// Create an URI from a file system path. The {@link Uri.scheme scheme}
/// will be `file`.
///
/// The *difference* between {@link Uri.parse} and {@link Uri.file} is that the latter treats the argument
/// as path, not as stringified-uri. E.g. `Uri.file(path)` is *not* the same as
/// `Uri.parse('file://' + path)` because the path might contain characters that are
/// interpreted (# and ?). See the following sample:
/// ```ts
/// const good = URI.file('/coding/c#/project1');
/// good.scheme === 'file';
/// good.path === '/coding/c#/project1';
/// good.fragment === '';
///
/// const bad = URI.parse('file://' + '/coding/c#/project1');
/// bad.scheme === 'file';
/// bad.path === '/coding/c'; // path is now broken
/// bad.fragment === '/project1';
/// ```
///
/// @param path A file system or UNC path.
/// @returns A new Uri instance.
pub fn Uri::file(path : String) -> Uri {
  uri_file_ffi(path)
}

///|
/// Create an URI from a string, e.g. `http://www.example.com/some/path`,
/// `file:///usr/home`, or `scheme:with/path`.
///
/// *Note* that for a while uris without a `scheme` were accepted. That is not correct
/// as all uris should have a scheme. To avoid breakage of existing code the optional
/// `strict`-argument has been added. We *strongly* advise to use it, e.g. `Uri.parse('my:uri', true)`
///
/// @see {@link Uri.toString}
/// @param value The string value of an Uri.
/// @param strict Throw an error when `value` is empty or when no `scheme` can be parsed.
/// @returns A new Uri instance.
pub fn Uri::parse(value : String, strict? : Bool = false) -> Uri {
  uri_parse_ffi(value, strict)
}

///|
/// Create a new uri which path is the result of joining
/// the path of the base uri with the provided path segments.
///
/// - Note 1: `joinPath` only affects the path component
/// and all other components (scheme, authority, query, and fragment) are
/// left as they are.
/// - Note 2: The base uri must have a path; an error is thrown otherwise.
///
/// The path segments are normalized in the following ways:
/// - sequences of path separators (`/` or `\`) are replaced with a single separator
/// - for `file`-uris on windows, the backslash-character (`\`) is considered a path-separator
/// - the `..`-segment denotes the parent segment, the `.` denotes the current segment
/// - paths have a root which always remains, for instance on windows drive-letters are roots
/// so that is true: `joinPath(Uri.file('file:///c:/root'), '../../other').fsPath === 'c:/other'`
///
/// @param base An uri. Must have a path.
/// @param pathSegments One more more path fragments
/// @returns A new uri which path is joined with the given fragments
pub fn Uri::join_path(base : Uri, segments : Array[String]) -> Uri {
  uri_join_path_ffi(base, segments)
}

///|
/// Returns a string representation of this Uri. The representation and normalization
/// of a URI depends on the scheme.
///
/// * The resulting string can be safely used with {@link Uri.parse}.
/// * The resulting string shall *not* be used for display purposes.
///
/// *Note* that the implementation will encode _aggressive_ which often leads to unexpected,
/// but not incorrect, results. For instance, colons are encoded to `%3A` which might be unexpected
/// in file-uri. Also `&` and `=` will be encoded which might be unexpected for http-uris. For stability
/// reasons this cannot be changed anymore. If you suffer from too aggressive encoding you should use
/// the `skipEncoding`-argument: `uri.toString(true)`.
///
/// @param skipEncoding Do not percentage-encode the result, defaults to `false`. Note that
/// 	the `#` and `?` characters occurring in the path will always be encoded.
/// @returns A string representation of this Uri.
pub extern "js" fn Uri::to_string(self : Uri) -> String =
  #| (uri) => uri.toString()

///|
/// The string representing the corresponding file system path of this Uri.
///
/// Will handle UNC paths and normalize windows drive letters to lower-case. Also
/// uses the platform specific path separator.
///
/// * Will *not* validate the path for invalid characters and semantics.
/// * Will *not* look at the scheme of this Uri.
/// * The resulting string shall *not* be used for display purposes but
/// for disk operations, like `readFile` et al.
///
/// The *difference* to the {@linkcode Uri.path path}-property is the use of the platform specific
/// path separator and the handling of UNC paths. The sample below outlines the difference:
/// ```ts
/// const u = URI.parse('file://server/c$/folder/file.txt')
/// u.authority === 'server'
/// u.path === '/c$/folder/file.txt'
/// u.fsPath === '\\server\c$\folder\file.txt'
/// ```
pub extern "js" fn Uri::fs_path(self : Uri) -> String =
  #| (uri) => uri.fsPath

///|
/// Scheme is the `http` part of `http://www.example.com/some/path?query#fragment`.
/// The part before the first colon.
pub extern "js" fn Uri::scheme(self : Uri) -> String =
  #| (uri) => uri.scheme

///|
/// Authority is the `www.example.com` part of `http://www.example.com/some/path?query#fragment`.
/// The part between the first double slashes and the next slash.
pub extern "js" fn Uri::authority(self : Uri) -> String =
  #| (uri) => uri.authority

///|
/// Path is the `/some/path` part of `http://www.example.com/some/path?query#fragment`.
pub extern "js" fn Uri::path(self : Uri) -> String =
  #| (uri) => uri.path

///|
/// Query is the `query` part of `http://www.example.com/some/path?query#fragment`.
pub extern "js" fn Uri::query(self : Uri) -> String =
  #| (uri) => uri.query

///|
/// Fragment is the `fragment` part of `http://www.example.com/some/path?query#fragment`.
pub extern "js" fn Uri::fragment(self : Uri) -> String =
  #| (uri) => uri.fragment

///|
extern "js" fn Uri::with_change_raw(self : Uri, change : JsValue) -> Uri =
  #| (uri, change) => uri.with(change)

///|
/// Derive a new Uri from this Uri.
///
/// ```ts
/// let file = Uri.parse('before:some/file/path');
/// let other = file.with({ scheme: 'after' });
/// assert.ok(other.toString() === 'after:some/file/path');
/// ```
///
/// @param change An object that describes a change to this Uri. To unset components use `null` or
///  the empty string.
/// @returns A new Uri that reflects the given change. Will return `this` Uri if the change
///  is not changing anything.
pub fn Uri::with_parts(
  self : Uri,
  scheme? : String,
  authority? : String,
  path? : String,
  query? : String,
  fragment? : String,
) -> Uri {
  let change = uri_change_ffi(
    option_to_js(scheme),
    option_to_js(authority),
    option_to_js(path),
    option_to_js(query),
    option_to_js(fragment),
  )
  Uri::with_change_raw(self, change)
}

///|
pub fn Uri::to_json(self : Uri) -> Any {
  JsValue::make(Uri::uri_to_json_raw(self)).cast()
}

///|
extern "js" fn Uri::uri_to_json_raw(self : Uri) -> JsValue =
  #| (uri) => uri.toJSON()

///|
/// Derive a new Uri from this Uri.
///
/// ```ts
/// let file = Uri.parse('before:some/file/path');
/// let other = file.with({ scheme: 'after' });
/// assert.ok(other.toString() === 'after:some/file/path');
/// ```
///
/// @param change An object that describes a change to this Uri. To unset components use `null` or
///  the empty string.
/// @returns A new Uri that reflects the given change. Will return `this` Uri if the change
///  is not changing anything.
pub extern "js" fn Uri::with_query(uri : Uri, query : String) -> Uri =
  #| (uri, query) => uri.with({ query })

///|
/// Externs.
extern "js" fn uri_file_ffi(path : String) -> Uri =
  #| (path) => require("vscode").Uri.file(path)

///|
extern "js" fn uri_parse_ffi(value : String, strict : Bool) -> Uri =
  #| (value, strict) => require("vscode").Uri.parse(value, strict)

///|
extern "js" fn uri_join_path_ffi(base : Uri, segments : Array[String]) -> Uri =
  #| (base, segments) => require("vscode").Uri.joinPath(base, ...segments)

///|

///|
extern "js" fn uri_change_ffi(
  scheme : JsValue,
  authority : JsValue,
  path : JsValue,
  query : JsValue,
  fragment : JsValue,
) -> JsValue =
  #| (scheme, authority, path, query, fragment) => {
  #|   const change = {};
  #|   if (scheme !== undefined && scheme !== null) change.scheme = scheme;
  #|   if (authority !== undefined && authority !== null) change.authority = authority;
  #|   if (path !== undefined && path !== null) change.path = path;
  #|   if (query !== undefined && query !== null) change.query = query;
  #|   if (fragment !== undefined && fragment !== null) change.fragment = fragment;
  #|   return change;
  #| }
