///|
/// Shared VS Code type bindings for JS backend.

///|
/// Events
pub type Event[T]

///|
/// An event emitter can be used to create and manage an {@link Event} for others
/// to subscribe to. One emitter always owns one event.
///
/// Use this class if you want to provide event from within your extension, for instance
/// inside a {@link TextDocumentContentProvider} or when providing
/// API to other extensions.
pub type EventEmitter[T]

///|
/// A function that represents an event to which you subscribe by calling it with
/// a listener function as argument.
///
/// @param listener The listener function will be called when the event happens.
/// @param thisArgs The `this`-argument which will be used when calling the event listener.
/// @param disposables An array to which a {@link Disposable} will be added.
/// @returns A disposable which unsubscribes the event listener.
pub fn[T] Event::subscribe(
  self : Event[T],
  listener : (T) -> Unit,
) -> Disposable {
  event_subscribe_ffi(
    JsValue::make(self),
    value => listener(value.cast()),
    JsValue::make(()),
  )
}

///|
pub fn[T] Event::subscribe_async(
  self : Event[T],
  listener : async (T) -> Unit,
) -> Disposable {
  self.subscribe(value => {
    ignore(@js_async.Promise::from_async(() => listener(value)))
  })
}

///|
/// EventEmitter helpers
pub fn[T] EventEmitter::new() -> EventEmitter[T] {
  event_emitter_new_ffi().cast()
}

///|

///|
/// The event listeners can subscribe to.
pub fn[T] EventEmitter::event(self : EventEmitter[T]) -> Event[T] {
  event_emitter_event_ffi(JsValue::make(self)).cast()
}

///|
/// Notify all subscribers of the {@link EventEmitter.event event}. Failure
/// of one or more listener will not fail this function call.
///
/// @param data The event object.
pub fn[T] EventEmitter::fire(self : EventEmitter[T], value : T) -> Unit {
  event_emitter_fire_ffi(JsValue::make(self), JsValue::make(value))
}

///|
/// Dispose this object and free resources.
pub fn[T] EventEmitter::dispose(self : EventEmitter[T]) -> Unit {
  event_emitter_dispose_ffi(JsValue::make(self))
}

///|
pub impl[T] AsDisposable for EventEmitter[T] with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// Cancellation token helpers
pub extern "js" fn CancellationTokenSource::new() -> CancellationTokenSource =
  #| () => new (require("vscode").CancellationTokenSource)()

///|
/// The cancellation token of this source.
pub extern "js" fn CancellationTokenSource::token(
  self : CancellationTokenSource,
) -> CancellationToken =
  #| (source) => source.token

///|
/// Signal cancellation on the token.
pub extern "js" fn CancellationTokenSource::cancel(
  self : CancellationTokenSource,
) -> Unit =
  #| (source) => source.cancel()

///|
/// Dispose object and free resources.
extern "js" fn cancellation_token_source_dispose_raw(
  source : CancellationTokenSource,
) -> Unit =
  #| (source) => source.dispose()

///|
pub fn CancellationTokenSource::dispose(self : CancellationTokenSource) -> Unit {
  cancellation_token_source_dispose_raw(self)
}

///|
pub impl AsDisposable for CancellationTokenSource with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// Is `true` when the token has been cancelled, `false` otherwise.

///|
/// An {@link Event} which fires upon cancellation.

///|
/// Creates a new cancellation error.
pub extern "js" fn CancellationError::new() -> CancellationError =
  #| () => new (require("vscode").CancellationError)()

///|
/// Core types
pub type Uri

///|
/// A cancellation token is passed to an asynchronous or long running
/// operation to request cancellation, like cancelling a request
/// for completion items because the user continued to type.
///
/// To get an instance of a `CancellationToken` use a
/// {@link CancellationTokenSource}.
pub(all) struct CancellationToken {
  mut is_cancellation_requested : Bool
  on_cancellation_requested : Event[Unit]
}

///|
/// A cancellation source creates and controls a {@link CancellationToken cancellation token}.
pub type CancellationTokenSource

///|
/// An error type that should be used to signal cancellation of an operation.
///
/// This type can be used in response to a {@link CancellationToken cancellation token}
/// being cancelled or when an operation is being cancelled by the
/// executor of that operation.
pub type CancellationError

///|
/// Represents an extension.
///
/// To get an instance of an `Extension` use {@link extensions.getExtension getExtension}.
pub type Extension[T]

///|
/// The clipboard provides read and write access to the system's clipboard.
pub type Clipboard

///|
/// Represents a reference to a command. Provides a title which
/// will be used to represent a command in the UI and, optionally,
/// an array of arguments which will be passed to the command handler
/// function when invoked.
pub(all) struct Command {
  mut title : String
  mut command : String
  mut tooltip : String?
  mut arguments : Array[Any]?
}

///|
/// Possible kinds of UI that can use extensions.
pub(all) enum UIKind {
  Desktop = 1
  Web = 2
} derive(Eq)

///|
/// A special value wrapper denoting a value that is safe to not clean.
/// This is to be used when you can guarantee no identifiable information is contained in the value and the cleaning is improperly redacting it.
pub type TelemetryTrustedValue

///|
/// A telemetry logger which can be used by extensions to log usage and error telemetry.
///
/// A logger wraps around an {@link TelemetrySender sender} but it guarantees that
/// - user settings to disable or tweak telemetry are respected, and that
/// - potential sensitive data is removed
///
/// It also enables an "echo UI" that prints whatever data is send and it allows the editor
/// to forward unhandled errors to the respective extensions.
///
/// To get an instance of a `TelemetryLogger`, use
/// {@link env.createTelemetryLogger `createTelemetryLogger`}.
pub type TelemetryLogger

///|
/// The telemetry sender is the contract between a telemetry logger and some telemetry service. **Note** that extensions must NOT
/// call the methods of their sender directly as the logger provides extra guards and cleaning.
///
/// ```js
/// const sender: vscode.TelemetrySender = {...};
/// const logger = vscode.env.createTelemetryLogger(sender);
///
/// // GOOD - uses the logger
/// logger.logUsage('myEvent', { myData: 'myValue' });
///
/// // BAD - uses the sender directly: no data cleansing, ignores user settings, no echoing to the telemetry output channel etc
/// sender.logEvent('myEvent', { myData: 'myValue' });
/// ```
pub type TelemetrySender

///|
/// Options for creating a {@link TelemetryLogger}
pub struct TelemetryLoggerOptions {
  ignore_built_in_common_properties : Bool?
  ignore_unhandled_errors : Bool?
  additional_common_properties : Array[(String, Any)]?
}

///|
/// Represents a line and character position, such as
/// the position of the cursor.
///
/// Position objects are __immutable__. Use the {@link Position.with with} or
/// {@link Position.translate translate} methods to derive new positions
/// from an existing position.
pub type Position

///|
/// A range represents an ordered pair of two positions.
/// It is guaranteed that {@link Range.start start}.isBeforeOrEqual({@link Range.end end})
///
/// Range objects are __immutable__. Use the {@link Range.with with},
/// {@link Range.intersection intersection}, or {@link Range.union union} methods
/// to derive new ranges from an existing range.
pub type Range

///|
/// Represents a diagnostic, such as a compiler error or warning. Diagnostic objects
/// are only valid in the scope of a file.
pub type Diagnostic

///|
/// A diagnostics collection is a container that manages a set of
/// {@link Diagnostic diagnostics}. Diagnostics are always scopes to a
/// diagnostics collection and a resource.
///
/// To get an instance of a `DiagnosticCollection` use
/// {@link languages.createDiagnosticCollection createDiagnosticCollection}.
pub type DiagnosticCollection

///|
pub(all) enum DiagnosticSeverity {
  Error = 0
  Warning = 1
  Information = 2
  Hint = 3
} derive(Eq)

///|
pub(all) enum DiagnosticTag {
  Unnecessary = 1
  Deprecated = 2
} derive(Eq)

///|
pub(all) enum DiagnosticCodeValue {
  Text(String)
  Numeric(Int)
}

///|
pub fn DiagnosticCodeValue::as_text(self : DiagnosticCodeValue) -> String? {
  match self {
    Text(value) => Some(value)
    Numeric(_) => None
  }
}

///|
pub fn DiagnosticCodeValue::as_int(self : DiagnosticCodeValue) -> Int? {
  match self {
    Text(_) => None
    Numeric(value) => Some(value)
  }
}

///|
pub(all) enum DiagnosticCode {
  Text(String)
  Numeric(Int)
  ValueAndTarget(DiagnosticCodeValue, Uri)
}

///|
pub fn DiagnosticCode::as_text(self : DiagnosticCode) -> String? {
  match self {
    Text(value) => Some(value)
    Numeric(_) => None
    ValueAndTarget(value, _) => value.as_text()
  }
}

///|
pub fn DiagnosticCode::as_int(self : DiagnosticCode) -> Int? {
  match self {
    Text(_) => None
    Numeric(value) => Some(value)
    ValueAndTarget(value, _) => value.as_int()
  }
}

///|
pub fn DiagnosticCode::target(self : DiagnosticCode) -> Uri? {
  match self {
    ValueAndTarget(_, target) => Some(target)
    _ => None
  }
}

///|
fn diagnostic_code_value_to_js(value : DiagnosticCodeValue) -> JsValue {
  match value {
    Text(value) => JsValue::make(value)
    Numeric(value) => JsValue::make(value)
  }
}

///|
fn diagnostic_code_to_js(value : DiagnosticCode) -> JsValue {
  match value {
    Text(value) => JsValue::make(value)
    Numeric(value) => JsValue::make(value)
    ValueAndTarget(value, target) =>
      diagnostic_code_to_js_ffi(
        diagnostic_code_value_to_js(value),
        JsValue::make(target),
      )
  }
}

///|
fn diagnostic_code_from_js(value : JsValue) -> DiagnosticCode? {
  match js_value_as_string_ffi(value) {
    Some(text) => Some(Text(text))
    None =>
      match js_value_as_int_ffi(value) {
        Some(value) => Some(Numeric(value))
        None =>
          if value.is_null_or_undefined() {
            None
          } else {
            let raw_value = diagnostic_code_value_raw(value)
            let raw_target = diagnostic_code_target_raw(value)
            if raw_value.is_null_or_undefined() ||
              raw_target.is_null_or_undefined() {
              None
            } else {
              let value_part : DiagnosticCodeValue = match
                js_value_as_string_ffi(raw_value) {
                Some(text) => Text(text)
                None =>
                  match js_value_as_int_ffi(raw_value) {
                    Some(value) => Numeric(value)
                    None => return None
                  }
              }
              Some(ValueAndTarget(value_part, raw_target.cast()))
            }
          }
      }
  }
}

///|
/// Represents a related message and source code location for a diagnostic. This should be
/// used to point to code locations that cause or related to a diagnostics, e.g. when duplicating
/// a symbol in a scope.
pub type DiagnosticRelatedInformation

///|
/// The event that is fired when diagnostics change.
pub struct DiagnosticChangeEvent {
  uris : Array[Uri]
}

///|
/// A language selector is the combination of one or many language identifiers
/// and {@link DocumentFilter language filters}.
///
/// *Note* that a document selector that is just a language identifier selects *all*
/// documents, even those that are not saved on disk. Only use such selectors when
/// a feature works without further context, e.g. without the need to resolve related
/// 'files'.
///
/// @example
/// let sel:DocumentSelector = { scheme: 'file', language: 'typescript' };
pub(all) enum DocumentSelector {
  Filter(DocumentFilter)
  Language(String)
  Entries(Array[DocumentSelectorEntry])
}

///|
pub(all) enum LanguageSelector {
  DocumentSelector(DocumentSelector)
}

///|
/// A language status item is the preferred way to present language status reports for the active text editors,
/// such as selected linter or notifying about a configuration problem.
pub type LanguageStatusItem

///|
pub(all) enum LanguageStatusSeverity {
  Information = 0
  Warning = 1
  Error = 2
} derive(Eq)

///|
/// Accessibility information which controls screen reader behavior.
pub struct AccessibilityInformation {
  label : String
  role : String?
}

///|
/// @param line A zero-based line value.
/// @param character A zero-based character value.
pub extern "js" fn Position::new(line : Int, character : Int) -> Position =
  #| (line, character) => new (require("vscode").Position)(line, character)

///|
/// The zero-based line value.
pub extern "js" fn Position::line(self : Position) -> Int =
  #| (position) => position.line

///|
/// The zero-based character value.
pub extern "js" fn Position::character(self : Position) -> Int =
  #| (position) => position.character

///|
/// Creates a new diagnostic object.
///
/// @param range The range to which this diagnostic applies.
/// @param message The human-readable message.
/// @param severity The severity, default is {@link DiagnosticSeverity.Error error}.
pub fn Diagnostic::new(
  range : Range,
  message : String,
  severity? : DiagnosticSeverity,
) -> Diagnostic {
  diagnostic_new_ffi(range, message, option_to_js(severity))
}

///|
pub extern "js" fn Diagnostic::range(self : Diagnostic) -> Range =
  #| (diag) => diag.range

///|
pub extern "js" fn Diagnostic::set_range(
  self : Diagnostic,
  value : Range,
) -> Unit =
  #| (diag, value) => { diag.range = value; }

///|
pub extern "js" fn Diagnostic::message(self : Diagnostic) -> String =
  #| (diag) => diag.message

///|
pub extern "js" fn Diagnostic::set_message(
  self : Diagnostic,
  value : String,
) -> Unit =
  #| (diag, value) => { diag.message = value; }

///|
pub extern "js" fn Diagnostic::severity(
  self : Diagnostic,
) -> DiagnosticSeverity =
  #| (diag) => diag.severity

///|
pub extern "js" fn Diagnostic::set_severity(
  self : Diagnostic,
  value : DiagnosticSeverity,
) -> Unit =
  #| (diag, value) => { diag.severity = value; }

///|
pub fn Diagnostic::code(self : Diagnostic) -> DiagnosticCode? {
  diagnostic_code_from_js(Diagnostic::diagnostic_code_raw(self))
}

///|
pub fn Diagnostic::set_code(self : Diagnostic, value : DiagnosticCode) -> Unit {
  Diagnostic::diagnostic_set_code_raw(self, diagnostic_code_to_js(value))
}

///|
pub fn Diagnostic::clear_code(self : Diagnostic) -> Unit {
  Diagnostic::diagnostic_set_code_raw(self, JsValue::make(()))
}

///|
pub fn Diagnostic::source(self : Diagnostic) -> String? {
  let raw = Diagnostic::diagnostic_source_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn Diagnostic::set_source(self : Diagnostic, value : String) -> Unit {
  Diagnostic::diagnostic_set_source_raw(self, JsValue::make(value))
}

///|
pub fn Diagnostic::clear_source(self : Diagnostic) -> Unit {
  Diagnostic::diagnostic_set_source_raw(self, JsValue::make(()))
}

///|
pub fn Diagnostic::tags(self : Diagnostic) -> Array[DiagnosticTag]? {
  let raw = Diagnostic::diagnostic_tags_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn Diagnostic::set_tags(
  self : Diagnostic,
  value : Array[DiagnosticTag],
) -> Unit {
  Diagnostic::diagnostic_set_tags_raw(self, JsValue::make(value))
}

///|
pub fn Diagnostic::clear_tags(self : Diagnostic) -> Unit {
  Diagnostic::diagnostic_set_tags_raw(self, JsValue::make(()))
}

///|
/// The range to which this diagnostic applies.

///|
/// The range to which this diagnostic applies.

///|
/// The human-readable message.

///|
/// The human-readable message.

///|
/// The severity, default is {@link DiagnosticSeverity.Error error}.

///|
/// The severity, default is {@link DiagnosticSeverity.Error error}.

///|
/// A code or identifier for this diagnostic.
/// Should be used for later processing, e.g. when providing {@link CodeActionContext code actions}.

///|
/// A code or identifier for this diagnostic.
/// Should be used for later processing, e.g. when providing {@link CodeActionContext code actions}.

///|
/// A code or identifier for this diagnostic.
/// Should be used for later processing, e.g. when providing {@link CodeActionContext code actions}.

///|
/// A human-readable string describing the source of this
/// diagnostic, e.g. 'typescript' or 'super lint'.

///|
/// A human-readable string describing the source of this
/// diagnostic, e.g. 'typescript' or 'super lint'.

///|
/// A human-readable string describing the source of this
/// diagnostic, e.g. 'typescript' or 'super lint'.

///|
/// An array of related diagnostic information, e.g. when symbol-names within
/// a scope collide all definitions can be marked via this property.
pub fn Diagnostic::related_information(
  self : Diagnostic,
) -> Array[DiagnosticRelatedInformation]? {
  let raw = Diagnostic::diagnostic_related_information_raw(self)
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An array of related diagnostic information, e.g. when symbol-names within
/// a scope collide all definitions can be marked via this property.
pub fn Diagnostic::set_related_information(
  self : Diagnostic,
  value : Array[DiagnosticRelatedInformation],
) -> Unit {
  Diagnostic::diagnostic_set_related_information_raw(self, JsValue::make(value))
}

///|
/// An array of related diagnostic information, e.g. when symbol-names within
/// a scope collide all definitions can be marked via this property.
pub fn Diagnostic::clear_related_information(self : Diagnostic) -> Unit {
  Diagnostic::diagnostic_set_related_information_raw(self, JsValue::make(()))
}

///|
/// Additional metadata about the diagnostic.

///|
/// Additional metadata about the diagnostic.

///|
/// Additional metadata about the diagnostic.

///|
/// Creates a new related diagnostic information object.
///
/// @param location The location.
/// @param message The message.
pub fn DiagnosticRelatedInformation::new(
  location : Location,
  message : String,
) -> DiagnosticRelatedInformation {
  diagnostic_related_information_ffi(location, message)
}

///|
pub extern "js" fn DiagnosticRelatedInformation::location(
  self : DiagnosticRelatedInformation,
) -> Location =
  #| (value) => value.location

///|
pub extern "js" fn DiagnosticRelatedInformation::set_location(
  self : DiagnosticRelatedInformation,
  value : Location,
) -> Unit =
  #| (info, value) => { info.location = value; }

///|
pub extern "js" fn DiagnosticRelatedInformation::message(
  self : DiagnosticRelatedInformation,
) -> String =
  #| (value) => value.message

///|
pub extern "js" fn DiagnosticRelatedInformation::set_message(
  self : DiagnosticRelatedInformation,
  value : String,
) -> Unit =
  #| (info, value) => { info.message = value; }

///|
/// The location of this related diagnostic information.

///|
/// The location of this related diagnostic information.

///|
/// The message of this related diagnostic information.

///|
/// The message of this related diagnostic information.

///|
/// The name of this diagnostic collection, for instance `typescript`. Every diagnostic
/// from this collection will be associated with this name. Also, the task framework uses this
/// name when defining [problem matchers](https://code.visualstudio.com/docs/editor/tasks#_defining-a-problem-matcher).
pub extern "js" fn DiagnosticCollection::name(
  self : DiagnosticCollection,
) -> String =
  #| (collection) => collection.name

///|
/// Assign diagnostics for given resource. Will replace
/// existing diagnostics for that resource.
///
/// @param uri A resource identifier.
/// @param diagnostics Array of diagnostics or `undefined`
pub extern "js" fn DiagnosticCollection::set(
  self : DiagnosticCollection,
  uri : Uri,
  diagnostics : Array[Diagnostic],
) -> Unit =
  #| (collection, uri, diagnostics) => collection.set(uri, diagnostics)

///|
/// Remove all diagnostics from this collection that belong
/// to the provided `uri`. The same as `#set(uri, undefined)`.
///
/// @param uri A resource identifier.
pub extern "js" fn DiagnosticCollection::delete(
  self : DiagnosticCollection,
  uri : Uri,
) -> Unit =
  #| (collection, uri) => collection.delete(uri)

///|
/// Remove all diagnostics from this collection. The same
/// as calling `#set(undefined)`;
pub extern "js" fn DiagnosticCollection::clear(
  self : DiagnosticCollection,
) -> Unit =
  #| (collection) => collection.clear()

///|
/// Dispose and free associated resources. Calls
/// {@link DiagnosticCollection.clear clear}.
extern "js" fn diagnostic_collection_dispose_raw(
  collection : DiagnosticCollection,
) -> Unit =
  #| (collection) => collection.dispose()

///|
pub fn DiagnosticCollection::dispose(self : DiagnosticCollection) -> Unit {
  diagnostic_collection_dispose_raw(self)
}

///|
pub impl AsDisposable for DiagnosticCollection with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// Get the diagnostics for a given resource. *Note* that you cannot
/// modify the diagnostics-array returned from this call.
///
/// @param uri A resource identifier.
/// @returns An immutable array of {@link Diagnostic diagnostics} or `undefined`.
pub fn DiagnosticCollection::get(
  self : DiagnosticCollection,
  uri : Uri,
) -> Array[Diagnostic]? {
  let raw = DiagnosticCollection::diagnostic_collection_get_raw(self, uri)
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An array of resources for which diagnostics have changed.
pub fn DiagnosticChangeEvent::new(uris : Array[Uri]) -> DiagnosticChangeEvent {
  DiagnosticChangeEvent::{ uris, }
}

///|
/// An array of resources for which diagnostics have changed.

///|
extern "js" fn diagnostic_new_ffi(
  range : Range,
  message : String,
  severity : JsValue,
) -> Diagnostic =
  #| (range, message, severity) => {
  #|   if (severity === undefined || severity === null) {
  #|     return new (require("vscode").Diagnostic)(range, message);
  #|   }
  #|   return new (require("vscode").Diagnostic)(range, message, severity);
  #| }

///|
extern "js" fn diagnostic_code_to_js_ffi(
  value : JsValue,
  target : JsValue,
) -> JsValue =
  #| (value, target) => ({ value, target })

///|
extern "js" fn diagnostic_code_value_raw(value : JsValue) -> JsValue =
  #| (value) => value?.value

///|
extern "js" fn diagnostic_code_target_raw(value : JsValue) -> JsValue =
  #| (value) => value?.target

///|
extern "js" fn diagnostic_related_information_ffi(
  location : Location,
  message : String,
) -> DiagnosticRelatedInformation =
  #| (location, message) =>
  #|   new (require("vscode").DiagnosticRelatedInformation)(location, message)

///|
extern "js" fn Diagnostic::diagnostic_code_raw(self : Diagnostic) -> JsValue =
  #| (diag) => diag.code

///|
extern "js" fn Diagnostic::diagnostic_set_code_raw(
  self : Diagnostic,
  value : JsValue,
) -> Unit =
  #| (diag, value) => { diag.code = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn Diagnostic::diagnostic_source_raw(self : Diagnostic) -> JsValue =
  #| (diag) => diag.source

///|
extern "js" fn Diagnostic::diagnostic_set_source_raw(
  self : Diagnostic,
  value : JsValue,
) -> Unit =
  #| (diag, value) => { diag.source = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn Diagnostic::diagnostic_tags_raw(self : Diagnostic) -> JsValue =
  #| (diag) => diag.tags

///|
extern "js" fn Diagnostic::diagnostic_set_tags_raw(
  self : Diagnostic,
  value : JsValue,
) -> Unit =
  #| (diag, value) => { diag.tags = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn Diagnostic::diagnostic_related_information_raw(
  self : Diagnostic,
) -> JsValue =
  #| (diag) => diag.relatedInformation

///|
extern "js" fn Diagnostic::diagnostic_set_related_information_raw(
  self : Diagnostic,
  value : JsValue,
) -> Unit =
  #| (diag, value) => { diag.relatedInformation = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn DiagnosticCollection::diagnostic_collection_get_raw(
  self : DiagnosticCollection,
  uri : Uri,
) -> JsValue =
  #| (collection, uri) => collection.get(uri)

///|
/// Create a new range from two positions. If `start` is not
/// before or equal to `end`, the values will be swapped.
///
/// @param start A position.
/// @param end A position.
pub extern "js" fn Range::new(start : Position, end : Position) -> Range =
  #| (start, end) => new (require("vscode").Range)(start, end)

///|
pub extern "js" fn Range::from_numbers(
  start_line : Int,
  start_character : Int,
  end_line : Int,
  end_character : Int,
) -> Range =
  #| (startLine, startCharacter, endLine, endCharacter) =>
  #|   new (require("vscode").Range)(startLine, startCharacter, endLine, endCharacter)

///|
/// Create a selection from two positions.
///
/// @param anchor A position.
/// @param active A position.
pub extern "js" fn Selection::new(
  anchor : Position,
  active : Position,
) -> Selection =
  #| (anchor, active) => new (require("vscode").Selection)(anchor, active)

///|
pub extern "js" fn Selection::from_numbers(
  anchor_line : Int,
  anchor_character : Int,
  active_line : Int,
  active_character : Int,
) -> Selection =
  #| (anchorLine, anchorCharacter, activeLine, activeCharacter) =>
  #|   new (require("vscode").Selection)(
  #|     anchorLine,
  #|     anchorCharacter,
  #|     activeLine,
  #|     activeCharacter,
  #|   )

///|
/// The zero-based line value.

///|
/// The zero-based character value.
///
/// Character offsets are expressed using UTF-16 [code units](https://developer.mozilla.org/en-US/docs/Glossary/Code_unit).

///|
/// Check if this position is before `other`.
///
/// @param other A position.
/// @returns `true` if position is on a smaller line
/// or on the same line on a smaller character.
pub extern "js" fn Position::is_before(
  self : Position,
  other : Position,
) -> Bool =
  #| (pos, other) => pos.isBefore(other)

///|
/// Check if this position is before or equal to `other`.
///
/// @param other A position.
/// @returns `true` if position is on a smaller line
/// or on the same line on a smaller or equal character.
pub extern "js" fn Position::is_before_or_equal(
  self : Position,
  other : Position,
) -> Bool =
  #| (pos, other) => pos.isBeforeOrEqual(other)

///|
/// Check if this position is after `other`.
///
/// @param other A position.
/// @returns `true` if position is on a greater line
/// or on the same line on a greater character.
pub extern "js" fn Position::is_after(
  self : Position,
  other : Position,
) -> Bool =
  #| (pos, other) => pos.isAfter(other)

///|
/// Check if this position is after or equal to `other`.
///
/// @param other A position.
/// @returns `true` if position is on a greater line
/// or on the same line on a greater or equal character.
pub extern "js" fn Position::is_after_or_equal(
  self : Position,
  other : Position,
) -> Bool =
  #| (pos, other) => pos.isAfterOrEqual(other)

///|
/// Check if this position is equal to `other`.
///
/// @param other A position.
/// @returns `true` if the line and character of the given position are equal to
/// the line and character of this position.
pub extern "js" fn Position::is_equal(
  self : Position,
  other : Position,
) -> Bool =
  #| (pos, other) => pos.isEqual(other)

///|
/// Compare this to `other`.
///
/// @param other A position.
/// @returns A number smaller than zero if this position is before the given position,
/// a number greater than zero if this position is after the given position, or zero when
/// this and the given position are equal.
pub extern "js" fn Position::compare_to(
  self : Position,
  other : Position,
) -> Int =
  #| (pos, other) => pos.compareTo(other)

///|
/// Create a new position relative to this position.
///
/// @param lineDelta Delta value for the line value, default is `0`.
/// @param characterDelta Delta value for the character value, default is `0`.
/// @returns A position which line and character is the sum of the current line and
/// character and the corresponding deltas.
pub extern "js" fn Position::translate(
  self : Position,
  line_delta? : Int = 0,
  character_delta? : Int = 0,
) -> Position =
  #| (pos, lineDelta, characterDelta) => pos.translate(lineDelta, characterDelta)

///|

///|
/// Create a new position derived from this position.
///
/// @param line Value that should be used as line value, default is the {@link Position.line existing value}
/// @param character Value that should be used as character value, default is the {@link Position.character existing value}
/// @returns A position where line and character are replaced by the given values.
pub extern "js" fn Position::with_line(self : Position, line : Int) -> Position =
  #| (pos, line) => pos.with(line)

///|
/// Create a new position derived from this position.
///
/// @param line Value that should be used as line value, default is the {@link Position.line existing value}
/// @param character Value that should be used as character value, default is the {@link Position.character existing value}
/// @returns A position where line and character are replaced by the given values.
pub extern "js" fn Position::with_character(
  self : Position,
  character : Int,
) -> Position =
  #| (pos, character) => pos.with(undefined, character)

///|
/// Create a new position derived from this position.
///
/// @param line Value that should be used as line value, default is the {@link Position.line existing value}
/// @param character Value that should be used as character value, default is the {@link Position.character existing value}
/// @returns A position where line and character are replaced by the given values.
pub extern "js" fn Position::with_values(
  self : Position,
  line : Int,
  character : Int,
) -> Position =
  #| (pos, line, character) => pos.with(line, character)

///|
/// The start position. It is before or equal to {@link Range.end end}.
pub extern "js" fn Range::start(self : Range) -> Position =
  #| (range) => range.start

///|
/// The end position. It is after or equal to {@link Range.start start}.
pub extern "js" fn Range::end(self : Range) -> Position =
  #| (range) => range.end

///|
/// `true` if `start` and `end` are equal.
pub extern "js" fn Range::is_empty(self : Range) -> Bool =
  #| (range) => range.isEmpty

///|
/// `true` if `start.line` and `end.line` are equal.
pub extern "js" fn Range::is_single_line(self : Range) -> Bool =
  #| (range) => range.isSingleLine

///|
/// Check if a position or a range is contained in this range.
///
/// @param positionOrRange A position or a range.
/// @returns `true` if the position or range is inside or equal
/// to this range.
pub extern "js" fn Range::contains_position(
  self : Range,
  position : Position,
) -> Bool =
  #| (range, position) => range.contains(position)

///|
/// Check if a position or a range is contained in this range.
///
/// @param positionOrRange A position or a range.
/// @returns `true` if the position or range is inside or equal
/// to this range.
pub extern "js" fn Range::contains_range(self : Range, other : Range) -> Bool =
  #| (range, other) => range.contains(other)

///|
/// Check if `other` equals this range.
///
/// @param other A range.
/// @returns `true` when start and end are {@link Position.isEqual equal} to
/// start and end of this range.
pub extern "js" fn Range::is_equal(self : Range, other : Range) -> Bool =
  #| (range, other) => range.isEqual(other)

///|
/// Intersect `range` with this range and returns a new range or `undefined`
/// if the ranges have no overlap.
///
/// @param range A range.
/// @returns A range of the greater start and smaller end positions. Will
/// return undefined when there is no overlap.
pub fn Range::intersection(self : Range, other : Range) -> Range? {
  let value = range_intersection_ffi(self, other)
  if JsValue::is_null_or_undefined(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
/// Compute the union of `other` with this range.
///
/// @param other A range.
/// @returns A range of smaller start position and the greater end position.
pub extern "js" fn Range::union(self : Range, other : Range) -> Range =
  #| (range, other) => range.union(other)

///|
/// Derived a new range from this range.
///
/// @param start A position that should be used as start. The default value is the {@link Range.start current start}.
/// @param end A position that should be used as end. The default value is the {@link Range.end current end}.
/// @returns A range derived from this range with the given start and end position.
/// If start and end are not different `this` range will be returned.
pub extern "js" fn Range::with_start(self : Range, start : Position) -> Range =
  #| (range, start) => range.with(start)

///|
/// Derived a new range from this range.
///
/// @param start A position that should be used as start. The default value is the {@link Range.start current start}.
/// @param end A position that should be used as end. The default value is the {@link Range.end current end}.
/// @returns A range derived from this range with the given start and end position.
/// If start and end are not different `this` range will be returned.
pub extern "js" fn Range::with_end(self : Range, end : Position) -> Range =
  #| (range, end) => range.with(undefined, end)

///|
/// Derived a new range from this range.
///
/// @param start A position that should be used as start. The default value is the {@link Range.start current start}.
/// @param end A position that should be used as end. The default value is the {@link Range.end current end}.
/// @returns A range derived from this range with the given start and end position.
/// If start and end are not different `this` range will be returned.
pub extern "js" fn Range::with_positions(
  self : Range,
  start : Position,
  end : Position,
) -> Range =
  #| (range, start, end) => range.with(start, end)

///|
/// The position at which the selection starts.
/// This position might be before or after {@link Selection.active active}.
pub extern "js" fn Selection::anchor(self : Selection) -> Position =
  #| (selection) => selection.anchor

///|
/// The position of the cursor.
/// This position might be before or after {@link Selection.anchor anchor}.
pub extern "js" fn Selection::active(self : Selection) -> Position =
  #| (selection) => selection.active

///|
/// A selection is reversed if its {@link Selection.anchor anchor} is the {@link Selection.end end} position.
pub extern "js" fn Selection::is_reversed(self : Selection) -> Bool =
  #| (selection) => selection.isReversed

///|
pub fn Command::new(
  title : String,
  command : String,
  tooltip? : String = "",
  arguments? : Array[Any] = [],
) -> Command {
  let tooltip_value : String? = if tooltip == "" { None } else { Some(tooltip) }
  let arguments_value : Array[Any]? = if arguments.length() == 0 {
    None
  } else {
    Some(arguments)
  }
  Command::{
    title,
    command,
    tooltip: tooltip_value,
    arguments: arguments_value,
  }
}

///|
pub fn AccessibilityInformation::new(
  label : String,
  role? : String,
) -> AccessibilityInformation {
  AccessibilityInformation::{ label, role }
}

///|
fn accessibility_information_to_js(value : AccessibilityInformation) -> JsValue {
  accessibility_information_to_js_ffi(value.label, option_to_js(value.role))
}

///|
fn accessibility_information_from_js(
  value : JsValue,
) -> AccessibilityInformation? {
  let label_raw = accessibility_information_label_raw(value)
  let role_raw = accessibility_information_role_raw(value)
  let role = js_value_as_string_ffi(role_raw)
  match js_value_as_string_ffi(label_raw) {
    Some(label) => Some(AccessibilityInformation::{ label, role })
    None => None
  }
}

///|
extern "js" fn accessibility_information_to_js_ffi(
  label : String,
  role : JsValue,
) -> JsValue =
  #| (label, role) => {
  #|   const info = { label };
  #|   if (role !== undefined && role !== null) {
  #|     info.role = role;
  #|   }
  #|   return info;
  #| }

///|
extern "js" fn accessibility_information_label_raw(value : JsValue) -> JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.label

///|
extern "js" fn accessibility_information_role_raw(value : JsValue) -> JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.role

///|
pub extern "js" fn AuthenticationSessionAccountInformation::new(
  id : String,
  label : String,
) -> AuthenticationSessionAccountInformation =
  #| (id, label) => ({ id, label })

///|
/// The identifier of this item.

///|
/// The short name of this item, like 'Java Language Status', etc.

///|
/// The short name of this item, like 'Java Language Status', etc.

///|
/// The short name of this item, like 'Java Language Status', etc.

///|
/// A {@link DocumentSelector selector} that defines for what editors
/// this item shows.
pub fn LanguageStatusItem::selector(
  self : LanguageStatusItem,
) -> DocumentSelector {
  DocumentSelector::from_js(
    LanguageStatusItem::language_status_item_selector_raw(self),
  )
}

///|
/// A {@link DocumentSelector selector} that defines for what editors
/// this item shows.
pub fn LanguageStatusItem::set_selector(
  self : LanguageStatusItem,
  selector : DocumentSelector,
) -> Unit {
  LanguageStatusItem::language_status_item_set_selector_raw(
    self,
    language_status_document_selector_to_js(selector),
  )
}

///|
fn language_status_document_selector_to_js(
  selector : DocumentSelector,
) -> JsValue {
  match selector {
    Filter(value) => language_status_document_filter_to_js(value)
    Language(value) => JsValue::make(value)
    Entries(values) => {
      let encoded : Array[JsValue] = []
      for value in values {
        encoded.push(language_status_document_selector_entry_to_js(value))
      }
      JsValue::make(encoded)
    }
  }
}

///|
fn language_status_document_selector_entry_to_js(
  value : DocumentSelectorEntry,
) -> JsValue {
  match value {
    Filter(value) => language_status_document_filter_to_js(value)
    Language(value) => JsValue::make(value)
  }
}

///|
fn language_status_document_filter_to_js(value : DocumentFilter) -> JsValue {
  language_status_document_filter_to_js_ffi(
    option_to_js(value.language),
    option_to_js(value.notebook_type),
    option_to_js(value.scheme),
    language_status_option_glob_pattern_to_js(value.pattern),
  )
}

///|
fn language_status_option_glob_pattern_to_js(value : GlobPattern?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) =>
      match value {
        Text(value) => JsValue::make(value)
        Relative(value) => JsValue::make(value)
      }
  }
}

///|
/// The severity of this item.
///
/// Defaults to {@link LanguageStatusSeverity.Information information}. You can use this property to
/// signal to users that there is a problem that needs attention, like a missing executable or an
/// invalid configuration.
pub extern "js" fn LanguageStatusItem::severity(
  self : LanguageStatusItem,
) -> LanguageStatusSeverity =
  #| (item) => item.severity

///|
/// The severity of this item.
///
/// Defaults to {@link LanguageStatusSeverity.Information information}. You can use this property to
/// signal to users that there is a problem that needs attention, like a missing executable or an
/// invalid configuration.
pub extern "js" fn LanguageStatusItem::set_severity(
  self : LanguageStatusItem,
  severity : LanguageStatusSeverity,
) -> Unit =
  #| (item, severity) => { item.severity = severity; }

///|
/// The text to show for the entry. You can embed icons in the text by leveraging the syntax:
///
/// `My text $(icon-name) contains icons like $(icon-name) this one.`
///
/// Where the icon-name is taken from the ThemeIcon [icon set](https://code.visualstudio.com/api/references/icons-in-labels#icon-listing), e.g.
/// `light-bulb`, `thumbsup`, `zap` etc.
pub extern "js" fn LanguageStatusItem::text(
  self : LanguageStatusItem,
) -> String =
  #| (item) => item.text

///|
/// The text to show for the entry. You can embed icons in the text by leveraging the syntax:
///
/// `My text $(icon-name) contains icons like $(icon-name) this one.`
///
/// Where the icon-name is taken from the ThemeIcon [icon set](https://code.visualstudio.com/api/references/icons-in-labels#icon-listing), e.g.
/// `light-bulb`, `thumbsup`, `zap` etc.
pub extern "js" fn LanguageStatusItem::set_text(
  self : LanguageStatusItem,
  text : String,
) -> Unit =
  #| (item, text) => { item.text = text; }

///|
/// Optional, human-readable details for this item.

///|
/// Optional, human-readable details for this item.

///|
/// Optional, human-readable details for this item.

///|
/// Controls whether the item is shown as "busy". Defaults to `false`.

///|
/// Controls whether the item is shown as "busy". Defaults to `false`.

///|
/// A {@linkcode Command command} for this item.

///|
/// A {@linkcode Command command} for this item.

///|
/// A {@linkcode Command command} for this item.

///|
/// Accessibility information used when a screen reader interacts with this item
pub fn LanguageStatusItem::accessibility_information(
  self : LanguageStatusItem,
) -> AccessibilityInformation? {
  let raw = LanguageStatusItem::language_status_item_accessibility_information_raw(
    self,
  )
  accessibility_information_from_js(raw)
}

///|
/// Accessibility information used when a screen reader interacts with this item
pub fn LanguageStatusItem::set_accessibility_information(
  self : LanguageStatusItem,
  value : AccessibilityInformation,
) -> Unit {
  LanguageStatusItem::language_status_item_set_accessibility_information_raw(
    self,
    accessibility_information_to_js(value),
  )
}

///|
/// Accessibility information used when a screen reader interacts with this item
pub fn LanguageStatusItem::clear_accessibility_information(
  self : LanguageStatusItem,
) -> Unit {
  LanguageStatusItem::language_status_item_set_accessibility_information_raw(
    self,
    JsValue::make(()),
  )
}

///|
/// Dispose and free associated resources.
extern "js" fn language_status_item_dispose_raw(
  item : LanguageStatusItem,
) -> Unit =
  #| (item) => item.dispose()

///|
pub fn LanguageStatusItem::dispose(self : LanguageStatusItem) -> Unit {
  language_status_item_dispose_raw(self)
}

///|
pub impl AsDisposable for LanguageStatusItem with as_disposable(self) {
  disposable_from_js(self)
}

///|
extern "js" fn LanguageStatusItem::language_status_item_selector_raw(
  self : LanguageStatusItem,
) -> JsValue =
  #| (item) => item.selector

///|
extern "js" fn LanguageStatusItem::language_status_item_set_selector_raw(
  self : LanguageStatusItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.selector = value; }

///|
extern "js" fn language_status_document_filter_to_js_ffi(
  language : JsValue,
  notebook_type : JsValue,
  scheme : JsValue,
  pattern : JsValue,
) -> JsValue =
  #| (language, notebookType, scheme, pattern) => {
  #|   const filter = {};
  #|   if (language !== undefined && language !== null) filter.language = language;
  #|   if (notebookType !== undefined && notebookType !== null) {
  #|     filter.notebookType = notebookType;
  #|   }
  #|   if (scheme !== undefined && scheme !== null) filter.scheme = scheme;
  #|   if (pattern !== undefined && pattern !== null) filter.pattern = pattern;
  #|   return filter;
  #| }

///|
extern "js" fn LanguageStatusItem::language_status_item_accessibility_information_raw(
  self : LanguageStatusItem,
) -> JsValue =
  #| (item) => item.accessibilityInformation

///|
extern "js" fn LanguageStatusItem::language_status_item_set_accessibility_information_raw(
  self : LanguageStatusItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.accessibilityInformation = value === undefined || value === null ? undefined : value; }

///|
/// Represents a location inside a resource, such as a line
/// inside a text file.
pub type Location

///|
/// Represents the connection of two locations. Provides additional metadata over normal {@link Location locations},
/// including an origin range.
pub(all) struct LocationLink {
  mut targetUri : Uri
  mut targetRange : Range
  mut targetSelectionRange : Range?
  mut originSelectionRange : Range?
}

///|
/// The base class of all breakpoint types.
pub type Breakpoint

///|
/// A breakpoint specified by a source location.
pub type SourceBreakpoint

///|
/// A breakpoint specified by a function name.
pub type FunctionBreakpoint

///|
/// An event describing the changes to the set of {@link Breakpoint breakpoints}.
pub struct BreakpointsChangeEvent {
  added : Array[Breakpoint]
  removed : Array[Breakpoint]
  changed : Array[Breakpoint]
}

///|
/// A debug session.
pub type DebugSession

///|
/// Represents the debug console.
pub type DebugConsole

///|
/// A custom Debug Adapter Protocol event received from a {@link DebugSession debug session}.
pub struct DebugSessionCustomEvent {
  session : DebugSession
  event : String
  body : Any
}

///|
/// Represents a thread in a debug session.
pub type DebugThread

///|
/// Represents a stack frame in a debug session.
pub type DebugStackFrame

///|
pub type DebugStackItem

///|
/// Configuration for a debug session.
pub struct DebugConfiguration {
  mut type_ : String
  mut name : String
  mut request : String
}

///|
/// Options for {@link debug.startDebugging starting a debug session}.
pub(all) struct DebugSessionOptions {
  mut parent_session : DebugSession?
  mut lifecycle_managed_by_parent : Bool?
  mut console_mode : DebugConsoleMode?
  mut no_debug : Bool?
  mut compact : Bool?
  mut suppress_save_before_start : Bool?
  mut suppress_debug_toolbar : Bool?
  mut suppress_debug_statusbar : Bool?
  mut suppress_debug_view : Bool?
  mut test_run : Any?
}

///|
/// A task to execute
pub type Task

///|
/// A task filter denotes tasks by their version and types
pub(all) struct TaskFilter {
  mut version : String?
  mut type_ : String?
}

///|
/// An object representing an executed Task. It can be used
/// to terminate a task.
///
/// This interface is not intended to be implemented.
pub type TaskExecution

///|
/// An event signaling the start of a task execution.
///
/// This interface is not intended to be implemented.
pub struct TaskStartEvent {
  execution : TaskExecution
}

///|
/// An event signaling the end of an executed task.
///
/// This interface is not intended to be implemented.
pub struct TaskEndEvent {
  execution : TaskExecution
}

///|
/// An event signaling the start of a process execution
/// triggered through a task
pub struct TaskProcessStartEvent {
  execution : TaskExecution
  processId : Int
}

///|
/// An event signaling the end of a process execution
/// triggered through a task
pub struct TaskProcessEndEvent {
  execution : TaskExecution
  exitCode : Int?
}

///|
/// An source control is able to provide {@link SourceControlResourceState resource states}
/// to the editor and interact with the editor in several source control related ways.
pub type SourceControl

///|
/// Represents the input box in the Source Control viewlet.
pub type SourceControlInputBox

///|
/// A source control resource group is a collection of
/// {@link SourceControlResourceState source control resource states}.
pub type SourceControlResourceGroup

///|
/// An source control resource state represents the state of an underlying workspace
/// resource within a certain {@link SourceControlResourceGroup source control group}.
pub struct SourceControlResourceState {
  resourceUri : Uri
  command : Command?
  decorations : SourceControlResourceDecorations?
  contextValue : String?
}

///|
/// The theme-aware decorations for a
/// {@link SourceControlResourceState source control resource state}.
pub type SourceControlResourceThemableDecorations

///|
/// The decorations for a {@link SourceControlResourceState source control resource state}.
/// Can be independently specified for light and dark themes.
pub type SourceControlResourceDecorations

///|
/// Represents a session of a currently logged in user.
pub type AuthenticationSession

///|
/// The information of an account associated with an {@link AuthenticationSession}.
pub type AuthenticationSessionAccountInformation

///|
/// Basic information about an {@link AuthenticationProvider}
pub struct AuthenticationProviderInformation {
  id : String
  label : String
}

///|
/// Options for creating an {@link AuthenticationProvider}.
pub struct AuthenticationProviderOptions {
  supports_multiple_accounts : Bool?
}

///|
/// An {@link Event} which fires when an {@link AuthenticationSession} is added, removed, or changed.
pub struct AuthenticationProviderAuthenticationSessionsChangeEvent {
  added : Array[AuthenticationSession]
  removed : Array[AuthenticationSession]
  changed : Array[AuthenticationSession]
}

///|
/// The options passed in to the {@link AuthenticationProvider.getSessions} and
/// {@link AuthenticationProvider.createSession} call.
pub(all) struct AuthenticationProviderSessionOptions {
  mut account : AuthenticationSessionAccountInformation?
}

///|
/// An {@link Event} which fires when an {@link AuthenticationSession} is added, removed, or changed.
pub struct AuthenticationSessionsChangeEvent {
  provider : AuthenticationProviderInformation
}

///|
/// Optional options to be used when calling {@link authentication.getSession} with interactive options `forceNewSession` & `createIfNone`.
pub(all) struct AuthenticationGetSessionPresentationOptions {
  mut detail : String?
}

///|
/// Optional options to be used when calling {@link authentication.getSession} with the flag `forceNewSession`.
/// @deprecated Use {@link AuthenticationGetSessionPresentationOptions} instead.
pub struct AuthenticationForceNewSessionOptions {
  detail : String?
}

///|
pub(all) enum AuthenticationGetSessionPresentationOptionsCreateIfNone {
  BoolValue(Bool)
  AuthenticationGetSessionPresentationOptions(
    AuthenticationGetSessionPresentationOptions
  )
}

///|
pub(all) enum AuthenticationForceNewSessionValue {
  BoolValue(Bool)
  AuthenticationGetSessionPresentationOptions(
    AuthenticationGetSessionPresentationOptions
  )
  AuthenticationForceNewSessionOptions(AuthenticationForceNewSessionOptions)
}

///|
/// Options to be used when getting an {@link AuthenticationSession} from an {@link AuthenticationProvider}.
pub(all) struct AuthenticationGetSessionOptions {
  mut clear_session_preference : Bool?
  mut create_if_none : AuthenticationGetSessionPresentationOptionsCreateIfNone?
  mut force_new_session : AuthenticationForceNewSessionValue?
  mut silent : Bool?
  mut account : AuthenticationSessionAccountInformation?
}

///|
/// Represents parameters for creating a session based on a WWW-Authenticate header value.
/// This is used when an API returns a 401 with a WWW-Authenticate header indicating
/// that additional authentication is required. The details of which will be passed down
/// to the authentication provider to create a session.
///
/// @note The authorization provider must support handling challenges and specifically
/// the challenges in this WWW-Authenticate value.
/// @note For more information on WWW-Authenticate please see https://developer.mozilla.org/docs/Web/HTTP/Reference/Headers/WWW-Authenticate
pub struct AuthenticationWwwAuthenticateRequest {
  www_authenticate : String
  fallback_scopes : Array[String]?
}

///|
pub fn AuthenticationGetSessionPresentationOptions::new(
  detail? : String,
) -> AuthenticationGetSessionPresentationOptions {
  AuthenticationGetSessionPresentationOptions::{ detail, }
}

///|
pub fn AuthenticationForceNewSessionOptions::new(
  detail? : String,
) -> AuthenticationForceNewSessionOptions {
  AuthenticationForceNewSessionOptions::{ detail, }
}

///|
pub fn AuthenticationGetSessionOptions::new(
  clear_session_preference? : Bool,
  create_if_none? : AuthenticationGetSessionPresentationOptionsCreateIfNone,
  force_new_session? : AuthenticationForceNewSessionValue,
  silent? : Bool,
  account? : AuthenticationSessionAccountInformation,
) -> AuthenticationGetSessionOptions {
  AuthenticationGetSessionOptions::{
    clear_session_preference,
    create_if_none,
    force_new_session,
    silent,
    account,
  }
}

///|
pub fn AuthenticationWwwAuthenticateRequest::new(
  www_authenticate : String,
  fallback_scopes? : Array[String],
) -> AuthenticationWwwAuthenticateRequest {
  AuthenticationWwwAuthenticateRequest::{ www_authenticate, fallback_scopes }
}

///|
pub fn AuthenticationProviderInformation::new(
  id : String,
  label : String,
) -> AuthenticationProviderInformation {
  AuthenticationProviderInformation::{ id, label }
}

///|
pub extern "js" fn AuthenticationSession::new(
  id : String,
  access_token : String,
  account : AuthenticationSessionAccountInformation,
  scopes : Array[String],
) -> AuthenticationSession =
  #| (id, accessToken, account, scopes) => ({ id, accessToken, account, scopes })

///|
pub fn AuthenticationProviderAuthenticationSessionsChangeEvent::new(
  added? : Array[AuthenticationSession] = [],
  removed? : Array[AuthenticationSession] = [],
  changed? : Array[AuthenticationSession] = [],
) -> AuthenticationProviderAuthenticationSessionsChangeEvent {
  AuthenticationProviderAuthenticationSessionsChangeEvent::{
    added,
    removed,
    changed,
  }
}

///|
pub fn AuthenticationSessionsChangeEvent::new(
  provider : AuthenticationProviderInformation,
) -> AuthenticationSessionsChangeEvent {
  AuthenticationSessionsChangeEvent::{ provider, }
}

///|
/// An extension context is a collection of utilities private to an
/// extension.
///
/// An instance of an `ExtensionContext` is provided as the first
/// parameter to the `activate`-call of an extension.
pub type ExtensionContext

///|
/// A memento represents a storage utility. It can store and retrieve
/// values.
pub type Memento

///|
/// Window/editor types
pub type TabGroups

///|
/// Represents a group of tabs. A tab group itself consists of multiple tabs.
pub type TabGroup

///|
/// Represents a tab within a {@link TabGroup group of tabs}.
/// Tabs are merely the graphical representation within the editor area.
/// A backing editor is not a guarantee.
pub type Tab

///|
/// An event describing changes to tab groups.
pub struct TabGroupChangeEvent {
  opened : Array[TabGroup]
  closed : Array[TabGroup]
  changed : Array[TabGroup]
}

///|
/// An event describing change to tabs.
pub struct TabChangeEvent {
  opened : Array[Tab]
  closed : Array[Tab]
  changed : Array[Tab]
}

///|
/// Represents an editor that is attached to a {@link TextDocument document}.
pub type TextEditor

///|
/// Represents an event describing the change in a {@link TextEditor.selections text editor's selections}.
pub struct TextEditorSelectionChangeEvent {
  textEditor : TextEditor
  selections : Array[Selection]
  kind : TextEditorSelectionChangeKind?
}

///|
pub(all) enum TextEditorSelectionChangeKind {
  Keyboard = 1
  Mouse = 2
  Command = 3
} derive(Eq)

///|
pub(all) enum TextEditorCursorStyle {
  Line = 1
  Block = 2
  Underline = 3
  LineThin = 4
  BlockOutline = 5
  UnderlineThin = 6
} derive(Eq)

///|
pub(all) enum TextEditorLineNumbersStyle {
  Off = 0
  On = 1
  Relative = 2
  Interval = 3
} derive(Eq)

///|
/// Represents an event describing the change in a {@link TextEditor.visibleRanges text editor's visible ranges}.
pub struct TextEditorVisibleRangesChangeEvent {
  textEditor : TextEditor
  visibleRanges : Array[Range]
}

///|
/// Represents an event describing the change in a {@link TextEditor.options text editor's options}.
pub struct TextEditorOptionsChangeEvent {
  textEditor : TextEditor
  options : TextEditorOptions
}

///|
/// Represents an event describing the change of a {@link TextEditor.viewColumn text editor's view column}.
pub struct TextEditorViewColumnChangeEvent {
  textEditor : TextEditor
  viewColumn : ViewColumn
}

///|
/// Represents a notebook editor that is attached to a {@link NotebookDocument notebook}.
/// Additional properties of the NotebookEditor are available in the proposed
/// API, which will be finalized later.
pub(all) type NotebookEditor

///|
/// Represents an event describing the change in a {@link NotebookEditor.selections notebook editor's selections}.
pub struct NotebookEditorSelectionChangeEvent {
  notebookEditor : NotebookEditor
  selections : Array[NotebookRange]
}

///|
/// Represents an event describing the change in a {@link NotebookEditor.visibleRanges notebook editor's visibleRanges}.
pub struct NotebookEditorVisibleRangesChangeEvent {
  notebookEditor : NotebookEditor
  visibleRanges : Array[NotebookRange]
}

///|
/// An individual terminal instance within the integrated terminal.
pub type Terminal

///|
/// Represents how a terminal exited.
pub struct TerminalExitStatus {
  code : Int?
  reason : TerminalExitReason
}

///|
/// Represents the state of a {@link Terminal}.
pub struct TerminalState {
  isInteractedWith : Bool
  shell : String?
}

///|
/// [Shell integration](https://code.visualstudio.com/docs/terminal/shell-integration)-powered capabilities owned by a terminal.
pub struct TerminalShellIntegration {
  cwd : Uri?
}

///|
/// A command that was executed in a terminal.
pub struct TerminalShellExecution {
  commandLine : TerminalShellExecutionCommandLine
  cwd : Uri?
}

///|
/// An event signalling that a terminal's shell integration has changed.
pub struct TerminalShellIntegrationChangeEvent {
  terminal : Terminal
  shellIntegration : TerminalShellIntegration
}

///|
/// An event signalling that an execution has started in a terminal.
pub struct TerminalShellExecutionStartEvent {
  terminal : Terminal
  shellIntegration : TerminalShellIntegration
  execution : TerminalShellExecution
}

///|
/// An event signalling that an execution has ended in a terminal.
pub struct TerminalShellExecutionEndEvent {
  terminal : Terminal
  shellIntegration : TerminalShellIntegration
  execution : TerminalShellExecution
  exitCode : Int?
}

///|
/// Represents the state of a window.
pub struct WindowState {
  focused : Bool
  active : Bool
}

///|
/// Represents a text document, such as a source file. Text documents have
/// {@link TextLine lines} and knowledge about an underlying resource like a file.
pub type TextDocument

///|
/// Represents a line of text, such as a line of source code.
///
/// TextLine objects are __immutable__. When a {@link TextDocument document} changes,
/// previously retrieved lines will not represent the latest state.
pub struct TextLine {
  lineNumber : Int
  text : String
  range : Range
  rangeIncludingLineBreak : Range
  firstNonWhitespaceCharacterIndex : Int
  isEmptyOrWhitespace : Bool
}

///|
/// Represents a text selection in an editor.
pub type Selection

///|
/// Represents an end of line character sequence in a {@link TextDocument document}.
pub(all) enum EndOfLine {
  LF = 1
  CRLF = 2
} derive(Eq)

///|
/// Represents a {@link TextEditor text editor}'s {@link TextEditor.options options}.
pub(all) struct TextEditorOptions {
  mut tab_size : StringOrInt?
  mut indent_size : StringOrInt?
  mut insert_spaces : StringOrBool?
  mut cursor_style : TextEditorCursorStyle?
  mut line_numbers : TextEditorLineNumbersStyle?
}

///|
/// Represents different {@link TextEditor.revealRange reveal} strategies in a text editor.
pub(all) enum TextEditorRevealType {
  Default = 0
  InCenter = 1
  InCenterIfOutsideViewport = 2
  AtTop = 3
} derive(Eq)

///|
/// A complex edit that will be applied in one transaction on a TextEditor.
/// This holds a description of the edits and if the edits are valid (i.e. no overlapping regions, document was not changed in the meantime, etc.)
/// they can be applied on a {@link TextDocument document} associated with a {@link TextEditor text editor}.
pub type TextEditorEdit

///|
pub struct TextEditorEditOptions {
  undo_stop_before : Bool
  undo_stop_after : Bool
}

///|
/// A snippet string is a template which allows to insert text
/// and to control the editor cursor when insertion happens.
///
/// A snippet can define tab stops and placeholders with `$1`, `$2`
/// and `${3:foo}`. `$0` defines the final tab stop, it defaults to
/// the end of the snippet. Variables are defined with `$name` and
/// `${name:default value}`. Also see
/// [the full snippet syntax](https://code.visualstudio.com/docs/editor/userdefinedsnippets#_create-your-own-snippets).
pub type SnippetString

///|
pub struct TextEditorInsertSnippetOptions {
  undo_stop_before : Bool
  undo_stop_after : Bool
  keep_whitespace : Bool
}

///|
/// The associated uri for this document.
///
/// *Note* that most documents use the `file`-scheme, which means they are files on disk. However, **not** all documents are
/// saved on disk and therefore the `scheme` must be checked before trying to access the underlying file or siblings on disk.
///
/// @see {@link FileSystemProvider}
/// @see {@link TextDocumentContentProvider}
pub extern "js" fn TextDocument::uri(self : TextDocument) -> Uri =
  #| (doc) => doc.uri

///|
/// The identifier of the language associated with this document.
pub extern "js" fn TextDocument::language_id(self : TextDocument) -> String =
  #| (doc) => doc.languageId

///|
/// The file system path of the associated resource. Shorthand
/// notation for {@link TextDocument.uri TextDocument.uri.fsPath}. Independent of the uri scheme.
pub extern "js" fn TextDocument::file_name(self : TextDocument) -> String =
  #| (doc) => doc.fileName

///|
/// Is this document representing an untitled file which has never been saved yet. *Note* that
/// this does not mean the document will be saved to disk, use {@linkcode Uri.scheme}
/// to figure out where a document will be {@link FileSystemProvider saved}, e.g. `file`, `ftp` etc.
pub extern "js" fn TextDocument::is_untitled(self : TextDocument) -> Bool =
  #| (doc) => doc.isUntitled

///|
/// The file encoding of this document that will be used when the document is saved.
///
/// Use the {@link workspace.onDidChangeTextDocument onDidChangeTextDocument}-event to
/// get notified when the document encoding changes.
///
/// Note that the possible encoding values are currently defined as any of the following:
/// 'utf8', 'utf8bom', 'utf16le', 'utf16be', 'windows1252', 'iso88591', 'iso88593',
/// 'iso885915', 'macroman', 'cp437', 'windows1256', 'iso88596', 'windows1257',
/// 'iso88594', 'iso885914', 'windows1250', 'iso88592', 'cp852', 'windows1251',
/// 'cp866', 'cp1125', 'iso88595', 'koi8r', 'koi8u', 'iso885913', 'windows1253',
/// 'iso88597', 'windows1255', 'iso88598', 'iso885910', 'iso885916', 'windows1254',
/// 'iso88599', 'windows1258', 'gbk', 'gb18030', 'cp950', 'big5hkscs', 'shiftjis',
/// 'eucjp', 'euckr', 'windows874', 'iso885911', 'koi8ru', 'koi8t', 'gb2312',
/// 'cp865', 'cp850'.
pub extern "js" fn TextDocument::encoding(self : TextDocument) -> String =
  #| (doc) => doc.encoding

///|
/// The version number of this document (it will strictly increase after each
/// change, including undo/redo).
pub extern "js" fn TextDocument::version(self : TextDocument) -> Int =
  #| (doc) => doc.version

///|
/// `true` if there are unpersisted changes.
pub extern "js" fn TextDocument::is_dirty(self : TextDocument) -> Bool =
  #| (doc) => doc.isDirty

///|
/// `true` if the document has been closed. A closed document isn't synchronized anymore
/// and won't be re-used when the same resource is opened again.
pub extern "js" fn TextDocument::is_closed(self : TextDocument) -> Bool =
  #| (doc) => doc.isClosed

///|
/// The {@link EndOfLine end of line} sequence that is predominately
/// used in this document.
pub extern "js" fn TextDocument::eol(self : TextDocument) -> EndOfLine =
  #| (doc) => doc.eol

///|
/// The number of lines in this document.
pub extern "js" fn TextDocument::line_count(self : TextDocument) -> Int =
  #| (doc) => doc.lineCount

///|
extern "js" fn TextDocument::save_promise(
  self : TextDocument,
) -> @js_async.Promise[Bool] =
  #| (doc) => doc.save()

///|
/// Save the underlying file.
///
/// @returns A promise that will resolve to `true` when the file
/// has been saved. If the save failed, will return `false`.
pub async fn TextDocument::save(self : TextDocument) -> Bool {
  @js_async.Promise::wait(TextDocument::save_promise(self))
}

///|
/// Returns a text line denoted by the line number. Note
/// that the returned object is *not* live and changes to the
/// document are not reflected.
///
/// @param line A line number in `[0, lineCount)`.
/// @returns A {@link TextLine line}.
pub extern "js" fn TextDocument::line_at_line(
  self : TextDocument,
  line : Int,
) -> TextLine =
  #| (doc, line) => doc.lineAt(line)

///|
/// Returns a text line denoted by the line number. Note
/// that the returned object is *not* live and changes to the
/// document are not reflected.
///
/// @param line A line number in `[0, lineCount)`.
/// @returns A {@link TextLine line}.
pub extern "js" fn TextDocument::line_at_position(
  self : TextDocument,
  position : Position,
) -> TextLine =
  #| (doc, position) => doc.lineAt(position)

///|
/// Converts the position to a zero-based offset.
///
/// The position will be {@link TextDocument.validatePosition adjusted}.
///
/// @param position A position.
/// @returns A valid zero-based offset in UTF-16 [code units](https://developer.mozilla.org/en-US/docs/Glossary/Code_unit).
pub extern "js" fn TextDocument::offset_at(
  self : TextDocument,
  position : Position,
) -> Int =
  #| (doc, position) => doc.offsetAt(position)

///|
/// Converts a zero-based offset to a position.
///
/// @param offset A zero-based offset into the document. This offset is in UTF-16 [code units](https://developer.mozilla.org/en-US/docs/Glossary/Code_unit).
/// @returns A valid {@link Position}.
pub extern "js" fn TextDocument::position_at(
  self : TextDocument,
  offset : Int,
) -> Position =
  #| (doc, offset) => doc.positionAt(offset)

///|
/// Get the text of this document. A substring can be retrieved by providing
/// a range. The range will be {@link TextDocument.validateRange adjusted}.
///
/// @param range Include only the text included by the range.
/// @returns The text inside the provided range or the entire text.
pub extern "js" fn TextDocument::get_text(self : TextDocument) -> String =
  #| (doc) => doc.getText()

///|
/// Get the text of this document. A substring can be retrieved by providing
/// a range. The range will be {@link TextDocument.validateRange adjusted}.
///
/// @param range Include only the text included by the range.
/// @returns The text inside the provided range or the entire text.
pub extern "js" fn TextDocument::get_text_range(
  self : TextDocument,
  range : Range,
) -> String =
  #| (doc, range) => doc.getText(range)

///|
/// Get a word-range at the given position. By default words are defined by
/// common separators, like space, -, _, etc. In addition, per language custom
/// [word definitions] can be defined. It
/// is also possible to provide a custom regular expression.
///
/// * *Note 1:* A custom regular expression must not match the empty string and
/// if it does, it will be ignored.
/// * *Note 2:* A custom regular expression will fail to match multiline strings
/// and in the name of speed regular expressions should not match words with
/// spaces. Use {@linkcode TextLine.text} for more complex, non-wordy, scenarios.
///
/// The position will be {@link TextDocument.validatePosition adjusted}.
///
/// @param position A position.
/// @param regex Optional regular expression that describes what a word is.
/// @returns A range spanning a word, or `undefined`.
pub fn TextDocument::get_word_range_at_position(
  self : TextDocument,
  position : Position,
  regex? : RegExp,
) -> Range? {
  let value = text_document_get_word_range_at_position_ffi(
    self,
    position,
    option_to_js(regex),
  )
  if JsValue::is_null_or_undefined(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
/// Ensure a range is completely contained in this document.
///
/// @param range A range.
/// @returns The given range or a new, adjusted range.
pub extern "js" fn TextDocument::validate_range(
  self : TextDocument,
  range : Range,
) -> Range =
  #| (doc, range) => doc.validateRange(range)

///|
/// Ensure a position is contained in the range of this document.
///
/// @param position A position.
/// @returns The given position or a new, adjusted position.
pub extern "js" fn TextDocument::validate_position(
  self : TextDocument,
  position : Position,
) -> Position =
  #| (doc, position) => doc.validatePosition(position)

///|
pub fn TextLine::new(
  line_number : Int,
  text : String,
  range : Range,
  range_including_line_break : Range,
  first_non_whitespace_character_index : Int,
  is_empty_or_whitespace : Bool,
) -> TextLine {
  TextLine::{
    lineNumber: line_number,
    text,
    range,
    rangeIncludingLineBreak: range_including_line_break,
    firstNonWhitespaceCharacterIndex: first_non_whitespace_character_index,
    isEmptyOrWhitespace: is_empty_or_whitespace,
  }
}

///|
/// The zero-based line number.

///|
/// The text of this line without the line separator characters.

///|
/// The range this line covers without the line separator characters.

///|
/// The range this line covers with the line separator characters.

///|
/// The offset of the first character which is not a whitespace character as defined
/// by `/\s/`. **Note** that if a line is all whitespace the length of the line is returned.

///|
/// Whether this line is whitespace only, shorthand
/// for {@link TextLine.firstNonWhitespaceCharacterIndex} === {@link TextLine.text TextLine.text.length}.

///|
/// Denotes a location of an editor in the window. Editors can be arranged in a grid
/// and each column represents one editor location in that grid by counting the editors
/// in order of their appearance.
pub(all) enum ViewColumn {
  Active
  Beside
  One
  Two
  Three
  Four
  Five
  Six
  Seven
  Eight
  Nine
  Custom(Int)
} derive(Eq)

///|
fn view_column_to_int(value : ViewColumn) -> Int {
  match value {
    Active => -1
    Beside => -2
    One => 1
    Two => 2
    Three => 3
    Four => 4
    Five => 5
    Six => 6
    Seven => 7
    Eight => 8
    Nine => 9
    Custom(value) => value
  }
}

///|
fn view_column_from_int(value : Int) -> ViewColumn {
  match value {
    -1 => Active
    -2 => Beside
    1 => One
    2 => Two
    3 => Three
    4 => Four
    5 => Five
    6 => Six
    7 => Seven
    8 => Eight
    9 => Nine
    _ => Custom(value)
  }
}

///|
/// Represents options to configure the behavior of showing a {@link TextDocument document} in an {@link TextEditor editor}.
pub(all) struct TextDocumentShowOptions {
  mut view_column : ViewColumn?
  mut preserve_focus : Bool?
  mut preview : Bool?
  mut selection : Range?
}

///|
/// Represents a cell of a {@link NotebookDocument notebook}, either a {@link NotebookCellKind.Code code}-cell
/// or {@link NotebookCellKind.Markup markup}-cell.
///
/// NotebookCell instances are immutable and are kept in sync for as long as they are part of their notebook.
pub type NotebookCell

///|
/// NotebookCellData is the raw representation of notebook cells. Its is part of {@linkcode NotebookData}.
pub type NotebookCellData

///|
pub(all) enum NotebookCellKind {
  Markup = 1
  Code = 2
} derive(Eq)

///|
/// Notebook cell output represents a result of executing a cell. It is a container type for multiple
/// {@link NotebookCellOutputItem output items} where contained items represent the same result but
/// use different MIME types.
pub type NotebookCellOutput

///|
/// One representation of a {@link NotebookCellOutput notebook output}, defined by MIME type and data.
pub type NotebookCellOutputItem

///|
/// A notebook range represents an ordered pair of two cell indices.
/// It is guaranteed that start is less than or equal to end.
pub type NotebookRange

///|
pub(all) enum NotebookEditorRevealType {
  Default = 0
  InCenter = 1
  InCenterIfOutsideViewport = 2
  AtTop = 3
} derive(Eq)

///|
/// Represents a notebook which itself is a sequence of {@link NotebookCell code or markup cells}. Notebook documents are
/// created from {@link NotebookData notebook data}.
pub type NotebookDocument

///|
/// Represents options to configure the behavior of showing a {@link NotebookDocument notebook document} in an {@link NotebookEditor notebook editor}.
pub struct NotebookDocumentShowOptions {
  view_column : ViewColumn?
  preserve_focus : Bool?
  preview : Bool?
  selections : Array[NotebookRange]?
}

///|
/// Represents rendering styles for a {@link TextEditorDecorationType text editor decoration}.
pub type DecorationRenderOptions

///|
/// Represents a handle to a set of decorations
/// sharing the same {@link DecorationRenderOptions styling options} in a {@link TextEditor text editor}.
///
/// To get an instance of a `TextEditorDecorationType` use
/// {@link window.createTextEditorDecorationType createTextEditorDecorationType}.
pub struct TextEditorDecorationType {
  key : String
}

///|
/// Represents options for a specific decoration in a {@link TextEditorDecorationType decoration set}.
pub type DecorationOptions

///|
/// Options to configure the behavior of the message.
///
/// @see {@link window.showInformationMessage showInformationMessage}
/// @see {@link window.showWarningMessage showWarningMessage}
/// @see {@link window.showErrorMessage showErrorMessage}
pub(all) struct MessageOptions {
  mut modal : Bool?
  mut detail : String?
}

///|
/// Represents an action that is shown with an information, warning, or
/// error message.
///
/// @see {@link window.showInformationMessage showInformationMessage}
/// @see {@link window.showWarningMessage showWarningMessage}
/// @see {@link window.showErrorMessage showErrorMessage}
pub(all) struct MessageItem {
  mut title : String
  mut isCloseAffordance : Bool?
}

///|
pub fn MessageItem::new(
  title : String,
  is_close_affordance? : Bool,
) -> MessageItem {
  MessageItem::{ title, isCloseAffordance: is_close_affordance }
}

///|
/// A short title like 'Retry', 'Open Log' etc.

///|
/// A hint for modal dialogs that the item should be triggered
/// when the user cancels the dialog (e.g. by pressing the ESC
/// key).
///
/// Note: this option is ignored for non-modal messages.

///|
/// Options to configure the behavior of the quick pick UI.
pub(all) struct QuickPickOptions {
  mut title : String?
  mut match_on_description : Bool?
  mut match_on_detail : Bool?
  mut place_holder : String?
  mut prompt : String?
  mut ignore_focus_out : Bool?
  mut can_pick_many : Bool?
  on_did_select_item : QuickPickSelectItemCallback?
}

///|
pub(all) enum QuickPickSelectItemCallback {
  QuickPickItem((QuickPickItem) -> Unit)
  StringItem((String) -> Unit)
}

///|
/// The base interface for all quick input types.
///
/// Quick input provides a unified way for extensions to interact with users through simple UI elements.
/// A quick input UI is initially not visible. After configuring it through its properties the extension
/// can make it visible by calling {@link QuickInput.show show}.
///
/// There are several reasons why this UI might have to be hidden and the extension will be notified
/// through {@link QuickInput.onDidHide onDidHide}. Examples include: an explicit call to
/// {@link QuickInput.hide hide}, the user pressing Esc, some other input UI opening, etc.
///
/// A user pressing Enter or some other gesture implying acceptance of the current state does not
/// automatically hide this UI component. It is up to the extension to decide whether to accept the
/// user's input and if the UI should indeed be hidden through a call to {@link QuickInput.hide hide}.
///
/// When the extension no longer needs this input UI, it should {@link QuickInput.dispose dispose} it
/// to allow for freeing up any resources associated with it.
///
/// See {@link QuickPick} and {@link InputBox} for concrete UIs.
pub type QuickInput

///|
/// A button for an action in a {@link QuickPick} or {@link InputBox}.
pub struct QuickInputButton {
  iconPath : IconPath
  tooltip : String?
}

///|
/// Predefined buttons for {@link QuickPick} and {@link InputBox}.
pub type QuickInputButtons

///|
/// An event describing a button that was pressed on a {@link QuickPickItem}.
pub struct QuickPickItemButtonEvent[T] {
  button : QuickInputButton
  item : T
}

///|
/// Represents a validation message for an {@link InputBox}.
pub struct InputBoxValidationMessage {
  message : String
  severity : InputBoxValidationSeverity
}

///|
pub(all) enum InputBoxValidationSeverity {
  Info = 1
  Warning = 2
  Error = 3
} derive(Eq)

///|

///|
/// Defines the kind of {@link QuickPickItem quick pick item}.
pub(all) enum QuickPickItemKind {
  Separator
  Default
}

///|
/// Represents an item that can be selected from a list of items.
pub(all) struct QuickPickItem {
  mut label : String
  mut kind : QuickPickItemKind?
  mut iconPath : IconPath?
  mut description : String?
  mut detail : String?
  mut resourceUri : Uri?
  mut picked : Bool?
  mut alwaysShow : Bool?
  mut buttons : Array[QuickInputButton]?
}

///|
/// Options to configure the behavior of the {@link WorkspaceFolder workspace folder} pick UI.
pub(all) struct WorkspaceFolderPickOptions {
  mut place_holder : String?
  mut ignore_focus_out : Bool?
}

///|
/// A workspace folder is one of potentially many roots opened by the editor. All workspace folders
/// are equal which means there is no notion of an active or primary workspace folder.
pub type WorkspaceFolder

///|
/// Options to configure the behavior of a file open dialog.
///
/// * Note 1: On Windows and Linux, a file dialog cannot be both a file selector and a folder selector, so if you
/// set both `canSelectFiles` and `canSelectFolders` to `true` on these platforms, a folder selector will be shown.
/// * Note 2: Explicitly setting `canSelectFiles` and `canSelectFolders` to `false` is futile
/// and the editor then silently adjusts the options to select files.
pub(all) struct OpenDialogOptions {
  mut default_uri : Uri?
  mut open_label : String?
  mut can_select_files : Bool?
  mut can_select_folders : Bool?
  mut can_select_many : Bool?
  mut filters : DialogFilters?
  mut title : String?
}

///|
/// Options to configure the behaviour of a file save dialog.
pub(all) struct SaveDialogOptions {
  mut default_uri : Uri?
  mut save_label : String?
  mut filters : DialogFilters?
  mut title : String?
}

///|
/// Options to configure the behavior of the input box UI.
pub(all) struct InputBoxOptions {
  mut title : String?
  mut value : String?
  mut value_selection : Array[Int]?
  mut prompt : String?
  mut place_holder : String?
  mut password : Bool?
  mut ignore_focus_out : Bool?
  validate_input : InputBoxValidateInput?
}

///|
pub(all) enum InputBoxValidateInput {
  Sync((String) -> InputBoxValidationResult?)
  Async(async (String) -> InputBoxValidationResult?)
}

///|
/// A concrete {@link QuickInput} to let the user pick an item from a list of items of type `T`.
///
/// The items can be filtered through a filter text field and there is an option
/// {@link QuickPick.canSelectMany canSelectMany} to allow for selecting multiple items.
///
/// Note that in many cases the more convenient {@link window.showQuickPick} is easier to use.
/// {@link window.createQuickPick} should be used when {@link window.showQuickPick} does not offer
/// the required flexibility.
pub type QuickPick[T]

///|
/// A concrete {@link QuickInput} to let the user input a text value.
///
/// Note that in many cases the more convenient {@link window.showInputBox} is easier to use.
/// {@link window.createInputBox} should be used when {@link window.showInputBox} does not offer
/// the required flexibility.
pub type InputBox

///|
/// An output channel is a container for readonly textual information.
///
/// To get an instance of an `OutputChannel` use
/// {@link window.createOutputChannel createOutputChannel}.
pub type OutputChannel

///|
/// A channel for containing log output.
///
/// To get an instance of a `LogOutputChannel` use
/// {@link window.createOutputChannel createOutputChannel}.
pub type LogOutputChannel

///|
/// Log levels
pub(all) enum LogLevel {
  Off = 0
  Trace = 1
  Debug = 2
  Info = 3
  Warning = 4
  Error = 5
} derive(Eq)

///|
/// A panel that contains a webview.
pub type WebviewPanel

///|
/// Content settings for a webview panel.
pub struct WebviewPanelOptions {
  enable_find_widget : Bool?
  retain_context_when_hidden : Bool?
}

///|
/// Content settings for a webview.
pub struct WebviewOptions {
  enable_scripts : Bool?
  enable_forms : Bool?
  enable_command_uris : CommandUrisValue?
  local_resource_roots : Array[Uri]?
  port_mapping : Array[WebviewPortMapping]?
}

///|
/// Displays html content, similarly to an iframe.
pub type Webview

///|
/// A status bar item is a status bar contribution that can
/// show text and icons and run a command on click.
pub type StatusBarItem

///|
pub(all) enum StatusBarAlignment {
  Left = 1
  Right = 2
}

///|
/// Defines a generalized way of reporting progress updates.
pub type Progress[T]

///|
/// Value-object describing where and how progress should show.
pub(all) struct ProgressOptions {
  location : ProgressLocationValue
  mut title : String?
  mut cancellable : Bool?
}

///|
pub(all) enum ProgressLocation {
  SourceControl = 1
  Window = 10
  Notification = 15
} derive(Eq)

///|
/// Value-object describing what options a terminal should use.
pub type TerminalOptions

///|
/// Value-object describing what options a virtual process terminal should use.
pub type ExtensionTerminalOptions

///|
pub(all) enum TreeDataChange[T] {
  Element(T)
  Elements(Array[T])
  All
}

///|
/// Options for creating a {@link TreeView}
pub type TreeViewOptions[T]

///|
/// Represents a Tree view
pub type TreeView[T]

///|
/// A tree item is an UI element of the tree. Tree items are created by the {@link TreeDataProvider data provider}.
pub type TreeItem

///|
/// The event that is fired when an element in the {@link TreeView} is expanded or collapsed
pub struct TreeViewExpansionEvent[T] {
  element : T
}

///|
/// The event that is fired when there is a change in {@link TreeView.selection tree view's selection}
pub struct TreeViewSelectionChangeEvent[T] {
  selection : Array[T]
}

///|
/// The event that is fired when there is a change in {@link TreeView.visible tree view's visibility}
pub struct TreeViewVisibilityChangeEvent {
  visible : Bool
}

///|
/// An event describing the change in a tree item's checkbox state.
pub struct TreeCheckboxChangeEvent[T] {
  items : Array[TreeCheckboxChangeItem[T]]
}

///|
pub fn[T] TreeCheckboxChangeEvent::new(
  items : Array[TreeCheckboxChangeItem[T]],
) -> TreeCheckboxChangeEvent[T] {
  TreeCheckboxChangeEvent::{ items, }
}

///|
pub struct TreeCheckboxChangeItem[T] {
  element : T
  state : TreeItemCheckboxState
}

///|
pub(all) enum TreeItemCheckboxState {
  Unchecked = 0
  Checked = 1
} derive(Eq)

///|
/// A badge presenting a value for a view
pub struct ViewBadge {
  value : Int
  tooltip : String
}

///|
/// Provides support for drag and drop in `TreeView`.
pub struct TreeDragAndDropController[T] {
  drop_mime_types : Array[String]?
  drag_mime_types : Array[String]?
  preview_item : T?
}

///|
/// A uri handler is responsible for handling system-wide {@link Uri uris}.
///
/// @see {@link window.registerUriHandler}.
pub type UriHandler

///|
/// Restore webview panels that have been persisted when vscode shuts down.
///
/// There are two types of webview persistence:
///
/// - Persistence within a session.
/// - Persistence across sessions (across restarts of the editor).
///
/// A `WebviewPanelSerializer` is only required for the second case: persisting a webview across sessions.
///
/// Persistence within a session allows a webview to save its state when it becomes hidden
/// and restore its content from this state when it becomes visible again. It is powered entirely
/// by the webview content itself. To save off a persisted state, call `acquireVsCodeApi().setState()` with
/// any json serializable object. To restore the state again, call `getState()`
///
/// ```js
/// // Within the webview
/// const vscode = acquireVsCodeApi();
///
/// // Get existing state
/// const oldState = vscode.getState() || { value: 0 };
///
/// // Update state
/// setState({ value: oldState.value + 1 })
/// ```
///
/// A `WebviewPanelSerializer` extends this persistence across restarts of the editor. When the editor is shutdown,
/// it will save off the state from `setState` of all webviews that have a serializer. When the
/// webview first becomes visible after the restart, this state is passed to `deserializeWebviewPanel`.
/// The extension can then restore the old `WebviewPanel` from this state.
///
/// @param T Type of the webview's state.
pub type WebviewPanelSerializer

///|
pub struct WebviewViewOptions {
  retain_context_when_hidden : Bool?
}

///|
/// A webview based view.
pub type WebviewView

///|
/// Additional information the webview view being resolved.
///
/// @param T Type of the webview's state.
pub struct WebviewViewResolveContext {
  state : Any?
}

///|
/// Represents a custom document used by a {@linkcode CustomEditorProvider}.
///
/// Custom documents are only used within a given `CustomEditorProvider`. The lifecycle of a `CustomDocument` is
/// managed by the editor. When no more references remain to a `CustomDocument`, it is disposed of.
pub type CustomDocument

///|
/// Additional information about the opening custom document.
pub struct CustomDocumentOpenContext {
  backupId : String?
  untitledDocumentData : Bytes?
}

///|
/// Additional information used to implement {@linkcode CustomDocumentBackup}.
pub struct CustomDocumentBackupContext {
  destination : Uri
}

///|
/// A backup for an {@linkcode CustomDocument}.
pub type CustomDocumentBackup

///|
/// Event triggered by extensions to signal to the editor that an edit has occurred on an {@linkcode CustomDocument}.
///
/// @see {@linkcode CustomEditorProvider.onDidChangeCustomDocument}.
pub struct CustomDocumentEditEvent[T] {
  document : T
  label : String?
}

///|
/// Event triggered by extensions to signal to the editor that the content of a {@linkcode CustomDocument}
/// has changed.
///
/// @see {@linkcode CustomEditorProvider.onDidChangeCustomDocument}.
pub struct CustomDocumentContentChangeEvent[T] {
  document : T
}

///|
pub struct CustomEditorProviderOptions {
  webview_options : WebviewPanelOptions?
  supports_multiple_editors_per_document : Bool?
}

///|
/// Provides information on a line in a terminal in order to provide links for it.
pub(all) struct TerminalLinkContext {
  mut line : String
  mut terminal : Terminal
}

///|
/// A link on a terminal line.
pub type TerminalLink

///|
/// A terminal profile defines how a terminal will be launched.
pub type TerminalProfile

///|
/// A file decoration represents metadata that can be rendered with a file.
pub type FileDecoration

///|
pub(all) enum FileDecorationChange {
  UriValue(Uri)
  Uris(Array[Uri])
  All
}

///|
pub fn FileDecorationChange::from_uri(value : Uri) -> FileDecorationChange {
  UriValue(value)
}

///|
pub fn FileDecorationChange::from_uris(
  value : Array[Uri],
) -> FileDecorationChange {
  Uris(value)
}

///|
pub fn FileDecorationChange::all() -> FileDecorationChange {
  All
}

///|
/// Represents a color theme.
pub type ColorTheme

///|
pub(all) enum ColorThemeKind {
  Light = 1
  Dark = 2
  HighContrast = 3
  HighContrastLight = 4
} derive(Eq)

///|
/// A collection of {@link Comment comments} representing a conversation at a particular range in a document.
pub type CommentThread

///|
/// Collapsible state of a {@link CommentThread comment thread}
pub(all) enum CommentThreadCollapsibleState {
  Collapsed = 0
  Expanded = 1
} derive(Eq)

///|
/// Comment mode of a {@link Comment}
pub(all) enum CommentMode {
  Editing = 0
  Preview = 1
} derive(Eq)

///|
/// The state of a comment thread.
pub(all) enum CommentThreadState {
  Unresolved = 0
  Resolved = 1
} derive(Eq)

///|
/// Author information of a {@link Comment}
pub(all) struct CommentAuthorInformation {
  mut name : String
  mut iconPath : Uri?
}

///|
/// Reactions of a {@link Comment}
pub struct CommentReaction {
  label : String
  iconPath : StringOrUri
  count : Int
  authorHasReacted : Bool
}

///|
/// A comment is displayed within the editor or the Comments Panel, depending on how it is provided.
pub(all) struct Comment {
  mut body : MarkdownStringValue
  mut mode : CommentMode
  mut author : CommentAuthorInformation
  mut context_value : String?
  mut reactions : Array[CommentReaction]?
  mut label : String?
  mut timestamp : Date?
}

///|
/// Command argument for actions registered in `comments/commentThread/context`.
pub(all) struct CommentReply {
  mut thread : CommentThread
  mut text : String
}

///|
/// The ranges a CommentingRangeProvider enables commenting on.
pub(all) struct CommentingRanges {
  mut enableFileComments : Bool
  mut ranges : Array[Range]?
}

///|
/// Represents a {@link CommentController comment controller}'s {@link CommentController.options options}.
pub(all) struct CommentOptions {
  mut prompt : String?
  mut placeHolder : String?
}

///|
/// A comment controller is able to provide {@link CommentThread comments} support to the editor and
/// provide users various ways to interact with comments.
pub type CommentController

///|
/// Workspace types
pub type FileSystem

///|
/// The `FileStat`-type represents metadata about a file
pub(all) struct FileStat {
  file_type : FileType
  mut ctime : Int
  mut mtime : Int
  mut size : Int
  mut permissions : FilePermission?
}

///|
pub(all) enum FileType {
  Unknown = 0
  File = 1
  Directory = 2
  SymbolicLink = 64
} derive(Eq)

///|
pub(all) enum FilePermission {
  Readonly = 1
} derive(Eq)

///|
pub struct DirectoryEntry {
  name : String
  file_type : FileType
}

///|
pub(all) enum FileChangeType {
  Created = 1
  Changed = 2
  Deleted = 3
} derive(Eq)

///|
/// A type that filesystem providers should use to signal errors.
///
/// This class has factory methods for common error-cases, like `FileNotFound` when
/// a file or folder doesn't exist, use them like so: `throw vscode.FileSystemError.FileNotFound(someUri);`
pub type FileSystemError

///|
/// An event describing a change to the set of {@link workspace.workspaceFolders workspace folders}.
pub struct WorkspaceFoldersChangeEvent {
  added : Array[WorkspaceFolder]
  removed : Array[WorkspaceFolder]
}

///|
/// A relative pattern is a helper to construct glob patterns that are matched
/// relatively to a base file path. The base path can either be an absolute file
/// path as string or uri or a {@link WorkspaceFolder workspace folder}, which is the
/// preferred way of creating the relative pattern.
pub type RelativePattern

///|
/// A file glob pattern to match file paths against. This can either be a glob pattern string
/// (like `**​/*.{ts,js}` or `*.{ts,js}`) or a {@link RelativePattern relative pattern}.
///
/// Glob patterns can have the following syntax:
/// * `*` to match zero or more characters in a path segment
/// * `?` to match on one character in a path segment
/// * `**` to match any number of path segments, including none
/// * `{}` to group conditions (e.g. `**​/*.{ts,js}` matches all TypeScript and JavaScript files)
/// * `[]` to declare a range of characters to match in a path segment (e.g., `example.[0-9]` to match on `example.0`, `example.1`, …)
/// * `[!...]` to negate a range of characters to match in a path segment (e.g., `example.[!0-9]` to match on `example.a`, `example.b`, but not `example.0`)
///
/// Note: a backslash (`\`) is not valid within a glob pattern. If you have an existing file
/// path to match against, consider to use the {@link RelativePattern relative pattern} support
/// that takes care of converting any backslash into slash. Otherwise, make sure to convert
/// any backslash to slash when creating the glob pattern.
pub(all) enum GlobPattern {
  Text(String)
  Relative(RelativePattern)
}

///|
/// A file system watcher notifies about changes to files and folders
/// on disk or from other {@link FileSystemProvider FileSystemProviders}.
///
/// To get an instance of a `FileSystemWatcher` use
/// {@link workspace.createFileSystemWatcher createFileSystemWatcher}.
pub type FileSystemWatcher

///|
pub fn FileStat::new(
  file_type : FileType,
  ctime : Int,
  mtime : Int,
  size : Int,
  permissions? : FilePermission,
) -> FileStat {
  FileStat::{ file_type, ctime, mtime, size, permissions }
}

///|

///|
/// The creation timestamp in milliseconds elapsed since January 1, 1970 00:00:00 UTC.

///|
/// The modification timestamp in milliseconds elapsed since January 1, 1970 00:00:00 UTC.
///
/// *Note:* If the file changed, it is important to provide an updated `mtime` that advanced
/// from the previous value. Otherwise there may be optimizations in place that will not show
/// the updated file contents in an editor for example.

///|
/// The size in bytes.
///
/// *Note:* If the file changed, it is important to provide an updated `size`. Otherwise there
/// may be optimizations in place that will not show the updated file contents in an editor for
/// example.

///|
/// The permissions of the file, e.g. whether the file is readonly.
///
/// *Note:* This value might be a bitmask, e.g. `FilePermission.Readonly | FilePermission.Other`.
fn FileStat::from_js(raw : JsValue) -> FileStat {
  let raw_permissions = file_stat_permissions_raw(raw)
  FileStat::{
    file_type: file_stat_type_raw(raw),
    ctime: file_stat_ctime_raw(raw),
    mtime: file_stat_mtime_raw(raw),
    size: file_stat_size_raw(raw),
    permissions: if JsValue::is_null_or_undefined(raw_permissions) {
      None
    } else {
      Some(raw_permissions.cast())
    },
  }
}

///|
/// Creates a new filesystem error.
///
/// @param messageOrUri Message or uri.
pub fn FileSystemError::new(message_or_uri? : StringOrUri) -> FileSystemError {
  file_system_error_new_ffi(option_string_or_uri_to_js(message_or_uri))
}

///|
pub fn FileSystemError::file_not_found(
  message_or_uri? : StringOrUri,
) -> FileSystemError {
  file_system_error_file_not_found_ffi(
    option_string_or_uri_to_js(message_or_uri),
  )
}

///|
pub fn FileSystemError::file_exists(
  message_or_uri? : StringOrUri,
) -> FileSystemError {
  file_system_error_file_exists_ffi(option_string_or_uri_to_js(message_or_uri))
}

///|
pub fn FileSystemError::file_not_a_directory(
  message_or_uri? : StringOrUri,
) -> FileSystemError {
  file_system_error_file_not_a_directory_ffi(
    option_string_or_uri_to_js(message_or_uri),
  )
}

///|
pub fn FileSystemError::file_is_a_directory(
  message_or_uri? : StringOrUri,
) -> FileSystemError {
  file_system_error_file_is_a_directory_ffi(
    option_string_or_uri_to_js(message_or_uri),
  )
}

///|
pub fn FileSystemError::no_permissions(
  message_or_uri? : StringOrUri,
) -> FileSystemError {
  file_system_error_no_permissions_ffi(
    option_string_or_uri_to_js(message_or_uri),
  )
}

///|
pub fn FileSystemError::unavailable(
  message_or_uri? : StringOrUri,
) -> FileSystemError {
  file_system_error_unavailable_ffi(option_string_or_uri_to_js(message_or_uri))
}

///|
/// A code that identifies this error.
///
/// Possible values are names of errors, like {@linkcode FileSystemError.FileNotFound FileNotFound},
/// or `Unknown` for unspecified errors.
pub extern "js" fn FileSystemError::code(self : FileSystemError) -> String =
  #| (error) => error.code

///|
/// A workspace edit is a collection of textual and files changes for
/// multiple resources and documents.
///
/// Use the {@link workspace.applyEdit applyEdit}-function to apply a workspace edit.
pub type WorkspaceEdit

///|
/// Additional data about a workspace edit.
pub(all) struct WorkspaceEditMetadata {
  mut is_refactoring : Bool?
}

///|
/// Additional data for entries of a workspace edit. Supports to label entries and marks entries
/// as needing confirmation by the user. The editor groups edits with equal labels into tree nodes,
/// for instance all edits labelled with "Changes in Strings" would be a tree node.
pub(all) struct WorkspaceEditEntryMetadata {
  mut label : String
  mut needs_confirmation : Bool
  mut description : String?
  mut icon_path : IconPath?
}

///|
pub(all) enum WorkspaceEditFileContents {
  BytesValue(Bytes)
  FileValue(DataTransferFile)
}

///|
fn WorkspaceEditFileContents::to_js(
  self : WorkspaceEditFileContents,
) -> JsValue {
  match self {
    BytesValue(value) => JsValue::make(bytes_to_uint8_array(value))
    FileValue(value) => JsValue::make(value)
  }
}

///|
fn option_workspace_edit_file_contents_to_js(
  value : WorkspaceEditFileContents?,
) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
}

///|
pub struct WorkspaceEditCreateFileOptions {
  overwrite : Bool?
  ignore_if_exists : Bool?
  contents : WorkspaceEditFileContents?
}

///|
pub fn WorkspaceEditCreateFileOptions::new(
  overwrite? : Bool,
  ignore_if_exists? : Bool,
  contents? : WorkspaceEditFileContents,
) -> WorkspaceEditCreateFileOptions {
  WorkspaceEditCreateFileOptions::{ overwrite, ignore_if_exists, contents }
}

///|
pub struct WorkspaceEditDeleteFileOptions {
  recursive : Bool?
  ignore_if_not_exists : Bool?
}

///|
pub fn WorkspaceEditDeleteFileOptions::new(
  recursive? : Bool,
  ignore_if_not_exists? : Bool,
) -> WorkspaceEditDeleteFileOptions {
  WorkspaceEditDeleteFileOptions::{ recursive, ignore_if_not_exists }
}

///|
pub struct WorkspaceEditRenameFileOptions {
  overwrite : Bool?
  ignore_if_exists : Bool?
}

///|
pub fn WorkspaceEditRenameFileOptions::new(
  overwrite? : Bool,
  ignore_if_exists? : Bool,
) -> WorkspaceEditRenameFileOptions {
  WorkspaceEditRenameFileOptions::{ overwrite, ignore_if_exists }
}

///|
/// A text edit represents edits that should be applied
/// to a document.
pub type TextEdit

///|
/// A snippet edit represents an interactive edit that is performed by
/// the editor.
///
/// *Note* that a snippet edit can always be performed as a normal {@link TextEdit text edit}.
/// This will happen when no matching editor is open or when a {@link WorkspaceEdit workspace edit}
/// contains snippet edits for multiple files. In that case only those that match the active editor
/// will be performed as snippet edits and the others as normal text edits.
pub type SnippetTextEdit

///|
/// A notebook edit represents edits that should be applied to the contents of a notebook.
pub type NotebookEdit

///|
/// Represents an icon in the UI. This is either an uri, separate uris for the light- and dark-themes,
/// or a {@link ThemeIcon theme icon}.
pub(all) enum IconPath {
  UriValue(Uri)
  LightDarkValue(IconPathLightDark)
  ThemeIconValue(ThemeIcon)
}

///|
pub struct IconPathLightDark {
  light : Uri
  dark : Uri
}

///|
/// A reference to one of the workbench colors as defined in https://code.visualstudio.com/api/references/theme-color.
/// Using a theme color is preferred over a custom color as it gives theme authors and users the possibility to change the color.
pub type ThemeColor

///|
/// A reference to a named icon. Currently, {@link ThemeIcon.File File}, {@link ThemeIcon.Folder Folder},
/// and [ThemeIcon ids](https://code.visualstudio.com/api/references/icons-in-labels#icon-listing) are supported.
/// Using a theme icon is preferred over a custom icon as it gives product theme authors the possibility to change the icons.
///
/// *Note* that theme icons can also be rendered inside labels and descriptions. Places that support theme icons spell this out
/// and they use the `$(<name>)`-syntax, for instance `quickPick.label = "Hello World $(globe)"`.
pub type ThemeIcon

///|
/// An event describing a transactional {@link TextDocument document} change.
pub struct TextDocumentChangeEvent {
  document : TextDocument
  contentChanges : Array[TextDocumentContentChangeEvent]
  reason : TextDocumentChangeReason?
}

///|
/// An event that is fired when a {@link TextDocument document} will be saved.
///
/// To make modifications to the document before it is being saved, call the
/// {@linkcode TextDocumentWillSaveEvent.waitUntil waitUntil}-function with a thenable
/// that resolves to an array of {@link TextEdit text edits}.
pub struct TextDocumentWillSaveEvent {
  token : CancellationToken
  document : TextDocument
  reason : TextDocumentSaveReason
}

///|
/// An event describing an individual change in the text of a {@link TextDocument document}.
pub struct TextDocumentContentChangeEvent {
  range : Range
  rangeOffset : Int
  rangeLength : Int
  text : String
}

///|
/// Reasons for why a text document has changed.
pub(all) enum TextDocumentChangeReason {
  Undo = 1
  Redo = 2
} derive(Eq)

///|
/// Represents reasons why a text document is saved.
pub(all) enum TextDocumentSaveReason {
  Manual = 1
  AfterDelay = 2
  FocusOut = 3
} derive(Eq)

///|
/// An event describing a transactional {@link NotebookDocument notebook} change.
pub struct NotebookDocumentChangeEvent {
  notebook : NotebookDocument
  metadata : Any?
  contentChanges : Array[NotebookDocumentContentChange]
  cellChanges : Array[NotebookDocumentCellChange]
}

///|
/// Describes a structural change to a notebook document, e.g newly added and removed cells.
///
/// @see {@link NotebookDocumentChangeEvent}
pub struct NotebookDocumentContentChange {
  range : NotebookRange
  addedCells : Array[NotebookCell]
  removedCells : Array[NotebookCell]
}

///|
/// Describes a change to a notebook cell.
///
/// @see {@link NotebookDocumentChangeEvent}
pub struct NotebookDocumentCellChange {
  cell : NotebookCell
  document : TextDocument?
  metadata : Any?
  outputs : Array[NotebookCellOutput]?
  executionSummary : NotebookCellExecutionSummary?
}

///|
/// An event that is fired when a {@link NotebookDocument notebook document} will be saved.
///
/// To make modifications to the document before it is being saved, call the
/// {@linkcode NotebookDocumentWillSaveEvent.waitUntil waitUntil}-function with a thenable
/// that resolves to a {@link WorkspaceEdit workspace edit}.
pub struct NotebookDocumentWillSaveEvent {
  token : CancellationToken
  notebook : NotebookDocument
  reason : TextDocumentSaveReason
}

///|
/// The notebook serializer enables the editor to open notebook files.
///
/// At its core the editor only knows a {@link NotebookData notebook data structure} but not
/// how that data structure is written to a file, nor how it is read from a file. The
/// notebook serializer bridges this gap by deserializing bytes into notebook data and
/// vice versa.
pub type NotebookSerializer

///|
/// Notebook content options define what parts of a notebook are persisted. Note
///
/// For instance, a notebook serializer can opt-out of saving outputs and in that case the editor doesn't mark a
/// notebooks as {@link NotebookDocument.isDirty dirty} when its output has changed.
pub(all) struct NotebookDocumentContentOptions {
  mut transient_outputs : Bool?
  mut transient_cell_metadata : Array[(String, Bool)]?
  mut transient_document_metadata : Array[(String, Bool)]?
}

///|
/// An event that is fired when files are going to be created.
///
/// To make modifications to the workspace before the files are created,
/// call the {@linkcode FileWillCreateEvent.waitUntil waitUntil}-function with a
/// thenable that resolves to a {@link WorkspaceEdit workspace edit}.
pub struct FileWillCreateEvent {
  files : Array[Uri]
  token : CancellationToken
}

///|
/// An event that is fired after files are created.
pub struct FileCreateEvent {
  files : Array[Uri]
}

///|
/// An event that is fired when files are going to be deleted.
///
/// To make modifications to the workspace before the files are deleted,
/// call the {@link FileWillCreateEvent.waitUntil `waitUntil`}-function with a
/// thenable that resolves to a {@link WorkspaceEdit workspace edit}.
pub struct FileWillDeleteEvent {
  files : Array[Uri]
  token : CancellationToken
}

///|
/// An event that is fired after files are deleted.
pub struct FileDeleteEvent {
  files : Array[Uri]
}

///|
/// An event that is fired when files are going to be renamed.
///
/// To make modifications to the workspace before the files are renamed,
/// call the {@link FileWillCreateEvent.waitUntil `waitUntil`}-function with a
/// thenable that resolves to a {@link WorkspaceEdit workspace edit}.
pub struct FileWillRenameEvent {
  files : Array[FileRenameEventEntry]
  token : CancellationToken
}

///|
/// An event that is fired after files are renamed.
pub struct FileRenameEvent {
  files : Array[FileRenameEventEntry]
}

///|
pub struct FileRenameEventEntry {
  oldUri : Uri
  newUri : Uri
}

///|
/// The event filesystem providers must use to signal a file change.
pub struct FileChangeEvent {
  uri : Uri
  type_ : FileChangeType
}

///|
/// The configuration scope which can be:
/// - a {@link Uri} representing a resource
/// - a {@link TextDocument} representing an open text document
/// - a {@link WorkspaceFolder} representing a workspace folder
/// - an object containing:
///   - `uri`: an optional {@link Uri} of a text document
///   - `languageId`: the language identifier of a text document
pub(all) enum ConfigurationScope {
  Uri(Uri)
  WorkspaceFolderScope(WorkspaceFolder)
  TextEditorScope(TextEditor)
  TextDocumentScope(TextDocument)
  LanguageId(String)
  Global
}

///|
/// The configuration target
pub(all) enum ConfigurationTarget {
  Global = 1
  Workspace = 2
  WorkspaceFolder = 3
} derive(Eq)

///|
pub(all) enum ConfigurationTargetValue {
  Target(ConfigurationTarget)
  BoolValue(Bool)
}

///|
fn ConfigurationTargetValue::to_js(self : ConfigurationTargetValue) -> JsValue {
  match self {
    Target(value) => JsValue::make(value)
    BoolValue(value) => JsValue::make(value)
  }
}

///|
fn option_configuration_target_value_to_js(
  value : ConfigurationTargetValue?,
) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
}

///|
/// Represents the configuration. It is a merged view of
///
/// - *Default Settings*
/// - *Global (User) Settings*
/// - *Workspace settings*
/// - *Workspace Folder settings* - From one of the {@link workspace.workspaceFolders Workspace Folders} under which requested resource belongs to.
/// - *Language settings* - Settings defined under requested language.
///
/// The *effective* value (returned by {@linkcode WorkspaceConfiguration.get get}) is computed by overriding or merging the values in the following order:
///
/// 1. `defaultValue` (if defined in `package.json` otherwise derived from the value's type)
/// 1. `globalValue` (if defined)
/// 1. `workspaceValue` (if defined)
/// 1. `workspaceFolderValue` (if defined)
/// 1. `defaultLanguageValue` (if defined)
/// 1. `globalLanguageValue` (if defined)
/// 1. `workspaceLanguageValue` (if defined)
/// 1. `workspaceFolderLanguageValue` (if defined)
///
/// **Note:** Only `object` value types are merged and all other value types are overridden.
///
/// Example 1: Overriding
///
/// ```ts
/// defaultValue = 'on';
/// globalValue = 'relative'
/// workspaceFolderValue = 'off'
/// value = 'off'
/// ```
///
/// Example 2: Language Values
///
/// ```ts
/// defaultValue = 'on';
/// globalValue = 'relative'
/// workspaceFolderValue = 'off'
/// globalLanguageValue = 'on'
/// value = 'on'
/// ```
///
/// Example 3: Object Values
///
/// ```ts
/// defaultValue = { "a": 1, "b": 2 };
/// globalValue = { "b": 3, "c": 4 };
/// value = { "a": 1, "b": 3, "c": 4 };
/// ```
///
/// *Note:* Workspace and Workspace Folder configurations contains `launch` and `tasks` settings. Their basename will be
/// part of the section identifier. The following snippets shows how to retrieve all configurations
/// from `launch.json`:
///
/// ```ts
/// // launch.json configuration
/// const config = workspace.getConfiguration('launch', vscode.workspace.workspaceFolders[0].uri);
///
/// // retrieve values
/// const values = config.get('configurations');
/// ```
///
/// Refer to [Settings](https://code.visualstudio.com/docs/getstarted/settings) for more information.
pub type WorkspaceConfiguration

///|
pub struct ConfigurationInspect[T] {
  key : String
  default_value : T?
  global_value : T?
  workspace_value : T?
  workspace_folder_value : T?
  default_language_value : T?
  global_language_value : T?
  workspace_language_value : T?
  workspace_folder_language_value : T?
  language_ids : Array[String]?
}

///|
/// An event describing the change in Configuration
pub type ConfigurationChangeEvent

///|
pub struct WorkspaceFolderInput {
  uri : Uri
  name : String?
}

///|
/// Human-readable text that supports formatting via the [markdown syntax](https://commonmark.org).
///
/// Rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax is supported
/// when the {@linkcode supportThemeIcons} is set to `true`.
///
/// Rendering of embedded html is supported when {@linkcode supportHtml} is set to `true`.
pub type MarkdownString

///|
/// MarkedString can be used to render human-readable text. It is either a markdown string
/// or a code-block that provides a language and a code snippet. Note that
/// markdown strings will be sanitized - that means html will be escaped.
///
/// @deprecated This type is deprecated, please use {@linkcode MarkdownString} instead.
pub struct MarkedString {
  language : String
  value : String
}

///|
/// A hover represents additional information for a symbol or word. Hovers are
/// rendered in a tooltip-like widget.
pub type Hover

///|
/// Represents a parameter of a callable-signature. A parameter can
/// have a label and a doc-comment.
pub type ParameterInformation

///|
/// Represents the signature of something callable. A signature
/// can have a label, like a function-name, a doc-comment, and
/// a set of parameters.
pub type SignatureInformation

///|
/// Signature help represents the signature of something
/// callable. There can be multiple signatures but only one
/// active and only one active parameter.
pub type SignatureHelp

///|
/// How a {@linkcode SignatureHelpProvider} was triggered.
pub(all) enum SignatureHelpTriggerKind {
  Invoke = 1
  TriggerCharacter = 2
  ContentChange = 3
} derive(Eq)

///|
/// Additional information about the context in which a
/// {@linkcode SignatureHelpProvider.provideSignatureHelp SignatureHelpProvider} was triggered.
pub struct SignatureHelpContext {
  triggerKind : SignatureHelpTriggerKind
  triggerCharacter : String?
  isRetrigger : Bool
  activeSignatureHelp : SignatureHelp?
}

///|
/// Metadata about a registered {@linkcode SignatureHelpProvider}.
pub struct SignatureHelpProviderMetadata {
  trigger_characters : Array[String]
  retrigger_characters : Array[String]?
}

///|
/// A completion item represents a text snippet that is proposed to complete text that is being typed.
///
/// It is sufficient to create a completion item from just a {@link CompletionItem.label label}. In that
/// case the completion item will replace the {@link TextDocument.getWordRangeAtPosition word}
/// until the cursor with the given label or {@link CompletionItem.insertText insertText}. Otherwise the
/// given {@link CompletionItem.textEdit edit} is used.
///
/// When selecting a completion item in the editor its defined or synthesized text edit will be applied
/// to *all* cursors/selections whereas {@link CompletionItem.additionalTextEdits additionalTextEdits} will be
/// applied as provided.
///
/// @see {@link CompletionItemProvider.provideCompletionItems}
/// @see {@link CompletionItemProvider.resolveCompletionItem}
pub type CompletionItem

///|
/// A structured label for a {@link CompletionItem completion item}.
pub(all) struct CompletionItemLabel {
  mut label : String
  mut detail : String?
  mut description : String?
}

///|
/// Represents a collection of {@link CompletionItem completion items} to be presented
/// in the editor.
pub type CompletionList[T]

///|
/// Completion item kinds.
pub(all) enum CompletionItemKind {
  Text = 0
  Method = 1
  Function = 2
  Constructor = 3
  Field = 4
  Variable = 5
  Class = 6
  Interface = 7
  Module = 8
  Property = 9
  Unit = 10
  Value = 11
  Enum = 12
  Keyword = 13
  Snippet = 14
  Color = 15
  File = 16
  Reference = 17
  Folder = 18
  EnumMember = 19
  Constant = 20
  Struct = 21
  Event = 22
  Operator = 23
  TypeParameter = 24
  User = 25
  Issue = 26
} derive(Eq)

///|
/// Completion item tags are extra annotations that tweak the rendering of a completion
/// item.
pub(all) enum CompletionItemTag {
  Deprecated = 1
} derive(Eq)

///|
/// Contains additional information about the context in which
/// {@link CompletionItemProvider.provideCompletionItems completion provider} is triggered.
pub struct CompletionContext {
  trigger_kind : CompletionTriggerKind
  trigger_character : String?
}

///|
/// How a {@link CompletionItemProvider completion provider} was triggered
pub(all) enum CompletionTriggerKind {
  Invoke = 0
  TriggerCharacter = 1
  TriggerForIncompleteCompletions = 2
} derive(Eq)

///|
/// A document highlight is a range inside a text document which deserves
/// special attention. Usually a document highlight is visualized by changing
/// the background color of its range.
pub type DocumentHighlight

///|
/// A document highlight kind.
pub(all) enum DocumentHighlightKind {
  Text = 0
  Read = 1
  Write = 2
} derive(Eq)

///|
/// Kind of a code action.
///
/// Kinds are a hierarchical list of identifiers separated by `.`, e.g. `"refactor.extract.function"`.
///
/// Code action kinds are used by the editor for UI elements such as the refactoring context menu. Users
/// can also trigger code actions with a specific kind with the `editor.action.codeAction` command.
pub(all) enum CodeActionKind {
  Empty
  QuickFix
  Refactor
  RefactorExtract
  RefactorInline
  RefactorMove
  RefactorRewrite
  Source
  SourceOrganizeImports
  SourceFixAll
  Notebook
  Custom(String)
} derive(Eq)

///|
/// The reason why code actions were requested.
pub(all) enum CodeActionTriggerKind {
  Invoke = 1
  Automatic = 2
} derive(Eq)

///|
/// Contains additional diagnostic information about the context in which
/// a {@link CodeActionProvider.provideCodeActions code action} is run.
pub struct CodeActionContext {
  diagnostics : Array[Diagnostic]
  only : CodeActionKind?
  trigger_kind : CodeActionTriggerKind
}

///|
/// A code action represents a change that can be performed in code, e.g. to fix a problem or
/// to refactor code.
///
/// A CodeAction must set either {@linkcode CodeAction.edit edit} and/or a {@linkcode CodeAction.command command}. If both are supplied, the `edit` is applied first, then the command is executed.
pub type CodeAction

///|
/// Metadata about the type of code actions that a {@link CodeActionProvider} provides.
pub struct CodeActionProviderMetadata {
  provided_kinds : Array[CodeActionKind]?
}

///|
/// Value-object describing what options formatting should use.
pub(all) struct FormattingOptions {
  mut tab_size : Int
  mut insert_spaces : Bool
}

///|
/// A document link is a range in a text document that links to an internal or external resource, like another
/// text document or a web site.
pub type DocumentLink

///|
/// A code lens represents a {@link Command} that should be shown along with
/// source text, like the number of references, a way to run tests, etc.
///
/// A code lens is _unresolved_ when no command is associated to it. For performance
/// reasons the creation of a code lens and resolving should be done to two stages.
///
/// @see {@link CodeLensProvider.provideCodeLenses}
/// @see {@link CodeLensProvider.resolveCodeLens}
pub type CodeLens

///|
/// Represents a color in RGBA space.
pub type Color

///|
/// Represents a color range from a document.
pub type ColorInformation

///|
/// A color presentation object describes how a {@linkcode Color} should be represented as text and what
/// edits are required to refer to it from source code.
///
/// For some languages one color can have multiple presentations, e.g. css can represent the color red with
/// the constant `Red`, the hex-value `#ff0000`, or in rgba and hsla forms. In csharp other representations
/// apply, e.g. `System.Drawing.Color.Red`.
pub type ColorPresentation

///|
pub struct ColorPresentationContext {
  document : TextDocument
  range : Range
}

///|
/// A line based folding range. To be valid, start and end line must be bigger than zero and smaller than the number of lines in the document.
/// Invalid ranges will be ignored.
pub type FoldingRange

///|
/// An enumeration of specific folding range kinds. The kind is an optional field of a {@link FoldingRange}
/// and is used to distinguish specific folding ranges such as ranges originated from comments. The kind is used by commands like
/// `Fold all comments` or `Fold all regions`.
/// If the kind is not set on the range, the range originated from a syntax element other than comments, imports or region markers.
pub(all) enum FoldingRangeKind {
  Comment
  Imports
  Region
} derive(Eq)

///|
/// Folding context (for future use)
pub struct FoldingContext {
  max_ranges : Int
}

///|
/// A symbol kind.
pub(all) enum SymbolKind {
  File = 0
  Module = 1
  Namespace = 2
  Package = 3
  Class = 4
  Method = 5
  Property = 6
  Field = 7
  Constructor = 8
  Enum = 9
  Interface = 10
  Function = 11
  Variable = 12
  Constant = 13
  String = 14
  Number = 15
  Boolean = 16
  Array = 17
  Object = 18
  Key = 19
  Null = 20
  EnumMember = 21
  Struct = 22
  Event = 23
  Operator = 24
  TypeParameter = 25
} derive(Eq)

///|
/// Symbol tags are extra annotations that tweak the rendering of a symbol.
pub(all) enum SymbolTag {
  Deprecated = 1
} derive(Eq)

///|
/// Represents information about programming constructs like variables, classes,
/// interfaces etc.
pub type SymbolInformation

///|
/// Represents programming constructs like variables, classes, interfaces etc. that appear in a document. Document
/// symbols can be hierarchical and they have two ranges: one that encloses its definition and one that points to
/// its most interesting range, e.g. the range of an identifier.
pub type DocumentSymbol

///|
/// Metadata about a document symbol provider.
pub(all) struct DocumentSymbolProviderMetadata {
  mut label : String?
}

///|
/// Represents programming constructs like functions or constructors in the context
/// of call hierarchy.
pub type CallHierarchyItem

///|
/// Represents an incoming call, e.g. a caller of a method or constructor.
pub type CallHierarchyIncomingCall

///|
/// Represents an outgoing call, e.g. calling a getter from a method or a method from a constructor etc.
pub type CallHierarchyOutgoingCall

///|
/// Represents an item of a type hierarchy, like a class or an interface.
pub type TypeHierarchyItem

///|
/// Value-object that contains additional information when
/// requesting references.
pub struct ReferenceContext {
  includeDeclaration : Bool
}

///|
/// Inlay hint information.
pub type InlayHint

///|
/// An inlay hint label part allows for interactive and composite labels of inlay hints.
pub type InlayHintLabelPart

///|
/// Inlay hint kinds.
///
/// The kind of an inline hint defines its appearance, e.g the corresponding foreground and background colors are being
/// used.
pub(all) enum InlayHintKind {
  Type = 1
  Parameter = 2
} derive(Eq)

///|
/// Creates a new inlay hint label part.
///
/// @param value The value of the part.
pub fn InlayHintLabelPart::new(value : String) -> InlayHintLabelPart {
  inlay_hint_label_part_ffi(value)
}

///|
/// The value of this label part.
pub extern "js" fn InlayHintLabelPart::value(
  self : InlayHintLabelPart,
) -> String =
  #| (value) => value.value

///|
/// A semantic tokens legend contains the needed information to decipher
/// the integer encoded representation of semantic tokens.
pub type SemanticTokensLegend

///|
/// A semantic tokens builder can help with creating a `SemanticTokens` instance
/// which contains delta encoded semantic tokens.
pub type SemanticTokensBuilder

///|
/// Represents semantic tokens, either in a range or in an entire document.
/// @see {@link DocumentSemanticTokensProvider.provideDocumentSemanticTokens provideDocumentSemanticTokens} for an explanation of the format.
/// @see {@link SemanticTokensBuilder} for a helper to create an instance.
pub type SemanticTokens

///|
/// Represents an edit to semantic tokens.
/// @see {@link DocumentSemanticTokensProvider.provideDocumentSemanticTokensEdits provideDocumentSemanticTokensEdits} for an explanation of the format.
pub type SemanticTokensEdit

///|
/// Represents edits to semantic tokens.
/// @see {@link DocumentSemanticTokensProvider.provideDocumentSemanticTokensEdits provideDocumentSemanticTokensEdits} for an explanation of the format.
pub type SemanticTokensEdits

///|
/// Represents a collection of {@link InlineCompletionItem inline completion items} to be presented
/// in the editor.
pub type InlineCompletionList

///|
/// Provides information about the context in which an inline completion was requested.
pub struct InlineCompletionContext {
  trigger_kind : InlineCompletionTriggerKind
  selected_info : SelectedCompletionInfo?
}

///|
/// Describes how an {@link InlineCompletionItemProvider inline completion provider} was triggered.
pub(all) enum InlineCompletionTriggerKind {
  Invoke = 0
  Automatic = 1
} derive(Eq)

///|
/// An inline completion item represents a text snippet that is proposed inline to complete text that is being typed.
///
/// @see {@link InlineCompletionItemProvider.provideInlineCompletionItems}
pub type InlineCompletionItem

///|
/// Describes the currently selected completion item.
pub struct SelectedCompletionInfo {
  range : Range
  text : String
}

///|
/// Inline value information can be provided by different means:
/// - directly as a text value (class InlineValueText).
/// - as a name to use for a variable lookup (class InlineValueVariableLookup)
/// - as an evaluatable expression (class InlineValueEvaluatableExpression)
/// The InlineValue types combines all inline value types into one type.
pub(all) enum InlineValue {
  Text(InlineValueText)
  VariableLookup(InlineValueVariableLookup)
  EvaluatableExpression(InlineValueEvaluatableExpression)
}

///|
/// Provide inline value as text.
pub type InlineValueText

///|
/// Provide inline value through a variable lookup.
/// If only a range is specified, the variable name will be extracted from the underlying document.
/// An optional variable name can be used to override the extracted name.
pub type InlineValueVariableLookup

///|
/// Provide an inline value through an expression evaluation.
/// If only a range is specified, the expression will be extracted from the underlying document.
/// An optional expression can be used to override the extracted expression.
pub type InlineValueEvaluatableExpression

///|
/// A value-object that contains contextual information when requesting inline values from a InlineValuesProvider.
pub struct InlineValueContext {
  frame_id : Int
  stopped_location : Range
}

///|
pub(all) enum DocumentDropOrPasteEditKind {
  Empty
  Text
  TextUpdateImports
  Custom(String)
}

///|
/// An edit operation applied {@link DocumentDropEditProvider on drop}.
pub type DocumentDropEdit

///|
/// Provides additional metadata about how a {@linkcode DocumentDropEditProvider} works.
pub struct DocumentDropEditProviderMetadata {
  provided_kinds : Array[DocumentDropOrPasteEditKind]?
  drop_mime_types : Array[String]
}

///|
/// The reason why paste edits were requested.
pub(all) enum DocumentPasteTriggerKind {
  Automatic = 0
  PasteAs = 1
} derive(Eq)

///|
/// Additional information about the paste operation.
pub struct DocumentPasteEditContext {
  trigger_kind : DocumentPasteTriggerKind
  only : DocumentDropOrPasteEditKind?
}

///|
/// An edit the applies a paste operation.
pub type DocumentPasteEdit

///|
/// Provides additional metadata about how a {@linkcode DocumentPasteEditProvider} works.
pub struct DocumentPasteProviderMetadata {
  provided_kinds : Array[DocumentDropOrPasteEditKind]
  copy_mime_types : Array[String]?
  paste_mime_types : Array[String]?
}

///|
/// A map containing a mapping of the mime type of the corresponding transferred data.
///
/// Drag and drop controllers that implement {@link TreeDragAndDropController.handleDrag `handleDrag`} can add additional mime types to the
/// data transfer. These additional mime types will only be included in the `handleDrop` when the drag was initiated from
/// an element in the same drag and drop controller.
pub type DataTransfer

///|
/// Encapsulates data transferred during drag and drop operations.
pub type DataTransferItem

///|
/// A file associated with a {@linkcode DataTransferItem}.
///
/// Instances of this type can only be created by the editor and not by extensions.
pub struct DataTransferFile {
  name : String
  uri : Uri?
}

///|
/// A selection range represents a part of a selection hierarchy. A selection range
/// may have a parent selection range that contains it.
pub type SelectionRange

///|

///|
/// Represents a list of ranges that can be edited together along with a word pattern to describe valid range contents.
pub type LinkedEditingRanges

///|

///|
#external
priv type Uint8Array

///|
#external
priv type Uint32Array

///|
fn bytes_to_uint8_array(value : Bytes) -> Uint8Array {
  JsValue::make(value).cast()
}

///|
fn bytes_from_uint8_array(value : Uint8Array) -> Bytes {
  JsValue::make(value).cast()
}

///|
fn array_to_uint32_array(value : Array[Int]) -> Uint32Array {
  uint32_array_from_array_ffi(value)
}

///|
fn array_from_uint32_array(value : Uint32Array) -> Array[Int] {
  uint32_array_to_array_ffi(value)
}

///|
extern "js" fn uint32_array_from_array_ffi(value : Array[Int]) -> Uint32Array =
  #| (value) => Uint32Array.from(value)

///|
extern "js" fn uint32_array_to_array_ffi(value : Uint32Array) -> Array[Int] =
  #| (value) => Array.from(value)

///|
/// Raw representation of a notebook.
///
/// Extensions are responsible for creating {@linkcode NotebookData} so that the editor
/// can create a {@linkcode NotebookDocument}.
///
/// @see {@link NotebookSerializer}
pub type NotebookData

///|
/// Text editor helpers

///|
/// The primary selection on this text editor. Shorthand for `TextEditor.selections[0]`.
pub extern "js" fn TextEditor::document(self : TextEditor) -> TextDocument =
  #| (editor) => editor.document

///|
/// The primary selection on this text editor. Shorthand for `TextEditor.selections[0]`.
pub extern "js" fn TextEditor::selection(self : TextEditor) -> Selection =
  #| (editor) => editor.selection

///|
/// The primary selection on this text editor. Shorthand for `TextEditor.selections[0]`.
pub extern "js" fn TextEditor::set_selection(
  self : TextEditor,
  selection : Selection,
) -> Unit =
  #| (editor, selection) => { editor.selection = selection; }

///|
/// The selections in this text editor. The primary selection is always at index 0.
pub extern "js" fn TextEditor::selections(
  self : TextEditor,
) -> Array[Selection] =
  #| (editor) => editor.selections

///|
/// The selections in this text editor. The primary selection is always at index 0.
pub extern "js" fn TextEditor::set_selections(
  self : TextEditor,
  selections : Array[Selection],
) -> Unit =
  #| (editor, selections) => {
  #|   editor.selections = selections;
  #| }

///|
/// The current visible ranges in the editor (vertically).
/// This accounts only for vertical scrolling, and not for horizontal scrolling.
pub extern "js" fn TextEditor::visible_ranges(
  self : TextEditor,
) -> Array[Range] =
  #| (editor) => editor.visibleRanges

///|
/// Text editor options.
pub extern "js" fn TextEditor::options(self : TextEditor) -> TextEditorOptions =
  #| (editor) => editor.options

///|
/// Text editor options.
pub extern "js" fn TextEditor::set_options(
  self : TextEditor,
  options : TextEditorOptions,
) -> Unit =
  #| (editor, options) => { editor.options = options; }

///|
/// The column in which this editor shows. Will be `undefined` in case this
/// isn't one of the main editors, e.g. an embedded editor, or when the editor
/// column is larger than three.
pub fn TextEditor::view_column(self : TextEditor) -> ViewColumn? {
  match TextEditor::text_editor_view_column_raw(self) {
    None => None
    Some(value) => Some(view_column_from_int(value))
  }
}

///|
fn text_editor_edit_options_to_js(value : TextEditorEditOptions?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(options) =>
      text_editor_edit_options_to_js_ffi(
        options.undo_stop_before,
        options.undo_stop_after,
      )
  }
}

///|
fn text_editor_insert_snippet_options_to_js(
  value : TextEditorInsertSnippetOptions?,
) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(options) =>
      text_editor_insert_snippet_options_to_js_ffi(
        options.undo_stop_before,
        options.undo_stop_after,
        options.keep_whitespace,
      )
  }
}

///|
extern "js" fn TextEditor::text_editor_view_column_raw(
  self : TextEditor,
) -> Int? =
  #| (editor) => editor.viewColumn

///|
fn TextEditor::edit_promise(
  self : TextEditor,
  callback : (TextEditorEdit) -> Unit,
  options : TextEditorEditOptions?,
) -> @js_async.Promise[Bool] {
  text_editor_edit_ffi(self, callback, text_editor_edit_options_to_js(options))
}

///|
fn TextEditor::insert_snippet_raw_promise(
  self : TextEditor,
  snippet : SnippetString,
  location : JsValue,
  options : TextEditorInsertSnippetOptions?,
) -> @js_async.Promise[Bool] {
  text_editor_insert_snippet_ffi(
    self,
    snippet,
    location,
    text_editor_insert_snippet_options_to_js(options),
  )
}

///|
/// Perform an edit on the document associated with this text editor.
///
/// The given callback-function is invoked with an {@link TextEditorEdit edit-builder} which must
/// be used to make edits. Note that the edit-builder is only valid while the
/// callback executes.
///
/// @param callback A function which can create edits using an {@link TextEditorEdit edit-builder}.
/// @param options The undo/redo behavior around this edit. By default, undo stops will be created before and after this edit.
/// @returns A promise that resolves with a value indicating if the edits could be applied.
pub async fn TextEditor::edit(
  self : TextEditor,
  callback : (TextEditorEdit) -> Unit,
  options? : TextEditorEditOptions,
) -> Bool {
  @js_async.Promise::wait(TextEditor::edit_promise(self, callback, options))
}

///|
/// Insert a {@link SnippetString snippet} and put the editor into snippet mode. "Snippet mode"
/// means the editor adds placeholders and additional cursors so that the user can complete
/// or accept the snippet.
///
/// @param snippet The snippet to insert in this edit.
/// @param location Position or range at which to insert the snippet, defaults to the current editor selection or selections.
/// @param options The undo/redo behavior around this edit. By default, undo stops will be created before and after this edit.
/// @returns A promise that resolves with a value indicating if the snippet could be inserted. Note that the promise does not signal
/// that the snippet is completely filled-in or accepted.
pub async fn TextEditor::insert_snippet(
  self : TextEditor,
  snippet : SnippetString,
  options? : TextEditorInsertSnippetOptions,
) -> Bool {
  @js_async.Promise::wait(
    TextEditor::insert_snippet_raw_promise(
      self,
      snippet,
      JsValue::make(()),
      options,
    ),
  )
}

///|
/// Insert a {@link SnippetString snippet} and put the editor into snippet mode. "Snippet mode"
/// means the editor adds placeholders and additional cursors so that the user can complete
/// or accept the snippet.
///
/// @param snippet The snippet to insert in this edit.
/// @param location Position or range at which to insert the snippet, defaults to the current editor selection or selections.
/// @param options The undo/redo behavior around this edit. By default, undo stops will be created before and after this edit.
/// @returns A promise that resolves with a value indicating if the snippet could be inserted. Note that the promise does not signal
/// that the snippet is completely filled-in or accepted.
pub async fn TextEditor::insert_snippet_at_position(
  self : TextEditor,
  snippet : SnippetString,
  position : Position,
  options? : TextEditorInsertSnippetOptions,
) -> Bool {
  @js_async.Promise::wait(
    TextEditor::insert_snippet_raw_promise(
      self,
      snippet,
      JsValue::make(position),
      options,
    ),
  )
}

///|
/// Insert a {@link SnippetString snippet} and put the editor into snippet mode. "Snippet mode"
/// means the editor adds placeholders and additional cursors so that the user can complete
/// or accept the snippet.
///
/// @param snippet The snippet to insert in this edit.
/// @param location Position or range at which to insert the snippet, defaults to the current editor selection or selections.
/// @param options The undo/redo behavior around this edit. By default, undo stops will be created before and after this edit.
/// @returns A promise that resolves with a value indicating if the snippet could be inserted. Note that the promise does not signal
/// that the snippet is completely filled-in or accepted.
pub async fn TextEditor::insert_snippet_at_range(
  self : TextEditor,
  snippet : SnippetString,
  range : Range,
  options? : TextEditorInsertSnippetOptions,
) -> Bool {
  @js_async.Promise::wait(
    TextEditor::insert_snippet_raw_promise(
      self,
      snippet,
      JsValue::make(range),
      options,
    ),
  )
}

///|
/// Insert a {@link SnippetString snippet} and put the editor into snippet mode. "Snippet mode"
/// means the editor adds placeholders and additional cursors so that the user can complete
/// or accept the snippet.
///
/// @param snippet The snippet to insert in this edit.
/// @param location Position or range at which to insert the snippet, defaults to the current editor selection or selections.
/// @param options The undo/redo behavior around this edit. By default, undo stops will be created before and after this edit.
/// @returns A promise that resolves with a value indicating if the snippet could be inserted. Note that the promise does not signal
/// that the snippet is completely filled-in or accepted.
pub async fn TextEditor::insert_snippet_at_positions(
  self : TextEditor,
  snippet : SnippetString,
  positions : Array[Position],
  options? : TextEditorInsertSnippetOptions,
) -> Bool {
  @js_async.Promise::wait(
    TextEditor::insert_snippet_raw_promise(
      self,
      snippet,
      JsValue::make(positions),
      options,
    ),
  )
}

///|
/// Insert a {@link SnippetString snippet} and put the editor into snippet mode. "Snippet mode"
/// means the editor adds placeholders and additional cursors so that the user can complete
/// or accept the snippet.
///
/// @param snippet The snippet to insert in this edit.
/// @param location Position or range at which to insert the snippet, defaults to the current editor selection or selections.
/// @param options The undo/redo behavior around this edit. By default, undo stops will be created before and after this edit.
/// @returns A promise that resolves with a value indicating if the snippet could be inserted. Note that the promise does not signal
/// that the snippet is completely filled-in or accepted.
pub async fn TextEditor::insert_snippet_at_ranges(
  self : TextEditor,
  snippet : SnippetString,
  ranges : Array[Range],
  options? : TextEditorInsertSnippetOptions,
) -> Bool {
  @js_async.Promise::wait(
    TextEditor::insert_snippet_raw_promise(
      self,
      snippet,
      JsValue::make(ranges),
      options,
    ),
  )
}

///|
/// Adds a set of decorations to the text editor. If a set of decorations already exists with
/// the given {@link TextEditorDecorationType decoration type}, they will be replaced. If
/// `rangesOrOptions` is empty, the existing decorations with the given {@link TextEditorDecorationType decoration type}
/// will be removed.
///
/// @see {@link window.createTextEditorDecorationType createTextEditorDecorationType}.
///
/// @param decorationType A decoration type.
/// @param rangesOrOptions Either {@link Range ranges} or more detailed {@link DecorationOptions options}.
pub extern "js" fn TextEditor::set_decorations_ranges(
  self : TextEditor,
  decoration_type : TextEditorDecorationType,
  ranges : Array[Range],
) -> Unit =
  #| (editor, decorationType, ranges) => editor.setDecorations(decorationType, ranges)

///|
/// Adds a set of decorations to the text editor. If a set of decorations already exists with
/// the given {@link TextEditorDecorationType decoration type}, they will be replaced. If
/// `rangesOrOptions` is empty, the existing decorations with the given {@link TextEditorDecorationType decoration type}
/// will be removed.
///
/// @see {@link window.createTextEditorDecorationType createTextEditorDecorationType}.
///
/// @param decorationType A decoration type.
/// @param rangesOrOptions Either {@link Range ranges} or more detailed {@link DecorationOptions options}.
pub fn TextEditor::set_decorations_options(
  self : TextEditor,
  decoration_type : TextEditorDecorationType,
  options : Array[DecorationOptions],
) -> Unit {
  text_editor_set_decorations_options_raw(self, decoration_type, options)
}

///|
extern "js" fn text_editor_set_decorations_options_raw(
  editor : TextEditor,
  decoration_type : TextEditorDecorationType,
  options : Array[DecorationOptions],
) -> Unit =
  #| (editor, decorationType, options) => editor.setDecorations(decorationType, options)

///|
/// Scroll as indicated by `revealType` in order to reveal the given range.
///
/// @param range A range.
/// @param revealType The scrolling strategy for revealing `range`.
pub extern "js" fn TextEditor::reveal_range(
  self : TextEditor,
  range : Range,
  reveal_type? : TextEditorRevealType = JsValue::make(()).cast(),
) -> Unit =
  #| (editor, range, revealType) => editor.revealRange(range, revealType)

///|
/// Show the text editor.
///
/// @deprecated Use {@link window.showTextDocument} instead.
///
/// @param column The {@link ViewColumn column} in which to show this editor.
/// This method shows unexpected behavior and will be removed in the next major update.
pub fn TextEditor::show(self : TextEditor, column? : ViewColumn) -> Unit {
  text_editor_show_raw(self, text_editor_option_view_column_to_js(column))
}

///|
fn text_editor_option_view_column_to_js(value : ViewColumn?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => JsValue::make(view_column_to_int(value))
  }
}

///|
extern "js" fn text_editor_show_raw(
  editor : TextEditor,
  column : JsValue,
) -> Unit =
  #| (editor, column) => editor.show(column)

///|
/// Hide the text editor.
///
/// @deprecated Use the command `workbench.action.closeActiveEditor` instead.
/// This method shows unexpected behavior and will be removed in the next major update.
pub extern "js" fn TextEditor::hide(self : TextEditor) -> Unit =
  #| (editor) => editor.hide()

///|
/// Internal representation of the handle.

///|
/// Remove this decoration type and all decorations on all text editors using it.
extern "js" fn text_editor_decoration_type_dispose_raw(
  decoration : TextEditorDecorationType,
) -> Unit =
  #| (decoration) => decoration.dispose()

///|
pub fn TextEditorDecorationType::dispose(self : TextEditorDecorationType) -> Unit {
  text_editor_decoration_type_dispose_raw(self)
}

///|
pub impl AsDisposable for TextEditorDecorationType with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// The {@link TextEditor text editor} for which the options have changed.
pub fn TextEditorOptionsChangeEvent::new(
  text_editor : TextEditor,
  options : TextEditorOptions,
) -> TextEditorOptionsChangeEvent {
  TextEditorOptionsChangeEvent::{ textEditor: text_editor, options }
}

///|
/// The {@link TextEditor text editor} for which the options have changed.

///|
/// The new value for the {@link TextEditor.options text editor's options}.

///|
/// The {@link TextEditor text editor} for which the selections have changed.
pub fn TextEditorSelectionChangeEvent::new(
  text_editor : TextEditor,
  selections : Array[Selection],
  kind? : TextEditorSelectionChangeKind,
) -> TextEditorSelectionChangeEvent {
  TextEditorSelectionChangeEvent::{ textEditor: text_editor, selections, kind }
}

///|
/// The {@link TextEditor text editor} for which the selections have changed.

///|
/// The new value for the {@link TextEditor.selections text editor's selections}.

///|
/// The {@link TextEditorSelectionChangeKind change kind} which has triggered this
/// event. Can be `undefined`.

///|
/// The {@link TextEditor text editor} for which the view column has changed.
pub fn TextEditorViewColumnChangeEvent::new(
  text_editor : TextEditor,
  view_column : ViewColumn,
) -> TextEditorViewColumnChangeEvent {
  TextEditorViewColumnChangeEvent::{
    textEditor: text_editor,
    viewColumn: view_column,
  }
}

///|
/// The {@link TextEditor text editor} for which the view column has changed.

///|
/// The new value for the {@link TextEditor.viewColumn text editor's view column}.

///|
/// The {@link TextEditor text editor} for which the visible ranges have changed.
pub fn TextEditorVisibleRangesChangeEvent::new(
  text_editor : TextEditor,
  visible_ranges : Array[Range],
) -> TextEditorVisibleRangesChangeEvent {
  TextEditorVisibleRangesChangeEvent::{
    textEditor: text_editor,
    visibleRanges: visible_ranges,
  }
}

///|
/// The {@link TextEditor text editor} for which the visible ranges have changed.

///|
/// The new value for the {@link TextEditor.visibleRanges text editor's visible ranges}.

///|
/// The {@link NotebookEditor notebook editor} for which the selections have changed.
pub fn NotebookEditorSelectionChangeEvent::new(
  notebook_editor : NotebookEditor,
  selections : Array[NotebookRange],
) -> NotebookEditorSelectionChangeEvent {
  NotebookEditorSelectionChangeEvent::{
    notebookEditor: notebook_editor,
    selections,
  }
}

///|
/// The {@link NotebookEditor notebook editor} for which the selections have changed.

///|
/// The new value for the {@link NotebookEditor.selections notebook editor's selections}.

///|
/// The {@link NotebookEditor notebook editor} for which the visible ranges have changed.
pub fn NotebookEditorVisibleRangesChangeEvent::new(
  notebook_editor : NotebookEditor,
  visible_ranges : Array[NotebookRange],
) -> NotebookEditorVisibleRangesChangeEvent {
  NotebookEditorVisibleRangesChangeEvent::{
    notebookEditor: notebook_editor,
    visibleRanges: visible_ranges,
  }
}

///|
/// The {@link NotebookEditor notebook editor} for which the visible ranges have changed.

///|
/// The new value for the {@link NotebookEditor.visibleRanges notebook editor's visibleRanges}.

///|
/// Replace a certain text region with a new value.
/// You can use `\r\n` or `\n` in `value` and they will be normalized to the current {@link TextDocument document}.
///
/// @param location The range this operation should remove.
/// @param value The new text this operation should insert after removing `location`.
pub extern "js" fn TextEditorEdit::replace_range(
  self : TextEditorEdit,
  range : Range,
  value : String,
) -> Unit =
  #| (edit, range, value) => edit.replace(range, value)

///|
/// Replace a certain text region with a new value.
/// You can use `\r\n` or `\n` in `value` and they will be normalized to the current {@link TextDocument document}.
///
/// @param location The range this operation should remove.
/// @param value The new text this operation should insert after removing `location`.
pub extern "js" fn TextEditorEdit::replace_position(
  self : TextEditorEdit,
  position : Position,
  value : String,
) -> Unit =
  #| (edit, position, value) => edit.replace(position, value)

///|
/// Replace a certain text region with a new value.
/// You can use `\r\n` or `\n` in `value` and they will be normalized to the current {@link TextDocument document}.
///
/// @param location The range this operation should remove.
/// @param value The new text this operation should insert after removing `location`.
pub extern "js" fn TextEditorEdit::replace_selection(
  self : TextEditorEdit,
  selection : Selection,
  value : String,
) -> Unit =
  #| (edit, selection, value) => edit.replace(selection, value)

///|
/// Insert text at a location.
/// You can use `\r\n` or `\n` in `value` and they will be normalized to the current {@link TextDocument document}.
/// Although the equivalent text edit can be made with {@link TextEditorEdit.replace replace}, `insert` will produce a different resulting selection (it will get moved).
///
/// @param location The position where the new text should be inserted.
/// @param value The new text this operation should insert.
pub extern "js" fn TextEditorEdit::insert(
  self : TextEditorEdit,
  position : Position,
  value : String,
) -> Unit =
  #| (edit, position, value) => edit.insert(position, value)

///|
/// Delete a certain text region.
///
/// @param location The range this operation should remove.
pub extern "js" fn TextEditorEdit::delete_range(
  self : TextEditorEdit,
  range : Range,
) -> Unit =
  #| (edit, range) => edit.delete(range)

///|
/// Delete a certain text region.
///
/// @param location The range this operation should remove.
pub extern "js" fn TextEditorEdit::delete_selection(
  self : TextEditorEdit,
  selection : Selection,
) -> Unit =
  #| (edit, selection) => edit.delete(selection)

///|
/// Set the end of line sequence.
///
/// @param endOfLine The new end of line for the {@link TextDocument document}.
pub extern "js" fn TextEditorEdit::set_end_of_line(
  self : TextEditorEdit,
  eol : EndOfLine,
) -> Unit =
  #| (edit, eol) => edit.setEndOfLine(eol)

///|
/// Create a new snippet string.
///
/// @param value A snippet string.
pub extern "js" fn SnippetString::new(value : String) -> SnippetString =
  #| (value) => new (require("vscode").SnippetString)(value)

///|
/// The snippet string.
pub extern "js" fn SnippetString::value(self : SnippetString) -> String =
  #| (value) => value.value

///|
pub extern "js" fn SnippetString::set_value(
  self : SnippetString,
  value : String,
) -> Unit =
  #| (snippet, value) => { snippet.value = value; }

///|
/// Builder-function that appends the given string to
/// the {@linkcode SnippetString.value value} of this snippet string.
///
/// @param string A value to append 'as given'. The string will be escaped.
/// @returns This snippet string.
pub extern "js" fn SnippetString::append_text(
  self : SnippetString,
  text : String,
) -> SnippetString =
  #| (snippet, text) => snippet.appendText(text)

///|
/// Builder-function that appends a tabstop (`$1`, `$2` etc) to
/// the {@linkcode SnippetString.value value} of this snippet string.
///
/// @param number The number of this tabstop, defaults to an auto-increment
/// value starting at 1.
/// @returns This snippet string.
pub fn SnippetString::append_tabstop(
  self : SnippetString,
  number? : Int,
) -> SnippetString {
  snippet_string_append_tabstop_raw(self, option_to_js(number))
}

///|
/// Builder-function that appends a placeholder (`${1:value}`) to
/// the {@linkcode SnippetString.value value} of this snippet string.
///
/// @param value The value of this placeholder - either a string or a function
/// with which a nested snippet can be created.
/// @param number The number of this tabstop, defaults to an auto-increment
/// value starting at 1.
/// @returns This snippet string.
pub fn SnippetString::append_placeholder_text(
  self : SnippetString,
  value : String,
  number? : Int,
) -> SnippetString {
  snippet_string_append_placeholder_raw(
    self,
    JsValue::make(value),
    option_to_js(number),
  )
}

///|
/// Builder-function that appends a placeholder (`${1:value}`) to
/// the {@linkcode SnippetString.value value} of this snippet string.
///
/// @param value The value of this placeholder - either a string or a function
/// with which a nested snippet can be created.
/// @param number The number of this tabstop, defaults to an auto-increment
/// value starting at 1.
/// @returns This snippet string.
pub fn SnippetString::append_placeholder_snippet(
  self : SnippetString,
  builder : (SnippetString) -> Unit,
  number? : Int,
) -> SnippetString {
  snippet_string_append_placeholder_callback_raw(
    self,
    builder,
    option_to_js(number),
  )
}

///|
/// Builder-function that appends a choice (`${1|a,b,c|}`) to
/// the {@linkcode SnippetString.value value} of this snippet string.
///
/// @param values The values for choices - the array of strings
/// @param number The number of this tabstop, defaults to an auto-increment
/// value starting at 1.
/// @returns This snippet string.
pub fn SnippetString::append_choice(
  self : SnippetString,
  values : Array[String],
  number? : Int,
) -> SnippetString {
  snippet_string_append_choice_raw(self, values, option_to_js(number))
}

///|
/// Builder-function that appends a variable (`${VAR}`) to
/// the {@linkcode SnippetString.value value} of this snippet string.
///
/// @param name The name of the variable - excluding the `$`.
/// @param defaultValue The default value which is used when the variable name cannot
/// be resolved - either a string or a function with which a nested snippet can be created.
/// @returns This snippet string.
pub fn SnippetString::append_variable_text(
  self : SnippetString,
  name : String,
  default_value : String,
) -> SnippetString {
  snippet_string_append_variable_raw(self, name, JsValue::make(default_value))
}

///|
/// Builder-function that appends a variable (`${VAR}`) to
/// the {@linkcode SnippetString.value value} of this snippet string.
///
/// @param name The name of the variable - excluding the `$`.
/// @param defaultValue The default value which is used when the variable name cannot
/// be resolved - either a string or a function with which a nested snippet can be created.
/// @returns This snippet string.
pub fn SnippetString::append_variable_snippet(
  self : SnippetString,
  name : String,
  builder : (SnippetString) -> Unit,
) -> SnippetString {
  snippet_string_append_variable_callback_raw(self, name, builder)
}

///|
extern "js" fn snippet_string_append_tabstop_raw(
  snippet : SnippetString,
  number : JsValue,
) -> SnippetString =
  #| (snippet, number) => snippet.appendTabstop(number)

///|
extern "js" fn snippet_string_append_placeholder_raw(
  snippet : SnippetString,
  value : JsValue,
  number : JsValue,
) -> SnippetString =
  #| (snippet, value, number) => snippet.appendPlaceholder(value, number)

///|
extern "js" fn snippet_string_append_placeholder_callback_raw(
  snippet : SnippetString,
  builder : (SnippetString) -> Unit,
  number : JsValue,
) -> SnippetString =
  #| (snippet, builder, number) =>
  #|   snippet.appendPlaceholder((nested) => {
  #|     builder(nested);
  #|     return nested;
  #|   }, number)

///|
extern "js" fn snippet_string_append_choice_raw(
  snippet : SnippetString,
  values : Array[String],
  number : JsValue,
) -> SnippetString =
  #| (snippet, values, number) => snippet.appendChoice(values, number)

///|
extern "js" fn snippet_string_append_variable_raw(
  snippet : SnippetString,
  name : String,
  default_value : JsValue,
) -> SnippetString =
  #| (snippet, name, defaultValue) => snippet.appendVariable(name, defaultValue)

///|
extern "js" fn snippet_string_append_variable_callback_raw(
  snippet : SnippetString,
  name : String,
  builder : (SnippetString) -> Unit,
) -> SnippetString =
  #| (snippet, name, builder) =>
  #|   snippet.appendVariable(name, (nested) => {
  #|     builder(nested);
  #|     return nested;
  #|   })

///|
pub fn TextEditorEditOptions::new(
  undo_stop_before? : Bool = true,
  undo_stop_after? : Bool = true,
) -> TextEditorEditOptions {
  TextEditorEditOptions::{ undo_stop_before, undo_stop_after }
}

///|
pub fn TextEditorInsertSnippetOptions::new(
  undo_stop_before? : Bool = true,
  undo_stop_after? : Bool = true,
  keep_whitespace? : Bool = false,
) -> TextEditorInsertSnippetOptions {
  TextEditorInsertSnippetOptions::{
    undo_stop_before,
    undo_stop_after,
    keep_whitespace,
  }
}

///|
extern "js" fn range_intersection_ffi(range : Range, other : Range) -> JsValue =
  #| (range, other) => range.intersection(other)

///|
extern "js" fn text_document_get_word_range_at_position_ffi(
  doc : TextDocument,
  position : Position,
  regex : JsValue,
) -> JsValue =
  #| (doc, position, regex) => doc.getWordRangeAtPosition(position, regex)

///|
extern "js" fn text_editor_edit_ffi(
  editor : TextEditor,
  callback : (TextEditorEdit) -> Unit,
  options : JsValue,
) -> @js_async.Promise[Bool] =
  #| (editor, callback, options) =>
  #|   editor.edit((editBuilder) => callback(editBuilder), options)

///|
extern "js" fn text_editor_insert_snippet_ffi(
  editor : TextEditor,
  snippet : SnippetString,
  location : JsValue,
  options : JsValue,
) -> @js_async.Promise[Bool] =
  #| (editor, snippet, location, options) =>
  #|   editor.insertSnippet(snippet, location, options)

///|
extern "js" fn text_editor_edit_options_to_js_ffi(
  undo_stop_before : Bool,
  undo_stop_after : Bool,
) -> JsValue =
  #| (undoStopBefore, undoStopAfter) => ({ undoStopBefore, undoStopAfter })

///|
extern "js" fn text_editor_insert_snippet_options_to_js_ffi(
  undo_stop_before : Bool,
  undo_stop_after : Bool,
  keep_whitespace : Bool,
) -> JsValue =
  #| (undoStopBefore, undoStopAfter, keepWhitespace) => ({
  #|   undoStopBefore,
  #|   undoStopAfter,
  #|   keepWhitespace,
  #| })

///|
extern "js" fn event_subscribe_ffi(
  event : JsValue,
  listener : (JsValue) -> Unit,
  this_arg : JsValue,
) -> Disposable =
  #| (event, listener, thisArg) => event((e) => listener(e), thisArg)

///|
extern "js" fn event_emitter_new_ffi() -> JsValue =
  #| () => new (require("vscode").EventEmitter)()

///|
extern "js" fn event_emitter_event_ffi(emitter : JsValue) -> JsValue =
  #| (emitter) => emitter.event

///|
extern "js" fn event_emitter_fire_ffi(
  emitter : JsValue,
  value : JsValue,
) -> Unit =
  #| (emitter, value) => emitter.fire(value)

///|
extern "js" fn event_emitter_dispose_ffi(emitter : JsValue) -> Unit =
  #| (emitter) => emitter.dispose()

///|
/// OutputChannel helpers
pub extern "js" fn OutputChannel::append(
  self : OutputChannel,
  value : String,
) -> Unit =
  #| (channel, value) => channel.append(value)

///|
/// The human-readable name of this output channel.

///|
/// Append the given value and a line feed character
/// to the channel.
///
/// @param value A string, falsy values will be printed.
pub extern "js" fn OutputChannel::append_line(
  self : OutputChannel,
  value : String,
) -> Unit =
  #| (channel, value) => channel.appendLine(value)

///|
/// Removes all output from the channel.
pub extern "js" fn OutputChannel::clear(self : OutputChannel) -> Unit =
  #| (channel) => channel.clear()

///|
/// Reveal this channel in the UI.
///
/// @param preserveFocus When `true` the channel will not take focus.
pub extern "js" fn OutputChannel::show(
  self : OutputChannel,
  preserve_focus? : Bool = false,
) -> Unit =
  #| (channel, preserveFocus) => channel.show(preserveFocus)

///|
/// Hide this channel from the UI.
pub extern "js" fn OutputChannel::hide(self : OutputChannel) -> Unit =
  #| (channel) => channel.hide()

///|
/// Dispose and free associated resources.
extern "js" fn output_channel_dispose_raw(channel : OutputChannel) -> Unit =
  #| (channel) => channel.dispose()

///|
pub fn OutputChannel::dispose(self : OutputChannel) -> Unit {
  output_channel_dispose_raw(self)
}

///|
pub impl AsDisposable for OutputChannel with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// Replaces all output from the channel with the given value.
///
/// @param value A string, falsy values will not be printed.
pub extern "js" fn OutputChannel::replace(
  self : OutputChannel,
  value : String,
) -> Unit =
  #| (channel, value) => channel.replace(value)

///|
/// The human-readable name of this output channel.
pub extern "js" fn OutputChannel::name(self : OutputChannel) -> String =
  #| (channel) => channel.name

///|
/// The current log level of the channel. Defaults to {@link env.logLevel editor log level}.
pub extern "js" fn LogOutputChannel::log_level(
  self : LogOutputChannel,
) -> LogLevel =
  #| (channel) => channel.logLevel

///|
/// An {@link Event} which fires when the log level of the channel changes.
pub extern "js" fn LogOutputChannel::on_did_change_log_level(
  self : LogOutputChannel,
) -> Event[LogLevel] =
  #| (channel) => channel.onDidChangeLogLevel

///|
/// Outputs the given trace message to the channel. Use this method to log verbose information.
///
/// The message is only logged if the channel is configured to display {@link LogLevel.Trace trace} log level.
///
/// @param message trace message to log
pub extern "js" fn LogOutputChannel::trace(
  self : LogOutputChannel,
  message : String,
) -> Unit =
  #| (channel, message) => channel.trace(message)

///|
/// Outputs the given debug message to the channel.
///
/// The message is only logged if the channel is configured to display {@link LogLevel.Debug debug} log level or lower.
///
/// @param message debug message to log
pub extern "js" fn LogOutputChannel::debug(
  self : LogOutputChannel,
  message : String,
) -> Unit =
  #| (channel, message) => channel.debug(message)

///|
/// Outputs the given information message to the channel.
///
/// The message is only logged if the channel is configured to display {@link LogLevel.Info info} log level or lower.
///
/// @param message info message to log
pub extern "js" fn LogOutputChannel::info(
  self : LogOutputChannel,
  message : String,
) -> Unit =
  #| (channel, message) => channel.info(message)

///|
/// Outputs the given warning message to the channel.
///
/// The message is only logged if the channel is configured to display {@link LogLevel.Warning warning} log level or lower.
///
/// @param message warning message to log
pub extern "js" fn LogOutputChannel::warn(
  self : LogOutputChannel,
  message : String,
) -> Unit =
  #| (channel, message) => channel.warn(message)

///|
/// Outputs the given error or error message to the channel.
///
/// The message is only logged if the channel is configured to display {@link LogLevel.Error error} log level or lower.
///
/// @param error Error or error message to log
pub extern "js" fn LogOutputChannel::error(
  self : LogOutputChannel,
  message : String,
) -> Unit =
  #| (channel, message) => channel.error(message)

///|
extern "js" fn log_output_channel_dispose_raw(
  channel : LogOutputChannel,
) -> Unit =
  #| (channel) => channel.dispose()

///|
pub fn LogOutputChannel::dispose(self : LogOutputChannel) -> Unit {
  log_output_channel_dispose_raw(self)
}

///|
pub impl AsDisposable for LogOutputChannel with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// StatusBarItem helpers
pub extern "js" fn StatusBarItem::show(self : StatusBarItem) -> Unit =
  #| (item) => item.show()

///|
/// Hide the entry in the status bar.
pub extern "js" fn StatusBarItem::hide(self : StatusBarItem) -> Unit =
  #| (item) => item.hide()

///|
/// Dispose and free associated resources. Call
/// {@link StatusBarItem.hide hide}.
extern "js" fn status_bar_item_dispose_raw(item : StatusBarItem) -> Unit =
  #| (item) => item.dispose()

///|
pub fn StatusBarItem::dispose(self : StatusBarItem) -> Unit {
  status_bar_item_dispose_raw(self)
}

///|
pub impl AsDisposable for StatusBarItem with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// The text to show for the entry. You can embed icons in the text by leveraging the syntax:
///
/// `My text $(icon-name) contains icons like $(icon-name) this one.`
///
/// Where the icon-name is taken from the ThemeIcon [icon set](https://code.visualstudio.com/api/references/icons-in-labels#icon-listing), e.g.
/// `light-bulb`, `thumbsup`, `zap` etc.

///|
/// The identifier of this item.
///
/// *Note*: if no identifier was provided by the {@linkcode window.createStatusBarItem}
/// method, the identifier will match the {@link Extension.id extension identifier}.

///|
/// The text to show for the entry. You can embed icons in the text by leveraging the syntax:
///
/// `My text $(icon-name) contains icons like $(icon-name) this one.`
///
/// Where the icon-name is taken from the ThemeIcon [icon set](https://code.visualstudio.com/api/references/icons-in-labels#icon-listing), e.g.
/// `light-bulb`, `thumbsup`, `zap` etc.

///|
/// The tooltip text when you hover over this entry.

///|
/// The tooltip text when you hover over this entry.

///|
/// The tooltip text when you hover over this entry.
pub extern "js" fn StatusBarItem::id(self : StatusBarItem) -> String =
  #| (item) => item.id

///|
/// The text to show for the entry. You can embed icons in the text by leveraging the syntax:
pub extern "js" fn StatusBarItem::text(self : StatusBarItem) -> String =
  #| (item) => item.text

///|
/// The text to show for the entry. You can embed icons in the text by leveraging the syntax:
pub extern "js" fn StatusBarItem::set_text(
  self : StatusBarItem,
  value : String,
) -> Unit =
  #| (item, value) => { item.text = value; }

///|
/// The tooltip text when you hover over this entry.
pub fn StatusBarItem::tooltip(self : StatusBarItem) -> Tooltip? {
  Tooltip::from_js(StatusBarItem::status_bar_item_tooltip_raw(self))
}

///|
/// The tooltip text when you hover over this entry.
pub fn StatusBarItem::set_tooltip(
  self : StatusBarItem,
  value : Tooltip,
) -> Unit {
  StatusBarItem::status_bar_item_set_tooltip_raw(self, value.to_js())
}

///|
/// The tooltip text when you hover over this entry.
pub fn StatusBarItem::clear_tooltip(self : StatusBarItem) -> Unit {
  StatusBarItem::status_bar_item_set_tooltip_raw(self, JsValue::make(()))
}

///|
/// {@linkcode Command} or identifier of a command to run on click.
///
/// The command must be {@link commands.getCommands known}.
///
/// Note that if this is a {@linkcode Command} object, only the {@linkcode Command.command command} and {@linkcode Command.arguments arguments}
/// are used by the editor.
pub fn StatusBarItem::command(self : StatusBarItem) -> CommandOrString? {
  CommandOrString::from_js(StatusBarItem::status_bar_item_command_raw(self))
}

///|
/// {@linkcode Command} or identifier of a command to run on click.
///
/// The command must be {@link commands.getCommands known}.
///
/// Note that if this is a {@linkcode Command} object, only the {@linkcode Command.command command} and {@linkcode Command.arguments arguments}
/// are used by the editor.
pub fn StatusBarItem::set_command(
  self : StatusBarItem,
  value : CommandOrString,
) -> Unit {
  StatusBarItem::status_bar_item_set_command_raw(self, value.to_js())
}

///|
/// {@linkcode Command} or identifier of a command to run on click.
///
/// The command must be {@link commands.getCommands known}.
///
/// Note that if this is a {@linkcode Command} object, only the {@linkcode Command.command command} and {@linkcode Command.arguments arguments}
/// are used by the editor.
pub fn StatusBarItem::clear_command(self : StatusBarItem) -> Unit {
  StatusBarItem::status_bar_item_set_command_raw(self, JsValue::make(()))
}

///|
/// The foreground color for this entry.
pub fn StatusBarItem::color(self : StatusBarItem) -> ColorValue? {
  ColorValue::from_js(StatusBarItem::status_bar_item_color_raw(self))
}

///|
/// The foreground color for this entry.
pub fn StatusBarItem::set_color(
  self : StatusBarItem,
  value : ColorValue,
) -> Unit {
  StatusBarItem::status_bar_item_set_color_raw(self, value.to_js())
}

///|
/// The foreground color for this entry.
pub fn StatusBarItem::clear_color(self : StatusBarItem) -> Unit {
  StatusBarItem::status_bar_item_set_color_raw(self, JsValue::make(()))
}

///|
/// The background color for this entry.
///
/// *Note*: only the following colors are supported:
/// * `new ThemeColor('statusBarItem.errorBackground')`
/// * `new ThemeColor('statusBarItem.warningBackground')`
///
/// More background colors may be supported in the future.
///
/// *Note*: when a background color is set, the statusbar may override
/// the `color` choice to ensure the entry is readable in all themes.
pub fn StatusBarItem::background_color(self : StatusBarItem) -> ThemeColor? {
  let raw = StatusBarItem::status_bar_item_background_color_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The background color for this entry.
///
/// *Note*: only the following colors are supported:
/// * `new ThemeColor('statusBarItem.errorBackground')`
/// * `new ThemeColor('statusBarItem.warningBackground')`
///
/// More background colors may be supported in the future.
///
/// *Note*: when a background color is set, the statusbar may override
/// the `color` choice to ensure the entry is readable in all themes.
pub fn StatusBarItem::set_background_color(
  self : StatusBarItem,
  value : ThemeColor,
) -> Unit {
  StatusBarItem::status_bar_item_set_background_color_raw(
    self,
    JsValue::make(value),
  )
}

///|
/// The background color for this entry.
///
/// *Note*: only the following colors are supported:
/// * `new ThemeColor('statusBarItem.errorBackground')`
/// * `new ThemeColor('statusBarItem.warningBackground')`
///
/// More background colors may be supported in the future.
///
/// *Note*: when a background color is set, the statusbar may override
/// the `color` choice to ensure the entry is readable in all themes.
pub fn StatusBarItem::clear_background_color(self : StatusBarItem) -> Unit {
  StatusBarItem::status_bar_item_set_background_color_raw(
    self,
    JsValue::make(()),
  )
}

///|
/// The alignment of this item.
pub extern "js" fn StatusBarItem::alignment(
  self : StatusBarItem,
) -> StatusBarAlignment =
  #| (item) => item.alignment

///|
/// The priority of this item. Higher value means the item should
/// be shown more to the left.
pub fn StatusBarItem::priority(self : StatusBarItem) -> Int? {
  let raw = StatusBarItem::status_bar_item_priority_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The name of the entry, like 'Python Language Indicator', 'Git Status' etc.
/// Try to keep the length of the name short, yet descriptive enough that
/// users can understand what the status bar item is about.
pub fn StatusBarItem::name(self : StatusBarItem) -> String? {
  let raw = StatusBarItem::status_bar_item_name_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The name of the entry, like 'Python Language Indicator', 'Git Status' etc.
pub fn StatusBarItem::set_name(self : StatusBarItem, value : String) -> Unit {
  StatusBarItem::status_bar_item_set_name_raw(self, JsValue::make(value))
}

///|
/// The name of the entry, like 'Python Language Indicator', 'Git Status' etc.
pub fn StatusBarItem::clear_name(self : StatusBarItem) -> Unit {
  StatusBarItem::status_bar_item_set_name_raw(self, JsValue::make(()))
}

///|
/// Accessibility information used when a screen reader interacts with this StatusBar item
pub fn StatusBarItem::accessibility_information(
  self : StatusBarItem,
) -> AccessibilityInformation? {
  let raw = StatusBarItem::status_bar_item_accessibility_information_raw(self)
  accessibility_information_from_js(raw)
}

///|
/// Accessibility information used when a screen reader interacts with this StatusBar item
pub fn StatusBarItem::set_accessibility_information(
  self : StatusBarItem,
  info : AccessibilityInformation,
) -> Unit {
  StatusBarItem::status_bar_item_set_accessibility_information_raw(
    self,
    accessibility_information_to_js(info),
  )
}

///|
/// Accessibility information used when a screen reader interacts with this StatusBar item
pub fn StatusBarItem::clear_accessibility_information(
  self : StatusBarItem,
) -> Unit {
  StatusBarItem::status_bar_item_set_accessibility_information_raw(
    self,
    JsValue::make(()),
  )
}

///|
extern "js" fn StatusBarItem::status_bar_item_accessibility_information_raw(
  self : StatusBarItem,
) -> JsValue =
  #| (item) => item.accessibilityInformation

///|
extern "js" fn StatusBarItem::status_bar_item_tooltip_raw(
  self : StatusBarItem,
) -> JsValue =
  #| (item) => item.tooltip

///|
extern "js" fn StatusBarItem::status_bar_item_set_tooltip_raw(
  self : StatusBarItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.tooltip = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn StatusBarItem::status_bar_item_command_raw(
  self : StatusBarItem,
) -> JsValue =
  #| (item) => item.command

///|
extern "js" fn StatusBarItem::status_bar_item_set_command_raw(
  self : StatusBarItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.command = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn StatusBarItem::status_bar_item_color_raw(
  self : StatusBarItem,
) -> JsValue =
  #| (item) => item.color

///|
extern "js" fn StatusBarItem::status_bar_item_set_color_raw(
  self : StatusBarItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.color = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn StatusBarItem::status_bar_item_background_color_raw(
  self : StatusBarItem,
) -> JsValue =
  #| (item) => item.backgroundColor

///|
extern "js" fn StatusBarItem::status_bar_item_set_background_color_raw(
  self : StatusBarItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.backgroundColor = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn StatusBarItem::status_bar_item_priority_raw(
  self : StatusBarItem,
) -> JsValue =
  #| (item) => item.priority

///|
extern "js" fn StatusBarItem::status_bar_item_name_raw(
  self : StatusBarItem,
) -> JsValue =
  #| (item) => item.name

///|
extern "js" fn StatusBarItem::status_bar_item_set_name_raw(
  self : StatusBarItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.name = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn StatusBarItem::status_bar_item_set_accessibility_information_raw(
  self : StatusBarItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.accessibilityInformation = value === undefined || value === null ? undefined : value; }

///|
/// Terminal helpers
extern "js" fn terminal_dispose_raw(terminal : Terminal) -> Unit =
  #| (terminal) => terminal.dispose()

///|
pub fn Terminal::dispose(self : Terminal) -> Unit {
  terminal_dispose_raw(self)
}

///|
pub impl AsDisposable for Terminal with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// The name of the terminal.

///|
extern "js" fn Terminal::process_id_promise(
  self : Terminal,
) -> @js_async.Promise[JsValue] =
  #| (terminal) => terminal.processId

///|
/// The process ID of the shell process.
pub async fn Terminal::process_id(self : Terminal) -> Int? {
  let raw = @js_async.Promise::wait(Terminal::process_id_promise(self))
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The object used to initialize the terminal, this is useful for example to detecting the
/// shell type of when the terminal was not launched by this extension or for detecting what
/// folder the shell was launched in.
pub fn Terminal::creation_options(self : Terminal) -> TerminalCreationOptions? {
  let raw = Terminal::terminal_creation_options_raw(self)
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(TerminalCreationOptions::from_js(raw))
  }
}

///|
/// The exit status of the terminal, this will be undefined while the terminal is active.
///
/// **Example:** Show a notification with the exit code when the terminal exits with a
/// non-zero exit code.
/// ```typescript
/// window.onDidCloseTerminal(t => {
///   if (t.exitStatus && t.exitStatus.code) {
///   	vscode.window.showInformationMessage(`Exit code: ${t.exitStatus.code}`);
///   }
/// });
/// ```

///|
/// The current state of the {@link Terminal}.

///|
/// An object that contains [shell integration](https://code.visualstudio.com/docs/terminal/shell-integration)-powered
/// features for the terminal. This will always be `undefined` immediately after the terminal
/// is created. Listen to {@link window.onDidChangeTerminalShellIntegration} to be notified
/// when shell integration is activated for a terminal.
///
/// Note that this object may remain undefined if shell integration never activates. For
/// example Command Prompt does not support shell integration and a user's shell setup could
/// conflict with the automatic shell integration activation.

///|
/// Send text to the terminal. The text is written to the stdin of the underlying pty process
/// (shell) of the terminal.
///
/// @param text The text to send.
/// @param shouldExecute Indicates that the text being sent should be executed rather than just inserted in the terminal.
/// The character(s) added are `\n` or `\r\n`, depending on the platform. This defaults to `true`.
pub extern "js" fn Terminal::send_text(
  self : Terminal,
  text : String,
  should_execute? : Bool = true,
) -> Unit =
  #| (terminal, text, shouldExecute) => terminal.sendText(text, shouldExecute)

///|
/// Show the terminal panel and reveal this terminal in the UI.
///
/// @param preserveFocus When `true` the terminal will not take focus.
pub extern "js" fn Terminal::show(
  self : Terminal,
  preserve_focus? : Bool = false,
) -> Unit =
  #| (terminal, preserveFocus) => terminal.show(preserveFocus)

///|
/// Hide the terminal panel if this terminal is currently showing.
pub extern "js" fn Terminal::hide(self : Terminal) -> Unit =
  #| (terminal) => terminal.hide()

///|
pub extern "js" fn Terminal::name(self : Terminal) -> String =
  #| (terminal) => terminal.name

///|
pub fn Terminal::exit_status(self : Terminal) -> TerminalExitStatus? {
  let raw = Terminal::terminal_exit_status_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub extern "js" fn Terminal::state(self : Terminal) -> TerminalState =
  #| (terminal) => terminal.state

///|
pub fn Terminal::shell_integration(
  self : Terminal,
) -> TerminalShellIntegration? {
  let raw = Terminal::terminal_shell_integration_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
extern "js" fn Terminal::terminal_creation_options_raw(
  self : Terminal,
) -> JsValue =
  #| (terminal) => terminal.creationOptions

///|
extern "js" fn Terminal::terminal_exit_status_raw(self : Terminal) -> JsValue =
  #| (terminal) => terminal.exitStatus

///|
extern "js" fn Terminal::terminal_shell_integration_raw(
  self : Terminal,
) -> JsValue =
  #| (terminal) => terminal.shellIntegration

///|
/// All the groups within the group container.
pub extern "js" fn TabGroups::all(self : TabGroups) -> Array[TabGroup] =
  #| (groups) => groups.all

///|
/// The currently active group.
pub extern "js" fn TabGroups::active_tab_group(self : TabGroups) -> TabGroup =
  #| (groups) => groups.activeTabGroup

///|
/// An {@link Event event} which fires when {@link TabGroup tab groups} have changed.
pub extern "js" fn TabGroups::on_did_change_tab_groups(
  self : TabGroups,
) -> Event[TabGroupChangeEvent] =
  #| (groups) => groups.onDidChangeTabGroups

///|
/// An {@link Event event} which fires when {@link Tab tabs} have changed.
pub extern "js" fn TabGroups::on_did_change_tabs(
  self : TabGroups,
) -> Event[TabChangeEvent] =
  #| (groups) => groups.onDidChangeTabs

///|
extern "js" fn TabGroups::close_tab_promise(
  self : TabGroups,
  tab : Tab,
  preserve_focus? : Bool = false,
) -> @js_async.Promise[Bool] =
  #| (groups, tab, preserveFocus) => groups.close(tab, preserveFocus)

///|
/// Closes the tab. This makes the tab object invalid and the tab
/// should no longer be used for further actions.
/// Note: In the case of a dirty tab, a confirmation dialog will be shown which may be cancelled. If cancelled the tab is still valid
///
/// @param tab The tab to close.
/// @param preserveFocus When `true` focus will remain in its current position. If `false` it will jump to the next tab.
/// @returns A promise that resolves to `true` when all tabs have been closed.
pub async fn TabGroups::close_tab(
  self : TabGroups,
  tab : Tab,
  preserve_focus? : Bool = false,
) -> Bool {
  @js_async.Promise::wait(
    TabGroups::close_tab_promise(self, tab, preserve_focus~),
  )
}

///|
extern "js" fn TabGroups::close_tab_group_promise(
  self : TabGroups,
  tab_group : TabGroup,
  preserve_focus? : Bool = false,
) -> @js_async.Promise[Bool] =
  #| (groups, tabGroup, preserveFocus) => groups.close(tabGroup, preserveFocus)

///|
/// Closes the tab. This makes the tab object invalid and the tab
/// should no longer be used for further actions.
/// Note: In the case of a dirty tab, a confirmation dialog will be shown which may be cancelled. If cancelled the tab is still valid
///
/// @param tab The tab to close.
/// @param preserveFocus When `true` focus will remain in its current position. If `false` it will jump to the next tab.
/// @returns A promise that resolves to `true` when all tabs have been closed.
pub async fn TabGroups::close_tab_group(
  self : TabGroups,
  tab_group : TabGroup,
  preserve_focus? : Bool = false,
) -> Bool {
  @js_async.Promise::wait(
    TabGroups::close_tab_group_promise(self, tab_group, preserve_focus~),
  )
}

///|
pub extern "js" fn TabGroup::is_active(self : TabGroup) -> Bool =
  #| (group) => group.isActive

///|
pub extern "js" fn TabGroup::view_column(self : TabGroup) -> ViewColumn =
  #| (group) => group.viewColumn

///|
pub fn TabGroup::active_tab(self : TabGroup) -> Tab? {
  let raw = TabGroup::tab_group_active_tab_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub extern "js" fn TabGroup::tabs(self : TabGroup) -> Array[Tab] =
  #| (group) => group.tabs

///|
extern "js" fn TabGroup::tab_group_active_tab_raw(self : TabGroup) -> JsValue =
  #| (group) => group.activeTab

///|
pub extern "js" fn Tab::label(self : Tab) -> String =
  #| (tab) => tab.label

///|
pub extern "js" fn Tab::group(self : Tab) -> TabGroup =
  #| (tab) => tab.group

///|
pub extern "js" fn Tab::input(self : Tab) -> TabInput =
  #| (tab) => tab.input

///|
pub extern "js" fn Tab::is_active(self : Tab) -> Bool =
  #| (tab) => tab.isActive

///|
pub extern "js" fn Tab::is_dirty(self : Tab) -> Bool =
  #| (tab) => tab.isDirty

///|
pub extern "js" fn Tab::is_pinned(self : Tab) -> Bool =
  #| (tab) => tab.isPinned

///|
pub extern "js" fn Tab::is_preview(self : Tab) -> Bool =
  #| (tab) => tab.isPreview

///|
/// The terminal that shell integration has been activated in.
pub fn TerminalShellIntegrationChangeEvent::new(
  terminal : Terminal,
  shell_integration : TerminalShellIntegration,
) -> TerminalShellIntegrationChangeEvent {
  TerminalShellIntegrationChangeEvent::{
    terminal,
    shellIntegration: shell_integration,
  }
}

///|
/// The terminal that shell integration has been activated in.

///|
/// The shell integration object.

///|
/// The terminal that shell integration has been activated in.
pub fn TerminalShellExecutionStartEvent::new(
  terminal : Terminal,
  shell_integration : TerminalShellIntegration,
  execution : TerminalShellExecution,
) -> TerminalShellExecutionStartEvent {
  TerminalShellExecutionStartEvent::{
    terminal,
    shellIntegration: shell_integration,
    execution,
  }
}

///|
/// The terminal that shell integration has been activated in.

///|
/// The shell integration object.

///|
/// The terminal shell execution that has ended.

///|
/// The terminal that shell integration has been activated in.
pub fn TerminalShellExecutionEndEvent::new(
  terminal : Terminal,
  shell_integration : TerminalShellIntegration,
  execution : TerminalShellExecution,
  exit_code? : Int,
) -> TerminalShellExecutionEndEvent {
  TerminalShellExecutionEndEvent::{
    terminal,
    shellIntegration: shell_integration,
    execution,
    exitCode: exit_code,
  }
}

///|
/// The terminal that shell integration has been activated in.

///|
/// The shell integration object.

///|
/// The terminal shell execution that has ended.

///|
/// The exit code reported by the shell.
///
/// When this is `undefined` it can mean several things:
///
/// - The shell either did not report an exit  code (ie. the shell integration script is
///   misbehaving)
/// - The shell reported a command started before the command finished (eg. a sub-shell was
///   opened).
/// - The user canceled the command via ctrl+c.
/// - The user pressed enter when there was no input.
///
/// Generally this should not happen. Depending on the use case, it may be best to treat this
/// as a failure.
///
/// @example
/// const execution = shellIntegration.executeCommand({
///   command: 'echo',
///   args: ['Hello world']
/// });
/// window.onDidEndTerminalShellExecution(event => {
///   if (event.execution === execution) {
///     if (event.exitCode === undefined) {
/// 	     console.log('Command finished but exit code is unknown');
///     } else if (event.exitCode === 0) {
/// 	     console.log('Command succeeded');
///     } else {
/// 	     console.log('Command failed');
///     }
///   }
/// });

///|
/// QuickPick helpers
pub extern "js" fn QuickPick::show(self : QuickPick[QuickPickItem]) -> Unit =
  #| (picker) => picker.show()

///|
pub extern "js" fn QuickPick::hide(self : QuickPick[QuickPickItem]) -> Unit =
  #| (picker) => picker.hide()

///|
extern "js" fn quick_pick_dispose_raw(picker : JsValue) -> Unit =
  #| (picker) => picker.dispose()

///|
pub fn[T] QuickPick::dispose(self : QuickPick[T]) -> Unit {
  quick_pick_dispose_raw(JsValue::make(self))
}

///|
pub impl[T] AsDisposable for QuickPick[T] with as_disposable(self) {
  disposable_from_js(self)
}

///|
fn[T] quick_pick_cast(picker : QuickPick[T]) -> QuickPick[JsValue] {
  JsValue::make(picker).cast()
}

///|
/// Items to pick from. This can be read and updated by the extension.
pub fn[T] QuickPick::items(self : QuickPick[T]) -> Array[T] {
  QuickPick::quick_pick_items_raw(quick_pick_cast(self)).cast()
}

///|
/// The current value of the filter text.
pub fn[T] QuickPick::value(self : QuickPick[T]) -> String {
  QuickPick::quick_pick_value_raw(quick_pick_cast(self)).cast()
}

///|
/// The current value of the filter text.
pub fn[T] QuickPick::set_value(self : QuickPick[T], value : String) -> Unit {
  QuickPick::quick_pick_set_value_raw(
    quick_pick_cast(self),
    JsValue::make(value),
  )
}

///|
/// Optional placeholder text displayed in the filter text box when no value has been entered.
pub fn[T] QuickPick::placeholder(self : QuickPick[T]) -> String? {
  let raw = QuickPick::quick_pick_placeholder_raw(quick_pick_cast(self))
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Optional placeholder text displayed in the filter text box when no value has been entered.
pub fn[T] QuickPick::set_placeholder(
  self : QuickPick[T],
  value : String,
) -> Unit {
  QuickPick::quick_pick_set_placeholder_raw(
    quick_pick_cast(self),
    JsValue::make(value),
  )
}

///|
/// Optional placeholder text displayed in the filter text box when no value has been entered.
pub fn[T] QuickPick::clear_placeholder(self : QuickPick[T]) -> Unit {
  QuickPick::quick_pick_set_placeholder_raw(
    quick_pick_cast(self),
    JsValue::make(()),
  )
}

///|
/// Optional text that provides instructions or context to the user.
///
/// The prompt is displayed below the input box and above the list of items.
pub fn[T] QuickPick::prompt(self : QuickPick[T]) -> String? {
  let raw = QuickPick::quick_pick_prompt_raw(quick_pick_cast(self))
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Optional text that provides instructions or context to the user.
///
/// The prompt is displayed below the input box and above the list of items.
pub fn[T] QuickPick::set_prompt(self : QuickPick[T], value : String) -> Unit {
  QuickPick::quick_pick_set_prompt_raw(
    quick_pick_cast(self),
    JsValue::make(value),
  )
}

///|
/// Optional text that provides instructions or context to the user.
///
/// The prompt is displayed below the input box and above the list of items.
pub fn[T] QuickPick::clear_prompt(self : QuickPick[T]) -> Unit {
  QuickPick::quick_pick_set_prompt_raw(quick_pick_cast(self), JsValue::make(()))
}

///|
/// An event signaling when the value of the filter text has changed.
pub extern "js" fn QuickPick::on_did_change_value(
  self : QuickPick[QuickPickItem],
) -> Event[String] =
  #| (picker) => picker.onDidChangeValue

///|
/// An event signaling when the user indicated acceptance of the selected item(s).
pub extern "js" fn QuickPick::on_did_accept(
  self : QuickPick[QuickPickItem],
) -> Event[Unit] =
  #| (picker) => picker.onDidAccept

///|
/// Buttons for actions in the UI.
pub extern "js" fn QuickPick::buttons(
  self : QuickPick[QuickPickItem],
) -> Array[QuickInputButton] =
  #| (picker) => picker.buttons

///|
/// Buttons for actions in the UI.
pub extern "js" fn QuickPick::set_buttons(
  self : QuickPick[QuickPickItem],
  value : Array[QuickInputButton],
) -> Unit =
  #| (picker, value) => { picker.buttons = value; }

///|
/// An event signaling when a button was triggered.
///
/// This event fires for buttons stored in the {@link QuickPick.buttons buttons} array. This event does
/// not fire for buttons on a {@link QuickPickItem}.
pub extern "js" fn QuickPick::on_did_trigger_button(
  self : QuickPick[QuickPickItem],
) -> Event[QuickInputButton] =
  #| (picker) => picker.onDidTriggerButton

///|
/// An event signaling when a button in a particular {@link QuickPickItem} was triggered.
///
/// This event does not fire for buttons in the title bar which are part of {@link QuickPick.buttons buttons}.
pub extern "js" fn QuickPick::on_did_trigger_item_button(
  self : QuickPick[QuickPickItem],
) -> Event[QuickPickItemButtonEvent[QuickPickItem]] =
  #| (picker) => picker.onDidTriggerItemButton

///|
/// Items to pick from. This can be read and updated by the extension.
pub fn[T] QuickPick::set_items(self : QuickPick[T], items : Array[T]) -> Unit {
  QuickPick::quick_pick_set_items_raw(
    quick_pick_cast(self),
    JsValue::make(items),
  )
}

///|
/// Determines if multiple items can be selected at the same time. Defaults to `false`.
pub extern "js" fn QuickPick::can_select_many(
  self : QuickPick[QuickPickItem],
) -> Bool =
  #| (picker) => picker.canSelectMany

///|
/// Determines if multiple items can be selected at the same time. Defaults to `false`.
pub extern "js" fn QuickPick::set_can_select_many(
  self : QuickPick[QuickPickItem],
  value : Bool,
) -> Unit =
  #| (picker, value) => { picker.canSelectMany = value; }

///|
/// Determines if the filter text should also be matched against the {@link QuickPickItem.description description} of the items. Defaults to `false`.
pub extern "js" fn QuickPick::match_on_description(
  self : QuickPick[QuickPickItem],
) -> Bool =
  #| (picker) => picker.matchOnDescription

///|
/// Determines if the filter text should also be matched against the {@link QuickPickItem.description description} of the items. Defaults to `false`.
pub extern "js" fn QuickPick::set_match_on_description(
  self : QuickPick[QuickPickItem],
  value : Bool,
) -> Unit =
  #| (picker, value) => { picker.matchOnDescription = value; }

///|
/// Determines if the filter text should also be matched against the {@link QuickPickItem.detail detail} of the items. Defaults to `false`.
pub extern "js" fn QuickPick::match_on_detail(
  self : QuickPick[QuickPickItem],
) -> Bool =
  #| (picker) => picker.matchOnDetail

///|
/// Determines if the filter text should also be matched against the {@link QuickPickItem.detail detail} of the items. Defaults to `false`.
pub extern "js" fn QuickPick::set_match_on_detail(
  self : QuickPick[QuickPickItem],
  value : Bool,
) -> Unit =
  #| (picker, value) => { picker.matchOnDetail = value; }

///|
/// Determines if the scroll position is maintained when the quick pick items are updated. Defaults to `false`.
pub fn QuickPick::keep_scroll_position(
  self : QuickPick[QuickPickItem],
) -> Bool? {
  let raw = QuickPick::quick_pick_keep_scroll_position_raw(self)
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Determines if the scroll position is maintained when the quick pick items are updated. Defaults to `false`.
pub fn QuickPick::set_keep_scroll_position(
  self : QuickPick[QuickPickItem],
  value : Bool,
) -> Unit {
  QuickPick::quick_pick_set_keep_scroll_position_raw(self, JsValue::make(value))
}

///|
/// Determines if the scroll position is maintained when the quick pick items are updated. Defaults to `false`.
pub fn QuickPick::clear_keep_scroll_position(
  self : QuickPick[QuickPickItem],
) -> Unit {
  QuickPick::quick_pick_set_keep_scroll_position_raw(self, JsValue::make(()))
}

///|
/// Active items. This can be read and updated by the extension.
pub fn[T] QuickPick::active_items(self : QuickPick[T]) -> Array[T] {
  QuickPick::quick_pick_active_items_raw(quick_pick_cast(self)).cast()
}

///|
/// Active items. This can be read and updated by the extension.
pub fn[T] QuickPick::set_active_items(
  self : QuickPick[T],
  items : Array[T],
) -> Unit {
  QuickPick::quick_pick_set_active_items_raw(
    quick_pick_cast(self),
    JsValue::make(items),
  )
}

///|
/// An event signaling when the active items have changed.
pub extern "js" fn QuickPick::on_did_change_active(
  self : QuickPick[QuickPickItem],
) -> Event[Array[QuickPickItem]] =
  #| (picker) => picker.onDidChangeActive

///|
/// Selected items. This can be read and updated by the extension.
pub fn[T] QuickPick::selected_items(self : QuickPick[T]) -> Array[T] {
  QuickPick::quick_pick_selected_items_raw(quick_pick_cast(self)).cast()
}

///|
/// Selected items. This can be read and updated by the extension.
pub fn[T] QuickPick::set_selected_items(
  self : QuickPick[T],
  items : Array[T],
) -> Unit {
  QuickPick::quick_pick_set_selected_items_raw(
    quick_pick_cast(self),
    JsValue::make(items),
  )
}

///|
/// An event signaling when the selected items have changed.
pub extern "js" fn QuickPick::on_did_change_selection(
  self : QuickPick[QuickPickItem],
) -> Event[Array[QuickPickItem]] =
  #| (picker) => picker.onDidChangeSelection

///|
pub fn QuickPick::title(self : QuickPick[QuickPickItem]) -> String? {
  let raw = QuickPick::quick_pick_title_raw(self)
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn QuickPick::set_title(
  self : QuickPick[QuickPickItem],
  value : String,
) -> Unit {
  QuickPick::quick_pick_set_title_raw(self, JsValue::make(value))
}

///|
pub fn QuickPick::clear_title(self : QuickPick[QuickPickItem]) -> Unit {
  QuickPick::quick_pick_set_title_raw(self, JsValue::make(()))
}

///|
pub fn QuickPick::step(self : QuickPick[QuickPickItem]) -> Int? {
  let raw = QuickPick::quick_pick_step_raw(self)
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn QuickPick::set_step(
  self : QuickPick[QuickPickItem],
  value : Int,
) -> Unit {
  QuickPick::quick_pick_set_step_raw(self, JsValue::make(value))
}

///|
pub fn QuickPick::clear_step(self : QuickPick[QuickPickItem]) -> Unit {
  QuickPick::quick_pick_set_step_raw(self, JsValue::make(()))
}

///|
pub fn QuickPick::total_steps(self : QuickPick[QuickPickItem]) -> Int? {
  let raw = QuickPick::quick_pick_total_steps_raw(self)
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn QuickPick::set_total_steps(
  self : QuickPick[QuickPickItem],
  value : Int,
) -> Unit {
  QuickPick::quick_pick_set_total_steps_raw(self, JsValue::make(value))
}

///|
pub fn QuickPick::clear_total_steps(self : QuickPick[QuickPickItem]) -> Unit {
  QuickPick::quick_pick_set_total_steps_raw(self, JsValue::make(()))
}

///|
pub extern "js" fn QuickPick::enabled(self : QuickPick[QuickPickItem]) -> Bool =
  #| (picker) => picker.enabled

///|
pub extern "js" fn QuickPick::set_enabled(
  self : QuickPick[QuickPickItem],
  value : Bool,
) -> Unit =
  #| (picker, value) => { picker.enabled = value; }

///|
pub extern "js" fn QuickPick::busy(self : QuickPick[QuickPickItem]) -> Bool =
  #| (picker) => picker.busy

///|
pub extern "js" fn QuickPick::set_busy(
  self : QuickPick[QuickPickItem],
  value : Bool,
) -> Unit =
  #| (picker, value) => { picker.busy = value; }

///|
pub extern "js" fn QuickPick::ignore_focus_out(
  self : QuickPick[QuickPickItem],
) -> Bool =
  #| (picker) => picker.ignoreFocusOut

///|
pub extern "js" fn QuickPick::set_ignore_focus_out(
  self : QuickPick[QuickPickItem],
  value : Bool,
) -> Unit =
  #| (picker, value) => { picker.ignoreFocusOut = value; }

///|
pub extern "js" fn QuickPick::on_did_hide(
  self : QuickPick[QuickPickItem],
) -> Event[Unit] =
  #| (picker) => picker.onDidHide

///|
extern "js" fn QuickPick::quick_pick_keep_scroll_position_raw(
  self : QuickPick[QuickPickItem],
) -> JsValue =
  #| (picker) => picker.keepScrollPosition

///|
extern "js" fn QuickPick::quick_pick_items_raw(
  self : QuickPick[JsValue],
) -> JsValue =
  #| (picker) => picker.items

///|
extern "js" fn QuickPick::quick_pick_set_items_raw(
  self : QuickPick[JsValue],
  value : JsValue,
) -> Unit =
  #| (picker, value) => { picker.items = value; }

///|
extern "js" fn QuickPick::quick_pick_value_raw(
  self : QuickPick[JsValue],
) -> JsValue =
  #| (picker) => picker.value

///|
extern "js" fn QuickPick::quick_pick_set_value_raw(
  self : QuickPick[JsValue],
  value : JsValue,
) -> Unit =
  #| (picker, value) => { picker.value = value; }

///|
extern "js" fn QuickPick::quick_pick_placeholder_raw(
  self : QuickPick[JsValue],
) -> JsValue =
  #| (picker) => picker.placeholder

///|
extern "js" fn QuickPick::quick_pick_set_placeholder_raw(
  self : QuickPick[JsValue],
  value : JsValue,
) -> Unit =
  #| (picker, value) => { picker.placeholder = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn QuickPick::quick_pick_prompt_raw(
  self : QuickPick[JsValue],
) -> JsValue =
  #| (picker) => picker.prompt

///|
extern "js" fn QuickPick::quick_pick_set_prompt_raw(
  self : QuickPick[JsValue],
  value : JsValue,
) -> Unit =
  #| (picker, value) => { picker.prompt = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn QuickPick::quick_pick_set_keep_scroll_position_raw(
  self : QuickPick[QuickPickItem],
  value : JsValue,
) -> Unit =
  #| (picker, value) => { picker.keepScrollPosition = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn QuickPick::quick_pick_title_raw(
  self : QuickPick[QuickPickItem],
) -> JsValue =
  #| (picker) => picker.title

///|
extern "js" fn QuickPick::quick_pick_set_title_raw(
  self : QuickPick[QuickPickItem],
  value : JsValue,
) -> Unit =
  #| (picker, value) => { picker.title = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn QuickPick::quick_pick_step_raw(
  self : QuickPick[QuickPickItem],
) -> JsValue =
  #| (picker) => picker.step

///|
extern "js" fn QuickPick::quick_pick_set_step_raw(
  self : QuickPick[QuickPickItem],
  value : JsValue,
) -> Unit =
  #| (picker, value) => { picker.step = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn QuickPick::quick_pick_total_steps_raw(
  self : QuickPick[QuickPickItem],
) -> JsValue =
  #| (picker) => picker.totalSteps

///|
extern "js" fn QuickPick::quick_pick_set_total_steps_raw(
  self : QuickPick[QuickPickItem],
  value : JsValue,
) -> Unit =
  #| (picker, value) => { picker.totalSteps = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn QuickPick::quick_pick_active_items_raw(
  self : QuickPick[JsValue],
) -> JsValue =
  #| (picker) => picker.activeItems

///|
extern "js" fn QuickPick::quick_pick_set_active_items_raw(
  self : QuickPick[JsValue],
  value : JsValue,
) -> Unit =
  #| (picker, value) => { picker.activeItems = value; }

///|
extern "js" fn QuickPick::quick_pick_selected_items_raw(
  self : QuickPick[JsValue],
) -> JsValue =
  #| (picker) => picker.selectedItems

///|
extern "js" fn QuickPick::quick_pick_set_selected_items_raw(
  self : QuickPick[JsValue],
  value : JsValue,
) -> Unit =
  #| (picker, value) => { picker.selectedItems = value; }

///|
/// InputBox helpers
pub extern "js" fn InputBox::show(self : InputBox) -> Unit =
  #| (input) => input.show()

///|
pub extern "js" fn InputBox::hide(self : InputBox) -> Unit =
  #| (input) => input.hide()

///|
extern "js" fn input_box_dispose_raw(input : InputBox) -> Unit =
  #| (input) => input.dispose()

///|
pub fn InputBox::dispose(self : InputBox) -> Unit {
  input_box_dispose_raw(self)
}

///|
pub impl AsDisposable for InputBox with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// An optional prompt text providing some ask or explanation to the user.

///|
/// The current input value.
pub extern "js" fn InputBox::value(self : InputBox) -> String =
  #| (input) => input.value

///|
/// The current input value.
pub extern "js" fn InputBox::set_value(self : InputBox, value : String) -> Unit =
  #| (input, value) => { input.value = value; }

///|
/// Selection range in the input value.
///
/// Defined as tuple of two numbers where the first is the inclusive start index and the second the
/// exclusive end index. When `undefined` the whole pre-filled value will be selected, when empty
/// (start equals end) only the cursor will be set, otherwise the defined range will be selected.
///
/// This property does not get updated when the user types or makes a selection, but it can be updated
/// by the extension.
pub fn InputBox::value_selection(self : InputBox) -> Array[Int]? {
  let raw = InputBox::input_box_value_selection_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Selection range in the input value.
///
/// Defined as tuple of two numbers where the first is the inclusive start index and the second the
/// exclusive end index. When `undefined` the whole pre-filled value will be selected, when empty
/// (start equals end) only the cursor will be set, otherwise the defined range will be selected.
///
/// This property does not get updated when the user types or makes a selection, but it can be updated
/// by the extension.
pub fn InputBox::set_value_selection(
  self : InputBox,
  value : Array[Int],
) -> Unit {
  InputBox::input_box_set_value_selection_raw(self, JsValue::make(value))
}

///|
/// Selection range in the input value.
///
/// Defined as tuple of two numbers where the first is the inclusive start index and the second the
/// exclusive end index. When `undefined` the whole pre-filled value will be selected, when empty
/// (start equals end) only the cursor will be set, otherwise the defined range will be selected.
///
/// This property does not get updated when the user types or makes a selection, but it can be updated
/// by the extension.
pub fn InputBox::clear_value_selection(self : InputBox) -> Unit {
  InputBox::input_box_set_value_selection_raw(self, JsValue::make(()))
}

///|
/// Optional placeholder text shown when no value has been input.
pub fn InputBox::placeholder(self : InputBox) -> String? {
  let raw = InputBox::input_box_placeholder_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Optional placeholder text shown when no value has been input.
pub fn InputBox::set_placeholder(self : InputBox, value : String) -> Unit {
  InputBox::input_box_set_placeholder_raw(self, JsValue::make(value))
}

///|
/// Optional placeholder text shown when no value has been input.
pub fn InputBox::clear_placeholder(self : InputBox) -> Unit {
  InputBox::input_box_set_placeholder_raw(self, JsValue::make(()))
}

///|
/// Determines if the input value should be hidden. Defaults to `false`.
pub extern "js" fn InputBox::password(self : InputBox) -> Bool =
  #| (input) => input.password

///|
/// Determines if the input value should be hidden. Defaults to `false`.
pub extern "js" fn InputBox::set_password(
  self : InputBox,
  value : Bool,
) -> Unit =
  #| (input, value) => { input.password = value; }

///|
/// An event signaling when the value has changed.
pub extern "js" fn InputBox::on_did_change_value(
  self : InputBox,
) -> Event[String] =
  #| (input) => input.onDidChangeValue

///|
/// An event signaling when the user indicated acceptance of the input value.
pub extern "js" fn InputBox::on_did_accept(self : InputBox) -> Event[Unit] =
  #| (input) => input.onDidAccept

///|
/// Buttons for actions in the UI.
pub extern "js" fn InputBox::buttons(
  self : InputBox,
) -> Array[QuickInputButton] =
  #| (input) => input.buttons

///|
/// Buttons for actions in the UI.
pub extern "js" fn InputBox::set_buttons(
  self : InputBox,
  value : Array[QuickInputButton],
) -> Unit =
  #| (input, value) => { input.buttons = value; }

///|
/// An event signaling when a button was triggered.
pub extern "js" fn InputBox::on_did_trigger_button(
  self : InputBox,
) -> Event[QuickInputButton] =
  #| (input) => input.onDidTriggerButton

///|
/// An optional prompt text providing some ask or explanation to the user.
pub fn InputBox::prompt(self : InputBox) -> String? {
  let raw = InputBox::input_box_prompt_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An optional prompt text providing some ask or explanation to the user.
pub fn InputBox::set_prompt(self : InputBox, value : String) -> Unit {
  InputBox::input_box_set_prompt_raw(self, JsValue::make(value))
}

///|
/// An optional validation message indicating a problem with the current input value.
///
/// By setting a string, the InputBox will use a default {@link InputBoxValidationSeverity} of Error.
/// Returning `undefined` clears the validation message.
pub fn InputBox::validation_message(
  self : InputBox,
) -> InputBoxValidationResult? {
  let raw = InputBox::input_box_validation_message_raw(self)
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    InputBoxValidationResult::from_js(raw)
  }
}

///|
/// An optional validation message indicating a problem with the current input value.
///
/// By setting a string, the InputBox will use a default {@link InputBoxValidationSeverity} of Error.
/// Returning `undefined` clears the validation message.
pub fn InputBox::set_validation_message(
  self : InputBox,
  value : InputBoxValidationResult,
) -> Unit {
  InputBox::input_box_set_validation_message_raw(self, value.to_js())
}

///|
/// An optional validation message indicating a problem with the current input value.
///
/// By setting a string, the InputBox will use a default {@link InputBoxValidationSeverity} of Error.
/// Returning `undefined` clears the validation message.
pub fn InputBox::clear_validation_message(self : InputBox) -> Unit {
  InputBox::input_box_set_validation_message_raw(self, JsValue::make(()))
}

///|
pub fn InputBox::title(self : InputBox) -> String? {
  let raw = InputBox::input_box_title_raw(self)
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn InputBox::set_title(self : InputBox, value : String) -> Unit {
  InputBox::input_box_set_title_raw(self, JsValue::make(value))
}

///|
pub fn InputBox::clear_title(self : InputBox) -> Unit {
  InputBox::input_box_set_title_raw(self, JsValue::make(()))
}

///|
pub fn InputBox::step(self : InputBox) -> Int? {
  let raw = InputBox::input_box_step_raw(self)
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn InputBox::set_step(self : InputBox, value : Int) -> Unit {
  InputBox::input_box_set_step_raw(self, JsValue::make(value))
}

///|
pub fn InputBox::clear_step(self : InputBox) -> Unit {
  InputBox::input_box_set_step_raw(self, JsValue::make(()))
}

///|
pub fn InputBox::total_steps(self : InputBox) -> Int? {
  let raw = InputBox::input_box_total_steps_raw(self)
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn InputBox::set_total_steps(self : InputBox, value : Int) -> Unit {
  InputBox::input_box_set_total_steps_raw(self, JsValue::make(value))
}

///|
pub fn InputBox::clear_total_steps(self : InputBox) -> Unit {
  InputBox::input_box_set_total_steps_raw(self, JsValue::make(()))
}

///|
pub extern "js" fn InputBox::enabled(self : InputBox) -> Bool =
  #| (input) => input.enabled

///|
pub extern "js" fn InputBox::set_enabled(self : InputBox, value : Bool) -> Unit =
  #| (input, value) => { input.enabled = value; }

///|
pub extern "js" fn InputBox::busy(self : InputBox) -> Bool =
  #| (input) => input.busy

///|
pub extern "js" fn InputBox::set_busy(self : InputBox, value : Bool) -> Unit =
  #| (input, value) => { input.busy = value; }

///|
pub extern "js" fn InputBox::ignore_focus_out(self : InputBox) -> Bool =
  #| (input) => input.ignoreFocusOut

///|
pub extern "js" fn InputBox::set_ignore_focus_out(
  self : InputBox,
  value : Bool,
) -> Unit =
  #| (input, value) => { input.ignoreFocusOut = value; }

///|
pub extern "js" fn InputBox::on_did_hide(self : InputBox) -> Event[Unit] =
  #| (input) => input.onDidHide

///|
extern "js" fn InputBox::input_box_validation_message_raw(
  self : InputBox,
) -> JsValue =
  #| (input) => input.validationMessage

///|
extern "js" fn InputBox::input_box_value_selection_raw(
  self : InputBox,
) -> JsValue =
  #| (input) => input.valueSelection

///|
extern "js" fn InputBox::input_box_set_value_selection_raw(
  self : InputBox,
  value : JsValue,
) -> Unit =
  #| (input, value) => { input.valueSelection = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn InputBox::input_box_placeholder_raw(self : InputBox) -> JsValue =
  #| (input) => input.placeholder

///|
extern "js" fn InputBox::input_box_set_placeholder_raw(
  self : InputBox,
  value : JsValue,
) -> Unit =
  #| (input, value) => { input.placeholder = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn InputBox::input_box_prompt_raw(self : InputBox) -> JsValue =
  #| (input) => input.prompt

///|
extern "js" fn InputBox::input_box_set_prompt_raw(
  self : InputBox,
  value : JsValue,
) -> Unit =
  #| (input, value) => { input.prompt = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn InputBox::input_box_set_validation_message_raw(
  self : InputBox,
  value : JsValue,
) -> Unit =
  #| (input, value) => { input.validationMessage = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn InputBox::input_box_title_raw(self : InputBox) -> JsValue =
  #| (input) => input.title

///|
extern "js" fn InputBox::input_box_set_title_raw(
  self : InputBox,
  value : JsValue,
) -> Unit =
  #| (input, value) => { input.title = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn InputBox::input_box_step_raw(self : InputBox) -> JsValue =
  #| (input) => input.step

///|
extern "js" fn InputBox::input_box_set_step_raw(
  self : InputBox,
  value : JsValue,
) -> Unit =
  #| (input, value) => { input.step = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn InputBox::input_box_total_steps_raw(self : InputBox) -> JsValue =
  #| (input) => input.totalSteps

///|
extern "js" fn InputBox::input_box_set_total_steps_raw(
  self : InputBox,
  value : JsValue,
) -> Unit =
  #| (input, value) => { input.totalSteps = value === undefined || value === null ? undefined : value; }

///|
fn[T] option_to_js(value : T?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => JsValue::make(value)
  }
}

///|
fn option_string_or_uri_to_js(value : StringOrUri?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
}

///|
pub fn QuickInputButton::new(
  icon_path : IconPath,
  tooltip? : String,
) -> QuickInputButton {
  QuickInputButton::{ iconPath: icon_path, tooltip }
}

///|
/// The icon for the button.

///|
/// An optional tooltip displayed when hovering over the button.

///|
pub fn QuickInputButtons::new(button : QuickInputButton) -> QuickInputButtons {
  quick_input_buttons_ffi(button)
}

///|

///|
pub extern "js" fn QuickInputButtons::back() -> QuickInputButton =
  #| () => require("vscode").QuickInputButtons.Back

///|
extern "js" fn quick_input_buttons_ffi(
  button : QuickInputButton,
) -> QuickInputButtons =
  #| (button) => ({ button })

///|
/// The button that was pressed.
pub fn[T] QuickPickItemButtonEvent::new(
  button : QuickInputButton,
  item : T,
) -> QuickPickItemButtonEvent[T] {
  QuickPickItemButtonEvent::{ button, item }
}

///|
/// The button that was pressed.
pub fn[T] QuickPickItemButtonEvent::button(
  self : QuickPickItemButtonEvent[T],
) -> QuickInputButton {
  self.button
}

///|
/// The item that the button belongs to.
pub fn[T] QuickPickItemButtonEvent::item(
  self : QuickPickItemButtonEvent[T],
) -> T {
  self.item
}

///|
/// A human-readable string which is rendered prominently.
///
/// Supports rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax.
///
/// **Note:** When {@link QuickPickItem.kind kind} is set to {@link QuickPickItemKind.Default} (so a regular
/// item instead of a separator), it supports rendering of {@link ThemeIcon theme icons} via the
/// `$(<name>)`-syntax.

///|
/// A human-readable string which is rendered prominently.
///
/// Supports rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax.
///
/// **Note:** When {@link QuickPickItem.kind kind} is set to {@link QuickPickItemKind.Default} (so a regular
/// item instead of a separator), it supports rendering of {@link ThemeIcon theme icons} via the
/// `$(<name>)`-syntax.

///|
/// The kind of this item that determines how it is rendered in the quick pick.
///
/// When not specified, the default is {@link QuickPickItemKind.Default}.

///|
/// The kind of this item that determines how it is rendered in the quick pick.
///
/// When not specified, the default is {@link QuickPickItemKind.Default}.

///|
/// The kind of this item that determines how it is rendered in the quick pick.
///
/// When not specified, the default is {@link QuickPickItemKind.Default}.

///|
/// The icon for the item.

///|
/// The icon for the item.

///|
/// The icon for the item.

///|
/// A human-readable string which is rendered less prominently in the same line.
///
/// Supports rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax.
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// A human-readable string which is rendered less prominently in the same line.
///
/// Supports rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax.
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// A human-readable string which is rendered less prominently in the same line.
///
/// Supports rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax.
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// A human-readable string which is rendered less prominently in a separate line.
///
/// Supports rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax.
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// A human-readable string which is rendered less prominently in a separate line.
///
/// Supports rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax.
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// A human-readable string which is rendered less prominently in a separate line.
///
/// Supports rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax.
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// A {@link Uri} representing the resource associated with this item.
///
/// When set, this property is used to automatically derive several item properties if they are not explicitly provided:
/// - **Label**: Derived from the resource's file name when {@link QuickPickItem.label label} is not provided or is empty.
/// - **Description**: Derived from the resource's path when {@link QuickPickItem.description description} is not provided or is empty.
/// - **Icon**: Derived from the current file icon theme when {@link QuickPickItem.iconPath iconPath} is set to
///   {@link ThemeIcon.File} or {@link ThemeIcon.Folder}.

///|
/// A {@link Uri} representing the resource associated with this item.
///
/// When set, this property is used to automatically derive several item properties if they are not explicitly provided:
/// - **Label**: Derived from the resource's file name when {@link QuickPickItem.label label} is not provided or is empty.
/// - **Description**: Derived from the resource's path when {@link QuickPickItem.description description} is not provided or is empty.
/// - **Icon**: Derived from the current file icon theme when {@link QuickPickItem.iconPath iconPath} is set to
///   {@link ThemeIcon.File} or {@link ThemeIcon.Folder}.

///|
/// A {@link Uri} representing the resource associated with this item.
///
/// When set, this property is used to automatically derive several item properties if they are not explicitly provided:
/// - **Label**: Derived from the resource's file name when {@link QuickPickItem.label label} is not provided or is empty.
/// - **Description**: Derived from the resource's path when {@link QuickPickItem.description description} is not provided or is empty.
/// - **Icon**: Derived from the current file icon theme when {@link QuickPickItem.iconPath iconPath} is set to
///   {@link ThemeIcon.File} or {@link ThemeIcon.Folder}.

///|
/// Optional flag indicating if this item is initially selected.
///
/// This is only honored when using the {@link window.showQuickPick showQuickPick} API. To do the same
/// thing with the {@link window.createQuickPick createQuickPick} API, simply set the
/// {@link QuickPick.selectedItems selectedItems} to the items you want selected initially.
///
/// **Note:** This is only honored when the picker allows multiple selections.
///
/// @see {@link QuickPickOptions.canPickMany}
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// Optional flag indicating if this item is initially selected.
///
/// This is only honored when using the {@link window.showQuickPick showQuickPick} API. To do the same
/// thing with the {@link window.createQuickPick createQuickPick} API, simply set the
/// {@link QuickPick.selectedItems selectedItems} to the items you want selected initially.
///
/// **Note:** This is only honored when the picker allows multiple selections.
///
/// @see {@link QuickPickOptions.canPickMany}
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// Optional flag indicating if this item is initially selected.
///
/// This is only honored when using the {@link window.showQuickPick showQuickPick} API. To do the same
/// thing with the {@link window.createQuickPick createQuickPick} API, simply set the
/// {@link QuickPick.selectedItems selectedItems} to the items you want selected initially.
///
/// **Note:** This is only honored when the picker allows multiple selections.
///
/// @see {@link QuickPickOptions.canPickMany}
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// Determines if this item is always shown, even when filtered out by the user's input.
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// Determines if this item is always shown, even when filtered out by the user's input.
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// Determines if this item is always shown, even when filtered out by the user's input.
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// Optional buttons that will be rendered on this particular item.
///
/// These buttons will trigger an {@link QuickPickItemButtonEvent} when pressed. Buttons are only rendered
/// when using a quick pick created by the {@link window.createQuickPick createQuickPick} API. Buttons are
/// not rendered when using the {@link window.showQuickPick showQuickPick} API.
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// Optional buttons that will be rendered on this particular item.
///
/// These buttons will trigger an {@link QuickPickItemButtonEvent} when pressed. Buttons are only rendered
/// when using a quick pick created by the {@link window.createQuickPick createQuickPick} API. Buttons are
/// not rendered when using the {@link window.showQuickPick showQuickPick} API.
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
/// Optional buttons that will be rendered on this particular item.
///
/// These buttons will trigger an {@link QuickPickItemButtonEvent} when pressed. Buttons are only rendered
/// when using a quick pick created by the {@link window.createQuickPick createQuickPick} API. Buttons are
/// not rendered when using the {@link window.showQuickPick showQuickPick} API.
///
/// **Note:** This property is ignored when {@link QuickPickItem.kind kind} is set to
/// {@link QuickPickItemKind.Separator}.

///|
pub fn QuickPickItem::new(
  label : String,
  kind? : QuickPickItemKind,
  icon_path? : IconPath,
  description? : String,
  detail? : String,
  resource_uri? : Uri,
  picked? : Bool,
  always_show? : Bool,
  buttons? : Array[QuickInputButton],
) -> QuickPickItem {
  QuickPickItem::{
    label,
    kind,
    iconPath: icon_path,
    description,
    detail,
    resourceUri: resource_uri,
    picked,
    alwaysShow: always_show,
    buttons,
  }
}

///|
/// The validation message to display to the user.

///|
/// The severity level of the validation message.
///
/// **Note:** When using {@link InputBoxValidationSeverity.Error}, the user will not be able to accept
/// the input (e.g., by pressing Enter). {@link InputBoxValidationSeverity.Info Info} and
/// {@link InputBoxValidationSeverity.Warning Warning} severities will still allow the input to be accepted.

///|
pub fn InputBoxValidationMessage::new(
  message : String,
  severity : InputBoxValidationSeverity,
) -> InputBoxValidationMessage {
  InputBoxValidationMessage::{ message, severity }
}

///|
/// Progress helpers
pub fn[T] Progress::report(self : Progress[T], value : T) -> Unit {
  let raw : Progress[JsValue] = JsValue::make(self).cast()
  progress_report_raw(raw, JsValue::make(value))
}

///|
extern "js" fn progress_report_raw(
  progress : Progress[JsValue],
  value : JsValue,
) -> Unit =
  #| (progress, value) => progress.report(value)

///|
extern "js" fn file_system_watcher_dispose_raw(
  watcher : FileSystemWatcher,
) -> Unit =
  #| (watcher) => watcher.dispose()

///|
pub fn FileSystemWatcher::dispose(self : FileSystemWatcher) -> Unit {
  file_system_watcher_dispose_raw(self)
}

///|
pub impl AsDisposable for FileSystemWatcher with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// true if this file system watcher has been created such that
/// it ignores creation file system events.
pub extern "js" fn FileSystemWatcher::ignore_create_events(
  self : FileSystemWatcher,
) -> Bool =
  #| (watcher) => watcher.ignoreCreateEvents

///|
/// true if this file system watcher has been created such that
/// it ignores change file system events.
pub extern "js" fn FileSystemWatcher::ignore_change_events(
  self : FileSystemWatcher,
) -> Bool =
  #| (watcher) => watcher.ignoreChangeEvents

///|
/// true if this file system watcher has been created such that
/// it ignores delete file system events.
pub extern "js" fn FileSystemWatcher::ignore_delete_events(
  self : FileSystemWatcher,
) -> Bool =
  #| (watcher) => watcher.ignoreDeleteEvents

///|
/// An event which fires on file/folder creation.
pub extern "js" fn FileSystemWatcher::on_did_create(
  self : FileSystemWatcher,
) -> Event[Uri] =
  #| (watcher) => watcher.onDidCreate

///|
/// An event which fires on file/folder change.
pub extern "js" fn FileSystemWatcher::on_did_change(
  self : FileSystemWatcher,
) -> Event[Uri] =
  #| (watcher) => watcher.onDidChange

///|
/// An event which fires on file/folder deletion.
pub extern "js" fn FileSystemWatcher::on_did_delete(
  self : FileSystemWatcher,
) -> Event[Uri] =
  #| (watcher) => watcher.onDidDelete

///|

///|

///|
extern "js" fn FileSystem::stat_promise(
  self : FileSystem,
  uri : Uri,
) -> @js_async.Promise[JsValue] =
  #| (fs, uri) => fs.stat(uri)

///|
/// Retrieve metadata about a file.
///
/// @param uri The uri of the file to retrieve metadata about.
/// @returns The file metadata about the file.
pub async fn FileSystem::stat(self : FileSystem, uri : Uri) -> FileStat {
  FileStat::from_js(
    @js_async.Promise::wait(FileSystem::stat_promise(self, uri)),
  )
}

///|
extern "js" fn FileSystem::read_directory_promise(
  self : FileSystem,
  uri : Uri,
) -> @js_async.Promise[Array[DirectoryEntry]] =
  #| (fs, uri) => fs.readDirectory(uri)

///|
/// Retrieve all entries of a {@link FileType.Directory directory}.
///
/// @param uri The uri of the folder.
/// @returns An array of name/type-tuples or a thenable that resolves to such.
pub async fn FileSystem::read_directory(
  self : FileSystem,
  uri : Uri,
) -> Array[DirectoryEntry] {
  @js_async.Promise::wait(FileSystem::read_directory_promise(self, uri))
}

///|
extern "js" fn FileSystem::create_directory_promise(
  self : FileSystem,
  uri : Uri,
) -> @js_async.Promise[Unit] =
  #| (fs, uri) => fs.createDirectory(uri)

///|
/// Create a new directory (Note, that new files are created via `write`-calls).
///
/// *Note* that missing directories are created automatically, e.g this call has
/// `mkdirp` semantics.
///
/// @param uri The uri of the new folder.
pub async fn FileSystem::create_directory(self : FileSystem, uri : Uri) -> Unit {
  @js_async.Promise::wait(FileSystem::create_directory_promise(self, uri))
}

///|
extern "js" fn FileSystem::read_file_promise(
  self : FileSystem,
  uri : Uri,
) -> @js_async.Promise[Uint8Array] =
  #| (fs, uri) => fs.readFile(uri)

///|
/// Read the entire contents of a file.
///
/// @param uri The uri of the file.
/// @returns An array of bytes or a thenable that resolves to such.
pub async fn FileSystem::read_file(self : FileSystem, uri : Uri) -> Bytes {
  bytes_from_uint8_array(
    @js_async.Promise::wait(FileSystem::read_file_promise(self, uri)),
  )
}

///|
extern "js" fn FileSystem::write_file_promise(
  self : FileSystem,
  uri : Uri,
  content : Uint8Array,
) -> @js_async.Promise[Unit] =
  #| (fs, uri, content) => fs.writeFile(uri, content)

///|
/// Write data to a file, replacing its entire contents.
///
/// @param uri The uri of the file.
/// @param content The new content of the file.
pub async fn FileSystem::write_file(
  self : FileSystem,
  uri : Uri,
  content : Bytes,
) -> Unit {
  @js_async.Promise::wait(
    FileSystem::write_file_promise(self, uri, bytes_to_uint8_array(content)),
  )
}

///|
extern "js" fn FileSystem::delete_promise(
  self : FileSystem,
  uri : Uri,
  recursive : JsValue,
  use_trash : JsValue,
) -> @js_async.Promise[Unit] =
  #| (fs, uri, recursive, useTrash) => {
  #|   const options = {};
  #|   if (recursive !== undefined && recursive !== null) options.recursive = recursive;
  #|   if (useTrash !== undefined && useTrash !== null) options.useTrash = useTrash;
  #|   return Object.keys(options).length === 0
  #|     ? fs.delete(uri)
  #|     : fs.delete(uri, options);
  #| }

///|
/// Delete a file.
///
/// @param uri The resource that is to be deleted.
/// @param options Defines if trash can should be used and if deletion of folders is recursive
pub async fn FileSystem::delete(
  self : FileSystem,
  uri : Uri,
  recursive? : Bool,
  use_trash? : Bool,
) -> Unit {
  @js_async.Promise::wait(
    FileSystem::delete_promise(
      self,
      uri,
      option_to_js(recursive),
      option_to_js(use_trash),
    ),
  )
}

///|
extern "js" fn FileSystem::rename_promise(
  self : FileSystem,
  source : Uri,
  target : Uri,
  overwrite : JsValue,
) -> @js_async.Promise[Unit] =
  #| (fs, source, target, overwrite) => {
  #|   const options = {};
  #|   if (overwrite !== undefined && overwrite !== null) options.overwrite = overwrite;
  #|   return Object.keys(options).length === 0
  #|     ? fs.rename(source, target)
  #|     : fs.rename(source, target, options);
  #| }

///|
/// Rename a file or folder.
///
/// @param source The existing file.
/// @param target The new location.
/// @param options Defines if existing files should be overwritten.
pub async fn FileSystem::rename(
  self : FileSystem,
  source : Uri,
  target : Uri,
  overwrite? : Bool,
) -> Unit {
  @js_async.Promise::wait(
    FileSystem::rename_promise(self, source, target, option_to_js(overwrite)),
  )
}

///|
extern "js" fn FileSystem::copy_promise(
  self : FileSystem,
  source : Uri,
  target : Uri,
  overwrite : JsValue,
) -> @js_async.Promise[Unit] =
  #| (fs, source, target, overwrite) => {
  #|   const options = {};
  #|   if (overwrite !== undefined && overwrite !== null) options.overwrite = overwrite;
  #|   return Object.keys(options).length === 0
  #|     ? fs.copy(source, target)
  #|     : fs.copy(source, target, options);
  #| }

///|
/// Copy files or folders.
///
/// @param source The existing file.
/// @param target The destination location.
/// @param options Defines if existing files should be overwritten.
pub async fn FileSystem::copy(
  self : FileSystem,
  source : Uri,
  target : Uri,
  overwrite? : Bool,
) -> Unit {
  @js_async.Promise::wait(
    FileSystem::copy_promise(self, source, target, option_to_js(overwrite)),
  )
}

///|
/// Check if a given file system supports writing files.
///
/// Keep in mind that just because a file system supports writing, that does
/// not mean that writes will always succeed. There may be permissions issues
/// or other errors that prevent writing a file.
///
/// @param scheme The scheme of the filesystem, for example `file` or `git`.
///
/// @returns `true` if the file system supports writing, `false` if it does not
/// support writing (i.e. it is readonly), and `undefined` if the editor does not
/// know about the filesystem.
pub fn FileSystem::is_writable_file_system(
  self : FileSystem,
  scheme : String,
) -> Bool? {
  let raw = FileSystem::file_system_is_writable_raw(self, scheme)
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
extern "js" fn FileSystem::file_system_is_writable_raw(
  self : FileSystem,
  scheme : String,
) -> JsValue =
  #| (fs, scheme) => fs.isWritableFileSystem(scheme)

///|
extern "js" fn uri_handler_handle_uri_promise_ffi(
  handler : UriHandler,
  uri : Uri,
) -> @js_async.Promise[Unit] =
  #| (handler, uri) => Promise.resolve(handler.handleUri(uri))

///|
/// Handle the provided system-wide {@link Uri}.
///
/// @see {@link window.registerUriHandler}.
pub async fn UriHandler::handle_uri(self : UriHandler, uri : Uri) -> Unit {
  @js_async.Promise::wait(uri_handler_handle_uri_promise_ffi(self, uri))
}

///|
extern "js" fn webview_panel_serializer_deserialize_webview_panel_promise_ffi(
  serializer : WebviewPanelSerializer,
  panel : WebviewPanel,
  state : Any,
) -> @js_async.Promise[Unit] =
  #| (serializer, panel, state) => Promise.resolve(serializer.deserializeWebviewPanel(panel, state))

///|
/// Restore a webview panel from its serialized `state`.
///
/// Called when a serialized webview first becomes visible.
///
/// @param webviewPanel Webview panel to restore. The serializer should take ownership of this panel. The
/// serializer must restore the webview's `.html` and hook up all webview events.
/// @param state Persisted state from the webview content.
///
/// @returns Thenable indicating that the webview has been fully restored.
pub async fn WebviewPanelSerializer::deserialize_webview_panel(
  self : WebviewPanelSerializer,
  panel : WebviewPanel,
  state : Any,
) -> Unit {
  @js_async.Promise::wait(
    webview_panel_serializer_deserialize_webview_panel_promise_ffi(
      self, panel, state,
    ),
  )
}

///|
fn[T] tree_view_cast(view : TreeView[T]) -> TreeView[JsValue] {
  JsValue::make(view).cast()
}

///|
/// Event that is fired when an element is expanded
pub fn[T] TreeView::on_did_expand_element(
  self : TreeView[T],
) -> Event[TreeViewExpansionEvent[T]] {
  tree_view_on_did_expand_element_raw(tree_view_cast(self)).cast()
}

///|
/// Event that is fired when an element is collapsed
pub fn[T] TreeView::on_did_collapse_element(
  self : TreeView[T],
) -> Event[TreeViewExpansionEvent[T]] {
  tree_view_on_did_collapse_element_raw(tree_view_cast(self)).cast()
}

///|
/// Currently selected elements.
pub fn[T] TreeView::selection(self : TreeView[T]) -> Array[T] {
  tree_view_selection_raw(tree_view_cast(self)).cast()
}

///|
/// Event that is fired when the {@link TreeView.selection selection} has changed
pub fn[T] TreeView::on_did_change_selection(
  self : TreeView[T],
) -> Event[TreeViewSelectionChangeEvent[T]] {
  tree_view_on_did_change_selection_raw(tree_view_cast(self)).cast()
}

///|
/// `true` if the {@link TreeView tree view} is visible otherwise `false`.
pub fn[T] TreeView::visible(self : TreeView[T]) -> Bool {
  tree_view_visible_raw(tree_view_cast(self))
}

///|
/// Event that is fired when {@link TreeView.visible visibility} has changed
pub fn[T] TreeView::on_did_change_visibility(
  self : TreeView[T],
) -> Event[TreeViewVisibilityChangeEvent] {
  tree_view_on_did_change_visibility_raw(tree_view_cast(self)).cast()
}

///|
/// An event to signal that an element or root has either been checked or unchecked.
pub fn[T] TreeView::on_did_change_checkbox_state(
  self : TreeView[T],
) -> Event[TreeCheckboxChangeEvent[T]] {
  tree_view_on_did_change_checkbox_state_raw(tree_view_cast(self)).cast()
}

///|
/// An optional human-readable message that will be rendered in the view.
/// Setting the message to null, undefined, or empty string will remove the message from the view.
pub fn[T] TreeView::message(self : TreeView[T]) -> String? {
  let raw = TreeView::tree_view_message_raw(tree_view_cast(self))
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An optional human-readable message that will be rendered in the view.
/// Setting the message to null, undefined, or empty string will remove the message from the view.
pub fn[T] TreeView::set_message(self : TreeView[T], value : String) -> Unit {
  TreeView::tree_view_set_message_raw(
    tree_view_cast(self),
    JsValue::make(value),
  )
}

///|
/// An optional human-readable message that will be rendered in the view.
/// Setting the message to null, undefined, or empty string will remove the message from the view.
pub fn[T] TreeView::clear_message(self : TreeView[T]) -> Unit {
  TreeView::tree_view_set_message_raw(tree_view_cast(self), JsValue::make(()))
}

///|
/// The tree view title is initially taken from the extension package.json
/// Changes to the title property will be properly reflected in the UI in the title of the view.
pub fn[T] TreeView::title(self : TreeView[T]) -> String? {
  let raw = TreeView::tree_view_title_raw(tree_view_cast(self))
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The tree view title is initially taken from the extension package.json
/// Changes to the title property will be properly reflected in the UI in the title of the view.
pub fn[T] TreeView::set_title(self : TreeView[T], value : String) -> Unit {
  TreeView::tree_view_set_title_raw(tree_view_cast(self), JsValue::make(value))
}

///|
/// The tree view title is initially taken from the extension package.json
/// Changes to the title property will be properly reflected in the UI in the title of the view.
pub fn[T] TreeView::clear_title(self : TreeView[T]) -> Unit {
  TreeView::tree_view_set_title_raw(tree_view_cast(self), JsValue::make(()))
}

///|
/// An optional human-readable description which is rendered less prominently in the title of the view.
/// Setting the title description to null, undefined, or empty string will remove the description from the view.
pub fn[T] TreeView::description(self : TreeView[T]) -> String? {
  let raw = TreeView::tree_view_description_raw(tree_view_cast(self))
  if JsValue::is_null_or_undefined(raw) {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An optional human-readable description which is rendered less prominently in the title of the view.
/// Setting the title description to null, undefined, or empty string will remove the description from the view.
pub fn[T] TreeView::set_description(self : TreeView[T], value : String) -> Unit {
  TreeView::tree_view_set_description_raw(
    tree_view_cast(self),
    JsValue::make(value),
  )
}

///|
/// An optional human-readable description which is rendered less prominently in the title of the view.
/// Setting the title description to null, undefined, or empty string will remove the description from the view.
pub fn[T] TreeView::clear_description(self : TreeView[T]) -> Unit {
  TreeView::tree_view_set_description_raw(
    tree_view_cast(self),
    JsValue::make(()),
  )
}

///|
fn view_badge_to_js(value : ViewBadge) -> JsValue {
  view_badge_to_js_ffi(value.value, value.tooltip)
}

///|
fn view_badge_from_js(value : JsValue) -> ViewBadge? {
  let value_raw = view_badge_value_raw(value)
  let tooltip_raw = view_badge_tooltip_raw(value)
  if value_raw.is_null_or_undefined() || tooltip_raw.is_null_or_undefined() {
    None
  } else {
    Some(ViewBadge::{ value: value_raw.cast(), tooltip: tooltip_raw.cast() })
  }
}

///|
/// The badge to display for this TreeView.
/// To remove the badge, set to undefined.
pub fn[T] TreeView::badge(self : TreeView[T]) -> ViewBadge? {
  let raw = TreeView::tree_view_badge_raw(tree_view_cast(self))
  view_badge_from_js(raw)
}

///|
/// The badge to display for this TreeView.
/// To remove the badge, set to undefined.
pub fn[T] TreeView::set_badge(self : TreeView[T], value : ViewBadge) -> Unit {
  TreeView::tree_view_set_badge_raw(
    tree_view_cast(self),
    view_badge_to_js(value),
  )
}

///|
/// The badge to display for this TreeView.
/// To remove the badge, set to undefined.
pub fn[T] TreeView::clear_badge(self : TreeView[T]) -> Unit {
  TreeView::tree_view_set_badge_raw(tree_view_cast(self), JsValue::make(()))
}

///|
fn[T] TreeView::reveal_promise(
  self : TreeView[T],
  element : T,
  select : JsValue,
  focus : JsValue,
  expand : JsValue,
  expand_levels : JsValue,
) -> @js_async.Promise[Unit] {
  tree_view_reveal_promise_raw(
    tree_view_cast(self),
    JsValue::make(element),
    select,
    focus,
    expand,
    expand_levels,
  )
}

///|
/// Reveals the given element in the tree view.
/// If the tree view is not visible then the tree view is shown and element is revealed.
///
/// By default revealed element is selected.
/// In order to not to select, set the option `select` to `false`.
/// In order to focus, set the option `focus` to `true`.
/// In order to expand the revealed element, set the option `expand` to `true`. To expand recursively set `expand` to the number of levels to expand.
///
/// * *NOTE:* You can expand only to 3 levels maximum.
/// * *NOTE:* The {@link TreeDataProvider} that the `TreeView` {@link window.createTreeView is registered with} with must implement {@link TreeDataProvider.getParent getParent} method to access this API.
pub async fn[T] TreeView::reveal(
  self : TreeView[T],
  element : T,
  select? : Bool,
  focus? : Bool,
  expand? : Bool,
  expand_levels? : Int,
) -> Unit {
  @js_async.Promise::wait(
    TreeView::reveal_promise(
      self,
      element,
      option_to_js(select),
      option_to_js(focus),
      option_to_js(expand),
      option_to_js(expand_levels),
    ),
  )
}

///|
extern "js" fn tree_view_reveal_promise_raw(
  view : TreeView[JsValue],
  element : JsValue,
  select : JsValue,
  focus : JsValue,
  expand : JsValue,
  expand_levels : JsValue,
) -> @js_async.Promise[Unit] =
  #| (view, element, select, focus, expand, expandLevels) => {
  #|   const options = {};
  #|   if (select !== undefined && select !== null) options.select = select;
  #|   if (focus !== undefined && focus !== null) options.focus = focus;
  #|   if (expandLevels !== undefined && expandLevels !== null) {
  #|     options.expand = expandLevels;
  #|   } else if (expand !== undefined && expand !== null) {
  #|     options.expand = expand;
  #|   }
  #|   return Object.keys(options).length === 0
  #|     ? view.reveal(element)
  #|     : view.reveal(element, options);
  #| }

///|
extern "js" fn tree_view_on_did_expand_element_raw(
  view : TreeView[JsValue],
) -> JsValue =
  #| (view) => view.onDidExpandElement

///|
extern "js" fn tree_view_on_did_collapse_element_raw(
  view : TreeView[JsValue],
) -> JsValue =
  #| (view) => view.onDidCollapseElement

///|
extern "js" fn tree_view_selection_raw(view : TreeView[JsValue]) -> JsValue =
  #| (view) => view.selection

///|
extern "js" fn tree_view_on_did_change_selection_raw(
  view : TreeView[JsValue],
) -> JsValue =
  #| (view) => view.onDidChangeSelection

///|
extern "js" fn tree_view_visible_raw(view : TreeView[JsValue]) -> Bool =
  #| (view) => view.visible

///|
extern "js" fn tree_view_on_did_change_visibility_raw(
  view : TreeView[JsValue],
) -> JsValue =
  #| (view) => view.onDidChangeVisibility

///|
extern "js" fn tree_view_on_did_change_checkbox_state_raw(
  view : TreeView[JsValue],
) -> JsValue =
  #| (view) => view.onDidChangeCheckboxState

///|
extern "js" fn TreeView::tree_view_message_raw(
  self : TreeView[JsValue],
) -> JsValue =
  #| (view) => view.message

///|
extern "js" fn TreeView::tree_view_set_message_raw(
  self : TreeView[JsValue],
  value : JsValue,
) -> Unit =
  #| (view, value) => { view.message = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn TreeView::tree_view_title_raw(
  self : TreeView[JsValue],
) -> JsValue =
  #| (view) => view.title

///|
extern "js" fn TreeView::tree_view_set_title_raw(
  self : TreeView[JsValue],
  value : JsValue,
) -> Unit =
  #| (view, value) => { view.title = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn TreeView::tree_view_description_raw(
  self : TreeView[JsValue],
) -> JsValue =
  #| (view) => view.description

///|
extern "js" fn TreeView::tree_view_set_description_raw(
  self : TreeView[JsValue],
  value : JsValue,
) -> Unit =
  #| (view, value) => { view.description = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn TreeView::tree_view_badge_raw(
  self : TreeView[JsValue],
) -> JsValue =
  #| (view) => view.badge

///|
extern "js" fn TreeView::tree_view_set_badge_raw(
  self : TreeView[JsValue],
  value : JsValue,
) -> Unit =
  #| (view, value) => { view.badge = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn view_badge_to_js_ffi(value : Int, tooltip : String) -> JsValue =
  #| (value, tooltip) => ({ value, tooltip })

///|
extern "js" fn view_badge_value_raw(value : JsValue) -> JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.value

///|
extern "js" fn view_badge_tooltip_raw(value : JsValue) -> JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.tooltip

///|
/// Element that is expanded or collapsed.
pub fn[T] TreeViewExpansionEvent::new(element : T) -> TreeViewExpansionEvent[T] {
  TreeViewExpansionEvent::{ element, }
}

///|
/// Element that is expanded or collapsed.
pub fn[T] TreeViewExpansionEvent::element(
  self : TreeViewExpansionEvent[T],
) -> T {
  self.element
}

///|
/// Selected elements.
pub fn[T] TreeViewSelectionChangeEvent::new(
  selection : Array[T],
) -> TreeViewSelectionChangeEvent[T] {
  TreeViewSelectionChangeEvent::{ selection, }
}

///|
/// Selected elements.
pub fn[T] TreeViewSelectionChangeEvent::selection(
  self : TreeViewSelectionChangeEvent[T],
) -> Array[T] {
  self.selection
}

///|
/// `true` if the {@link TreeView tree view} is visible otherwise `false`.
pub fn TreeViewVisibilityChangeEvent::new(
  visible : Bool,
) -> TreeViewVisibilityChangeEvent {
  TreeViewVisibilityChangeEvent::{ visible, }
}

///|
/// `true` if the {@link TreeView tree view} is visible otherwise `false`.

///|
/// The items that were checked or unchecked.
pub fn[T] TreeCheckboxChangeEvent::items(
  self : TreeCheckboxChangeEvent[T],
) -> Array[TreeCheckboxChangeItem[T]] {
  let raw_items : Array[JsValue] = tree_checkbox_change_event_items_raw(
    JsValue::make(self),
  ).cast()
  let items : Array[TreeCheckboxChangeItem[T]] = []
  for raw_item in raw_items {
    items.push(tree_checkbox_change_item_from_js(raw_item))
  }
  items
}

///|
pub fn[T] TreeCheckboxChangeItem::element(
  self : TreeCheckboxChangeItem[T],
) -> T {
  self.element
}

///|
pub fn[T] TreeCheckboxChangeItem::state(
  self : TreeCheckboxChangeItem[T],
) -> TreeItemCheckboxState {
  self.state
}

///|
pub fn[T] TreeCheckboxChangeItem::new(
  element : T,
  state : TreeItemCheckboxState,
) -> TreeCheckboxChangeItem[T] {
  TreeCheckboxChangeItem::{ element, state }
}

///|
fn[T] tree_checkbox_change_item_from_js(
  raw : JsValue,
) -> TreeCheckboxChangeItem[T] {
  TreeCheckboxChangeItem::{
    element: tree_checkbox_change_item_element_raw(raw).cast(),
    state: tree_checkbox_change_item_state_raw(raw),
  }
}

///|
extern "js" fn tree_checkbox_change_event_items_raw(event : JsValue) -> JsValue =
  #| (event) => event.items

///|
extern "js" fn tree_checkbox_change_item_element_raw(item : JsValue) -> JsValue =
  #| (item) => item[0]

///|
extern "js" fn tree_checkbox_change_item_state_raw(
  item : JsValue,
) -> TreeItemCheckboxState =
  #| (item) => item[1]

///|
/// The associated uri for this workspace folder.
///
/// *Note:* The {@link Uri}-type was intentionally chosen such that future releases of the editor can support
/// workspace folders that are not stored on the local disk, e.g. `ftp://server/workspaces/foo`.
pub extern "js" fn WorkspaceFolder::new(
  uri : Uri,
  name : String,
  index : Int,
) -> WorkspaceFolder =
  #| (uri, name, index) => ({ uri, name, index })

///|
/// The associated uri for this workspace folder.
///
/// *Note:* The {@link Uri}-type was intentionally chosen such that future releases of the editor can support
/// workspace folders that are not stored on the local disk, e.g. `ftp://server/workspaces/foo`.
pub extern "js" fn WorkspaceFolder::uri(self : WorkspaceFolder) -> Uri =
  #| (folder) => folder.uri

///|
/// The name of this workspace folder. Defaults to the basename of its {@link Uri.path uri-path}
pub extern "js" fn WorkspaceFolder::name(self : WorkspaceFolder) -> String =
  #| (folder) => folder.name

///|
/// The ordinal number of this workspace folder.
pub extern "js" fn WorkspaceFolder::index(self : WorkspaceFolder) -> Int =
  #| (folder) => folder.index

///|
/// The name of this workspace folder. Defaults to
/// the basename of its {@link Uri.path uri-path}

///|
/// The ordinal number of this workspace folder.

///|
/// Added workspace folders.
pub fn WorkspaceFoldersChangeEvent::new(
  added? : Array[WorkspaceFolder] = [],
  removed? : Array[WorkspaceFolder] = [],
) -> WorkspaceFoldersChangeEvent {
  WorkspaceFoldersChangeEvent::{ added, removed }
}

///|

///|
/// Removed workspace folders.

///|
/// Workspace configuration helpers
pub extern "js" fn WorkspaceConfiguration::key(
  self : WorkspaceConfiguration,
) -> String =
  #| (config) => config.key

///|
extern "js" fn WorkspaceConfiguration::workspace_configuration_get_raw(
  self : WorkspaceConfiguration,
  section : String,
  default_value : JsValue,
) -> JsValue =
  #| (config, section, defaultValue) =>
  #|   defaultValue === undefined
  #|     ? config.get(section)
  #|     : config.get(section, defaultValue)

///|
extern "js" fn WorkspaceConfiguration::workspace_configuration_inspect_raw(
  self : WorkspaceConfiguration,
  section : String,
) -> JsValue =
  #| (config, section) => config.inspect(section)

///|
extern "js" fn configuration_inspect_default_raw(info : JsValue) -> JsValue =
  #| (info) => info.defaultValue

///|
extern "js" fn configuration_inspect_global_raw(info : JsValue) -> JsValue =
  #| (info) => info.globalValue

///|
extern "js" fn configuration_inspect_workspace_raw(info : JsValue) -> JsValue =
  #| (info) => info.workspaceValue

///|
extern "js" fn configuration_inspect_workspace_folder_raw(
  info : JsValue,
) -> JsValue =
  #| (info) => info.workspaceFolderValue

///|
extern "js" fn configuration_inspect_default_language_raw(
  info : JsValue,
) -> JsValue =
  #| (info) => info.defaultLanguageValue

///|
extern "js" fn configuration_inspect_global_language_raw(
  info : JsValue,
) -> JsValue =
  #| (info) => info.globalLanguageValue

///|
extern "js" fn configuration_inspect_workspace_language_raw(
  info : JsValue,
) -> JsValue =
  #| (info) => info.workspaceLanguageValue

///|
extern "js" fn configuration_inspect_workspace_folder_language_raw(
  info : JsValue,
) -> JsValue =
  #| (info) => info.workspaceFolderLanguageValue

///|
extern "js" fn configuration_inspect_language_ids_raw(
  info : JsValue,
) -> JsValue =
  #| (info) => info.languageIds

///|
extern "js" fn configuration_inspect_key_raw(info : JsValue) -> String =
  #| (info) => info.key

///|
/// Return a value from this configuration.
///
/// @param section Configuration name, supports _dotted_ names.
/// @returns The value `section` denotes or `undefined`.
pub fn[T] WorkspaceConfiguration::get(
  self : WorkspaceConfiguration,
  section : String,
) -> T? {
  let raw = WorkspaceConfiguration::workspace_configuration_get_raw(
    self,
    section,
    JsValue::make(()),
  )
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Return a value from this configuration.
///
/// @param section Configuration name, supports _dotted_ names.
/// @returns The value `section` denotes or `undefined`.
pub fn[T] WorkspaceConfiguration::get_or(
  self : WorkspaceConfiguration,
  section : String,
  default_value : T,
) -> T {
  WorkspaceConfiguration::workspace_configuration_get_raw(
    self,
    section,
    JsValue::make(default_value),
  ).cast()
}

///|
/// Return a value from this configuration.
///
/// @param section Configuration name, supports _dotted_ names.
/// @returns The value `section` denotes or `undefined`.
pub fn WorkspaceConfiguration::get_string_or(
  self : WorkspaceConfiguration,
  section : String,
  default_value : String,
) -> String {
  WorkspaceConfiguration::get_or(self, section, default_value)
}

///|
/// Return a value from this configuration.
///
/// @param section Configuration name, supports _dotted_ names.
/// @returns The value `section` denotes or `undefined`.
pub fn WorkspaceConfiguration::get_bool_or(
  self : WorkspaceConfiguration,
  section : String,
  default_value : Bool,
) -> Bool {
  WorkspaceConfiguration::get_or(self, section, default_value)
}

///|
/// Return a value from this configuration.
///
/// @param section Configuration name, supports _dotted_ names.
/// @returns The value `section` denotes or `undefined`.
pub fn WorkspaceConfiguration::get_string_option(
  self : WorkspaceConfiguration,
  section : String,
) -> String? {
  WorkspaceConfiguration::get(self, section)
}

///|
/// Return a value from this configuration.
///
/// @param section Configuration name, supports _dotted_ names.
/// @returns The value `section` denotes or `undefined`.
pub fn WorkspaceConfiguration::get_bool_option(
  self : WorkspaceConfiguration,
  section : String,
) -> Bool? {
  WorkspaceConfiguration::get(self, section)
}

///|
/// Check if this configuration has a certain value.
///
/// @param section Configuration name, supports _dotted_ names.
/// @returns `true` if the section doesn't resolve to `undefined`.
pub extern "js" fn WorkspaceConfiguration::has(
  self : WorkspaceConfiguration,
  section : String,
) -> Bool =
  #| (config, section) => config.has(section)

///|
/// Retrieve all information about a configuration setting. A configuration value
/// often consists of a *default* value, a global or installation-wide value,
/// a workspace-specific value, folder-specific value
/// and language-specific values (if {@link WorkspaceConfiguration} is scoped to a language).
///
/// Also provides all language ids under which the given configuration setting is defined.
///
/// *Note:* The configuration name must denote a leaf in the configuration tree
/// (`editor.fontSize` vs `editor`) otherwise no result is returned.
///
/// @param section Configuration name, supports _dotted_ names.
/// @returns Information about a configuration setting or `undefined`.
pub fn[T] WorkspaceConfiguration::inspect(
  self : WorkspaceConfiguration,
  section : String,
) -> ConfigurationInspect[T]? {
  let raw = WorkspaceConfiguration::workspace_configuration_inspect_raw(
    self, section,
  )
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(ConfigurationInspect::from_js(raw))
  }
}

///|
fn[T] configuration_inspect_option(raw : JsValue) -> T? {
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn[T] ConfigurationInspect::new(
  key : String,
  default_value? : T,
  global_value? : T,
  workspace_value? : T,
  workspace_folder_value? : T,
  default_language_value? : T,
  global_language_value? : T,
  workspace_language_value? : T,
  workspace_folder_language_value? : T,
  language_ids? : Array[String],
) -> ConfigurationInspect[T] {
  ConfigurationInspect::{
    key,
    default_value,
    global_value,
    workspace_value,
    workspace_folder_value,
    default_language_value,
    global_language_value,
    workspace_language_value,
    workspace_folder_language_value,
    language_ids,
  }
}

///|
fn[T] ConfigurationInspect::from_js(raw : JsValue) -> ConfigurationInspect[T] {
  ConfigurationInspect::{
    key: configuration_inspect_key_raw(raw),
    default_value: configuration_inspect_option(
      configuration_inspect_default_raw(raw),
    ),
    global_value: configuration_inspect_option(
      configuration_inspect_global_raw(raw),
    ),
    workspace_value: configuration_inspect_option(
      configuration_inspect_workspace_raw(raw),
    ),
    workspace_folder_value: configuration_inspect_option(
      configuration_inspect_workspace_folder_raw(raw),
    ),
    default_language_value: configuration_inspect_option(
      configuration_inspect_default_language_raw(raw),
    ),
    global_language_value: configuration_inspect_option(
      configuration_inspect_global_language_raw(raw),
    ),
    workspace_language_value: configuration_inspect_option(
      configuration_inspect_workspace_language_raw(raw),
    ),
    workspace_folder_language_value: configuration_inspect_option(
      configuration_inspect_workspace_folder_language_raw(raw),
    ),
    language_ids: configuration_inspect_option(
      configuration_inspect_language_ids_raw(raw),
    ),
  }
}

///|
pub fn[T] ConfigurationInspect::key(self : ConfigurationInspect[T]) -> String {
  self.key
}

///|
pub fn[T] ConfigurationInspect::default_value(
  self : ConfigurationInspect[T],
) -> T? {
  self.default_value
}

///|
pub fn[T] ConfigurationInspect::global_value(
  self : ConfigurationInspect[T],
) -> T? {
  self.global_value
}

///|
pub fn[T] ConfigurationInspect::workspace_value(
  self : ConfigurationInspect[T],
) -> T? {
  self.workspace_value
}

///|
pub fn[T] ConfigurationInspect::workspace_folder_value(
  self : ConfigurationInspect[T],
) -> T? {
  self.workspace_folder_value
}

///|
pub fn[T] ConfigurationInspect::default_language_value(
  self : ConfigurationInspect[T],
) -> T? {
  self.default_language_value
}

///|
pub fn[T] ConfigurationInspect::global_language_value(
  self : ConfigurationInspect[T],
) -> T? {
  self.global_language_value
}

///|
pub fn[T] ConfigurationInspect::workspace_language_value(
  self : ConfigurationInspect[T],
) -> T? {
  self.workspace_language_value
}

///|
pub fn[T] ConfigurationInspect::workspace_folder_language_value(
  self : ConfigurationInspect[T],
) -> T? {
  self.workspace_folder_language_value
}

///|
pub fn[T] ConfigurationInspect::language_ids(
  self : ConfigurationInspect[T],
) -> Array[String]? {
  self.language_ids
}

///|
extern "js" fn WorkspaceConfiguration::update_promise(
  self : WorkspaceConfiguration,
  section : String,
  value : JsValue,
  target : JsValue,
  override_in_language : Bool,
) -> @js_async.Promise[Unit] =
  #| (config, section, value, target, overrideInLanguage) =>
  #|   config.update(section, value, target, overrideInLanguage)

///|
/// Update a configuration value. The updated configuration values are persisted.
///
/// A value can be changed in
///
/// - {@link ConfigurationTarget.Global Global settings}: Changes the value for all instances of the editor.
/// - {@link ConfigurationTarget.Workspace Workspace settings}: Changes the value for current workspace, if available.
/// - {@link ConfigurationTarget.WorkspaceFolder Workspace folder settings}: Changes the value for settings from one of the {@link workspace.workspaceFolders Workspace Folders} under which the requested resource belongs to.
/// - Language settings: Changes the value for the requested languageId.
///
/// *Note:* To remove a configuration value use `undefined`, like so: `config.update('somekey', undefined)`
///
/// @param section Configuration name, supports _dotted_ names.
/// @param value The new value.
/// @param configurationTarget The {@link ConfigurationTarget configuration target} or a boolean value.
/// 	- If `true` updates {@link ConfigurationTarget.Global Global settings}.
/// 	- If `false` updates {@link ConfigurationTarget.Workspace Workspace settings}.
/// 	- If `undefined` or `null` updates to {@link ConfigurationTarget.WorkspaceFolder Workspace folder settings} if configuration is resource specific,
/// 	otherwise to {@link ConfigurationTarget.Workspace Workspace settings}.
/// @param overrideInLanguage Whether to update the value in the scope of requested languageId or not.
/// 	- If `true` updates the value under the requested languageId.
/// 	- If `undefined` updates the value under the requested languageId only if the configuration is defined for the language.
/// @throws error while updating
/// 	- configuration which is not registered.
/// 	- window configuration to workspace folder
/// 	- configuration to workspace or workspace folder when no workspace is opened.
/// 	- configuration to workspace folder when there is no workspace folder settings.
/// 	- configuration to workspace folder when {@link WorkspaceConfiguration} is not scoped to a resource.
pub async fn WorkspaceConfiguration::update(
  self : WorkspaceConfiguration,
  section : String,
  value? : Any,
  target? : ConfigurationTargetValue,
  override_in_language? : Bool = false,
) -> Unit {
  @js_async.Promise::wait(
    WorkspaceConfiguration::update_promise(
      self,
      section,
      option_to_js(value),
      option_configuration_target_value_to_js(target),
      override_in_language,
    ),
  )
}

///|
fn WorkspaceConfiguration::update_string_promise(
  self : WorkspaceConfiguration,
  section : String,
  value : String,
  target? : ConfigurationTarget,
  override_in_language? : Bool = false,
) -> @js_async.Promise[Unit] {
  let target_value = match target {
    None => JsValue::make(())
    Some(choice) => JsValue::make(choice)
  }
  WorkspaceConfiguration::update_promise(
    self,
    section,
    JsValue::make(value),
    target_value,
    override_in_language,
  )
}

///|
/// Update a configuration value. The updated configuration values are persisted.
///
/// A value can be changed in
///
/// - {@link ConfigurationTarget.Global Global settings}: Changes the value for all instances of the editor.
/// - {@link ConfigurationTarget.Workspace Workspace settings}: Changes the value for current workspace, if available.
/// - {@link ConfigurationTarget.WorkspaceFolder Workspace folder settings}: Changes the value for settings from one of the {@link workspace.workspaceFolders Workspace Folders} under which the requested resource belongs to.
/// - Language settings: Changes the value for the requested languageId.
///
/// *Note:* To remove a configuration value use `undefined`, like so: `config.update('somekey', undefined)`
///
/// @param section Configuration name, supports _dotted_ names.
/// @param value The new value.
/// @param configurationTarget The {@link ConfigurationTarget configuration target} or a boolean value.
/// 	- If `true` updates {@link ConfigurationTarget.Global Global settings}.
/// 	- If `false` updates {@link ConfigurationTarget.Workspace Workspace settings}.
/// 	- If `undefined` or `null` updates to {@link ConfigurationTarget.WorkspaceFolder Workspace folder settings} if configuration is resource specific,
/// 	otherwise to {@link ConfigurationTarget.Workspace Workspace settings}.
/// @param overrideInLanguage Whether to update the value in the scope of requested languageId or not.
/// 	- If `true` updates the value under the requested languageId.
/// 	- If `undefined` updates the value under the requested languageId only if the configuration is defined for the language.
/// @throws error while updating
/// 	- configuration which is not registered.
/// 	- window configuration to workspace folder
/// 	- configuration to workspace or workspace folder when no workspace is opened.
/// 	- configuration to workspace folder when there is no workspace folder settings.
/// 	- configuration to workspace folder when {@link WorkspaceConfiguration} is not scoped to a resource.
pub async fn WorkspaceConfiguration::update_string(
  self : WorkspaceConfiguration,
  section : String,
  value : String,
  target? : ConfigurationTarget,
  override_in_language? : Bool = false,
) -> Unit {
  match target {
    None =>
      @js_async.Promise::wait(
        WorkspaceConfiguration::update_string_promise(
          self,
          section,
          value,
          override_in_language~,
        ),
      )
    Some(choice) =>
      @js_async.Promise::wait(
        WorkspaceConfiguration::update_string_promise(
          self,
          section,
          value,
          target=choice,
          override_in_language~,
        ),
      )
  }
}

///|
fn WorkspaceConfiguration::update_bool_promise(
  self : WorkspaceConfiguration,
  section : String,
  value : Bool,
  target? : ConfigurationTarget,
  override_in_language? : Bool = false,
) -> @js_async.Promise[Unit] {
  let target_value = match target {
    None => JsValue::make(())
    Some(choice) => JsValue::make(choice)
  }
  WorkspaceConfiguration::update_promise(
    self,
    section,
    JsValue::make(value),
    target_value,
    override_in_language,
  )
}

///|
/// Update a configuration value. The updated configuration values are persisted.
///
/// A value can be changed in
///
/// - {@link ConfigurationTarget.Global Global settings}: Changes the value for all instances of the editor.
/// - {@link ConfigurationTarget.Workspace Workspace settings}: Changes the value for current workspace, if available.
/// - {@link ConfigurationTarget.WorkspaceFolder Workspace folder settings}: Changes the value for settings from one of the {@link workspace.workspaceFolders Workspace Folders} under which the requested resource belongs to.
/// - Language settings: Changes the value for the requested languageId.
///
/// *Note:* To remove a configuration value use `undefined`, like so: `config.update('somekey', undefined)`
///
/// @param section Configuration name, supports _dotted_ names.
/// @param value The new value.
/// @param configurationTarget The {@link ConfigurationTarget configuration target} or a boolean value.
/// 	- If `true` updates {@link ConfigurationTarget.Global Global settings}.
/// 	- If `false` updates {@link ConfigurationTarget.Workspace Workspace settings}.
/// 	- If `undefined` or `null` updates to {@link ConfigurationTarget.WorkspaceFolder Workspace folder settings} if configuration is resource specific,
/// 	otherwise to {@link ConfigurationTarget.Workspace Workspace settings}.
/// @param overrideInLanguage Whether to update the value in the scope of requested languageId or not.
/// 	- If `true` updates the value under the requested languageId.
/// 	- If `undefined` updates the value under the requested languageId only if the configuration is defined for the language.
/// @throws error while updating
/// 	- configuration which is not registered.
/// 	- window configuration to workspace folder
/// 	- configuration to workspace or workspace folder when no workspace is opened.
/// 	- configuration to workspace folder when there is no workspace folder settings.
/// 	- configuration to workspace folder when {@link WorkspaceConfiguration} is not scoped to a resource.
pub async fn WorkspaceConfiguration::update_bool(
  self : WorkspaceConfiguration,
  section : String,
  value : Bool,
  target? : ConfigurationTarget,
  override_in_language? : Bool = false,
) -> Unit {
  match target {
    None =>
      @js_async.Promise::wait(
        WorkspaceConfiguration::update_bool_promise(
          self,
          section,
          value,
          override_in_language~,
        ),
      )
    Some(choice) =>
      @js_async.Promise::wait(
        WorkspaceConfiguration::update_bool_promise(
          self,
          section,
          value,
          target=choice,
          override_in_language~,
        ),
      )
  }
}

///|
/// Checks if the given section has changed.
/// If scope is provided, checks if the section has changed for resources under the given scope.
///
/// @param section Configuration name, supports _dotted_ names.
/// @param scope A scope in which to check.
/// @returns `true` if the given section has changed.
pub fn ConfigurationChangeEvent::affects_configuration(
  self : ConfigurationChangeEvent,
  section : String,
  scope? : ConfigurationScope,
) -> Bool {
  let scope_js = match scope {
    None => JsValue::make(())
    Some(value) => configuration_scope_to_js(value)
  }
  ConfigurationChangeEvent::affects_configuration_raw(self, section, scope_js)
}

///|
fn configuration_scope_to_js(value : ConfigurationScope) -> JsValue {
  match value {
    Uri(value) => JsValue::make(value)
    WorkspaceFolderScope(value) => JsValue::make(value)
    TextEditorScope(value) => JsValue::make(value)
    TextDocumentScope(value) => JsValue::make(value)
    LanguageId(value) => configuration_scope_language_to_js_ffi(value)
    Global => configuration_scope_null_to_js_ffi()
  }
}

///|
extern "js" fn configuration_scope_language_to_js_ffi(
  language_id : String,
) -> JsValue =
  #| (languageId) => ({ languageId })

///|
extern "js" fn configuration_scope_null_to_js_ffi() -> JsValue =
  #| () => null

///|
extern "js" fn ConfigurationChangeEvent::affects_configuration_raw(
  self : ConfigurationChangeEvent,
  section : String,
  scope : JsValue,
) -> Bool =
  #| (event, section, scope) =>
  #|   scope === undefined ? event.affectsConfiguration(section) : event.affectsConfiguration(section, scope)

///|
/// Text document change helpers
pub fn TextDocumentContentChangeEvent::new(
  range : Range,
  range_offset : Int,
  range_length : Int,
  text : String,
) -> TextDocumentContentChangeEvent {
  TextDocumentContentChangeEvent::{
    range,
    rangeOffset: range_offset,
    rangeLength: range_length,
    text,
  }
}

///|
/// Text document change helpers

///|
/// The offset of the range that got replaced.

///|
/// The length of the range that got replaced.

///|
/// The new text for the range.

///|
/// The affected document.
pub fn TextDocumentChangeEvent::new(
  document : TextDocument,
  content_changes : Array[TextDocumentContentChangeEvent],
  reason? : TextDocumentChangeReason,
) -> TextDocumentChangeEvent {
  TextDocumentChangeEvent::{ document, contentChanges: content_changes, reason }
}

///|
/// The affected document.

///|
/// An array of content changes.

///|
/// The reason why the document was changed.
/// Is `undefined` if the reason is not known.

///|
/// The document that will be saved.

///|
/// The reason why save was triggered.

///|
extern "js" fn TextDocumentWillSaveEvent::wait_until_raw(
  self : TextDocumentWillSaveEvent,
  thenable : @js_async.Promise[Unit],
) -> Unit =
  #| (event, thenable) => event.waitUntil(thenable)

///|
/// Allows to pause the event loop and to apply {@link TextEdit pre-save-edits}.
/// Edits of subsequent calls to this function will be applied in order. The
/// edits will be *ignored* if concurrent modifications of the document happened.
///
/// *Note:* This function can only be called during event dispatch and not
/// in an asynchronous manner:
///
/// ```ts
/// workspace.onWillSaveTextDocument(event => {
/// 	// async, will *throw* an error
/// 	setTimeout(() => event.waitUntil(promise));
///
/// 	// sync, OK
/// 	event.waitUntil(promise);
/// })
/// ```
///
/// @param thenable A thenable that resolves to {@link TextEdit pre-save-edits}.
pub fn TextDocumentWillSaveEvent::wait_until(
  self : TextDocumentWillSaveEvent,
  thenable : async () -> Unit,
) -> Unit {
  TextDocumentWillSaveEvent::wait_until_raw(
    self,
    @js_async.Promise::from_async(thenable),
  )
}

///|
extern "js" fn TextDocumentWillSaveEvent::wait_until_edits_raw(
  self : TextDocumentWillSaveEvent,
  thenable : @js_async.Promise[Array[TextEdit]],
) -> Unit =
  #| (event, thenable) => event.waitUntil(thenable)

///|
/// Allows to pause the event loop and to apply {@link TextEdit pre-save-edits}.
/// Edits of subsequent calls to this function will be applied in order. The
/// edits will be *ignored* if concurrent modifications of the document happened.
///
/// *Note:* This function can only be called during event dispatch and not
/// in an asynchronous manner:
///
/// ```ts
/// workspace.onWillSaveTextDocument(event => {
/// 	// async, will *throw* an error
/// 	setTimeout(() => event.waitUntil(promise));
///
/// 	// sync, OK
/// 	event.waitUntil(promise);
/// })
/// ```
///
/// @param thenable A thenable that resolves to {@link TextEdit pre-save-edits}.
pub fn TextDocumentWillSaveEvent::wait_until_edits(
  self : TextDocumentWillSaveEvent,
  thenable : async () -> Array[TextEdit],
) -> Unit {
  TextDocumentWillSaveEvent::wait_until_edits_raw(
    self,
    @js_async.Promise::from_async(thenable),
  )
}

///|
/// File event helpers
pub fn FileCreateEvent::new(files : Array[Uri]) -> FileCreateEvent {
  FileCreateEvent::{ files, }
}

///|

///|
/// The files that got deleted.
pub fn FileDeleteEvent::new(files : Array[Uri]) -> FileDeleteEvent {
  FileDeleteEvent::{ files, }
}

///|
/// The files that got deleted.

///|
/// The files that got renamed.
pub fn FileRenameEvent::new(
  files : Array[FileRenameEventEntry],
) -> FileRenameEvent {
  FileRenameEvent::{ files, }
}

///|
/// The files that got renamed.

///|
pub fn FileRenameEventEntry::new(
  old_uri : Uri,
  new_uri : Uri,
) -> FileRenameEventEntry {
  FileRenameEventEntry::{ oldUri: old_uri, newUri: new_uri }
}

///|

///|

///|
/// The files that are going to be created.

///|
/// A cancellation token.

///|
/// Allows to pause the event and to apply a {@link WorkspaceEdit workspace edit}.
///
/// *Note:* This function can only be called during event dispatch and not
/// in an asynchronous manner:
///
/// ```ts
/// workspace.onWillCreateFiles(event => {
/// 	// async, will *throw* an error
/// 	setTimeout(() => event.waitUntil(promise));
///
/// 	// sync, OK
/// 	event.waitUntil(promise);
/// })
/// ```
///
/// @param thenable A thenable that delays saving.
pub extern "js" fn FileWillCreateEvent::wait_until_edit(
  self : FileWillCreateEvent,
  edit : WorkspaceEdit,
) -> Unit =
  #| (event, edit) => event.waitUntil(edit)

///|
extern "js" fn FileWillCreateEvent::wait_until_raw(
  self : FileWillCreateEvent,
  thenable : @js_async.Promise[WorkspaceEdit],
) -> Unit =
  #| (event, thenable) => event.waitUntil(thenable)

///|
/// Allows to pause the event and to apply a {@link WorkspaceEdit workspace edit}.
///
/// *Note:* This function can only be called during event dispatch and not
/// in an asynchronous manner:
///
/// ```ts
/// workspace.onWillCreateFiles(event => {
/// 	// async, will *throw* an error
/// 	setTimeout(() => event.waitUntil(promise));
///
/// 	// sync, OK
/// 	event.waitUntil(promise);
/// })
/// ```
///
/// @param thenable A thenable that delays saving.
pub fn FileWillCreateEvent::wait_until(
  self : FileWillCreateEvent,
  thenable : async () -> WorkspaceEdit,
) -> Unit {
  FileWillCreateEvent::wait_until_raw(
    self,
    @js_async.Promise::from_async(thenable),
  )
}

///|
/// The files that are going to be deleted.

///|
/// A cancellation token.

///|
/// Allows to pause the event and to apply a {@link WorkspaceEdit workspace edit}.
///
/// *Note:* This function can only be called during event dispatch and not
/// in an asynchronous manner:
///
/// ```ts
/// workspace.onWillCreateFiles(event => {
/// 	// async, will *throw* an error
/// 	setTimeout(() => event.waitUntil(promise));
///
/// 	// sync, OK
/// 	event.waitUntil(promise);
/// })
/// ```
///
/// @param thenable A thenable that delays saving.
pub extern "js" fn FileWillDeleteEvent::wait_until_edit(
  self : FileWillDeleteEvent,
  edit : WorkspaceEdit,
) -> Unit =
  #| (event, edit) => event.waitUntil(edit)

///|
extern "js" fn FileWillDeleteEvent::wait_until_raw(
  self : FileWillDeleteEvent,
  thenable : @js_async.Promise[WorkspaceEdit],
) -> Unit =
  #| (event, thenable) => event.waitUntil(thenable)

///|
/// Allows to pause the event and to apply a {@link WorkspaceEdit workspace edit}.
///
/// *Note:* This function can only be called during event dispatch and not
/// in an asynchronous manner:
///
/// ```ts
/// workspace.onWillCreateFiles(event => {
/// 	// async, will *throw* an error
/// 	setTimeout(() => event.waitUntil(promise));
///
/// 	// sync, OK
/// 	event.waitUntil(promise);
/// })
/// ```
///
/// @param thenable A thenable that delays saving.
pub fn FileWillDeleteEvent::wait_until(
  self : FileWillDeleteEvent,
  thenable : async () -> WorkspaceEdit,
) -> Unit {
  FileWillDeleteEvent::wait_until_raw(
    self,
    @js_async.Promise::from_async(thenable),
  )
}

///|
/// The files that are going to be renamed.

///|
/// A cancellation token.

///|
/// Allows to pause the event and to apply a {@link WorkspaceEdit workspace edit}.
///
/// *Note:* This function can only be called during event dispatch and not
/// in an asynchronous manner:
///
/// ```ts
/// workspace.onWillCreateFiles(event => {
/// 	// async, will *throw* an error
/// 	setTimeout(() => event.waitUntil(promise));
///
/// 	// sync, OK
/// 	event.waitUntil(promise);
/// })
/// ```
///
/// @param thenable A thenable that delays saving.
pub extern "js" fn FileWillRenameEvent::wait_until_edit(
  self : FileWillRenameEvent,
  edit : WorkspaceEdit,
) -> Unit =
  #| (event, edit) => event.waitUntil(edit)

///|
extern "js" fn FileWillRenameEvent::wait_until_raw(
  self : FileWillRenameEvent,
  thenable : @js_async.Promise[WorkspaceEdit],
) -> Unit =
  #| (event, thenable) => event.waitUntil(thenable)

///|
/// Allows to pause the event and to apply a {@link WorkspaceEdit workspace edit}.
///
/// *Note:* This function can only be called during event dispatch and not
/// in an asynchronous manner:
///
/// ```ts
/// workspace.onWillCreateFiles(event => {
/// 	// async, will *throw* an error
/// 	setTimeout(() => event.waitUntil(promise));
///
/// 	// sync, OK
/// 	event.waitUntil(promise);
/// })
/// ```
///
/// @param thenable A thenable that delays saving.
pub fn FileWillRenameEvent::wait_until(
  self : FileWillRenameEvent,
  thenable : async () -> WorkspaceEdit,
) -> Unit {
  FileWillRenameEvent::wait_until_raw(
    self,
    @js_async.Promise::from_async(thenable),
  )
}

///|

///|
pub fn FileChangeEvent::new(
  uri : Uri,
  change_type : FileChangeType,
) -> FileChangeEvent {
  FileChangeEvent::{ uri, type_: change_type }
}

///|
/// The uri of the file that has changed.

///|

///|
/// A base file path to which this pattern will be matched against relatively. The
/// file path must be absolute, should not have any trailing path separators and
/// not include any relative segments (`.` or `..`).

///|
/// A base file path to which this pattern will be matched against relatively.
///
/// This matches the `fsPath` value of {@link RelativePattern.baseUri}.
///
/// *Note:* updating this value will update {@link RelativePattern.baseUri} to
/// be a uri with `file` scheme.
///
/// @deprecated This property is deprecated, please use {@link RelativePattern.baseUri} instead.

///|
/// A file glob pattern like `*.{ts,js}` that will be matched on file paths
/// relative to the base path.
///
/// Example: Given a base of `/home/work/folder` and a file path of `/home/work/folder/index.js`,
/// the file glob pattern will match on `index.js`.

///|
pub(all) enum CommentThreadCanReply {
  BoolValue(Bool)
  Author(CommentAuthorInformation)
}

///|
fn CommentThreadCanReply::to_js(self : CommentThreadCanReply) -> JsValue {
  match self {
    BoolValue(value) => JsValue::make(value)
    Author(value) => JsValue::make(value)
  }
}

///|
fn CommentThreadCanReply::from_js(value : JsValue) -> CommentThreadCanReply? {
  match js_value_as_bool_ffi(value) {
    Some(boolean) => Some(CommentThreadCanReply::BoolValue(boolean))
    None =>
      if value.is_null_or_undefined() {
        None
      } else {
        Some(CommentThreadCanReply::Author(value.cast()))
      }
  }
}

///|
pub fn CommentAuthorInformation::new(
  name : String,
  icon_path? : Uri,
) -> CommentAuthorInformation {
  CommentAuthorInformation::{ name, iconPath: icon_path }
}

///|
pub fn CommentReaction::new(
  label : String,
  icon_path : StringOrUri,
  count : Int,
  author_has_reacted : Bool,
) -> CommentReaction {
  CommentReaction::{
    label,
    iconPath: icon_path,
    count,
    authorHasReacted: author_has_reacted,
  }
}

///|
pub fn Comment::new(
  body : MarkdownStringValue,
  mode : CommentMode,
  author : CommentAuthorInformation,
) -> Comment {
  comment_ffi(body.to_js(), mode, author)
}

///|
pub fn CommentOptions::new(
  prompt? : String = "",
  place_holder? : String = "",
) -> CommentOptions {
  let prompt_value : String? = if prompt == "" { None } else { Some(prompt) }
  let place_holder_value : String? = if place_holder == "" {
    None
  } else {
    Some(place_holder)
  }
  CommentOptions::{ prompt: prompt_value, placeHolder: place_holder_value }
}

///|
pub fn CommentingRanges::new(
  enable_file_comments : Bool,
  ranges? : Array[Range] = [],
) -> CommentingRanges {
  let range_values : Array[Range]? = if ranges.length() == 0 {
    None
  } else {
    Some(ranges)
  }
  CommentingRanges::{
    enableFileComments: enable_file_comments,
    ranges: range_values,
  }
}

///|
/// The id of this comment controller.
pub extern "js" fn CommentController::id(self : CommentController) -> String =
  #| (controller) => controller.id

///|
/// The human-readable label of this comment controller.
pub extern "js" fn CommentController::label(self : CommentController) -> String =
  #| (controller) => controller.label

///|
/// Comment controller options
pub fn CommentController::options(self : CommentController) -> CommentOptions? {
  let raw = CommentController::comment_controller_options_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Comment controller options
pub fn CommentController::set_options(
  self : CommentController,
  value : CommentOptions,
) -> Unit {
  CommentController::comment_controller_set_options_raw(
    self,
    JsValue::make(value),
  )
}

///|
/// Comment controller options
pub fn CommentController::clear_options(self : CommentController) -> Unit {
  CommentController::comment_controller_set_options_raw(self, JsValue::make(()))
}

///|
/// Optional commenting range provider. Provide a list {@link Range ranges} which support commenting to any given resource uri.
///
/// If not provided, users cannot leave any comments.
pub fn[T : CommentingRangeProvider] CommentController::set_commenting_range_provider(
  self : CommentController,
  value : T,
) -> Unit {
  CommentController::comment_controller_set_commenting_range_provider_raw(
    self,
    commenting_range_provider_ffi((document, token) => {
      @js_async.Promise::from_async(async fn() {
        option_to_js(value.provide_commenting_ranges(document, token))
      })
    }),
  )
}

///|
/// Optional commenting range provider. Provide a list {@link Range ranges} which support commenting to any given resource uri.
///
/// If not provided, users cannot leave any comments.
pub fn CommentController::clear_commenting_range_provider(
  self : CommentController,
) -> Unit {
  CommentController::comment_controller_set_commenting_range_provider_raw(
    self,
    JsValue::make(()),
  )
}

///|
/// Create a {@link CommentThread comment thread}. The comment thread will be displayed in visible text editors (if the resource matches)
/// and Comments Panel once created.
///
/// @param uri The uri of the document the thread has been created on.
/// @param range The range the comment thread is located within the document.
/// @param comments The ordered comments of the thread.
pub extern "js" fn CommentController::create_comment_thread(
  self : CommentController,
  uri : Uri,
  range : Range,
  comments : Array[Comment],
) -> CommentThread =
  #| (controller, uri, range, comments) =>
  #|   controller.createCommentThread(uri, range, comments)

///|
/// Optional reaction handler for creating and deleting reactions on a {@link Comment}.
pub fn CommentController::set_reaction_handler(
  self : CommentController,
  handler : async (Comment, CommentReaction) -> Unit,
) -> Unit {
  CommentController::comment_controller_set_reaction_handler_raw(
    self,
    JsValue::make((comment, reaction) => {
      @js_async.Promise::from_async(() => handler(comment, reaction))
    }),
  )
}

///|
/// Optional reaction handler for creating and deleting reactions on a {@link Comment}.
pub fn CommentController::clear_reaction_handler(
  self : CommentController,
) -> Unit {
  CommentController::comment_controller_set_reaction_handler_raw(
    self,
    JsValue::make(()),
  )
}

///|
/// Dispose this comment controller.
///
/// Once disposed, all {@link CommentThread comment threads} created by this comment controller will also be removed from the editor
/// and Comments Panel.
extern "js" fn comment_controller_dispose_raw(
  controller : CommentController,
) -> Unit =
  #| (controller) => controller.dispose()

///|
pub fn CommentController::dispose(self : CommentController) -> Unit {
  comment_controller_dispose_raw(self)
}

///|
pub impl AsDisposable for CommentController with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// The uri of the document the thread has been created on.
pub extern "js" fn CommentThread::uri(self : CommentThread) -> Uri =
  #| (thread) => thread.uri

///|
/// The range the comment thread is located within the document. The thread icon will be shown
/// at the last line of the range. When set to undefined, the comment will be associated with the
/// file, and not a specific range.
pub fn CommentThread::range(self : CommentThread) -> Range? {
  let raw = CommentThread::comment_thread_range_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The range the comment thread is located within the document. The thread icon will be shown
/// at the last line of the range. When set to undefined, the comment will be associated with the
/// file, and not a specific range.
pub fn CommentThread::set_range(self : CommentThread, value : Range) -> Unit {
  CommentThread::comment_thread_set_range_raw(self, JsValue::make(value))
}

///|
/// The range the comment thread is located within the document. The thread icon will be shown
/// at the last line of the range. When set to undefined, the comment will be associated with the
/// file, and not a specific range.
pub fn CommentThread::clear_range(self : CommentThread) -> Unit {
  CommentThread::comment_thread_set_range_raw(self, JsValue::make(()))
}

///|
pub extern "js" fn CommentThread::comments(
  self : CommentThread,
) -> Array[Comment] =
  #| (thread) => thread.comments

///|
pub extern "js" fn CommentThread::set_comments(
  self : CommentThread,
  value : Array[Comment],
) -> Unit =
  #| (thread, value) => { thread.comments = value; }

///|
pub extern "js" fn CommentThread::collapsible_state(
  self : CommentThread,
) -> CommentThreadCollapsibleState =
  #| (thread) => thread.collapsibleState

///|
pub extern "js" fn CommentThread::set_collapsible_state(
  self : CommentThread,
  value : CommentThreadCollapsibleState,
) -> Unit =
  #| (thread, value) => { thread.collapsibleState = value; }

///|
pub extern "js" fn CommentThread::is_equal(
  self : CommentThread,
  other : CommentThread,
) -> Bool =
  #| (left, right) => left === right

///|
/// Whether the thread supports reply.
/// Defaults to true.
pub fn CommentThread::can_reply(self : CommentThread) -> CommentThreadCanReply {
  match
    CommentThreadCanReply::from_js(
      CommentThread::comment_thread_can_reply_raw(self),
    ) {
    Some(value) => value
    None => CommentThreadCanReply::BoolValue(true)
  }
}

///|
/// Whether the thread supports reply.
/// Defaults to true.
pub fn CommentThread::set_can_reply(
  self : CommentThread,
  value : CommentThreadCanReply,
) -> Unit {
  CommentThread::comment_thread_set_can_reply_raw(self, value.to_js())
}

///|
/// Context value of the comment thread. This can be used to contribute thread specific actions.
/// For example, a comment thread is given a context value as `editable`. When contributing actions to `comments/commentThread/title`
/// using `menus` extension point, you can specify context value for key `commentThread` in `when` expression like `commentThread == editable`.
/// ```json
/// "contributes": {
///   "menus": {
///     "comments/commentThread/title": [
///       {
///         "command": "extension.deleteCommentThread",
///         "when": "commentThread == editable"
///       }
///     ]
///   }
/// }
/// ```
/// This will show action `extension.deleteCommentThread` only for comment threads with `contextValue` is `editable`.
pub fn CommentThread::context_value(self : CommentThread) -> String? {
  let raw = CommentThread::comment_thread_context_value_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Context value of the comment thread. This can be used to contribute thread specific actions.
/// For example, a comment thread is given a context value as `editable`. When contributing actions to `comments/commentThread/title`
/// using `menus` extension point, you can specify context value for key `commentThread` in `when` expression like `commentThread == editable`.
/// ```json
/// "contributes": {
///   "menus": {
///     "comments/commentThread/title": [
///       {
///         "command": "extension.deleteCommentThread",
///         "when": "commentThread == editable"
///       }
///     ]
///   }
/// }
/// ```
/// This will show action `extension.deleteCommentThread` only for comment threads with `contextValue` is `editable`.
pub fn CommentThread::set_context_value(
  self : CommentThread,
  value : String,
) -> Unit {
  CommentThread::comment_thread_set_context_value_raw(
    self,
    JsValue::make(value),
  )
}

///|
/// Context value of the comment thread. This can be used to contribute thread specific actions.
/// For example, a comment thread is given a context value as `editable`. When contributing actions to `comments/commentThread/title`
/// using `menus` extension point, you can specify context value for key `commentThread` in `when` expression like `commentThread == editable`.
/// ```json
/// "contributes": {
///   "menus": {
///     "comments/commentThread/title": [
///       {
///         "command": "extension.deleteCommentThread",
///         "when": "commentThread == editable"
///       }
///     ]
///   }
/// }
/// ```
/// This will show action `extension.deleteCommentThread` only for comment threads with `contextValue` is `editable`.
pub fn CommentThread::clear_context_value(self : CommentThread) -> Unit {
  CommentThread::comment_thread_set_context_value_raw(self, JsValue::make(()))
}

///|
/// The optional human-readable label describing the {@link CommentThread Comment Thread}
pub fn CommentThread::label(self : CommentThread) -> String? {
  let raw = CommentThread::comment_thread_label_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The optional human-readable label describing the {@link CommentThread Comment Thread}
pub fn CommentThread::set_label(self : CommentThread, value : String) -> Unit {
  CommentThread::comment_thread_set_label_raw(self, JsValue::make(value))
}

///|
/// The optional human-readable label describing the {@link CommentThread Comment Thread}
pub fn CommentThread::clear_label(self : CommentThread) -> Unit {
  CommentThread::comment_thread_set_label_raw(self, JsValue::make(()))
}

///|
/// The optional state of a comment thread, which may affect how the comment is displayed.
pub fn CommentThread::state(self : CommentThread) -> CommentThreadState? {
  let raw = CommentThread::comment_thread_state_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The optional state of a comment thread, which may affect how the comment is displayed.

///|
/// The optional state of a comment thread, which may affect how the comment is displayed.

///|
/// Dispose this comment thread.
///
/// Once disposed, this comment thread will be removed from visible editors and Comment Panel when appropriate.
extern "js" fn comment_thread_dispose_raw(thread : CommentThread) -> Unit =
  #| (thread) => thread.dispose()

///|
pub fn CommentThread::dispose(self : CommentThread) -> Unit {
  comment_thread_dispose_raw(self)
}

///|
pub impl AsDisposable for CommentThread with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// The display name of the author of the comment

///|
/// The display name of the author of the comment

///|
/// The optional icon path for the author

///|
/// The optional icon path for the author

///|
/// The optional icon path for the author

///|
/// The human-readable label for the reaction

///|
/// Icon for the reaction shown in UI.

///|
/// The number of users who have reacted to this reaction

///|
/// Whether the {@link CommentAuthorInformation author} of the comment has reacted to this reaction

///|
/// The human-readable comment body

///|
/// The human-readable comment body

///|
/// {@link CommentMode Comment mode} of the comment

///|
/// {@link CommentMode Comment mode} of the comment

///|
/// The {@link CommentAuthorInformation author information} of the comment

///|
/// The {@link CommentAuthorInformation author information} of the comment

///|
/// Context value of the comment. This can be used to contribute comment specific actions.
/// For example, a comment is given a context value as `editable`. When contributing actions to `comments/comment/title`
/// using `menus` extension point, you can specify context value for key `comment` in `when` expression like `comment == editable`.
/// ```json
/// 	"contributes": {
/// 		"menus": {
/// 			"comments/comment/title": [
/// 				{
/// 					"command": "extension.deleteComment",
/// 					"when": "comment == editable"
/// 				}
/// 			]
/// 		}
/// 	}
/// ```
/// This will show action `extension.deleteComment` only for comments with `contextValue` is `editable`.

///|
/// Context value of the comment. This can be used to contribute comment specific actions.
/// For example, a comment is given a context value as `editable`. When contributing actions to `comments/comment/title`
/// using `menus` extension point, you can specify context value for key `comment` in `when` expression like `comment == editable`.
/// ```json
/// 	"contributes": {
/// 		"menus": {
/// 			"comments/comment/title": [
/// 				{
/// 					"command": "extension.deleteComment",
/// 					"when": "comment == editable"
/// 				}
/// 			]
/// 		}
/// 	}
/// ```
/// This will show action `extension.deleteComment` only for comments with `contextValue` is `editable`.

///|
/// Context value of the comment. This can be used to contribute comment specific actions.
/// For example, a comment is given a context value as `editable`. When contributing actions to `comments/comment/title`
/// using `menus` extension point, you can specify context value for key `comment` in `when` expression like `comment == editable`.
/// ```json
/// 	"contributes": {
/// 		"menus": {
/// 			"comments/comment/title": [
/// 				{
/// 					"command": "extension.deleteComment",
/// 					"when": "comment == editable"
/// 				}
/// 			]
/// 		}
/// 	}
/// ```
/// This will show action `extension.deleteComment` only for comments with `contextValue` is `editable`.

///|
/// Optional reactions of the {@link Comment}

///|
/// Optional reactions of the {@link Comment}

///|
/// Optional reactions of the {@link Comment}

///|
/// Optional label describing the {@link Comment}
/// Label will be rendered next to authorName if exists.

///|
/// Optional label describing the {@link Comment}
/// Label will be rendered next to authorName if exists.

///|
/// Optional label describing the {@link Comment}
/// Label will be rendered next to authorName if exists.

///|
/// Optional timestamp that will be displayed in comments.
/// The date will be formatted according to the user's locale and settings.

///|
/// Optional timestamp that will be displayed in comments.
/// The date will be formatted according to the user's locale and settings.

///|
/// Optional timestamp that will be displayed in comments.
/// The date will be formatted according to the user's locale and settings.

///|
/// The active {@link CommentThread comment thread}
pub fn CommentReply::new(thread : CommentThread, text : String) -> CommentReply {
  CommentReply::{ thread, text }
}

///|
/// The active {@link CommentThread comment thread}

///|
/// The value in the comment editor

///|
/// Enables comments to be added to a file without a specific range.

///|
/// The ranges which allow new comment threads creation.

///|
/// The ranges which allow new comment threads creation.

///|
/// The ranges which allow new comment threads creation.

///|
/// An optional string to show on the comment input box when it's collapsed.

///|
/// An optional string to show on the comment input box when it's collapsed.

///|
/// An optional string to show on the comment input box when it's collapsed.

///|
/// An optional string to show as placeholder in the comment input box when it's focused.

///|
/// An optional string to show as placeholder in the comment input box when it's focused.

///|
/// An optional string to show as placeholder in the comment input box when it's focused.

///|
extern "js" fn comment_ffi(
  body : JsValue,
  mode : CommentMode,
  author : CommentAuthorInformation,
) -> Comment =
  #| (body, mode, author) => ({
  #|   body,
  #|   mode,
  #|   author,
  #| })

///|
extern "js" fn CommentController::comment_controller_set_commenting_range_provider_raw(
  self : CommentController,
  value : JsValue,
) -> Unit =
  #| (controller, value) => { controller.commentingRangeProvider = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn CommentController::comment_controller_options_raw(
  self : CommentController,
) -> JsValue =
  #| (controller) => controller.options

///|
extern "js" fn CommentController::comment_controller_set_options_raw(
  self : CommentController,
  value : JsValue,
) -> Unit =
  #| (controller, value) => { controller.options = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn commenting_range_provider_ffi(
  provide_commenting_ranges : (TextDocument, CancellationToken) -> @js_async.Promise[
    JsValue,
  ],
) -> JsValue =
  #| (provideCommentingRanges) => ({ provideCommentingRanges })

///|
extern "js" fn CommentController::comment_controller_set_reaction_handler_raw(
  self : CommentController,
  value : JsValue,
) -> Unit =
  #| (controller, value) => { controller.reactionHandler = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn CommentThread::comment_thread_can_reply_raw(
  self : CommentThread,
) -> JsValue =
  #| (thread) => thread.canReply

///|
extern "js" fn CommentThread::comment_thread_range_raw(
  self : CommentThread,
) -> JsValue =
  #| (thread) => thread.range

///|
extern "js" fn CommentThread::comment_thread_set_range_raw(
  self : CommentThread,
  value : JsValue,
) -> Unit =
  #| (thread, value) => { thread.range = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn CommentThread::comment_thread_context_value_raw(
  self : CommentThread,
) -> JsValue =
  #| (thread) => thread.contextValue

///|
extern "js" fn CommentThread::comment_thread_set_context_value_raw(
  self : CommentThread,
  value : JsValue,
) -> Unit =
  #| (thread, value) => { thread.contextValue = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn CommentThread::comment_thread_label_raw(
  self : CommentThread,
) -> JsValue =
  #| (thread) => thread.label

///|
extern "js" fn CommentThread::comment_thread_set_label_raw(
  self : CommentThread,
  value : JsValue,
) -> Unit =
  #| (thread, value) => { thread.label = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn CommentThread::comment_thread_state_raw(
  self : CommentThread,
) -> JsValue =
  #| (thread) => thread.state

///|
extern "js" fn CommentThread::comment_thread_set_can_reply_raw(
  self : CommentThread,
  value : JsValue,
) -> Unit =
  #| (thread, value) => { thread.canReply = value; }

///|
/// Whether the current window is focused.
pub fn WindowState::new(focused : Bool, active : Bool) -> WindowState {
  WindowState::{ focused, active }
}

///|
/// Whether the current window is focused.

///|
/// Whether the window has been interacted with recently. This will change
/// immediately on activity, or after a short time of user inactivity.

///|
/// The kind of this color theme: light, dark, high contrast dark and high contrast light.
pub extern "js" fn ColorTheme::new(kind : ColorThemeKind) -> ColorTheme =
  #| (kind) => ({ kind })

///|
/// The kind of this color theme: light, dark, high contrast dark and high contrast light.
pub extern "js" fn ColorTheme::kind(self : ColorTheme) -> ColorThemeKind =
  #| (theme) => theme.kind

///|
/// Creates a reference to a theme color.
/// @param id of the color. The available colors are listed in https://code.visualstudio.com/api/references/theme-color.
pub fn ThemeColor::new(id : String) -> ThemeColor {
  theme_color_ffi(id)
}

///|
/// The id of this color.
pub extern "js" fn ThemeColor::id(self : ThemeColor) -> String =
  #| (color) => color.id

///|
/// Creates a reference to a theme icon.
/// @param id id of the icon. The available icons are listed in https://code.visualstudio.com/api/references/icons-in-labels#icon-listing.
/// @param color optional `ThemeColor` for the icon. The color is currently only used in {@link TreeItem}.
pub fn ThemeIcon::new(id : String, color? : ThemeColor) -> ThemeIcon {
  theme_icon_ffi(id, option_to_js(color))
}

///|
pub fn ThemeIcon::file() -> ThemeIcon {
  theme_icon_file_ffi()
}

///|
pub fn ThemeIcon::folder() -> ThemeIcon {
  theme_icon_folder_ffi()
}

///|
/// The id of the icon. The available icons are listed in https://code.visualstudio.com/api/references/icons-in-labels#icon-listing.
pub extern "js" fn ThemeIcon::id(self : ThemeIcon) -> String =
  #| (icon) => icon.id

///|
/// The optional ThemeColor of the icon. The color is currently only used in {@link TreeItem}.
pub fn ThemeIcon::color(self : ThemeIcon) -> ThemeColor? {
  let raw = theme_icon_color_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
extern "js" fn theme_color_ffi(id : String) -> ThemeColor =
  #| (id) => new (require("vscode").ThemeColor)(id)

///|
extern "js" fn theme_icon_ffi(id : String, color : JsValue) -> ThemeIcon =
  #| (id, color) =>
  #|   color === undefined || color === null
  #|     ? new (require("vscode").ThemeIcon)(id)
  #|     : new (require("vscode").ThemeIcon)(id, color)

///|
extern "js" fn theme_icon_color_raw(icon : ThemeIcon) -> JsValue =
  #| (icon) => icon.color

///|
extern "js" fn theme_icon_file_ffi() -> ThemeIcon =
  #| () => require("vscode").ThemeIcon.File

///|
extern "js" fn theme_icon_folder_ffi() -> ThemeIcon =
  #| () => require("vscode").ThemeIcon.Folder

///|
/// Creates a new markdown string with the given value.
///
/// @param value Optional, initial value.
/// @param supportThemeIcons Optional, Specifies whether {@link ThemeIcon ThemeIcons} are supported within the {@linkcode MarkdownString}.
pub fn MarkdownString::new(
  value? : String = "",
  support_theme_icons? : Bool = false,
) -> MarkdownString {
  markdown_string_ffi(value, support_theme_icons)
}

///|
/// The markdown string.
pub extern "js" fn MarkdownString::value(self : MarkdownString) -> String =
  #| (value) => value.value

///|
/// The markdown string.
pub extern "js" fn MarkdownString::set_value(
  self : MarkdownString,
  value : String,
) -> Unit =
  #| (md, value) => { md.value = value; }

///|
/// Indicates that this markdown string is from a trusted source. Only *trusted*
/// markdown supports links that execute commands, e.g. `[Run it](command:myCommandId)`.
///
/// Defaults to `false` (commands are disabled).
pub fn MarkdownString::is_trusted(
  self : MarkdownString,
) -> MarkdownStringTrustedValue? {
  markdown_string_trusted_value_from_js(markdown_string_is_trusted_raw(self))
}

///|
/// Indicates that this markdown string is from a trusted source. Only *trusted*
/// markdown supports links that execute commands, e.g. `[Run it](command:myCommandId)`.
///
/// Defaults to `false` (commands are disabled).
pub fn MarkdownString::set_is_trusted(
  self : MarkdownString,
  value : MarkdownStringTrustedValue,
) -> Unit {
  markdown_string_set_is_trusted_raw(self, value.to_js())
}

///|
/// Indicates that this markdown string is from a trusted source. Only *trusted*
/// markdown supports links that execute commands, e.g. `[Run it](command:myCommandId)`.
///
/// Defaults to `false` (commands are disabled).
pub fn MarkdownString::clear_is_trusted(self : MarkdownString) -> Unit {
  markdown_string_set_is_trusted_raw(self, JsValue::make(()))
}

///|
/// Indicates that this markdown string can contain {@link ThemeIcon ThemeIcons}, e.g. `$(zap)`.
pub fn MarkdownString::support_theme_icons(self : MarkdownString) -> Bool? {
  let raw = markdown_string_support_theme_icons_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Indicates that this markdown string can contain {@link ThemeIcon ThemeIcons}, e.g. `$(zap)`.
pub fn MarkdownString::set_support_theme_icons(
  self : MarkdownString,
  value : Bool,
) -> Unit {
  markdown_string_set_support_theme_icons_raw(self, JsValue::make(value))
}

///|
/// Indicates that this markdown string can contain {@link ThemeIcon ThemeIcons}, e.g. `$(zap)`.
pub fn MarkdownString::clear_support_theme_icons(self : MarkdownString) -> Unit {
  markdown_string_set_support_theme_icons_raw(self, JsValue::make(()))
}

///|
/// Indicates that this markdown string can contain raw html tags. Defaults to `false`.
///
/// When `supportHtml` is false, the markdown renderer will strip out any raw html tags
/// that appear in the markdown text. This means you can only use markdown syntax for rendering.
///
/// When `supportHtml` is true, the markdown render will also allow a safe subset of html tags
/// and attributes to be rendered. See https://github.com/microsoft/vscode/blob/6d2920473c6f13759c978dd89104c4270a83422d/src/vs/base/browser/markdownRenderer.ts#L296
/// for a list of all supported tags and attributes.
pub fn MarkdownString::support_html(self : MarkdownString) -> Bool? {
  let raw = markdown_string_support_html_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Indicates that this markdown string can contain raw html tags. Defaults to `false`.
///
/// When `supportHtml` is false, the markdown renderer will strip out any raw html tags
/// that appear in the markdown text. This means you can only use markdown syntax for rendering.
///
/// When `supportHtml` is true, the markdown render will also allow a safe subset of html tags
/// and attributes to be rendered. See https://github.com/microsoft/vscode/blob/6d2920473c6f13759c978dd89104c4270a83422d/src/vs/base/browser/markdownRenderer.ts#L296
/// for a list of all supported tags and attributes.
pub fn MarkdownString::set_support_html(
  self : MarkdownString,
  value : Bool,
) -> Unit {
  markdown_string_set_support_html_raw(self, JsValue::make(value))
}

///|
/// Indicates that this markdown string can contain raw html tags. Defaults to `false`.
///
/// When `supportHtml` is false, the markdown renderer will strip out any raw html tags
/// that appear in the markdown text. This means you can only use markdown syntax for rendering.
///
/// When `supportHtml` is true, the markdown render will also allow a safe subset of html tags
/// and attributes to be rendered. See https://github.com/microsoft/vscode/blob/6d2920473c6f13759c978dd89104c4270a83422d/src/vs/base/browser/markdownRenderer.ts#L296
/// for a list of all supported tags and attributes.
pub fn MarkdownString::clear_support_html(self : MarkdownString) -> Unit {
  markdown_string_set_support_html_raw(self, JsValue::make(()))
}

///|

///|

///|

///|
/// Uri that relative paths are resolved relative to.
///
/// If the `baseUri` ends with `/`, it is considered a directory and relative paths in the markdown are resolved relative to that directory:
///
/// ```ts
/// const md = new vscode.MarkdownString(`[link](./file.js)`);
/// md.baseUri = vscode.Uri.file('/path/to/dir/');
/// // Here 'link' in the rendered markdown resolves to '/path/to/dir/file.js'
/// ```
///
/// If the `baseUri` is a file, relative paths in the markdown are resolved relative to the parent dir of that file:
///
/// ```ts
/// const md = new vscode.MarkdownString(`[link](./file.js)`);
/// md.baseUri = vscode.Uri.file('/path/to/otherFile.js');
/// // Here 'link' in the rendered markdown resolves to '/path/to/file.js'
/// ```

///|
/// Uri that relative paths are resolved relative to.
///
/// If the `baseUri` ends with `/`, it is considered a directory and relative paths in the markdown are resolved relative to that directory:
///
/// ```ts
/// const md = new vscode.MarkdownString(`[link](./file.js)`);
/// md.baseUri = vscode.Uri.file('/path/to/dir/');
/// // Here 'link' in the rendered markdown resolves to '/path/to/dir/file.js'
/// ```
///
/// If the `baseUri` is a file, relative paths in the markdown are resolved relative to the parent dir of that file:
///
/// ```ts
/// const md = new vscode.MarkdownString(`[link](./file.js)`);
/// md.baseUri = vscode.Uri.file('/path/to/otherFile.js');
/// // Here 'link' in the rendered markdown resolves to '/path/to/file.js'
/// ```

///|
/// Uri that relative paths are resolved relative to.
///
/// If the `baseUri` ends with `/`, it is considered a directory and relative paths in the markdown are resolved relative to that directory:
///
/// ```ts
/// const md = new vscode.MarkdownString(`[link](./file.js)`);
/// md.baseUri = vscode.Uri.file('/path/to/dir/');
/// // Here 'link' in the rendered markdown resolves to '/path/to/dir/file.js'
/// ```
///
/// If the `baseUri` is a file, relative paths in the markdown are resolved relative to the parent dir of that file:
///
/// ```ts
/// const md = new vscode.MarkdownString(`[link](./file.js)`);
/// md.baseUri = vscode.Uri.file('/path/to/otherFile.js');
/// // Here 'link' in the rendered markdown resolves to '/path/to/file.js'
/// ```

///|
pub fn MarkdownString::enabled_commands(
  self : MarkdownString,
) -> Array[String]? {
  let raw = markdown_string_enabled_commands_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn MarkdownString::set_enabled_commands(
  self : MarkdownString,
  value : Array[String],
) -> Unit {
  markdown_string_set_enabled_commands_raw(self, JsValue::make(value))
}

///|
pub fn MarkdownString::clear_enabled_commands(self : MarkdownString) -> Unit {
  markdown_string_set_enabled_commands_raw(self, JsValue::make(()))
}

///|
pub fn MarkdownString::base_uri(self : MarkdownString) -> Uri? {
  let raw = markdown_string_base_uri_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn MarkdownString::set_base_uri(self : MarkdownString, value : Uri) -> Unit {
  markdown_string_set_base_uri_raw(self, JsValue::make(value))
}

///|
pub fn MarkdownString::clear_base_uri(self : MarkdownString) -> Unit {
  markdown_string_set_base_uri_raw(self, JsValue::make(()))
}

///|
/// Appends and escapes the given string to this markdown string.
/// @param value Plain text.
pub extern "js" fn MarkdownString::append_text(
  self : MarkdownString,
  value : String,
) -> MarkdownString =
  #| (md, value) => md.appendText(value)

///|
/// Appends the given string 'as is' to this markdown string. When {@linkcode MarkdownString.supportThemeIcons supportThemeIcons} is `true`, {@link ThemeIcon ThemeIcons} in the `value` will be iconified.
/// @param value Markdown string.
pub extern "js" fn MarkdownString::append_markdown(
  self : MarkdownString,
  value : String,
) -> MarkdownString =
  #| (md, value) => md.appendMarkdown(value)

///|
/// Appends the given string as codeblock using the provided language.
/// @param value A code snippet.
/// @param language An optional {@link languages.getLanguages language identifier}.
pub extern "js" fn MarkdownString::append_codeblock(
  self : MarkdownString,
  value : String,
  language? : String = "",
) -> MarkdownString =
  #| (md, value, language) => language === "" ? md.appendCodeblock(value) : md.appendCodeblock(value, language)

///|
pub fn MarkedString::new(language : String, value : String) -> MarkedString {
  MarkedString::{ language, value }
}

///|
/// Creates a new hover object.
///
/// @param contents The contents of the hover.
/// @param range The range to which the hover applies.
pub fn Hover::new(contents : Array[HoverContent], range? : Range) -> Hover {
  hover_ffi(hover_contents_to_js(contents), option_to_js(range))
}

///|
pub fn Hover::new_single(content : HoverContent, range? : Range) -> Hover {
  match range {
    None => Hover::new([content])
    Some(value) => Hover::new([content], range=value)
  }
}

///|
/// The contents of this hover.
pub fn Hover::contents(self : Hover) -> Array[HoverContent] {
  hover_contents_from_js(hover_contents_raw(self))
}

///|
/// The contents of this hover.
pub fn Hover::set_contents(self : Hover, value : Array[HoverContent]) -> Unit {
  hover_set_contents_raw(self, JsValue::make(hover_contents_to_js(value)))
}

///|
/// The range to which this hover applies. When missing, the
/// editor will use the range at the current position or the
/// current position itself.
pub fn Hover::range(self : Hover) -> Range? {
  let raw = hover_range_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The range to which this hover applies. When missing, the
/// editor will use the range at the current position or the
/// current position itself.
pub fn Hover::set_range(self : Hover, value : Range) -> Unit {
  hover_set_range_raw(self, JsValue::make(value))
}

///|
/// The range to which this hover applies. When missing, the
/// editor will use the range at the current position or the
/// current position itself.
pub fn Hover::clear_range(self : Hover) -> Unit {
  hover_set_range_raw(self, JsValue::make(()))
}

///|
extern "js" fn markdown_string_ffi(
  value : String,
  support_theme_icons : Bool,
) -> MarkdownString =
  #| (value, supportThemeIcons) => new (require("vscode").MarkdownString)(value, supportThemeIcons)

///|
fn markdown_string_trusted_value_from_js(
  value : JsValue,
) -> MarkdownStringTrustedValue? {
  match js_value_as_bool_ffi(value) {
    Some(value) => Some(BoolValue(value))
    None =>
      if value.is_null_or_undefined() {
        None
      } else if values_js_value_is_array_ffi(value) {
        Some(EnabledCommands(value.cast()))
      } else {
        None
      }
  }
}

///|
extern "js" fn markdown_string_is_trusted_raw(
  value : MarkdownString,
) -> JsValue =
  #| (value) => value.isTrusted

///|
extern "js" fn markdown_string_set_is_trusted_raw(
  value : MarkdownString,
  trusted : JsValue,
) -> Unit =
  #| (value, trusted) => { value.isTrusted = trusted === undefined || trusted === null ? undefined : trusted; }

///|
extern "js" fn markdown_string_support_theme_icons_raw(
  value : MarkdownString,
) -> JsValue =
  #| (value) => value.supportThemeIcons

///|
extern "js" fn markdown_string_set_support_theme_icons_raw(
  value : MarkdownString,
  enabled : JsValue,
) -> Unit =
  #| (value, enabled) => { value.supportThemeIcons = enabled === undefined || enabled === null ? undefined : enabled; }

///|
extern "js" fn markdown_string_support_html_raw(
  value : MarkdownString,
) -> JsValue =
  #| (value) => value.supportHtml

///|
extern "js" fn markdown_string_set_support_html_raw(
  value : MarkdownString,
  enabled : JsValue,
) -> Unit =
  #| (value, enabled) => { value.supportHtml = enabled === undefined || enabled === null ? undefined : enabled; }

///|
extern "js" fn markdown_string_enabled_commands_raw(
  value : MarkdownString,
) -> JsValue =
  #| (value) => value.enabledCommands

///|
extern "js" fn markdown_string_set_enabled_commands_raw(
  value : MarkdownString,
  commands : JsValue,
) -> Unit =
  #| (value, commands) => { value.enabledCommands = commands === undefined || commands === null ? undefined : commands; }

///|
extern "js" fn markdown_string_base_uri_raw(value : MarkdownString) -> JsValue =
  #| (value) => value.baseUri

///|
extern "js" fn markdown_string_set_base_uri_raw(
  value : MarkdownString,
  base_uri : JsValue,
) -> Unit =
  #| (value, baseUri) => { value.baseUri = baseUri === undefined || baseUri === null ? undefined : baseUri; }

///|
fn hover_content_to_js(value : HoverContent) -> JsValue {
  match value {
    Markdown(value) => JsValue::make(value)
    Marked(value) => JsValue::make(value)
  }
}

///|
fn hover_contents_to_js(values : Array[HoverContent]) -> Array[JsValue] {
  let encoded : Array[JsValue] = []
  for value in values {
    encoded.push(hover_content_to_js(value))
  }
  encoded
}

///|
fn hover_content_from_js(value : JsValue) -> HoverContent {
  let language_raw = hover_marked_language_raw(value)
  let text_raw = hover_marked_value_raw(value)
  if language_raw.is_null_or_undefined() || text_raw.is_null_or_undefined() {
    Markdown(value.cast())
  } else {
    Marked(MarkedString::{
      language: language_raw.cast(),
      value: text_raw.cast(),
    })
  }
}

///|
fn hover_contents_from_js(value : JsValue) -> Array[HoverContent] {
  let raw_values : Array[JsValue] = value.cast()
  let contents : Array[HoverContent] = []
  for raw in raw_values {
    contents.push(hover_content_from_js(raw))
  }
  contents
}

///|
extern "js" fn hover_ffi(contents : Array[JsValue], range : JsValue) -> Hover =
  #| (contents, range) =>
  #|   range === undefined || range === null
  #|     ? new (require("vscode").Hover)(contents)
  #|     : new (require("vscode").Hover)(contents, range)

///|
extern "js" fn hover_contents_raw(value : Hover) -> JsValue =
  #| (value) => value.contents

///|
extern "js" fn hover_set_contents_raw(
  value : Hover,
  contents : JsValue,
) -> Unit =
  #| (value, contents) => { value.contents = contents; }

///|
extern "js" fn hover_range_raw(value : Hover) -> JsValue =
  #| (value) => value.range

///|
extern "js" fn hover_set_range_raw(value : Hover, range : JsValue) -> Unit =
  #| (value, range) => { value.range = range === undefined || range === null ? undefined : range; }

///|
extern "js" fn hover_marked_language_raw(value : JsValue) -> JsValue =
  #| (value) => value?.language

///|
extern "js" fn hover_marked_value_raw(value : JsValue) -> JsValue =
  #| (value) => value?.value

///|
pub fn CompletionItemLabel::new(
  label : String,
  detail? : String,
  description? : String,
) -> CompletionItemLabel {
  CompletionItemLabel::{ label, detail, description }
}

///|
/// Creates a new completion item.
///
/// Completion items must have at least a {@link CompletionItem.label label} which then
/// will be used as insert text as well as for sorting and filtering.
///
/// @param label The label of the completion.
/// @param kind The {@link CompletionItemKind kind} of the completion.
pub fn CompletionItem::new(
  label : CompletionItemLabelValue,
  kind? : CompletionItemKind,
) -> CompletionItem {
  completion_item_ffi(label.to_js(), option_to_js(kind))
}

///|
pub fn CompletionItem::from_text(
  label : String,
  kind? : CompletionItemKind,
) -> CompletionItem {
  match kind {
    None => CompletionItem::new(CompletionItemLabelValue::Text(label))
    Some(value) =>
      CompletionItem::new(CompletionItemLabelValue::Text(label), kind=value)
  }
}

///|
/// Creates a new completion list.
///
/// @param items The completion items.
/// @param isIncomplete The list is not complete.
pub fn CompletionList::new(
  items : Array[CompletionItem],
  is_incomplete? : Bool = false,
) -> CompletionList[CompletionItem] {
  completion_list_ffi(items, is_incomplete).cast()
}

///|
/// The label of this completion item. By default
/// this is also the text that is inserted when selecting
/// this completion.
pub fn CompletionItem::label(
  self : CompletionItem,
) -> CompletionItemLabelValue? {
  CompletionItemLabelValue::from_js(completion_item_label_raw(self))
}

///|
/// The kind of this completion item. Based on the kind
/// an icon is chosen by the editor.
pub fn CompletionItem::kind(self : CompletionItem) -> CompletionItemKind? {
  let raw = completion_item_kind_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The kind of this completion item. Based on the kind
/// an icon is chosen by the editor.
pub fn CompletionItem::set_kind(
  self : CompletionItem,
  value : CompletionItemKind,
) -> Unit {
  completion_item_set_kind_raw(self, JsValue::make(value))
}

///|
/// The kind of this completion item. Based on the kind
/// an icon is chosen by the editor.
pub fn CompletionItem::clear_kind(self : CompletionItem) -> Unit {
  completion_item_set_kind_raw(self, JsValue::make(()))
}

///|
/// A human-readable string that represents a doc-comment.
pub fn CompletionItem::documentation(
  self : CompletionItem,
) -> MarkdownStringValue? {
  MarkdownStringValue::from_js(completion_item_documentation_raw(self))
}

///|
/// A human-readable string that represents a doc-comment.
pub fn CompletionItem::set_documentation(
  self : CompletionItem,
  value : MarkdownStringValue,
) -> Unit {
  completion_item_set_documentation_raw(self, value.to_js())
}

///|
/// A human-readable string that represents a doc-comment.
pub fn CompletionItem::clear_documentation(self : CompletionItem) -> Unit {
  completion_item_set_documentation_raw(self, JsValue::make(()))
}

///|
/// A string or snippet that should be inserted in a document when selecting
/// this completion. When `falsy` the {@link CompletionItem.label label}
/// is used.
pub fn CompletionItem::insert_text(
  self : CompletionItem,
) -> StringOrSnippetString? {
  StringOrSnippetString::from_js(completion_item_insert_text_raw(self))
}

///|
/// A string or snippet that should be inserted in a document when selecting
/// this completion. When `falsy` the {@link CompletionItem.label label}
/// is used.
pub fn CompletionItem::set_insert_text(
  self : CompletionItem,
  value : StringOrSnippetString,
) -> Unit {
  completion_item_set_insert_text_raw(self, value.to_js())
}

///|
/// A string or snippet that should be inserted in a document when selecting
/// this completion. When `falsy` the {@link CompletionItem.label label}
/// is used.
pub fn CompletionItem::clear_insert_text(self : CompletionItem) -> Unit {
  completion_item_set_insert_text_raw(self, JsValue::make(()))
}

///|
/// An optional set of characters that when pressed while this completion is active will accept it first and
/// then type that character. *Note* that all commit characters should have `length=1` and that superfluous
/// characters will be ignored.
pub fn CompletionItem::commit_characters(
  self : CompletionItem,
) -> Array[String]? {
  let raw = completion_item_commit_characters_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An optional set of characters that when pressed while this completion is active will accept it first and
/// then type that character. *Note* that all commit characters should have `length=1` and that superfluous
/// characters will be ignored.
pub fn CompletionItem::set_commit_characters(
  self : CompletionItem,
  value : Array[String],
) -> Unit {
  completion_item_set_commit_characters_raw(self, JsValue::make(value))
}

///|
/// An optional set of characters that when pressed while this completion is active will accept it first and
/// then type that character. *Note* that all commit characters should have `length=1` and that superfluous
/// characters will be ignored.
pub fn CompletionItem::clear_commit_characters(self : CompletionItem) -> Unit {
  completion_item_set_commit_characters_raw(self, JsValue::make(()))
}

///|
/// An optional {@link Command} that is executed *after* inserting this completion. *Note* that
/// additional modifications to the current document should be described with the
/// {@link CompletionItem.additionalTextEdits additionalTextEdits}-property.
pub fn CompletionItem::command(self : CompletionItem) -> Command? {
  let raw = completion_item_command_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An optional {@link Command} that is executed *after* inserting this completion. *Note* that
/// additional modifications to the current document should be described with the
/// {@link CompletionItem.additionalTextEdits additionalTextEdits}-property.
pub fn CompletionItem::set_command(
  self : CompletionItem,
  value : Command,
) -> Unit {
  completion_item_set_command_raw(self, JsValue::make(value))
}

///|
/// An optional {@link Command} that is executed *after* inserting this completion. *Note* that
/// additional modifications to the current document should be described with the
/// {@link CompletionItem.additionalTextEdits additionalTextEdits}-property.
pub fn CompletionItem::clear_command(self : CompletionItem) -> Unit {
  completion_item_set_command_raw(self, JsValue::make(()))
}

///|
/// The completion items.
pub fn[T] CompletionList::items(self : CompletionList[T]) -> Array[T] {
  completion_list_items_raw(JsValue::make(self).cast()).cast()
}

///|
/// This list is not complete. Further typing should result in recomputing
/// this list.
pub fn[T] CompletionList::is_incomplete(self : CompletionList[T]) -> Bool {
  completion_list_is_incomplete_raw(JsValue::make(self).cast())
}

///|
/// This list is not complete. Further typing should result in recomputing
/// this list.
pub fn[T] CompletionList::set_is_incomplete(
  self : CompletionList[T],
  value : Bool,
) -> Unit {
  completion_list_set_is_incomplete_raw(JsValue::make(self).cast(), value)
}

///|
/// How the completion was triggered.
pub fn CompletionContext::new(
  trigger_kind : CompletionTriggerKind,
  trigger_character? : String,
) -> CompletionContext {
  CompletionContext::{ trigger_kind, trigger_character }
}

///|
/// How the completion was triggered.

///|
/// Character that triggered the completion item provider.
///
/// `undefined` if the provider was not triggered by a character.
///
/// The trigger character is already in the document when the completion provider is triggered.

///|
/// Creates a new parameter information object.
///
/// @param label A label string or inclusive start and exclusive end offsets within its containing signature label.
/// @param documentation A doc string.
pub fn ParameterInformation::new(
  label : ParameterLabel,
  documentation? : MarkdownStringValue,
) -> ParameterInformation {
  let documentation_value = match documentation {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
  parameter_information_ffi(label.to_js(), documentation_value)
}

///|
/// Creates a new signature information object.
///
/// @param label A label string.
/// @param documentation A doc string.
pub fn SignatureInformation::new(
  label : String,
  documentation? : MarkdownStringValue,
) -> SignatureInformation {
  let documentation_value = match documentation {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
  signature_information_ffi(label, documentation_value)
}

///|
pub fn SignatureHelp::new() -> SignatureHelp {
  signature_help_ffi()
}

///|
extern "js" fn parameter_information_ffi(
  label : JsValue,
  documentation : JsValue,
) -> ParameterInformation =
  #| (label, documentation) =>
  #|   documentation === undefined || documentation === null
  #|     ? new (require("vscode").ParameterInformation)(label)
  #|     : new (require("vscode").ParameterInformation)(label, documentation)

///|
extern "js" fn parameter_information_label_raw(
  info : ParameterInformation,
) -> JsValue =
  #| (info) => info.label

///|
extern "js" fn parameter_information_set_label_raw(
  info : ParameterInformation,
  value : JsValue,
) -> Unit =
  #| (info, value) => { info.label = value; }

///|
extern "js" fn parameter_information_documentation_raw(
  info : ParameterInformation,
) -> JsValue =
  #| (info) => info.documentation

///|
extern "js" fn parameter_information_set_documentation_raw(
  info : ParameterInformation,
  value : JsValue,
) -> Unit =
  #| (info, value) => { info.documentation = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn signature_information_ffi(
  label : String,
  documentation : JsValue,
) -> SignatureInformation =
  #| (label, documentation) =>
  #|   documentation === undefined || documentation === null
  #|     ? new (require("vscode").SignatureInformation)(label)
  #|     : new (require("vscode").SignatureInformation)(label, documentation)

///|
extern "js" fn signature_information_documentation_raw(
  info : SignatureInformation,
) -> JsValue =
  #| (info) => info.documentation

///|
extern "js" fn signature_information_set_documentation_raw(
  info : SignatureInformation,
  value : JsValue,
) -> Unit =
  #| (info, value) => { info.documentation = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn signature_information_active_parameter_raw(
  info : SignatureInformation,
) -> JsValue =
  #| (info) => info.activeParameter

///|
extern "js" fn signature_information_set_active_parameter_raw(
  info : SignatureInformation,
  value : JsValue,
) -> Unit =
  #| (info, value) => { info.activeParameter = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn signature_help_ffi() -> SignatureHelp =
  #| () => new (require("vscode").SignatureHelp)()

///|
pub fn SignatureHelpProviderMetadata::new(
  trigger_characters : Array[String],
  retrigger_characters? : Array[String],
) -> SignatureHelpProviderMetadata {
  SignatureHelpProviderMetadata::{ trigger_characters, retrigger_characters }
}

///|
/// The label of this signature.
///
/// Either a string or inclusive start and exclusive end offsets within its containing
/// {@link SignatureInformation.label signature label}. *Note*: A label of type string must be
/// a substring of its containing signature information's {@link SignatureInformation.label label}.
pub fn ParameterInformation::label(
  self : ParameterInformation,
) -> ParameterLabel? {
  ParameterLabel::from_js(parameter_information_label_raw(self))
}

///|
/// The label of this signature.
///
/// Either a string or inclusive start and exclusive end offsets within its containing
/// {@link SignatureInformation.label signature label}. *Note*: A label of type string must be
/// a substring of its containing signature information's {@link SignatureInformation.label label}.
pub fn ParameterInformation::set_label(
  self : ParameterInformation,
  value : ParameterLabel,
) -> Unit {
  parameter_information_set_label_raw(self, value.to_js())
}

///|
/// The human-readable doc-comment of this signature. Will be shown
/// in the UI but can be omitted.
pub fn ParameterInformation::documentation(
  self : ParameterInformation,
) -> MarkdownStringValue? {
  MarkdownStringValue::from_js(parameter_information_documentation_raw(self))
}

///|
/// The human-readable doc-comment of this signature. Will be shown
/// in the UI but can be omitted.
pub fn ParameterInformation::set_documentation(
  self : ParameterInformation,
  value : MarkdownStringValue,
) -> Unit {
  parameter_information_set_documentation_raw(self, value.to_js())
}

///|
/// The human-readable doc-comment of this signature. Will be shown
/// in the UI but can be omitted.
pub fn ParameterInformation::clear_documentation(
  self : ParameterInformation,
) -> Unit {
  parameter_information_set_documentation_raw(self, JsValue::make(()))
}

///|
/// The label of this signature. Will be shown in
/// the UI.
pub extern "js" fn SignatureInformation::label(
  self : SignatureInformation,
) -> String =
  #| (value) => value.label

///|
/// The label of this signature. Will be shown in
/// the UI.
pub extern "js" fn SignatureInformation::set_label(
  self : SignatureInformation,
  value : String,
) -> Unit =
  #| (info, value) => { info.label = value; }

///|
/// The human-readable doc-comment of this signature. Will be shown
/// in the UI but can be omitted.
pub fn SignatureInformation::documentation(
  self : SignatureInformation,
) -> MarkdownStringValue? {
  MarkdownStringValue::from_js(signature_information_documentation_raw(self))
}

///|
/// The human-readable doc-comment of this signature. Will be shown
/// in the UI but can be omitted.
pub fn SignatureInformation::set_documentation(
  self : SignatureInformation,
  value : MarkdownStringValue,
) -> Unit {
  signature_information_set_documentation_raw(self, value.to_js())
}

///|
/// The human-readable doc-comment of this signature. Will be shown
/// in the UI but can be omitted.
pub fn SignatureInformation::clear_documentation(
  self : SignatureInformation,
) -> Unit {
  signature_information_set_documentation_raw(self, JsValue::make(()))
}

///|
/// The parameters of this signature.
pub extern "js" fn SignatureInformation::parameters(
  self : SignatureInformation,
) -> Array[ParameterInformation] =
  #| (value) => value.parameters

///|
/// The parameters of this signature.
pub extern "js" fn SignatureInformation::set_parameters(
  self : SignatureInformation,
  value : Array[ParameterInformation],
) -> Unit =
  #| (info, value) => { info.parameters = value; }

///|
/// The index of the active parameter.
///
/// If provided, this is used in place of {@linkcode SignatureHelp.activeParameter}.
pub fn SignatureInformation::active_parameter(
  self : SignatureInformation,
) -> Int? {
  let raw = signature_information_active_parameter_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The index of the active parameter.
///
/// If provided, this is used in place of {@linkcode SignatureHelp.activeParameter}.
pub fn SignatureInformation::set_active_parameter(
  self : SignatureInformation,
  value : Int,
) -> Unit {
  signature_information_set_active_parameter_raw(self, JsValue::make(value))
}

///|
/// The index of the active parameter.
///
/// If provided, this is used in place of {@linkcode SignatureHelp.activeParameter}.
pub fn SignatureInformation::clear_active_parameter(
  self : SignatureInformation,
) -> Unit {
  signature_information_set_active_parameter_raw(self, JsValue::make(()))
}

///|
/// One or more signatures.
pub extern "js" fn SignatureHelp::signatures(
  self : SignatureHelp,
) -> Array[SignatureInformation] =
  #| (value) => value.signatures

///|
/// One or more signatures.
pub extern "js" fn SignatureHelp::set_signatures(
  self : SignatureHelp,
  value : Array[SignatureInformation],
) -> Unit =
  #| (info, value) => { info.signatures = value; }

///|
/// The active signature.
pub extern "js" fn SignatureHelp::active_signature(self : SignatureHelp) -> Int =
  #| (value) => value.activeSignature

///|
/// The active signature.
pub extern "js" fn SignatureHelp::set_active_signature(
  self : SignatureHelp,
  value : Int,
) -> Unit =
  #| (info, value) => { info.activeSignature = value; }

///|
/// The active parameter of the active signature.
pub extern "js" fn SignatureHelp::active_parameter(self : SignatureHelp) -> Int =
  #| (value) => value.activeParameter

///|
/// The active parameter of the active signature.
pub extern "js" fn SignatureHelp::set_active_parameter(
  self : SignatureHelp,
  value : Int,
) -> Unit =
  #| (info, value) => { info.activeParameter = value; }

///|
pub fn SignatureHelpContext::new(
  trigger_kind : SignatureHelpTriggerKind,
  is_retrigger : Bool,
  trigger_character? : String,
  active_signature_help? : SignatureHelp,
) -> SignatureHelpContext {
  SignatureHelpContext::{
    triggerKind: trigger_kind,
    triggerCharacter: trigger_character,
    isRetrigger: is_retrigger,
    activeSignatureHelp: active_signature_help,
  }
}

///|
/// Action that caused signature help to be triggered.

///|
/// Character that caused signature help to be triggered.
///
/// This is `undefined` when signature help is not triggered by typing, such as when manually invoking
/// signature help or when moving the cursor.

///|
/// `true` if signature help was already showing when it was triggered.
///
/// Retriggers occur when the signature help is already active and can be caused by actions such as
/// typing a trigger character, a cursor move, or document content changes.

///|
/// The currently active {@linkcode SignatureHelp}.
///
/// The `activeSignatureHelp` has its {@linkcode SignatureHelp.activeSignature activeSignature} field updated based on
/// the user arrowing through available signatures.

///|
/// List of characters that trigger signature help.

///|
/// List of characters that re-trigger signature help.
///
/// These trigger characters are only active when signature help is already showing. All trigger characters
/// are also counted as re-trigger characters.

///|
/// Creates a new document highlight object.
///
/// @param range The range the highlight applies to.
/// @param kind The highlight kind, default is {@link DocumentHighlightKind.Text text}.
pub fn DocumentHighlight::new(
  range : Range,
  kind? : DocumentHighlightKind,
) -> DocumentHighlight {
  document_highlight_ffi(range, option_to_js(kind))
}

///|
/// The range this highlight applies to.
pub extern "js" fn DocumentHighlight::range(self : DocumentHighlight) -> Range =
  #| (value) => value.range

///|
/// The range this highlight applies to.
pub extern "js" fn DocumentHighlight::set_range(
  self : DocumentHighlight,
  value : Range,
) -> Unit =
  #| (item, value) => { item.range = value; }

///|
/// The highlight kind, default is {@link DocumentHighlightKind.Text text}.
pub fn DocumentHighlight::kind(
  self : DocumentHighlight,
) -> DocumentHighlightKind? {
  let raw = document_highlight_kind_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The highlight kind, default is {@link DocumentHighlightKind.Text text}.
pub fn DocumentHighlight::set_kind(
  self : DocumentHighlight,
  value : DocumentHighlightKind,
) -> Unit {
  document_highlight_set_kind_raw(self, JsValue::make(value))
}

///|
/// The highlight kind, default is {@link DocumentHighlightKind.Text text}.
pub fn DocumentHighlight::clear_kind(self : DocumentHighlight) -> Unit {
  document_highlight_set_kind_raw(self, JsValue::make(()))
}

///|
fn code_action_kind_from_value(value : String) -> CodeActionKind {
  match value {
    "" => Empty
    "quickfix" => QuickFix
    "refactor" => Refactor
    "refactor.extract" => RefactorExtract
    "refactor.inline" => RefactorInline
    "refactor.move" => RefactorMove
    "refactor.rewrite" => RefactorRewrite
    "source" => Source
    "source.organizeImports" => SourceOrganizeImports
    "source.fixAll" => SourceFixAll
    "notebook" => Notebook
    _ => Custom(value)
  }
}

///|
/// String value of the kind, e.g. `"refactor.extract.function"`.
pub fn CodeActionKind::value(self : CodeActionKind) -> String {
  match self {
    Empty => ""
    QuickFix => "quickfix"
    Refactor => "refactor"
    RefactorExtract => "refactor.extract"
    RefactorInline => "refactor.inline"
    RefactorMove => "refactor.move"
    RefactorRewrite => "refactor.rewrite"
    Source => "source"
    SourceOrganizeImports => "source.organizeImports"
    SourceFixAll => "source.fixAll"
    Notebook => "notebook"
    Custom(value) => value
  }
}

///|
/// Create a new kind by appending a more specific selector to the current kind.
///
/// Does not modify the current kind.
pub fn CodeActionKind::append(
  self : CodeActionKind,
  parts : String,
) -> CodeActionKind {
  if parts == "" {
    self
  } else {
    let prefix = self.value()
    if prefix == "" {
      code_action_kind_from_value(parts)
    } else {
      code_action_kind_from_value("\{prefix}.\{parts}")
    }
  }
}

///|
/// Checks if this code action kind intersects `other`.
///
/// The kind `"refactor.extract"` for example intersects `refactor`, `"refactor.extract"` and `"refactor.extract.function"`,
/// but not `"unicorn.refactor.extract"`, or `"refactor.extractAll"`.
///
/// @param other Kind to check.
pub fn CodeActionKind::intersects(
  self : CodeActionKind,
  other : CodeActionKind,
) -> Bool {
  self.contains(other) || other.contains(self)
}

///|
/// Checks if `other` is a sub-kind of this `CodeActionKind`.
///
/// The kind `"refactor.extract"` for example contains `"refactor.extract"` and ``"refactor.extract.function"`,
/// but not `"unicorn.refactor.extract"`, or `"refactor.extractAll"` or `refactor`.
///
/// @param other Kind to check.
pub fn CodeActionKind::contains(
  self : CodeActionKind,
  other : CodeActionKind,
) -> Bool {
  let self_value = self.value()
  if self_value == "" {
    true
  } else {
    let other_value = other.value()
    if self_value == other_value {
      true
    } else {
      other_value.has_prefix("\{self_value}.")
    }
  }
}

///|
/// The reason why code actions were requested.
pub fn CodeActionContext::new(
  trigger_kind : CodeActionTriggerKind,
  diagnostics : Array[Diagnostic],
  only? : CodeActionKind,
) -> CodeActionContext {
  CodeActionContext::{ diagnostics, only, trigger_kind }
}

///|
pub fn CodeAction::new(title : String, kind? : CodeActionKind) -> CodeAction {
  code_action_ffi(title, code_action_kind_option_to_js(kind))
}

///|
/// The reason why code actions were requested.

///|
/// An array of diagnostics.

///|
/// Requested kind of actions to return.
///
/// Actions not of this kind are filtered out before being shown by the [lightbulb](https://code.visualstudio.com/docs/editor/editingevolved#_code-action).

///|
/// A short, human-readable, title for this code action.
pub extern "js" fn CodeAction::title(self : CodeAction) -> String =
  #| (value) => value.title

///|
/// A short, human-readable, title for this code action.
pub extern "js" fn CodeAction::set_title(
  self : CodeAction,
  value : String,
) -> Unit =
  #| (item, value) => { item.title = value; }

///|
/// A {@link WorkspaceEdit workspace edit} this code action performs.
pub fn CodeAction::edit(self : CodeAction) -> WorkspaceEdit? {
  let raw = code_action_edit_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// A {@link WorkspaceEdit workspace edit} this code action performs.
pub fn CodeAction::set_edit(self : CodeAction, value : WorkspaceEdit) -> Unit {
  code_action_set_edit_raw(self, JsValue::make(value))
}

///|
/// A {@link WorkspaceEdit workspace edit} this code action performs.
pub fn CodeAction::clear_edit(self : CodeAction) -> Unit {
  code_action_set_edit_raw(self, JsValue::make(()))
}

///|
/// {@link Diagnostic Diagnostics} that this code action resolves.
pub fn CodeAction::diagnostics(self : CodeAction) -> Array[Diagnostic]? {
  let raw = code_action_diagnostics_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// {@link Diagnostic Diagnostics} that this code action resolves.
pub fn CodeAction::set_diagnostics(
  self : CodeAction,
  value : Array[Diagnostic],
) -> Unit {
  code_action_set_diagnostics_raw(self, JsValue::make(value))
}

///|
/// {@link Diagnostic Diagnostics} that this code action resolves.
pub fn CodeAction::clear_diagnostics(self : CodeAction) -> Unit {
  code_action_set_diagnostics_raw(self, JsValue::make(()))
}

///|
/// A {@link Command} this code action executes.
///
/// If this command throws an exception, the editor displays the exception message to users in the editor at the
/// current cursor position.
pub fn CodeAction::command(self : CodeAction) -> Command? {
  let raw = code_action_command_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// A {@link Command} this code action executes.
///
/// If this command throws an exception, the editor displays the exception message to users in the editor at the
/// current cursor position.
pub fn CodeAction::set_command(self : CodeAction, value : Command) -> Unit {
  code_action_set_command_raw(self, JsValue::make(value))
}

///|
/// A {@link Command} this code action executes.
///
/// If this command throws an exception, the editor displays the exception message to users in the editor at the
/// current cursor position.
pub fn CodeAction::clear_command(self : CodeAction) -> Unit {
  code_action_set_command_raw(self, JsValue::make(()))
}

///|
/// {@link CodeActionKind Kind} of the code action.
///
/// Used to filter code actions.
pub fn CodeAction::kind(self : CodeAction) -> CodeActionKind? {
  let raw = code_action_kind_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(code_action_kind_from_value(code_action_kind_value_raw(raw)))
  }
}

///|
/// {@link CodeActionKind Kind} of the code action.
///
/// Used to filter code actions.
pub fn CodeAction::set_kind(self : CodeAction, value : CodeActionKind) -> Unit {
  code_action_set_kind_raw(self, code_action_kind_option_to_js(Some(value)))
}

///|
/// {@link CodeActionKind Kind} of the code action.
///
/// Used to filter code actions.
pub fn CodeAction::clear_kind(self : CodeAction) -> Unit {
  code_action_set_kind_raw(self, JsValue::make(()))
}

///|
/// Marks this as a preferred action. Preferred actions are used by the `auto fix` command and can be targeted
/// by keybindings.
///
/// A quick fix should be marked preferred if it properly addresses the underlying error.
/// A refactoring should be marked preferred if it is the most reasonable choice of actions to take.
pub fn CodeAction::is_preferred(self : CodeAction) -> Bool? {
  let raw = code_action_is_preferred_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Marks this as a preferred action. Preferred actions are used by the `auto fix` command and can be targeted
/// by keybindings.
///
/// A quick fix should be marked preferred if it properly addresses the underlying error.
/// A refactoring should be marked preferred if it is the most reasonable choice of actions to take.
pub fn CodeAction::set_is_preferred(self : CodeAction, value : Bool) -> Unit {
  code_action_set_is_preferred_raw(self, JsValue::make(value))
}

///|
/// Marks this as a preferred action. Preferred actions are used by the `auto fix` command and can be targeted
/// by keybindings.
///
/// A quick fix should be marked preferred if it properly addresses the underlying error.
/// A refactoring should be marked preferred if it is the most reasonable choice of actions to take.
pub fn CodeAction::clear_is_preferred(self : CodeAction) -> Unit {
  code_action_set_is_preferred_raw(self, JsValue::make(()))
}

///|
pub fn CodeActionProviderMetadata::new(
  provided_kinds? : Array[CodeActionKind] = [],
) -> CodeActionProviderMetadata {
  let provided_kinds_value : Array[CodeActionKind]? = if provided_kinds.length() ==
    0 {
    None
  } else {
    Some(provided_kinds)
  }
  CodeActionProviderMetadata::{ provided_kinds: provided_kinds_value }
}

///|
/// Size of a tab in spaces.

///|
/// Prefer spaces over tabs.

///|
pub fn FormattingOptions::new(
  tab_size : Int,
  insert_spaces : Bool,
) -> FormattingOptions {
  FormattingOptions::{ tab_size, insert_spaces }
}

///|
/// Creates a new document link.
///
/// @param range The range the document link applies to. Must not be empty.
/// @param target The uri the document link points to.
pub fn DocumentLink::new(range : Range, target? : Uri) -> DocumentLink {
  document_link_ffi(range, option_to_js(target))
}

///|
/// The range this link applies to.
pub extern "js" fn DocumentLink::range(self : DocumentLink) -> Range =
  #| (value) => value.range

///|
/// The range this link applies to.
pub extern "js" fn DocumentLink::set_range(
  self : DocumentLink,
  value : Range,
) -> Unit =
  #| (item, value) => { item.range = value; }

///|
/// The uri this link points to.
pub fn DocumentLink::target(self : DocumentLink) -> Uri? {
  let raw = document_link_target_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The uri this link points to.
pub fn DocumentLink::set_target(self : DocumentLink, value : Uri) -> Unit {
  document_link_set_target_raw(self, JsValue::make(value))
}

///|
/// The uri this link points to.
pub fn DocumentLink::clear_target(self : DocumentLink) -> Unit {
  document_link_set_target_raw(self, JsValue::make(()))
}

///|
/// The tooltip text when you hover over this link.
///
/// If a tooltip is provided, is will be displayed in a string that includes instructions on how to
/// trigger the link, such as `{0} (ctrl + click)`. The specific instructions vary depending on OS,
/// user settings, and localization.
pub fn DocumentLink::tooltip(self : DocumentLink) -> String? {
  let raw = document_link_tooltip_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The tooltip text when you hover over this link.
///
/// If a tooltip is provided, is will be displayed in a string that includes instructions on how to
/// trigger the link, such as `{0} (ctrl + click)`. The specific instructions vary depending on OS,
/// user settings, and localization.
pub fn DocumentLink::set_tooltip(self : DocumentLink, value : String) -> Unit {
  document_link_set_tooltip_raw(self, JsValue::make(value))
}

///|
/// The tooltip text when you hover over this link.
///
/// If a tooltip is provided, is will be displayed in a string that includes instructions on how to
/// trigger the link, such as `{0} (ctrl + click)`. The specific instructions vary depending on OS,
/// user settings, and localization.
pub fn DocumentLink::clear_tooltip(self : DocumentLink) -> Unit {
  document_link_set_tooltip_raw(self, JsValue::make(()))
}

///|
/// Creates a new code lens object.
///
/// @param range The range to which this code lens applies.
/// @param command The command associated to this code lens.
pub fn CodeLens::new(range : Range, command? : Command) -> CodeLens {
  code_lens_ffi(range, option_to_js(command))
}

///|
/// The range in which this code lens is valid. Should only span a single line.
pub extern "js" fn CodeLens::range(self : CodeLens) -> Range =
  #| (value) => value.range

///|
/// The range in which this code lens is valid. Should only span a single line.
pub extern "js" fn CodeLens::set_range(self : CodeLens, value : Range) -> Unit =
  #| (item, value) => { item.range = value; }

///|
/// The command this code lens represents.
pub fn CodeLens::command(self : CodeLens) -> Command? {
  let raw = code_lens_command_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The command this code lens represents.
pub fn CodeLens::set_command(self : CodeLens, value : Command) -> Unit {
  code_lens_set_command_raw(self, JsValue::make(value))
}

///|
/// The command this code lens represents.
pub fn CodeLens::clear_command(self : CodeLens) -> Unit {
  code_lens_set_command_raw(self, JsValue::make(()))
}

///|
/// `true` when there is a command associated.
pub fn CodeLens::is_resolved(self : CodeLens) -> Bool? {
  let raw = code_lens_is_resolved_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Creates a new color instance.
///
/// @param red The red component.
/// @param green The green component.
/// @param blue The blue component.
/// @param alpha The alpha component.
pub fn Color::new(
  red : Float,
  green : Float,
  blue : Float,
  alpha : Float,
) -> Color {
  color_ffi(red, green, blue, alpha)
}

///|
/// The red component of this color in the range `[0-1]`.
pub extern "js" fn Color::red(self : Color) -> Float =
  #| (color) => color.red

///|
/// The green component of this color in the range `[0-1]`.
pub extern "js" fn Color::green(self : Color) -> Float =
  #| (color) => color.green

///|
/// The blue component of this color in the range `[0-1]`.
pub extern "js" fn Color::blue(self : Color) -> Float =
  #| (color) => color.blue

///|
/// The alpha component of this color in the range `[0-1]`.
pub extern "js" fn Color::alpha(self : Color) -> Float =
  #| (color) => color.alpha

///|
extern "js" fn color_ffi(
  red : Float,
  green : Float,
  blue : Float,
  alpha : Float,
) -> Color =
  #| (red, green, blue, alpha) => new (require("vscode").Color)(red, green, blue, alpha)

///|
/// Creates a new color range.
///
/// @param range The range the color appears in. Must not be empty.
/// @param color The value of the color.
pub fn ColorInformation::new(range : Range, color : Color) -> ColorInformation {
  color_information_ffi(range, color)
}

///|
/// The range in the document where this color appears.
pub extern "js" fn ColorInformation::range(self : ColorInformation) -> Range =
  #| (value) => value.range

///|
/// The range in the document where this color appears.
pub extern "js" fn ColorInformation::set_range(
  self : ColorInformation,
  value : Range,
) -> Unit =
  #| (item, value) => { item.range = value; }

///|
/// The actual color value for this color range.
pub extern "js" fn ColorInformation::color(self : ColorInformation) -> Color =
  #| (value) => value.color

///|
/// The actual color value for this color range.
pub extern "js" fn ColorInformation::set_color(
  self : ColorInformation,
  value : Color,
) -> Unit =
  #| (item, value) => { item.color = value; }

///|
/// Creates a new color presentation.
///
/// @param label The label of this color presentation.
pub fn ColorPresentation::new(label : String) -> ColorPresentation {
  color_presentation_ffi(label)
}

///|
/// The label of this color presentation. It will be shown on the color
/// picker header. By default this is also the text that is inserted when selecting
/// this color presentation.
pub extern "js" fn ColorPresentation::label(self : ColorPresentation) -> String =
  #| (value) => value.label

///|
/// The label of this color presentation. It will be shown on the color
/// picker header. By default this is also the text that is inserted when selecting
/// this color presentation.
pub extern "js" fn ColorPresentation::set_label(
  self : ColorPresentation,
  value : String,
) -> Unit =
  #| (item, value) => { item.label = value; }

///|
/// An {@link TextEdit edit} which is applied to a document when selecting
/// this presentation for the color.  When `falsy` the {@link ColorPresentation.label label}
/// is used.
pub fn ColorPresentation::text_edit(self : ColorPresentation) -> TextEdit? {
  let raw = color_presentation_text_edit_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An {@link TextEdit edit} which is applied to a document when selecting
/// this presentation for the color.  When `falsy` the {@link ColorPresentation.label label}
/// is used.
pub fn ColorPresentation::set_text_edit(
  self : ColorPresentation,
  value : TextEdit,
) -> Unit {
  color_presentation_set_text_edit_raw(self, JsValue::make(value))
}

///|
/// An {@link TextEdit edit} which is applied to a document when selecting
/// this presentation for the color.  When `falsy` the {@link ColorPresentation.label label}
/// is used.
pub fn ColorPresentation::clear_text_edit(self : ColorPresentation) -> Unit {
  color_presentation_set_text_edit_raw(self, JsValue::make(()))
}

///|
/// An optional array of additional {@link TextEdit text edits} that are applied when
/// selecting this color presentation. Edits must not overlap with the main {@link ColorPresentation.textEdit edit} nor with themselves.
pub fn ColorPresentation::additional_text_edits(
  self : ColorPresentation,
) -> Array[TextEdit]? {
  let raw = color_presentation_additional_text_edits_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An optional array of additional {@link TextEdit text edits} that are applied when
/// selecting this color presentation. Edits must not overlap with the main {@link ColorPresentation.textEdit edit} nor with themselves.
pub fn ColorPresentation::set_additional_text_edits(
  self : ColorPresentation,
  value : Array[TextEdit],
) -> Unit {
  color_presentation_set_additional_text_edits_raw(self, JsValue::make(value))
}

///|
/// An optional array of additional {@link TextEdit text edits} that are applied when
/// selecting this color presentation. Edits must not overlap with the main {@link ColorPresentation.textEdit edit} nor with themselves.
pub fn ColorPresentation::clear_additional_text_edits(
  self : ColorPresentation,
) -> Unit {
  color_presentation_set_additional_text_edits_raw(self, JsValue::make(()))
}

///|

///|

///|
pub fn ColorPresentationContext::new(
  document : TextDocument,
  range : Range,
) -> ColorPresentationContext {
  ColorPresentationContext::{ document, range }
}

///|
pub fn FoldingContext::new(max_ranges : Int) -> FoldingContext {
  FoldingContext::{ max_ranges, }
}

///|

///|
/// Creates a new folding range.
///
/// @param start The start line of the folded range.
/// @param end The end line of the folded range.
/// @param kind The kind of the folding range.
pub fn FoldingRange::new(
  start : Int,
  end : Int,
  kind? : FoldingRangeKind,
) -> FoldingRange {
  folding_range_ffi(start, end, option_to_js(kind))
}

///|
/// The zero-based start line of the range to fold. The folded area starts after the line's last character.
/// To be valid, the end must be zero or larger and smaller than the number of lines in the document.
pub extern "js" fn FoldingRange::start(self : FoldingRange) -> Int =
  #| (value) => value.start

///|
/// The zero-based start line of the range to fold. The folded area starts after the line's last character.
/// To be valid, the end must be zero or larger and smaller than the number of lines in the document.
pub extern "js" fn FoldingRange::set_start(
  self : FoldingRange,
  value : Int,
) -> Unit =
  #| (item, value) => { item.start = value; }

///|
/// The zero-based end line of the range to fold. The folded area ends with the line's last character.
/// To be valid, the end must be zero or larger and smaller than the number of lines in the document.
pub extern "js" fn FoldingRange::end(self : FoldingRange) -> Int =
  #| (value) => value.end

///|
/// The zero-based end line of the range to fold. The folded area ends with the line's last character.
/// To be valid, the end must be zero or larger and smaller than the number of lines in the document.
pub extern "js" fn FoldingRange::set_end(
  self : FoldingRange,
  value : Int,
) -> Unit =
  #| (item, value) => { item.end = value; }

///|
/// Describes the {@link FoldingRangeKind Kind} of the folding range such as {@link FoldingRangeKind.Comment Comment} or
/// {@link FoldingRangeKind.Region Region}. The kind is used to categorize folding ranges and used by commands
/// like 'Fold all comments'. See
/// {@link FoldingRangeKind} for an enumeration of all kinds.
/// If not set, the range is originated from a syntax element.
pub fn FoldingRange::kind(self : FoldingRange) -> FoldingRangeKind? {
  let raw = folding_range_kind_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Describes the {@link FoldingRangeKind Kind} of the folding range such as {@link FoldingRangeKind.Comment Comment} or
/// {@link FoldingRangeKind.Region Region}. The kind is used to categorize folding ranges and used by commands
/// like 'Fold all comments'. See
/// {@link FoldingRangeKind} for an enumeration of all kinds.
/// If not set, the range is originated from a syntax element.
pub fn FoldingRange::set_kind(
  self : FoldingRange,
  value : FoldingRangeKind,
) -> Unit {
  folding_range_set_kind_raw(self, JsValue::make(value))
}

///|
/// Describes the {@link FoldingRangeKind Kind} of the folding range such as {@link FoldingRangeKind.Comment Comment} or
/// {@link FoldingRangeKind.Region Region}. The kind is used to categorize folding ranges and used by commands
/// like 'Fold all comments'. See
/// {@link FoldingRangeKind} for an enumeration of all kinds.
/// If not set, the range is originated from a syntax element.
pub fn FoldingRange::clear_kind(self : FoldingRange) -> Unit {
  folding_range_set_kind_raw(self, JsValue::make(()))
}

///|

///|

///|
/// Creates a new selection range.
///
/// @param range The range of the selection range.
/// @param parent The parent of the selection range.
pub fn SelectionRange::new(
  range : Range,
  parent? : SelectionRange,
) -> SelectionRange {
  selection_range_ffi(range, option_to_js(parent))
}

///|
/// The {@link Range} of this selection range.
pub extern "js" fn SelectionRange::range(self : SelectionRange) -> Range =
  #| (value) => value.range

///|
/// The parent selection range containing this range.
pub fn SelectionRange::parent(self : SelectionRange) -> SelectionRange? {
  let raw = selection_range_parent_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Create a new linked editing ranges object.
///
/// @param ranges A list of ranges that can be edited together
/// @param wordPattern An optional word pattern that describes valid contents for the given ranges
pub fn LinkedEditingRanges::new(
  ranges : Array[Range],
  word_pattern? : RegExp,
) -> LinkedEditingRanges {
  linked_editing_ranges_ffi(ranges, option_to_js(word_pattern))
}

///|
/// A list of ranges that can be edited together. The ranges must have
/// identical length and text content. The ranges cannot overlap.
pub extern "js" fn LinkedEditingRanges::ranges(
  self : LinkedEditingRanges,
) -> Array[Range] =
  #| (value) => value.ranges

///|
/// An optional word pattern that describes valid contents for the given ranges.
/// If no pattern is provided, the language configuration's word pattern will be used.
pub fn LinkedEditingRanges::word_pattern(self : LinkedEditingRanges) -> RegExp? {
  let raw = linked_editing_ranges_word_pattern_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
extern "js" fn linked_editing_ranges_ffi(
  ranges : Array[Range],
  word_pattern : JsValue,
) -> LinkedEditingRanges =
  #| (ranges, wordPattern) =>
  #|   wordPattern === undefined || wordPattern === null
  #|     ? new (require("vscode").LinkedEditingRanges)(ranges)
  #|     : new (require("vscode").LinkedEditingRanges)(ranges, wordPattern)

///|
extern "js" fn linked_editing_ranges_word_pattern_raw(
  value : LinkedEditingRanges,
) -> JsValue =
  #| (value) => value.wordPattern

///|
fn code_action_kind_option_to_js(value : CodeActionKind?) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => code_action_kind_to_js_ffi(value.value())
  }
}

///|
extern "js" fn document_highlight_ffi(
  range : Range,
  kind : JsValue,
) -> DocumentHighlight =
  #| (range, kind) =>
  #|   kind === undefined || kind === null
  #|     ? new (require("vscode").DocumentHighlight)(range)
  #|     : new (require("vscode").DocumentHighlight)(range, kind)

///|
extern "js" fn document_highlight_kind_raw(
  highlight : DocumentHighlight,
) -> JsValue =
  #| (highlight) => highlight.kind

///|
extern "js" fn document_highlight_set_kind_raw(
  highlight : DocumentHighlight,
  value : JsValue,
) -> Unit =
  #| (highlight, value) => { highlight.kind = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn code_action_kind_to_js_ffi(value : String) -> JsValue =
  #| (value) => {
  #|   const kind = require("vscode").CodeActionKind;
  #|   if (value === "") return kind.Empty;
  #|   let result = kind.Empty;
  #|   for (const part of value.split(".")) {
  #|     if (part.length === 0) continue;
  #|     result = result.append(part);
  #|   }
  #|   return result;
  #| }

///|
extern "js" fn code_action_kind_value_raw(value : JsValue) -> String =
  #| (value) => value.value

///|
extern "js" fn code_action_ffi(title : String, kind : JsValue) -> CodeAction =
  #| (title, kind) =>
  #|   kind === undefined || kind === null
  #|     ? new (require("vscode").CodeAction)(title)
  #|     : new (require("vscode").CodeAction)(title, kind)

///|
extern "js" fn code_action_edit_raw(action : CodeAction) -> JsValue =
  #| (action) => action.edit

///|
extern "js" fn code_action_set_edit_raw(
  action : CodeAction,
  value : JsValue,
) -> Unit =
  #| (action, value) => { action.edit = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn code_action_diagnostics_raw(action : CodeAction) -> JsValue =
  #| (action) => action.diagnostics

///|
extern "js" fn code_action_set_diagnostics_raw(
  action : CodeAction,
  value : JsValue,
) -> Unit =
  #| (action, value) => { action.diagnostics = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn code_action_command_raw(action : CodeAction) -> JsValue =
  #| (action) => action.command

///|
extern "js" fn code_action_set_command_raw(
  action : CodeAction,
  value : JsValue,
) -> Unit =
  #| (action, value) => { action.command = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn code_action_kind_raw(action : CodeAction) -> JsValue =
  #| (action) => action.kind

///|
extern "js" fn code_action_set_kind_raw(
  action : CodeAction,
  value : JsValue,
) -> Unit =
  #| (action, value) => { action.kind = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn code_action_is_preferred_raw(action : CodeAction) -> JsValue =
  #| (action) => action.isPreferred

///|
extern "js" fn code_action_set_is_preferred_raw(
  action : CodeAction,
  value : JsValue,
) -> Unit =
  #| (action, value) => { action.isPreferred = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn document_link_ffi(
  range : Range,
  target : JsValue,
) -> DocumentLink =
  #| (range, target) =>
  #|   target === undefined || target === null
  #|     ? new (require("vscode").DocumentLink)(range)
  #|     : new (require("vscode").DocumentLink)(range, target)

///|
extern "js" fn document_link_target_raw(link : DocumentLink) -> JsValue =
  #| (link) => link.target

///|
extern "js" fn document_link_set_target_raw(
  link : DocumentLink,
  value : JsValue,
) -> Unit =
  #| (link, value) => { link.target = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn document_link_tooltip_raw(link : DocumentLink) -> JsValue =
  #| (link) => link.tooltip

///|
extern "js" fn document_link_set_tooltip_raw(
  link : DocumentLink,
  value : JsValue,
) -> Unit =
  #| (link, value) => { link.tooltip = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn code_lens_ffi(range : Range, command : JsValue) -> CodeLens =
  #| (range, command) =>
  #|   command === undefined || command === null
  #|     ? new (require("vscode").CodeLens)(range)
  #|     : new (require("vscode").CodeLens)(range, command)

///|
extern "js" fn code_lens_command_raw(lens : CodeLens) -> JsValue =
  #| (lens) => lens.command

///|
extern "js" fn code_lens_set_command_raw(
  lens : CodeLens,
  value : JsValue,
) -> Unit =
  #| (lens, value) => { lens.command = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn code_lens_is_resolved_raw(lens : CodeLens) -> JsValue =
  #| (lens) => lens.isResolved

///|
extern "js" fn color_information_ffi(
  range : Range,
  color : Color,
) -> ColorInformation =
  #| (range, color) => new (require("vscode").ColorInformation)(range, color)

///|
extern "js" fn color_presentation_ffi(label : String) -> ColorPresentation =
  #| (label) => new (require("vscode").ColorPresentation)(label)

///|
extern "js" fn color_presentation_text_edit_raw(
  presentation : ColorPresentation,
) -> JsValue =
  #| (presentation) => presentation.textEdit

///|
extern "js" fn color_presentation_set_text_edit_raw(
  presentation : ColorPresentation,
  value : JsValue,
) -> Unit =
  #| (presentation, value) => { presentation.textEdit = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn color_presentation_additional_text_edits_raw(
  presentation : ColorPresentation,
) -> JsValue =
  #| (presentation) => presentation.additionalTextEdits

///|
extern "js" fn color_presentation_set_additional_text_edits_raw(
  presentation : ColorPresentation,
  value : JsValue,
) -> Unit =
  #| (presentation, value) => { presentation.additionalTextEdits = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn folding_range_ffi(
  start : Int,
  end : Int,
  kind : JsValue,
) -> FoldingRange =
  #| (start, end, kind) =>
  #|   kind === undefined || kind === null
  #|     ? new (require("vscode").FoldingRange)(start, end)
  #|     : new (require("vscode").FoldingRange)(start, end, kind)

///|
extern "js" fn folding_range_kind_raw(range : FoldingRange) -> JsValue =
  #| (range) => range.kind

///|
extern "js" fn folding_range_set_kind_raw(
  range : FoldingRange,
  value : JsValue,
) -> Unit =
  #| (range, value) => { range.kind = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn selection_range_ffi(
  range : Range,
  parent : JsValue,
) -> SelectionRange =
  #| (range, parent) =>
  #|   parent === undefined || parent === null
  #|     ? new (require("vscode").SelectionRange)(range)
  #|     : new (require("vscode").SelectionRange)(range, parent)

///|
extern "js" fn selection_range_parent_raw(
  selection : SelectionRange,
) -> JsValue =
  #| (selection) => selection.parent

///|
extern "js" fn call_hierarchy_item_ffi(
  kind : SymbolKind,
  name : String,
  detail : String,
  uri : Uri,
  range : Range,
  selection_range : Range,
) -> CallHierarchyItem =
  #| (kind, name, detail, uri, range, selectionRange) =>
  #|   new (require("vscode").CallHierarchyItem)(kind, name, detail, uri, range, selectionRange)

///|
extern "js" fn call_hierarchy_incoming_call_ffi(
  item : CallHierarchyItem,
  from_ranges : Array[Range],
) -> CallHierarchyIncomingCall =
  #| (item, fromRanges) => new (require("vscode").CallHierarchyIncomingCall)(item, fromRanges)

///|
extern "js" fn call_hierarchy_outgoing_call_ffi(
  item : CallHierarchyItem,
  from_ranges : Array[Range],
) -> CallHierarchyOutgoingCall =
  #| (item, fromRanges) => new (require("vscode").CallHierarchyOutgoingCall)(item, fromRanges)

///|
extern "js" fn type_hierarchy_item_ffi(
  kind : SymbolKind,
  name : String,
  detail : String,
  uri : Uri,
  range : Range,
  selection_range : Range,
) -> TypeHierarchyItem =
  #| (kind, name, detail, uri, range, selectionRange) =>
  #|   new (require("vscode").TypeHierarchyItem)(kind, name, detail, uri, range, selectionRange)

///|
extern "js" fn inlay_hint_ffi(
  position : Position,
  label : JsValue,
  kind : JsValue,
) -> InlayHint =
  #| (position, label, kind) =>
  #|   kind === undefined || kind === null
  #|     ? new (require("vscode").InlayHint)(position, label)
  #|     : new (require("vscode").InlayHint)(position, label, kind)

///|
extern "js" fn inlay_hint_label_raw(hint : InlayHint) -> JsValue =
  #| (hint) => hint.label

///|
extern "js" fn inlay_hint_kind_raw(hint : InlayHint) -> JsValue =
  #| (hint) => hint.kind

///|
extern "js" fn inlay_hint_set_label_raw(
  hint : InlayHint,
  value : JsValue,
) -> Unit =
  #| (hint, value) => { hint.label = value; }

///|
extern "js" fn inlay_hint_set_kind_raw(
  hint : InlayHint,
  value : JsValue,
) -> Unit =
  #| (hint, value) => { hint.kind = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn inlay_hint_label_part_ffi(value : String) -> InlayHintLabelPart =
  #| (value) => new (require("vscode").InlayHintLabelPart)(value)

///|
extern "js" fn inline_completion_list_ffi(
  items : Array[InlineCompletionItem],
) -> InlineCompletionList =
  #| (items) => new (require("vscode").InlineCompletionList)(items)

///|
extern "js" fn inline_completion_item_ffi(
  insert_text : JsValue,
  range : JsValue,
  command : JsValue,
) -> InlineCompletionItem =
  #| (insertText, range, command) => {
  #|   const value = new (require("vscode").InlineCompletionItem)(insertText);
  #|   if (range !== undefined && range !== null) value.range = range;
  #|   if (command !== undefined && command !== null) value.command = command;
  #|   return value;
  #| }

///|
extern "js" fn inline_completion_item_insert_text_raw(
  item : InlineCompletionItem,
) -> JsValue =
  #| (item) => item.insertText

///|
extern "js" fn inline_completion_item_range_raw(
  item : InlineCompletionItem,
) -> JsValue =
  #| (item) => item.range

///|
extern "js" fn inline_completion_item_command_raw(
  item : InlineCompletionItem,
) -> JsValue =
  #| (item) => item.command

///|
extern "js" fn document_drop_or_paste_kind_value_raw_ffi(
  value : JsValue,
) -> String =
  #| (value) => value.value

///|
extern "js" fn document_drop_edit_ffi(
  insert_text : JsValue,
  title : JsValue,
  kind : JsValue,
) -> DocumentDropEdit =
  #| (insertText, title, kind) =>
  #|   kind === undefined || kind === null
  #|     ? title === undefined || title === null
  #|       ? new (require("vscode").DocumentDropEdit)(insertText)
  #|       : new (require("vscode").DocumentDropEdit)(insertText, title)
  #|     : new (require("vscode").DocumentDropEdit)(insertText, title, kind)

///|
extern "js" fn document_drop_edit_title_raw(edit : DocumentDropEdit) -> JsValue =
  #| (edit) => edit.title

///|
extern "js" fn document_drop_edit_kind_raw(edit : DocumentDropEdit) -> JsValue =
  #| (edit) => edit.kind

///|
extern "js" fn document_drop_edit_yield_to_raw(
  edit : DocumentDropEdit,
) -> JsValue =
  #| (edit) => edit.yieldTo

///|
extern "js" fn document_drop_edit_insert_text_raw(
  edit : DocumentDropEdit,
) -> JsValue =
  #| (edit) => edit.insertText

///|
extern "js" fn document_drop_edit_additional_edit_raw(
  edit : DocumentDropEdit,
) -> JsValue =
  #| (edit) => edit.additionalEdit

///|
extern "js" fn document_paste_edit_ffi(
  insert_text : JsValue,
  title : String,
  kind : JsValue,
) -> DocumentPasteEdit =
  #| (insertText, title, kind) =>
  #|   new (require("vscode").DocumentPasteEdit)(insertText, title, kind)

///|
extern "js" fn document_paste_edit_kind_raw(
  edit : DocumentPasteEdit,
) -> JsValue =
  #| (edit) => edit.kind

///|
extern "js" fn document_paste_edit_set_kind_raw(
  edit : DocumentPasteEdit,
  value : JsValue,
) -> Unit =
  #| (edit, value) => { edit.kind = value; }

///|
/// Creates a new call hierarchy item.
pub fn CallHierarchyItem::new(
  kind : SymbolKind,
  name : String,
  detail : String,
  uri : Uri,
  range : Range,
  selection_range : Range,
) -> CallHierarchyItem {
  call_hierarchy_item_ffi(kind, name, detail, uri, range, selection_range)
}

///|
/// The name of this item.
pub extern "js" fn CallHierarchyItem::name(self : CallHierarchyItem) -> String =
  #| (value) => value.name

///|
/// The kind of this item.
pub extern "js" fn CallHierarchyItem::kind(
  self : CallHierarchyItem,
) -> SymbolKind =
  #| (value) => value.kind

///|
/// The resource identifier of this item.
pub extern "js" fn CallHierarchyItem::uri(self : CallHierarchyItem) -> Uri =
  #| (value) => value.uri

///|
/// More detail for this item, e.g. the signature of a function.
pub extern "js" fn CallHierarchyItem::detail(
  self : CallHierarchyItem,
) -> String =
  #| (value) => value.detail

///|
/// The range enclosing this symbol not including leading/trailing whitespace but everything else, e.g. comments and code.
pub extern "js" fn CallHierarchyItem::range(self : CallHierarchyItem) -> Range =
  #| (value) => value.range

///|
/// The range that should be selected and revealed when this symbol is being picked, e.g. the name of a function.
/// Must be contained by the {@linkcode CallHierarchyItem.range range}.
pub extern "js" fn CallHierarchyItem::selection_range(
  self : CallHierarchyItem,
) -> Range =
  #| (value) => value.selectionRange

///|
/// Create a new call object.
///
/// @param item The item making the call.
/// @param fromRanges The ranges at which the calls appear.
pub fn CallHierarchyIncomingCall::new(
  item : CallHierarchyItem,
  from_ranges : Array[Range],
) -> CallHierarchyIncomingCall {
  call_hierarchy_incoming_call_ffi(item, from_ranges)
}

///|
/// The item that makes the call.
pub extern "js" fn CallHierarchyIncomingCall::from_item(
  self : CallHierarchyIncomingCall,
) -> CallHierarchyItem =
  #| (value) => value.from

///|
/// The range at which at which the calls appears. This is relative to the caller
/// denoted by {@linkcode CallHierarchyIncomingCall.from this.from}.
pub extern "js" fn CallHierarchyIncomingCall::from_ranges(
  self : CallHierarchyIncomingCall,
) -> Array[Range] =
  #| (value) => value.fromRanges

///|
/// Create a new call object.
///
/// @param item The item being called
/// @param fromRanges The ranges at which the calls appear.
pub fn CallHierarchyOutgoingCall::new(
  item : CallHierarchyItem,
  from_ranges : Array[Range],
) -> CallHierarchyOutgoingCall {
  call_hierarchy_outgoing_call_ffi(item, from_ranges)
}

///|
/// The item that is called.
pub extern "js" fn CallHierarchyOutgoingCall::to_item(
  self : CallHierarchyOutgoingCall,
) -> CallHierarchyItem =
  #| (value) => value.to

///|
/// The range at which this item is called. This is the range relative to the caller, e.g the item
/// passed to {@linkcode CallHierarchyProvider.provideCallHierarchyOutgoingCalls provideCallHierarchyOutgoingCalls}
/// and not {@linkcode CallHierarchyOutgoingCall.to this.to}.
pub extern "js" fn CallHierarchyOutgoingCall::from_ranges(
  self : CallHierarchyOutgoingCall,
) -> Array[Range] =
  #| (value) => value.fromRanges

///|
/// Creates a new type hierarchy item.
///
/// @param kind The kind of the item.
/// @param name The name of the item.
/// @param detail The details of the item.
/// @param uri The Uri of the item.
/// @param range The whole range of the item.
/// @param selectionRange The selection range of the item.
pub fn TypeHierarchyItem::new(
  kind : SymbolKind,
  name : String,
  detail : String,
  uri : Uri,
  range : Range,
  selection_range : Range,
) -> TypeHierarchyItem {
  type_hierarchy_item_ffi(kind, name, detail, uri, range, selection_range)
}

///|
/// The name of this item.
pub extern "js" fn TypeHierarchyItem::name(self : TypeHierarchyItem) -> String =
  #| (value) => value.name

///|
/// The kind of this item.
pub extern "js" fn TypeHierarchyItem::kind(
  self : TypeHierarchyItem,
) -> SymbolKind =
  #| (value) => value.kind

///|
/// The resource identifier of this item.
pub extern "js" fn TypeHierarchyItem::uri(self : TypeHierarchyItem) -> Uri =
  #| (value) => value.uri

///|
/// More detail for this item, e.g. the signature of a class member.
pub extern "js" fn TypeHierarchyItem::detail(
  self : TypeHierarchyItem,
) -> String =
  #| (value) => value.detail

///|
/// The range enclosing this symbol not including leading/trailing whitespace
/// but everything else, e.g. comments and code.
pub extern "js" fn TypeHierarchyItem::range(self : TypeHierarchyItem) -> Range =
  #| (value) => value.range

///|
/// The range that should be selected and revealed when this symbol is being
/// picked, e.g. the name of a class. Must be contained by the {@link TypeHierarchyItem.range range}-property.
pub extern "js" fn TypeHierarchyItem::selection_range(
  self : TypeHierarchyItem,
) -> Range =
  #| (value) => value.selectionRange

///|
/// Creates a new inlay hint.
///
/// @param position The position of the hint.
/// @param label The label of the hint.
/// @param kind The {@link InlayHintKind kind} of the hint.
pub fn InlayHint::new(
  position : Position,
  label : InlayHintLabelValue,
  kind? : InlayHintKind,
) -> InlayHint {
  inlay_hint_ffi(position, label.to_js(), option_to_js(kind))
}

///|
/// The position of this hint.
pub extern "js" fn InlayHint::position(self : InlayHint) -> Position =
  #| (value) => value.position

///|
/// The label of this hint. A human readable string or an array of {@link InlayHintLabelPart label parts}.
///
/// *Note* that neither the string nor the label part can be empty.
pub fn InlayHint::label(self : InlayHint) -> InlayHintLabelValue? {
  InlayHintLabelValue::from_js(inlay_hint_label_raw(self))
}

///|
/// The label of this hint. A human readable string or an array of {@link InlayHintLabelPart label parts}.
///
/// *Note* that neither the string nor the label part can be empty.
pub fn InlayHint::set_label(
  self : InlayHint,
  value : InlayHintLabelValue,
) -> Unit {
  inlay_hint_set_label_raw(self, value.to_js())
}

///|
/// The kind of this hint. The inlay hint kind defines the appearance of this inlay hint.
pub fn InlayHint::kind(self : InlayHint) -> InlayHintKind? {
  let raw = inlay_hint_kind_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The kind of this hint. The inlay hint kind defines the appearance of this inlay hint.
pub fn InlayHint::set_kind(self : InlayHint, value : InlayHintKind) -> Unit {
  inlay_hint_set_kind_raw(self, JsValue::make(value))
}

///|
/// The kind of this hint. The inlay hint kind defines the appearance of this inlay hint.
pub fn InlayHint::clear_kind(self : InlayHint) -> Unit {
  inlay_hint_set_kind_raw(self, JsValue::make(()))
}

///|
/// Creates a semantic tokens legend.
///
/// @param tokenTypes An array of token types.
/// @param tokenModifiers An array of token modifiers.
pub fn SemanticTokensLegend::new(
  token_types : Array[String],
  token_modifiers? : Array[String] = [],
) -> SemanticTokensLegend {
  semantic_tokens_legend_ffi(token_types, token_modifiers)
}

///|
/// The possible token types.
pub extern "js" fn SemanticTokensLegend::token_types(
  self : SemanticTokensLegend,
) -> Array[String] =
  #| (legend) => legend.tokenTypes

///|
/// The possible token modifiers.
pub extern "js" fn SemanticTokensLegend::token_modifiers(
  self : SemanticTokensLegend,
) -> Array[String] =
  #| (legend) => legend.tokenModifiers

///|
/// Creates a semantic tokens builder.
///
/// @param legend A semantic tokens legend.
pub fn SemanticTokensBuilder::new(
  legend? : SemanticTokensLegend,
) -> SemanticTokensBuilder {
  semantic_tokens_builder_ffi(option_to_js(legend))
}

///|
pub extern "js" fn SemanticTokensBuilder::push_raw(
  self : SemanticTokensBuilder,
  line : Int,
  char : Int,
  length : Int,
  token_type : Int,
  token_modifiers? : Int = 0,
) -> Unit =
  #| (builder, line, char, length, tokenType, tokenModifiers) =>
  #|   builder.push(line, char, length, tokenType, tokenModifiers)

///|
/// Add another token.
///
/// @param line The token start line number (absolute value).
/// @param char The token start character (absolute value).
/// @param length The token length in characters.
/// @param tokenType The encoded token type.
/// @param tokenModifiers The encoded token modifiers.
pub extern "js" fn SemanticTokensBuilder::push_range(
  self : SemanticTokensBuilder,
  range : Range,
  token_type : String,
  token_modifiers? : Array[String] = [],
) -> Unit =
  #| (builder, range, tokenType, tokenModifiers) =>
  #|   tokenModifiers.length === 0
  #|     ? builder.push(range, tokenType)
  #|     : builder.push(range, tokenType, tokenModifiers)

///|
/// Finish and create a `SemanticTokens` instance.
pub extern "js" fn SemanticTokensBuilder::build(
  self : SemanticTokensBuilder,
  result_id? : String = "",
) -> SemanticTokens =
  #| (builder, resultId) => resultId === "" ? builder.build() : builder.build(resultId)

///|
/// Create new semantic tokens.
///
/// @param data Token data.
/// @param resultId Result identifier.
pub fn SemanticTokens::new(
  data : Array[Int],
  result_id? : String = "",
) -> SemanticTokens {
  semantic_tokens_ffi(
    array_to_uint32_array(data),
    if result_id == "" {
      JsValue::make(())
    } else {
      JsValue::make(result_id)
    },
  )
}

///|
/// The actual tokens data.
/// @see {@link DocumentSemanticTokensProvider.provideDocumentSemanticTokens provideDocumentSemanticTokens} for an explanation of the format.
pub fn SemanticTokens::data(self : SemanticTokens) -> Array[Int] {
  array_from_uint32_array(semantic_tokens_data_raw(self))
}

///|
/// The result id of the tokens.
///
/// This is the id that will be passed to `DocumentSemanticTokensProvider.provideDocumentSemanticTokensEdits` (if implemented).
pub fn SemanticTokens::result_id(self : SemanticTokens) -> String? {
  let raw = semantic_tokens_result_id_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Create a semantic token edit.
///
/// @param start Start offset
/// @param deleteCount Number of elements to remove.
/// @param data Elements to insert
pub fn SemanticTokensEdit::new(
  start : Int,
  delete_count : Int,
  data? : Array[Int],
) -> SemanticTokensEdit {
  semantic_tokens_edit_ffi(
    start,
    delete_count,
    match data {
      None => JsValue::make(())
      Some(value) => JsValue::make(array_to_uint32_array(value))
    },
  )
}

///|
/// The start offset of the edit.
pub extern "js" fn SemanticTokensEdit::start(self : SemanticTokensEdit) -> Int =
  #| (edit) => edit.start

///|
/// The count of elements to remove.
pub extern "js" fn SemanticTokensEdit::delete_count(
  self : SemanticTokensEdit,
) -> Int =
  #| (edit) => edit.deleteCount

///|
/// The elements to insert.
pub fn SemanticTokensEdit::data(self : SemanticTokensEdit) -> Array[Int]? {
  let raw = semantic_tokens_edit_data_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(array_from_uint32_array(raw.cast()))
  }
}

///|
/// Create new semantic tokens edits.
///
/// @param edits An array of semantic token edits
/// @param resultId Result identifier.
pub fn SemanticTokensEdits::new(
  edits : Array[SemanticTokensEdit],
  result_id? : String = "",
) -> SemanticTokensEdits {
  semantic_tokens_edits_ffi(
    edits,
    if result_id == "" {
      JsValue::make(())
    } else {
      JsValue::make(result_id)
    },
  )
}

///|
/// The edits to the tokens data.
/// All edits refer to the initial data state.
pub extern "js" fn SemanticTokensEdits::edits(
  self : SemanticTokensEdits,
) -> Array[SemanticTokensEdit] =
  #| (value) => value.edits

///|
/// The result id of the tokens.
///
/// This is the id that will be passed to `DocumentSemanticTokensProvider.provideDocumentSemanticTokensEdits` (if implemented).
pub fn SemanticTokensEdits::result_id(self : SemanticTokensEdits) -> String? {
  let raw = semantic_tokens_edits_result_id_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Creates a new list of inline completion items.
pub fn InlineCompletionList::new(
  items : Array[InlineCompletionItem],
) -> InlineCompletionList {
  inline_completion_list_ffi(items)
}

///|
/// The inline completion items.
pub extern "js" fn InlineCompletionList::items(
  self : InlineCompletionList,
) -> Array[InlineCompletionItem] =
  #| (value) => value.items

///|
pub fn InlineCompletionContext::new(
  trigger_kind : InlineCompletionTriggerKind,
  selected_info? : SelectedCompletionInfo,
) -> InlineCompletionContext {
  InlineCompletionContext::{ trigger_kind, selected_info }
}

///|
/// Describes how the inline completion was triggered.

///|
pub fn SelectedCompletionInfo::new(
  range : Range,
  text : String,
) -> SelectedCompletionInfo {
  SelectedCompletionInfo::{ range, text }
}

///|
/// Creates a new inline completion item.
///
/// @param insertText The text to replace the range with.
/// @param range The range to replace. If not set, the word at the requested position will be used.
/// @param command An optional {@link Command} that is executed *after* inserting this completion.
pub fn InlineCompletionItem::new(
  insert_text : StringOrSnippetString,
  range? : Range,
  command? : Command,
) -> InlineCompletionItem {
  inline_completion_item_ffi(
    insert_text.to_js(),
    option_to_js(range),
    option_to_js(command),
  )
}

///|
/// The text to replace the range with. Must be set.
/// Is used both for the preview and the accept operation.
pub fn InlineCompletionItem::insert_text(
  self : InlineCompletionItem,
) -> StringOrSnippetString? {
  StringOrSnippetString::from_js(inline_completion_item_insert_text_raw(self))
}

///|
pub fn InlineCompletionItem::range(self : InlineCompletionItem) -> Range? {
  let raw = inline_completion_item_range_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn InlineCompletionItem::command(self : InlineCompletionItem) -> Command? {
  let raw = inline_completion_item_command_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Creates a new InlineValueText object.
///
/// @param range The document line where to show the inline value.
/// @param text The value to be shown for the line.
pub fn InlineValueText::new(range : Range, text : String) -> InlineValueText {
  inline_value_text_ffi(range, text)
}

///|
/// The document range for which the inline value applies.
pub extern "js" fn InlineValueText::range(self : InlineValueText) -> Range =
  #| (value) => value.range

///|
/// The text of the inline value.
pub extern "js" fn InlineValueText::text(self : InlineValueText) -> String =
  #| (value) => value.text

///|
/// Creates a new InlineValueVariableLookup object.
///
/// @param range The document line where to show the inline value.
/// @param variableName The name of the variable to look up.
/// @param caseSensitiveLookup How to perform the lookup. If missing lookup is case sensitive.
pub fn InlineValueVariableLookup::new(
  range : Range,
  variable_name? : String = "",
  case_sensitive? : Bool = true,
) -> InlineValueVariableLookup {
  let variable_name_value : String? = if variable_name == "" {
    None
  } else {
    Some(variable_name)
  }
  inline_value_variable_lookup_ffi(
    range,
    option_to_js(variable_name_value),
    case_sensitive,
  )
}

///|
/// The document range for which the inline value applies.
/// The range is used to extract the variable name from the underlying document.
pub extern "js" fn InlineValueVariableLookup::range(
  self : InlineValueVariableLookup,
) -> Range =
  #| (value) => value.range

///|
/// If specified the name of the variable to look up.
pub fn InlineValueVariableLookup::variable_name(
  self : InlineValueVariableLookup,
) -> String? {
  let raw = inline_value_variable_lookup_variable_name_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// How to perform the lookup.
pub extern "js" fn InlineValueVariableLookup::case_sensitive_lookup(
  self : InlineValueVariableLookup,
) -> Bool =
  #| (value) => value.caseSensitiveLookup

///|
/// Creates a new InlineValueEvaluatableExpression object.
///
/// @param range The range in the underlying document from which the evaluatable expression is extracted.
/// @param expression If specified overrides the extracted expression.
pub fn InlineValueEvaluatableExpression::new(
  range : Range,
  expression? : String = "",
) -> InlineValueEvaluatableExpression {
  let expression_value : String? = if expression == "" {
    None
  } else {
    Some(expression)
  }
  inline_value_evaluatable_expression_ffi(range, option_to_js(expression_value))
}

///|
/// The document range for which the inline value applies.
/// The range is used to extract the evaluatable expression from the underlying document.
pub extern "js" fn InlineValueEvaluatableExpression::range(
  self : InlineValueEvaluatableExpression,
) -> Range =
  #| (value) => value.range

///|
/// If specified the expression overrides the extracted expression.
pub fn InlineValueEvaluatableExpression::expression(
  self : InlineValueEvaluatableExpression,
) -> String? {
  let raw = inline_value_evaluatable_expression_expression_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn InlineValueContext::new(
  frame_id : Int,
  stopped_location : Range,
) -> InlineValueContext {
  InlineValueContext::{ frame_id, stopped_location }
}

///|
/// The stack frame (as a DAP Id) where the execution has stopped.

///|
/// The document range where execution has stopped.
/// Typically the end position of the range denotes the line where the inline values are shown.

///|
fn document_drop_or_paste_edit_kind_from_value(
  value : String,
) -> DocumentDropOrPasteEditKind {
  match value {
    "" => Empty
    "text" => Text
    "text.updateImports" => TextUpdateImports
    _ => Custom(value)
  }
}

///|
/// The raw string value of the kind.
pub fn DocumentDropOrPasteEditKind::value(
  self : DocumentDropOrPasteEditKind,
) -> String {
  match self {
    Empty => ""
    Text => "text"
    TextUpdateImports => "text.updateImports"
    Custom(value) => value
  }
}

///|
fn DocumentDropOrPasteEditKind::to_js(
  self : DocumentDropOrPasteEditKind,
) -> JsValue {
  document_drop_or_paste_kind_from_value_ffi(self.value())
}

///|
/// Create a new kind by appending additional scopes to the current kind.
///
/// Does not modify the current kind.
pub fn DocumentDropOrPasteEditKind::append(
  self : DocumentDropOrPasteEditKind,
  part : String,
) -> DocumentDropOrPasteEditKind {
  document_drop_or_paste_edit_kind_from_value(
    document_drop_or_paste_kind_append_value_ffi(self.value(), part),
  )
}

///|
/// Checks if this kind intersects `other`.
///
/// The kind `"text.plain"` for example intersects `text`, `"text.plain"` and `"text.plain.list"`,
/// but not `"unicorn"`, or `"textUnicorn.plain"`.
///
/// @param other Kind to check.
pub fn DocumentDropOrPasteEditKind::intersects(
  self : DocumentDropOrPasteEditKind,
  other : DocumentDropOrPasteEditKind,
) -> Bool {
  document_drop_or_paste_kind_intersects_ffi(self.to_js(), other.to_js())
}

///|
/// Checks if `other` is a sub-kind of this `DocumentDropOrPasteEditKind`.
///
/// The kind `"text.plain"` for example contains `"text.plain"` and `"text.plain.list"`,
/// but not `"text"` or `"unicorn.text.plain"`.
///
/// @param other Kind to check.
pub fn DocumentDropOrPasteEditKind::contains(
  self : DocumentDropOrPasteEditKind,
  other : DocumentDropOrPasteEditKind,
) -> Bool {
  document_drop_or_paste_kind_contains_ffi(self.to_js(), other.to_js())
}

///|
extern "js" fn document_drop_or_paste_kind_from_value_ffi(
  value : String,
) -> JsValue =
  #| (value) => {
  #|   const kind = require("vscode").DocumentDropOrPasteEditKind;
  #|   if (value === "") {
  #|     return kind.Empty;
  #|   }
  #|   if (value === "text") {
  #|     return kind.Text;
  #|   }
  #|   if (value === "text.updateImports") {
  #|     return kind.TextUpdateImports;
  #|   }
  #|   let result = kind.Empty;
  #|   for (const part of value.split(".")) {
  #|     if (part.length === 0) continue;
  #|     result = result.append(part);
  #|   }
  #|   return result;
  #| }

///|
extern "js" fn document_drop_or_paste_kind_append_value_ffi(
  value : String,
  part : String,
) -> String =
  #| (value, part) => {
  #|   if (value.length === 0) {
  #|     return part;
  #|   }
  #|   if (part.length === 0) {
  #|     return value;
  #|   }
  #|   return `${value}.${part}`;
  #| }

///|
extern "js" fn document_drop_or_paste_kind_intersects_ffi(
  kind : JsValue,
  other : JsValue,
) -> Bool =
  #| (kind, other) => kind.intersects(other)

///|
extern "js" fn document_drop_or_paste_kind_contains_ffi(
  kind : JsValue,
  other : JsValue,
) -> Bool =
  #| (kind, other) => kind.contains(other)

///|
/// @param insertText The text or snippet to insert at the drop location.
/// @param title Human readable label that describes the edit.
/// @param kind {@link DocumentDropOrPasteEditKind Kind} of the edit.
pub fn DocumentDropEdit::new(
  insert_text : StringOrSnippetString,
  title? : String = "",
  kind? : DocumentDropOrPasteEditKind,
) -> DocumentDropEdit {
  let normalized_title : String? = if title == "" { None } else { Some(title) }
  document_drop_edit_ffi(
    insert_text.to_js(),
    option_to_js(normalized_title),
    match kind {
      None => JsValue::make(())
      Some(value) => value.to_js()
    },
  )
}

///|
/// Human readable label that describes the edit.
pub fn DocumentDropEdit::title(self : DocumentDropEdit) -> String? {
  let raw = document_drop_edit_title_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Human readable label that describes the edit.

///|
/// Human readable label that describes the edit.

///|
/// {@link DocumentDropOrPasteEditKind Kind} of the edit.
pub fn DocumentDropEdit::kind(
  self : DocumentDropEdit,
) -> DocumentDropOrPasteEditKind? {
  let raw = document_drop_edit_kind_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(
      document_drop_or_paste_edit_kind_from_value(
        document_drop_or_paste_kind_value_raw_ffi(raw),
      ),
    )
  }
}

///|
/// {@link DocumentDropOrPasteEditKind Kind} of the edit.

///|
/// {@link DocumentDropOrPasteEditKind Kind} of the edit.

///|
/// Controls the ordering or multiple edits. If this provider yield to edits, it will be shown lower in the list.
pub fn DocumentDropEdit::yield_to(
  self : DocumentDropEdit,
) -> Array[DocumentDropOrPasteEditKind]? {
  let raw = document_drop_edit_yield_to_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    let raw_values : Array[JsValue] = raw.cast()
    let values : Array[DocumentDropOrPasteEditKind] = []
    for raw_value in raw_values {
      values.push(
        document_drop_or_paste_edit_kind_from_value(
          document_drop_or_paste_kind_value_raw_ffi(raw_value),
        ),
      )
    }
    Some(values)
  }
}

///|
/// Controls the ordering or multiple edits. If this provider yield to edits, it will be shown lower in the list.

///|
/// Controls the ordering or multiple edits. If this provider yield to edits, it will be shown lower in the list.

///|
/// The text or snippet to insert at the drop location.
pub fn DocumentDropEdit::insert_text(
  self : DocumentDropEdit,
) -> StringOrSnippetString? {
  StringOrSnippetString::from_js(document_drop_edit_insert_text_raw(self))
}

///|
/// The text or snippet to insert at the drop location.

///|
/// An optional additional edit to apply on drop.
pub fn DocumentDropEdit::additional_edit(
  self : DocumentDropEdit,
) -> WorkspaceEdit? {
  let raw = document_drop_edit_additional_edit_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// An optional additional edit to apply on drop.

///|
/// An optional additional edit to apply on drop.

///|
pub fn DocumentPasteEditContext::new(
  trigger_kind : DocumentPasteTriggerKind,
  only? : DocumentDropOrPasteEditKind,
) -> DocumentPasteEditContext {
  DocumentPasteEditContext::{ trigger_kind, only }
}

///|
/// Requested kind of paste edits to return.
///
/// When a explicit kind if requested by {@linkcode DocumentPasteTriggerKind.PasteAs PasteAs}, providers are
/// encourage to be more flexible when generating an edit of the requested kind.

///|
/// The reason why paste edits were requested.

///|
/// Create a new paste edit.
///
/// @param insertText The text or snippet to insert at the pasted locations.
/// @param title Human readable label that describes the edit.
/// @param kind {@link DocumentDropOrPasteEditKind Kind} of the edit.
pub fn DocumentPasteEdit::new(
  insert_text : StringOrSnippetString,
  title : String,
  kind : DocumentDropOrPasteEditKind,
) -> DocumentPasteEdit {
  document_paste_edit_ffi(insert_text.to_js(), title, kind.to_js())
}

///|
/// Human readable label that describes the edit.
pub extern "js" fn DocumentPasteEdit::title(self : DocumentPasteEdit) -> String =
  #| (value) => value.title

///|
/// Human readable label that describes the edit.
pub extern "js" fn DocumentPasteEdit::set_title(
  self : DocumentPasteEdit,
  value : String,
) -> Unit =
  #| (item, value) => { item.title = value; }

///|
/// {@link DocumentDropOrPasteEditKind Kind} of the edit.
pub fn DocumentPasteEdit::kind(
  self : DocumentPasteEdit,
) -> DocumentDropOrPasteEditKind {
  document_drop_or_paste_edit_kind_from_value(
    document_drop_or_paste_kind_value_raw_ffi(
      document_paste_edit_kind_raw(self),
    ),
  )
}

///|
/// {@link DocumentDropOrPasteEditKind Kind} of the edit.
pub fn DocumentPasteEdit::set_kind(
  self : DocumentPasteEdit,
  value : DocumentDropOrPasteEditKind,
) -> Unit {
  document_paste_edit_set_kind_raw(self, value.to_js())
}

///|
/// The text or snippet to insert at the pasted locations.
///
/// If your edit requires more advanced insertion logic, set this to an empty string and provide an {@link DocumentPasteEdit.additionalEdit additional edit} instead.

///|
/// The text or snippet to insert at the pasted locations.
///
/// If your edit requires more advanced insertion logic, set this to an empty string and provide an {@link DocumentPasteEdit.additionalEdit additional edit} instead.

///|
/// An optional additional edit to apply on paste.

///|
/// An optional additional edit to apply on paste.

///|
/// An optional additional edit to apply on paste.

///|
/// Controls ordering when multiple paste edits can potentially be applied.
///
/// If this edit yields to another, it will be shown lower in the list of possible paste edits shown to the user.

///|
/// Controls ordering when multiple paste edits can potentially be applied.
///
/// If this edit yields to another, it will be shown lower in the list of possible paste edits shown to the user.

///|
/// Controls ordering when multiple paste edits can potentially be applied.
///
/// If this edit yields to another, it will be shown lower in the list of possible paste edits shown to the user.

///|
pub extern "js" fn DataTransfer::new() -> DataTransfer =
  #| () => new (require("vscode").DataTransfer)()

///|
/// Retrieves the data transfer item for a given mime type.
///
/// @param mimeType The mime type to get the data transfer item for, such as `text/plain` or `image/png`.
/// Mimes type look ups are case-insensitive.
///
/// Special mime types:
/// - `text/uri-list` — A string with `toString()`ed Uris separated by `\r\n`. To specify a cursor position in the file,
/// set the Uri's fragment to `L3,5`, where 3 is the line number and 5 is the column number.
pub fn DataTransfer::get(
  self : DataTransfer,
  mime_type : String,
) -> DataTransferItem? {
  let raw = DataTransfer::data_transfer_get_raw(self, mime_type)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Sets a mime type to data transfer item mapping.
///
/// @param mimeType The mime type to set the data for. Mimes types stored in lower case, with case-insensitive looks up.
/// @param value The data transfer item for the given mime type.
pub extern "js" fn DataTransfer::set(
  self : DataTransfer,
  mime_type : String,
  value : DataTransferItem,
) -> Unit =
  #| (transfer, mimeType, value) => transfer.set(mimeType, value)

///|
/// Allows iteration through the data transfer items.
///
/// @param callbackfn Callback for iteration through the data transfer items.
/// @param thisArg The `this` context used when invoking the handler function.
pub extern "js" fn DataTransfer::for_each(
  self : DataTransfer,
  callback : (DataTransferItem, String, DataTransfer) -> Unit,
) -> Unit =
  #| (transfer, callback) => transfer.forEach(callback)

///|
/// @param value Custom data stored on this item. Can be retrieved using {@linkcode DataTransferItem.value}.
pub fn DataTransferItem::new(value : Any) -> DataTransferItem {
  data_transfer_item_ffi(JsValue::make(value))
}

///|
extern "js" fn DataTransferItem::as_string_promise(
  self : DataTransferItem,
) -> @js_async.Promise[String] =
  #| (item) => item.asString()

///|
/// Get a string representation of this item.
///
/// If {@linkcode DataTransferItem.value} is an object, this returns the result of json stringifying {@linkcode DataTransferItem.value} value.
pub async fn DataTransferItem::as_string(self : DataTransferItem) -> String {
  @js_async.Promise::wait(DataTransferItem::as_string_promise(self))
}

///|
/// Try getting the {@link DataTransferFile file} associated with this data transfer item.
///
/// Note that the file object is only valid for the scope of the drag and drop operation.
///
/// @returns The file for the data transfer or `undefined` if the item is either not a file or the
/// file data cannot be accessed.
pub fn DataTransferItem::as_file(self : DataTransferItem) -> DataTransferFile? {
  let raw = DataTransferItem::data_transfer_item_as_file_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Custom data stored on this item.
///
/// You can use `value` to share data across operations. The original object can be retrieved so long as the extension that
/// created the `DataTransferItem` runs in the same extension host.
pub fn DataTransferItem::value(self : DataTransferItem) -> Any {
  JsValue::make(data_transfer_item_value_raw(self)).cast()
}

///|
/// The name of the file.
pub fn DataTransferFile::new(name : String, uri? : Uri) -> DataTransferFile {
  DataTransferFile::{ name, uri }
}

///|
/// The name of the file.

///|
/// The full file path of the file.
///
/// May be `undefined` on web.

///|
extern "js" fn DataTransferFile::data_promise(
  self : DataTransferFile,
) -> @js_async.Promise[Uint8Array] =
  #| (file) => file.data()

///|
/// The full file contents of the file.
pub async fn DataTransferFile::data(self : DataTransferFile) -> Bytes {
  bytes_from_uint8_array(
    @js_async.Promise::wait(DataTransferFile::data_promise(self)),
  )
}

///|
pub fn DocumentDropEditProviderMetadata::new(
  drop_mime_types : Array[String],
  provided_kinds? : Array[DocumentDropOrPasteEditKind] = [],
) -> DocumentDropEditProviderMetadata {
  let kinds : Array[DocumentDropOrPasteEditKind]? = if provided_kinds.length() ==
    0 {
    None
  } else {
    Some(provided_kinds)
  }
  DocumentDropEditProviderMetadata::{ provided_kinds: kinds, drop_mime_types }
}

///|
pub fn DocumentPasteProviderMetadata::new(
  provided_kinds : Array[DocumentDropOrPasteEditKind],
  copy_mime_types? : Array[String] = [],
  paste_mime_types? : Array[String] = [],
) -> DocumentPasteProviderMetadata {
  let copy_mime_types : Array[String]? = if copy_mime_types.length() == 0 {
    None
  } else {
    Some(copy_mime_types)
  }
  let paste_mime_types : Array[String]? = if paste_mime_types.length() == 0 {
    None
  } else {
    Some(paste_mime_types)
  }
  DocumentPasteProviderMetadata::{
    provided_kinds,
    copy_mime_types,
    paste_mime_types,
  }
}

///|
extern "js" fn semantic_tokens_builder_ffi(
  legend : JsValue,
) -> SemanticTokensBuilder =
  #| (legend) => {
  #|   const SemanticTokensBuilder = require("vscode").SemanticTokensBuilder;
  #|   return legend === undefined || legend === null
  #|     ? new SemanticTokensBuilder()
  #|     : new SemanticTokensBuilder(legend);
  #| }

///|
extern "js" fn semantic_tokens_legend_ffi(
  token_types : Array[String],
  token_modifiers : Array[String],
) -> SemanticTokensLegend =
  #| (tokenTypes, tokenModifiers) =>
  #|   new (require("vscode").SemanticTokensLegend)(tokenTypes, tokenModifiers)

///|
extern "js" fn semantic_tokens_ffi(
  data : Uint32Array,
  result_id : JsValue,
) -> SemanticTokens =
  #| (data, resultId) =>
  #|   resultId === undefined || resultId === null
  #|     ? new (require("vscode").SemanticTokens)(data)
  #|     : new (require("vscode").SemanticTokens)(data, resultId)

///|
extern "js" fn semantic_tokens_data_raw(tokens : SemanticTokens) -> Uint32Array =
  #| (value) => value.data

///|
extern "js" fn semantic_tokens_result_id_raw(
  tokens : SemanticTokens,
) -> JsValue =
  #| (value) => value.resultId

///|
extern "js" fn semantic_tokens_edit_ffi(
  start : Int,
  delete_count : Int,
  data : JsValue,
) -> SemanticTokensEdit =
  #| (start, deleteCount, data) =>
  #|   data === undefined || data === null
  #|     ? new (require("vscode").SemanticTokensEdit)(start, deleteCount)
  #|     : new (require("vscode").SemanticTokensEdit)(start, deleteCount, data)

///|
extern "js" fn semantic_tokens_edit_data_raw(
  edit : SemanticTokensEdit,
) -> JsValue =
  #| (value) => value.data

///|
extern "js" fn semantic_tokens_edits_ffi(
  edits : Array[SemanticTokensEdit],
  result_id : JsValue,
) -> SemanticTokensEdits =
  #| (edits, resultId) =>
  #|   resultId === undefined || resultId === null
  #|     ? new (require("vscode").SemanticTokensEdits)(edits)
  #|     : new (require("vscode").SemanticTokensEdits)(edits, resultId)

///|
extern "js" fn semantic_tokens_edits_result_id_raw(
  edits : SemanticTokensEdits,
) -> JsValue =
  #| (value) => value.resultId

///|
extern "js" fn inline_value_text_ffi(
  range : Range,
  text : String,
) -> InlineValueText =
  #| (range, text) => new (require("vscode").InlineValueText)(range, text)

///|
extern "js" fn inline_value_variable_lookup_ffi(
  range : Range,
  variable_name : JsValue,
  case_sensitive : Bool,
) -> InlineValueVariableLookup =
  #| (range, variableName, caseSensitive) =>
  #|   variableName === undefined || variableName === null
  #|     ? new (require("vscode").InlineValueVariableLookup)(range, undefined, caseSensitive)
  #|     : new (require("vscode").InlineValueVariableLookup)(range, variableName, caseSensitive)

///|
extern "js" fn inline_value_variable_lookup_variable_name_raw(
  value : InlineValueVariableLookup,
) -> JsValue =
  #| (value) => value.variableName

///|
extern "js" fn inline_value_evaluatable_expression_ffi(
  range : Range,
  expression : JsValue,
) -> InlineValueEvaluatableExpression =
  #| (range, expression) =>
  #|   expression === undefined || expression === null
  #|     ? new (require("vscode").InlineValueEvaluatableExpression)(range)
  #|     : new (require("vscode").InlineValueEvaluatableExpression)(range, expression)

///|
extern "js" fn inline_value_evaluatable_expression_expression_raw(
  value : InlineValueEvaluatableExpression,
) -> JsValue =
  #| (value) => value.expression

///|
extern "js" fn data_transfer_item_ffi(value : JsValue) -> DataTransferItem =
  #| (value) => new (require("vscode").DataTransferItem)(value)

///|
extern "js" fn DataTransfer::data_transfer_get_raw(
  self : DataTransfer,
  mime_type : String,
) -> JsValue =
  #| (transfer, mimeType) => transfer.get(mimeType)

///|
extern "js" fn DataTransferItem::data_transfer_item_as_file_raw(
  self : DataTransferItem,
) -> JsValue =
  #| (item) => item.asFile()

///|
extern "js" fn data_transfer_item_value_raw(item : DataTransferItem) -> JsValue =
  #| (item) => item.value

///|
/// Creates a new symbol information object.
///
/// @param name The name of the symbol.
/// @param kind The kind of the symbol.
/// @param containerName The name of the symbol containing the symbol.
/// @param location The location of the symbol.
pub fn SymbolInformation::new(
  name : String,
  kind : SymbolKind,
  container_name : String,
  location : Location,
) -> SymbolInformation {
  symbol_information_ffi(name, kind, container_name, location)
}

///|
pub fn SymbolInformation::from_range(
  name : String,
  kind : SymbolKind,
  range : Range,
  uri? : Uri,
  container_name? : String,
) -> SymbolInformation {
  symbol_information_range_ffi(
    name,
    kind,
    range,
    option_to_js(uri),
    option_to_js(container_name),
  )
}

///|
/// Creates a new document symbol.
///
/// @param name The name of the symbol.
/// @param detail Details for the symbol.
/// @param kind The kind of the symbol.
/// @param range The full range of the symbol.
/// @param selectionRange The range that should be reveal.
pub fn DocumentSymbol::new(
  name : String,
  detail : String,
  kind : SymbolKind,
  range : Range,
  selection_range : Range,
) -> DocumentSymbol {
  document_symbol_ffi(name, detail, kind, range, selection_range)
}

///|
pub fn DocumentSymbolProviderMetadata::new(
  label? : String,
) -> DocumentSymbolProviderMetadata {
  DocumentSymbolProviderMetadata::{ label, }
}

///|
/// The name of this symbol.

///|
/// The name of this symbol.

///|
/// The name of the symbol containing this symbol.

///|
/// The name of the symbol containing this symbol.

///|
/// The kind of this symbol.

///|
/// The kind of this symbol.

///|
/// The location of this symbol.

///|
/// The location of this symbol.

///|
/// Tags for this symbol.

///|
/// Tags for this symbol.

///|
/// Tags for this symbol.

///|
/// The name of this symbol.

///|
/// The name of this symbol.

///|
/// More detail for this symbol, e.g. the signature of a function.

///|
/// More detail for this symbol, e.g. the signature of a function.

///|
/// The kind of this symbol.

///|
/// The kind of this symbol.

///|
/// The range enclosing this symbol not including leading/trailing whitespace but everything else, e.g. comments and code.

///|
/// The range enclosing this symbol not including leading/trailing whitespace but everything else, e.g. comments and code.

///|
/// The range that should be selected and reveal when this symbol is being picked, e.g. the name of a function.
/// Must be contained by the {@linkcode DocumentSymbol.range range}.

///|
/// The range that should be selected and reveal when this symbol is being picked, e.g. the name of a function.
/// Must be contained by the {@linkcode DocumentSymbol.range range}.

///|
/// Children of this symbol, e.g. properties of a class.

///|
/// Children of this symbol, e.g. properties of a class.

///|
/// Tags for this symbol.

///|
/// Tags for this symbol.

///|
/// Tags for this symbol.

///|
/// Include the declaration of the current symbol.
pub fn ReferenceContext::new(include_declaration : Bool) -> ReferenceContext {
  ReferenceContext::{ includeDeclaration: include_declaration }
}

///|
/// Include the declaration of the current symbol.

///|
extern "js" fn symbol_information_range_ffi(
  name : String,
  kind : SymbolKind,
  range : Range,
  uri : JsValue,
  container_name : JsValue,
) -> SymbolInformation =
  #| (name, kind, range, uri, containerName) =>
  #|   new (require("vscode").SymbolInformation)(name, kind, range, uri, containerName)

///|
extern "js" fn symbol_information_ffi(
  name : String,
  kind : SymbolKind,
  container_name : String,
  location : Location,
) -> SymbolInformation =
  #| (name, kind, containerName, location) =>
  #|   new (require("vscode").SymbolInformation)(name, kind, containerName, location)

///|
extern "js" fn document_symbol_ffi(
  name : String,
  detail : String,
  kind : SymbolKind,
  range : Range,
  selection_range : Range,
) -> DocumentSymbol =
  #| (name, detail, kind, range, selectionRange) =>
  #|   new (require("vscode").DocumentSymbol)(name, detail, kind, range, selectionRange)

///|
/// Creates a new location object.
///
/// @param uri The resource identifier.
/// @param rangeOrPosition The range or position. Positions will be converted to an empty range.
pub fn Location::new(uri : Uri, range : Range) -> Location {
  location_ffi(uri, range)
}

///|
pub fn Location::from_position(uri : Uri, position : Position) -> Location {
  location_from_position_ffi(uri, position)
}

///|
/// The resource identifier of this location.
pub extern "js" fn Location::uri(self : Location) -> Uri =
  #| (value) => value.uri

///|
/// The document range of this location.
pub extern "js" fn Location::range(self : Location) -> Range =
  #| (value) => value.range

///|
/// The resource identifier of this location.
pub extern "js" fn Location::set_uri(self : Location, value : Uri) -> Unit =
  #| (location, value) => { location.uri = value; }

///|
/// The document range of this location.
pub extern "js" fn Location::set_range(self : Location, value : Range) -> Unit =
  #| (location, value) => { location.range = value; }

///|
pub fn LocationLink::new(
  target_uri : Uri,
  target_range : Range,
  target_selection_range? : Range,
  origin_selection_range? : Range,
) -> LocationLink {
  LocationLink::{
    targetUri: target_uri,
    targetRange: target_range,
    targetSelectionRange: target_selection_range,
    originSelectionRange: origin_selection_range,
  }
}

///|
/// The target resource identifier of this link.

///|
/// The full target range of this link.

///|
/// The span of this link.

///|
/// Span of the origin of this link.
///
/// Used as the underlined span for mouse definition hover. Defaults to the word range at
/// the definition position.
extern "js" fn completion_item_ffi(
  label : JsValue,
  kind : JsValue,
) -> CompletionItem =
  #| (label, kind) => {
  #|   const CompletionItem = require("vscode").CompletionItem;
  #|   return kind === undefined || kind === null
  #|     ? new CompletionItem(label)
  #|     : new CompletionItem(label, kind);
  #| }

///|
extern "js" fn completion_list_ffi(
  items : Array[CompletionItem],
  is_incomplete : Bool,
) -> JsValue =
  #| (items, isIncomplete) => new (require("vscode").CompletionList)(items, isIncomplete)

///|
extern "js" fn completion_item_label_raw(item : CompletionItem) -> JsValue =
  #| (item) => item.label

///|
extern "js" fn completion_item_kind_raw(item : CompletionItem) -> JsValue =
  #| (item) => item.kind

///|
extern "js" fn completion_item_set_kind_raw(
  item : CompletionItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.kind = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn completion_item_documentation_raw(
  item : CompletionItem,
) -> JsValue =
  #| (item) => item.documentation

///|
extern "js" fn completion_item_set_documentation_raw(
  item : CompletionItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.documentation = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn completion_item_insert_text_raw(
  item : CompletionItem,
) -> JsValue =
  #| (item) => item.insertText

///|
extern "js" fn completion_item_set_insert_text_raw(
  item : CompletionItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.insertText = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn completion_item_commit_characters_raw(
  item : CompletionItem,
) -> JsValue =
  #| (item) => item.commitCharacters

///|
extern "js" fn completion_item_set_commit_characters_raw(
  item : CompletionItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.commitCharacters = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn completion_item_command_raw(item : CompletionItem) -> JsValue =
  #| (item) => item.command

///|
extern "js" fn completion_item_set_command_raw(
  item : CompletionItem,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.command = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn completion_list_items_raw(
  list : CompletionList[JsValue],
) -> JsValue =
  #| (list) => list.items

///|
extern "js" fn completion_list_is_incomplete_raw(
  list : CompletionList[JsValue],
) -> Bool =
  #| (list) => list.isIncomplete

///|
extern "js" fn completion_list_set_is_incomplete_raw(
  list : CompletionList[JsValue],
  value : Bool,
) -> Unit =
  #| (list, value) => { list.isIncomplete = value; }

///|
extern "js" fn location_ffi(uri : Uri, range : Range) -> Location =
  #| (uri, range) => new (require("vscode").Location)(uri, range)

///|
extern "js" fn location_from_position_ffi(
  uri : Uri,
  position : Position,
) -> Location =
  #| (uri, position) => new (require("vscode").Location)(uri, position)

///|

///|
/// Creates a new telemetry trusted value.
///
/// @param value A value to trust
pub fn TelemetryTrustedValue::new(value : Any) -> TelemetryTrustedValue {
  telemetry_trusted_value_ffi(JsValue::make(value))
}

///|
/// The value that is trusted to not contain PII.
pub fn TelemetryTrustedValue::value(self : TelemetryTrustedValue) -> Any {
  JsValue::make(telemetry_trusted_value_raw(self)).cast()
}

///|
extern "js" fn telemetry_trusted_value_ffi(
  value : JsValue,
) -> TelemetryTrustedValue =
  #| (value) => new (require("vscode").TelemetryTrustedValue)(value)

///|
extern "js" fn telemetry_trusted_value_raw(
  value : TelemetryTrustedValue,
) -> JsValue =
  #| (value) => value.value

///|
/// An {@link Event} which fires when the enablement state of usage or error telemetry changes.
pub extern "js" fn TelemetryLogger::on_did_change_enable_states(
  self : TelemetryLogger,
) -> Event[TelemetryLogger] =
  #| (logger) => logger.onDidChangeEnableStates

///|
/// Whether or not usage telemetry is enabled for this logger.
pub extern "js" fn TelemetryLogger::is_usage_enabled(
  self : TelemetryLogger,
) -> Bool =
  #| (logger) => logger.isUsageEnabled

///|
/// Whether or not error telemetry is enabled for this logger.
pub extern "js" fn TelemetryLogger::is_errors_enabled(
  self : TelemetryLogger,
) -> Bool =
  #| (logger) => logger.isErrorsEnabled

///|
fn telemetry_data_to_js(data : Array[(String, Any)]?) -> JsValue {
  match data {
    None => JsValue::make(())
    Some(entries) => string_json_map_ffi(entries)
  }
}

///|
/// Log a usage event.
///
/// After completing cleaning, telemetry setting checks, and data mix-in calls `TelemetrySender.sendEventData` to log the event.
/// Automatically supports echoing to extension telemetry output channel.
/// @param eventName The event name to log
/// @param data The data to log
pub fn TelemetryLogger::log_usage(
  self : TelemetryLogger,
  event_name : String,
  data? : Array[(String, Any)],
) -> Unit {
  TelemetryLogger::telemetry_logger_log_usage_raw(
    self,
    event_name,
    telemetry_data_to_js(data),
  )
}

///|
/// Log an error event.
///
/// After completing cleaning, telemetry setting checks, and data mix-in calls `TelemetrySender.sendEventData` to log the event. Differs from `logUsage` in that it will log the event if the telemetry setting is Error+.
/// Automatically supports echoing to extension telemetry output channel.
/// @param eventName The event name to log
/// @param data The data to log
pub fn TelemetryLogger::log_error_event(
  self : TelemetryLogger,
  event_name : String,
  data? : Array[(String, Any)],
) -> Unit {
  TelemetryLogger::telemetry_logger_log_error_event_raw(
    self,
    event_name,
    telemetry_data_to_js(data),
  )
}

///|
/// Log an error event.
///
/// After completing cleaning, telemetry setting checks, and data mix-in calls `TelemetrySender.sendEventData` to log the event. Differs from `logUsage` in that it will log the event if the telemetry setting is Error+.
/// Automatically supports echoing to extension telemetry output channel.
/// @param eventName The event name to log
/// @param data The data to log
pub fn TelemetryLogger::log_error(
  self : TelemetryLogger,
  error : JsError,
  data? : Array[(String, Any)],
) -> Unit {
  TelemetryLogger::telemetry_logger_log_error_raw(
    self,
    JsValue::make(error),
    telemetry_data_to_js(data),
  )
}

///|
/// Dispose this object and free resources.
extern "js" fn telemetry_logger_dispose_raw(logger : TelemetryLogger) -> Unit =
  #| (logger) => logger.dispose()

///|
pub fn TelemetryLogger::dispose(self : TelemetryLogger) -> Unit {
  telemetry_logger_dispose_raw(self)
}

///|
pub impl AsDisposable for TelemetryLogger with as_disposable(self) {
  disposable_from_js(self)
}

///|
/// Function to send event data without a stacktrace. Used within a {@link TelemetryLogger}
///
/// @param eventName The name of the event which you are logging
/// @param data A serializable key value pair that is being logged
pub fn TelemetrySender::send_event_data(
  self : TelemetrySender,
  event_name : String,
  data? : Array[(String, Any)],
) -> Unit {
  TelemetrySender::telemetry_sender_send_event_data_raw(
    self,
    event_name,
    telemetry_data_to_js(data),
  )
}

///|
/// Function to send an error. Used within a {@link TelemetryLogger}
///
/// @param error The error being logged
/// @param data Any additional data to be collected with the exception
pub fn TelemetrySender::send_error_data(
  self : TelemetrySender,
  error : JsError,
  data? : Array[(String, Any)],
) -> Unit {
  TelemetrySender::telemetry_sender_send_error_data_raw(
    self,
    JsValue::make(error),
    telemetry_data_to_js(data),
  )
}

///|
fn TelemetrySender::flush_promise(
  self : TelemetrySender,
) -> @js_async.Promise[Unit] {
  telemetry_sender_flush_ffi(self)
}

///|
/// Optional flush function which will give this sender a chance to send any remaining events
/// as its {@link TelemetryLogger} is being disposed
pub async fn TelemetrySender::flush(self : TelemetrySender) -> Unit {
  @js_async.Promise::wait(TelemetrySender::flush_promise(self))
}

///|
extern "js" fn telemetry_sender_flush_ffi(
  sender : TelemetrySender,
) -> @js_async.Promise[Unit] =
  #| (sender) => Promise.resolve(sender.flush ? sender.flush() : undefined)

///|
extern "js" fn TelemetryLogger::telemetry_logger_log_usage_raw(
  self : TelemetryLogger,
  event_name : String,
  data : JsValue,
) -> Unit =
  #| (logger, eventName, data) => logger.logUsage(eventName, data)

///|
extern "js" fn TelemetryLogger::telemetry_logger_log_error_event_raw(
  self : TelemetryLogger,
  event_name : String,
  data : JsValue,
) -> Unit =
  #| (logger, eventName, data) => logger.logError(eventName, data)

///|
extern "js" fn TelemetryLogger::telemetry_logger_log_error_raw(
  self : TelemetryLogger,
  error : JsValue,
  data : JsValue,
) -> Unit =
  #| (logger, error, data) => logger.logError(error, data)

///|
extern "js" fn TelemetrySender::telemetry_sender_send_event_data_raw(
  self : TelemetrySender,
  event_name : String,
  data : JsValue,
) -> Unit =
  #| (sender, eventName, data) => sender.sendEventData(eventName, data)

///|
extern "js" fn TelemetrySender::telemetry_sender_send_error_data_raw(
  self : TelemetrySender,
  error : JsValue,
  data : JsValue,
) -> Unit =
  #| (sender, error, data) => sender.sendErrorData(error, data)

///|
/// Append the given value to the debug console.
///
/// @param value A string, falsy values will not be printed.
pub extern "js" fn DebugConsole::append(
  self : DebugConsole,
  value : String,
) -> Unit =
  #| (console, value) => console.append(value)

///|
/// Append the given value and a line feed character
/// to the debug console.
///
/// @param value A string, falsy values will be printed.
pub extern "js" fn DebugConsole::append_line(
  self : DebugConsole,
  value : String,
) -> Unit =
  #| (console, value) => console.appendLine(value)

///|
/// The {@link DebugSession debug session} for which the custom event was received.
pub fn DebugSessionCustomEvent::new(
  session : DebugSession,
  event : String,
  body : Any,
) -> DebugSessionCustomEvent {
  DebugSessionCustomEvent::{ session, event, body }
}

///|
/// The {@link DebugSession debug session} for which the custom event was received.

///|
/// Type of event.

///|
/// Event specific information.

///|
/// Workspace edit helpers
pub extern "js" fn WorkspaceEdit::new() -> WorkspaceEdit =
  #| () => new (require("vscode").WorkspaceEdit)()

///|
/// The number of affected resources of textual or resource changes.
pub extern "js" fn WorkspaceEdit::size(self : WorkspaceEdit) -> Int =
  #| (edit) => edit.size

///|
/// Replace the given range with given text for the given resource.
///
/// @param uri A resource identifier.
/// @param range A range.
/// @param newText A string.
/// @param metadata Optional metadata for the entry.
pub fn WorkspaceEdit::replace(
  self : WorkspaceEdit,
  uri : Uri,
  range : Range,
  new_text : String,
  metadata? : WorkspaceEditEntryMetadata,
) -> Unit {
  let metadata_js = match metadata {
    None => JsValue::make(())
    Some(value) => workspace_edit_entry_metadata_to_js(value)
  }
  WorkspaceEdit::workspace_edit_replace_raw(
    self, uri, range, new_text, metadata_js,
  )
}

///|
/// Insert the given text at the given position.
///
/// @param uri A resource identifier.
/// @param position A position.
/// @param newText A string.
/// @param metadata Optional metadata for the entry.
pub fn WorkspaceEdit::insert(
  self : WorkspaceEdit,
  uri : Uri,
  position : Position,
  new_text : String,
  metadata? : WorkspaceEditEntryMetadata,
) -> Unit {
  let metadata_js = match metadata {
    None => JsValue::make(())
    Some(value) => workspace_edit_entry_metadata_to_js(value)
  }
  WorkspaceEdit::workspace_edit_insert_raw(
    self, uri, position, new_text, metadata_js,
  )
}

///|
/// Delete the text at the given range.
///
/// @param uri A resource identifier.
/// @param range A range.
/// @param metadata Optional metadata for the entry.
pub fn WorkspaceEdit::delete(
  self : WorkspaceEdit,
  uri : Uri,
  range : Range,
  metadata? : WorkspaceEditEntryMetadata,
) -> Unit {
  let metadata_js = match metadata {
    None => JsValue::make(())
    Some(value) => workspace_edit_entry_metadata_to_js(value)
  }
  WorkspaceEdit::workspace_edit_delete_raw(self, uri, range, metadata_js)
}

///|
/// Check if a text edit for a resource exists.
///
/// @param uri A resource identifier.
/// @returns `true` if the given resource will be touched by this edit.
pub extern "js" fn WorkspaceEdit::has(self : WorkspaceEdit, uri : Uri) -> Bool =
  #| (edit, uri) => edit.has(uri)

///|
/// Set (and replace) text edits or snippet edits for a resource.
///
/// @param uri A resource identifier.
/// @param edits An array of edits.
pub extern "js" fn WorkspaceEdit::set_text_edits(
  self : WorkspaceEdit,
  uri : Uri,
  edits : Array[TextEdit],
) -> Unit =
  #| (edit, uri, edits) => edit.set(uri, edits)

///|
/// Set (and replace) text edits or snippet edits for a resource.
///
/// @param uri A resource identifier.
/// @param edits An array of edits.
pub extern "js" fn WorkspaceEdit::set_snippet_edits(
  self : WorkspaceEdit,
  uri : Uri,
  edits : Array[SnippetTextEdit],
) -> Unit =
  #| (edit, uri, edits) => edit.set(uri, edits)

///|
/// Set (and replace) text edits or snippet edits for a resource.
///
/// @param uri A resource identifier.
/// @param edits An array of edits.
pub extern "js" fn WorkspaceEdit::set_notebook_edits(
  self : WorkspaceEdit,
  uri : Uri,
  edits : Array[NotebookEdit],
) -> Unit =
  #| (edit, uri, edits) => edit.set(uri, edits)

///|
/// Get the text edits for a resource.
///
/// @param uri A resource identifier.
/// @returns An array of text edits.
pub extern "js" fn WorkspaceEdit::get(
  self : WorkspaceEdit,
  uri : Uri,
) -> Array[TextEdit] =
  #| (edit, uri) => edit.get(uri)

///|
/// Create a regular file.
///
/// @param uri Uri of the new file.
/// @param options Defines if an existing file should be overwritten or be
/// ignored. When `overwrite` and `ignoreIfExists` are both set `overwrite` wins.
/// When both are unset and when the file already exists then the edit cannot
/// be applied successfully. The `content`-property allows to set the initial contents
/// the file is being created with.
/// @param metadata Optional metadata for the entry.
pub fn WorkspaceEdit::create_file(
  self : WorkspaceEdit,
  uri : Uri,
  options? : WorkspaceEditCreateFileOptions,
  metadata? : WorkspaceEditEntryMetadata,
) -> Unit {
  let options_js = match options {
    None => JsValue::make(())
    Some(value) => workspace_edit_create_file_options_to_js(value)
  }
  let metadata_js = match metadata {
    None => JsValue::make(())
    Some(value) => workspace_edit_entry_metadata_to_js(value)
  }
  WorkspaceEdit::workspace_edit_create_file_raw(
    self, uri, options_js, metadata_js,
  )
}

///|
/// Delete a file or folder.
///
/// @param uri The uri of the file that is to be deleted.
/// @param metadata Optional metadata for the entry.
pub fn WorkspaceEdit::delete_file(
  self : WorkspaceEdit,
  uri : Uri,
  options? : WorkspaceEditDeleteFileOptions,
  metadata? : WorkspaceEditEntryMetadata,
) -> Unit {
  let options_js = match options {
    None => JsValue::make(())
    Some(value) => workspace_edit_delete_file_options_to_js(value)
  }
  let metadata_js = match metadata {
    None => JsValue::make(())
    Some(value) => workspace_edit_entry_metadata_to_js(value)
  }
  WorkspaceEdit::workspace_edit_delete_file_raw(
    self, uri, options_js, metadata_js,
  )
}

///|
/// Rename a file or folder.
///
/// @param oldUri The existing file.
/// @param newUri The new location.
/// @param options Defines if existing files should be overwritten or be
/// ignored. When overwrite and ignoreIfExists are both set overwrite wins.
/// @param metadata Optional metadata for the entry.
pub fn WorkspaceEdit::rename_file(
  self : WorkspaceEdit,
  old_uri : Uri,
  new_uri : Uri,
  options? : WorkspaceEditRenameFileOptions,
  metadata? : WorkspaceEditEntryMetadata,
) -> Unit {
  let options_js = match options {
    None => JsValue::make(())
    Some(value) => workspace_edit_rename_file_options_to_js(value)
  }
  let metadata_js = match metadata {
    None => JsValue::make(())
    Some(value) => workspace_edit_entry_metadata_to_js(value)
  }
  WorkspaceEdit::workspace_edit_rename_file_raw(
    self, old_uri, new_uri, options_js, metadata_js,
  )
}

///|
/// Get all text edits grouped by resource.
///
/// @returns A shallow copy of `[Uri, TextEdit[]]`-tuples.
pub fn WorkspaceEdit::entries(
  self : WorkspaceEdit,
) -> Array[(Uri, Array[TextEdit])] {
  JsValue::make(WorkspaceEdit::workspace_edit_entries_raw(self)).cast()
}

///|
pub fn WorkspaceEditEntryMetadata::new(
  label : String,
  needs_confirmation : Bool,
  description? : String,
  icon_path? : IconPath,
) -> WorkspaceEditEntryMetadata {
  WorkspaceEditEntryMetadata::{
    label,
    needs_confirmation,
    description,
    icon_path,
  }
}

///|
fn workspace_edit_entry_metadata_to_js(
  value : WorkspaceEditEntryMetadata,
) -> JsValue {
  workspace_edit_entry_metadata_to_js_ffi(
    value.label,
    value.needs_confirmation,
    option_to_js(value.description),
    option_icon_path_to_js(value.icon_path),
  )
}

///|
fn workspace_edit_create_file_options_to_js(
  value : WorkspaceEditCreateFileOptions,
) -> JsValue {
  workspace_edit_create_file_options_to_js_ffi(
    option_to_js(value.overwrite),
    option_to_js(value.ignore_if_exists),
    option_workspace_edit_file_contents_to_js(value.contents),
  )
}

///|
fn workspace_edit_delete_file_options_to_js(
  value : WorkspaceEditDeleteFileOptions,
) -> JsValue {
  workspace_edit_delete_file_options_to_js_ffi(
    option_to_js(value.recursive),
    option_to_js(value.ignore_if_not_exists),
  )
}

///|
fn workspace_edit_rename_file_options_to_js(
  value : WorkspaceEditRenameFileOptions,
) -> JsValue {
  workspace_edit_rename_file_options_to_js_ffi(
    option_to_js(value.overwrite),
    option_to_js(value.ignore_if_exists),
  )
}

///|
extern "js" fn WorkspaceEdit::workspace_edit_replace_raw(
  self : WorkspaceEdit,
  uri : Uri,
  range : Range,
  new_text : String,
  metadata : JsValue,
) -> Unit =
  #| (edit, uri, range, newText, metadata) => edit.replace(uri, range, newText, metadata)

///|
extern "js" fn WorkspaceEdit::workspace_edit_insert_raw(
  self : WorkspaceEdit,
  uri : Uri,
  position : Position,
  new_text : String,
  metadata : JsValue,
) -> Unit =
  #| (edit, uri, position, newText, metadata) => edit.insert(uri, position, newText, metadata)

///|
extern "js" fn WorkspaceEdit::workspace_edit_delete_raw(
  self : WorkspaceEdit,
  uri : Uri,
  range : Range,
  metadata : JsValue,
) -> Unit =
  #| (edit, uri, range, metadata) => edit.delete(uri, range, metadata)

///|
extern "js" fn WorkspaceEdit::workspace_edit_create_file_raw(
  self : WorkspaceEdit,
  uri : Uri,
  options : JsValue,
  metadata : JsValue,
) -> Unit =
  #| (edit, uri, options, metadata) => edit.createFile(uri, options, metadata)

///|
extern "js" fn WorkspaceEdit::workspace_edit_delete_file_raw(
  self : WorkspaceEdit,
  uri : Uri,
  options : JsValue,
  metadata : JsValue,
) -> Unit =
  #| (edit, uri, options, metadata) => edit.deleteFile(uri, options, metadata)

///|
extern "js" fn WorkspaceEdit::workspace_edit_rename_file_raw(
  self : WorkspaceEdit,
  old_uri : Uri,
  new_uri : Uri,
  options : JsValue,
  metadata : JsValue,
) -> Unit =
  #| (edit, oldUri, newUri, options, metadata) =>
  #|   edit.renameFile(oldUri, newUri, options, metadata)

///|
extern "js" fn WorkspaceEdit::workspace_edit_entries_raw(
  self : WorkspaceEdit,
) -> JsValue =
  #| (edit) => edit.entries()

///|
extern "js" fn workspace_edit_entry_metadata_to_js_ffi(
  label : String,
  needs_confirmation : Bool,
  description : JsValue,
  icon_path : JsValue,
) -> JsValue =
  #| (label, needsConfirmation, description, iconPath) => ({
  #|   label,
  #|   needsConfirmation,
  #|   description: description === undefined || description === null ? undefined : description,
  #|   iconPath: iconPath === undefined || iconPath === null ? undefined : iconPath,
  #| })

///|
extern "js" fn workspace_edit_create_file_options_to_js_ffi(
  overwrite : JsValue,
  ignore_if_exists : JsValue,
  contents : JsValue,
) -> JsValue =
  #| (overwrite, ignoreIfExists, contents) => {
  #|   const options = {};
  #|   if (overwrite !== undefined && overwrite !== null) {
  #|     options.overwrite = overwrite;
  #|   }
  #|   if (ignoreIfExists !== undefined && ignoreIfExists !== null) {
  #|     options.ignoreIfExists = ignoreIfExists;
  #|   }
  #|   if (contents !== undefined && contents !== null) {
  #|     options.contents = contents;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn workspace_edit_delete_file_options_to_js_ffi(
  recursive : JsValue,
  ignore_if_not_exists : JsValue,
) -> JsValue =
  #| (recursive, ignoreIfNotExists) => {
  #|   const options = {};
  #|   if (recursive !== undefined && recursive !== null) {
  #|     options.recursive = recursive;
  #|   }
  #|   if (ignoreIfNotExists !== undefined && ignoreIfNotExists !== null) {
  #|     options.ignoreIfNotExists = ignoreIfNotExists;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn workspace_edit_rename_file_options_to_js_ffi(
  overwrite : JsValue,
  ignore_if_exists : JsValue,
) -> JsValue =
  #| (overwrite, ignoreIfExists) => {
  #|   const options = {};
  #|   if (overwrite !== undefined && overwrite !== null) {
  #|     options.overwrite = overwrite;
  #|   }
  #|   if (ignoreIfExists !== undefined && ignoreIfExists !== null) {
  #|     options.ignoreIfExists = ignoreIfExists;
  #|   }
  #|   return options;
  #| }

///|
/// Create a new TextEdit.
///
/// @param range A range.
/// @param newText A string.
pub extern "js" fn TextEdit::new(range : Range, new_text : String) -> TextEdit =
  #| (range, newText) => new (require("vscode").TextEdit)(range, newText)

///|
/// Utility to create a replace edit.
///
/// @param range A range.
/// @param newText A string.
/// @returns A new text edit object.
pub extern "js" fn TextEdit::replace(
  range : Range,
  new_text : String,
) -> TextEdit =
  #| (range, newText) => require("vscode").TextEdit.replace(range, newText)

///|
/// Utility to create an insert edit.
///
/// @param position A position, will become an empty range.
/// @param newText A string.
/// @returns A new text edit object.
pub extern "js" fn TextEdit::insert(
  position : Position,
  new_text : String,
) -> TextEdit =
  #| (position, newText) => require("vscode").TextEdit.insert(position, newText)

///|
/// Utility to create a delete edit.
///
/// @param range A range.
/// @returns A new text edit object.
pub extern "js" fn TextEdit::delete(range : Range) -> TextEdit =
  #| (range) => require("vscode").TextEdit.delete(range)

///|
/// Utility to create an eol-edit.
///
/// @param eol An eol-sequence
/// @returns A new text edit object.
pub extern "js" fn TextEdit::set_end_of_line(eol : EndOfLine) -> TextEdit =
  #| (eol) => require("vscode").TextEdit.setEndOfLine(eol)

///|
/// The range this edit applies to.
pub extern "js" fn TextEdit::range(self : TextEdit) -> Range =
  #| (value) => value.range

///|
/// The string this edit will insert.
pub extern "js" fn TextEdit::new_text(self : TextEdit) -> String =
  #| (value) => value.newText

///|
/// The eol-sequence used in the document.
///
/// *Note* that the eol-sequence will be applied to the
/// whole document.
pub fn TextEdit::new_eol(self : TextEdit) -> EndOfLine? {
  let raw = text_edit_new_eol_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Create a new snippet edit.
///
/// @param range A range.
/// @param snippet A snippet string.
pub fn SnippetTextEdit::new(
  range : Range,
  snippet : SnippetString,
) -> SnippetTextEdit {
  snippet_text_edit_ffi(range, snippet)
}

///|
/// Utility to create a replace snippet edit.
///
/// @param range A range.
/// @param snippet A snippet string.
/// @returns A new snippet edit object.
pub fn SnippetTextEdit::replace(
  range : Range,
  snippet : SnippetString,
) -> SnippetTextEdit {
  snippet_text_edit_replace_ffi(range, snippet)
}

///|
/// Utility to create an insert snippet edit.
///
/// @param position A position, will become an empty range.
/// @param snippet A snippet string.
/// @returns A new snippet edit object.
pub fn SnippetTextEdit::insert(
  position : Position,
  snippet : SnippetString,
) -> SnippetTextEdit {
  snippet_text_edit_insert_ffi(position, snippet)
}

///|
/// The range this edit applies to.
pub extern "js" fn SnippetTextEdit::range(self : SnippetTextEdit) -> Range =
  #| (value) => value.range

///|
/// The {@link SnippetString snippet} this edit will perform.
pub extern "js" fn SnippetTextEdit::snippet(
  self : SnippetTextEdit,
) -> SnippetString =
  #| (value) => value.snippet

///|
/// Whether the snippet edit should be applied with existing whitespace preserved.
pub fn SnippetTextEdit::keep_whitespace(self : SnippetTextEdit) -> Bool? {
  let raw = snippet_text_edit_keep_whitespace_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
extern "js" fn text_edit_new_eol_raw(edit : TextEdit) -> JsValue =
  #| (edit) => edit.newEol

///|
extern "js" fn snippet_text_edit_ffi(
  range : Range,
  snippet : SnippetString,
) -> SnippetTextEdit =
  #| (range, snippet) => new (require("vscode").SnippetTextEdit)(range, snippet)

///|
extern "js" fn snippet_text_edit_replace_ffi(
  range : Range,
  snippet : SnippetString,
) -> SnippetTextEdit =
  #| (range, snippet) => require("vscode").SnippetTextEdit.replace(range, snippet)

///|
extern "js" fn snippet_text_edit_insert_ffi(
  position : Position,
  snippet : SnippetString,
) -> SnippetTextEdit =
  #| (position, snippet) => require("vscode").SnippetTextEdit.insert(position, snippet)

///|
extern "js" fn snippet_text_edit_keep_whitespace_raw(
  edit : SnippetTextEdit,
) -> JsValue =
  #| (edit) => edit.keepWhitespace

///|
extern "js" fn file_stat_type_raw(stat : JsValue) -> FileType =
  #| (stat) => stat.type

///|
extern "js" fn file_stat_ctime_raw(stat : JsValue) -> Int =
  #| (stat) => stat.ctime

///|
extern "js" fn file_stat_mtime_raw(stat : JsValue) -> Int =
  #| (stat) => stat.mtime

///|
extern "js" fn file_stat_size_raw(stat : JsValue) -> Int =
  #| (stat) => stat.size

///|
extern "js" fn file_stat_permissions_raw(stat : JsValue) -> JsValue =
  #| (stat) => stat.permissions

///|
extern "js" fn file_system_error_new_ffi(
  message_or_uri : JsValue,
) -> FileSystemError =
  #| (messageOrUri) =>
  #|   new (require("vscode").FileSystemError)(
  #|     messageOrUri === undefined || messageOrUri === null ? undefined : messageOrUri
  #|   )

///|
extern "js" fn file_system_error_file_not_found_ffi(
  message_or_uri : JsValue,
) -> FileSystemError =
  #| (messageOrUri) =>
  #|   require("vscode").FileSystemError.FileNotFound(
  #|     messageOrUri === undefined || messageOrUri === null ? undefined : messageOrUri
  #|   )

///|
extern "js" fn file_system_error_file_exists_ffi(
  message_or_uri : JsValue,
) -> FileSystemError =
  #| (messageOrUri) =>
  #|   require("vscode").FileSystemError.FileExists(
  #|     messageOrUri === undefined || messageOrUri === null ? undefined : messageOrUri
  #|   )

///|
extern "js" fn file_system_error_file_not_a_directory_ffi(
  message_or_uri : JsValue,
) -> FileSystemError =
  #| (messageOrUri) =>
  #|   require("vscode").FileSystemError.FileNotADirectory(
  #|     messageOrUri === undefined || messageOrUri === null ? undefined : messageOrUri
  #|   )

///|
extern "js" fn file_system_error_file_is_a_directory_ffi(
  message_or_uri : JsValue,
) -> FileSystemError =
  #| (messageOrUri) =>
  #|   require("vscode").FileSystemError.FileIsADirectory(
  #|     messageOrUri === undefined || messageOrUri === null ? undefined : messageOrUri
  #|   )

///|
extern "js" fn file_system_error_no_permissions_ffi(
  message_or_uri : JsValue,
) -> FileSystemError =
  #| (messageOrUri) =>
  #|   require("vscode").FileSystemError.NoPermissions(
  #|     messageOrUri === undefined || messageOrUri === null ? undefined : messageOrUri
  #|   )

///|
extern "js" fn file_system_error_unavailable_ffi(
  message_or_uri : JsValue,
) -> FileSystemError =
  #| (messageOrUri) =>
  #|   require("vscode").FileSystemError.Unavailable(
  #|     messageOrUri === undefined || messageOrUri === null ? undefined : messageOrUri
  #|   )
