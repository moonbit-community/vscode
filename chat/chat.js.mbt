///|
/// VS Code chat namespace bindings for the JS backend.
using @vscode {
  type CancellationToken,
  type DocumentSelector,
  type Command,
  type Event,
  type IconPath,
  type Any,
  type Location,
  type MarkdownString,
  type Uri,
}

///|
using @lm {
  type ChatLanguageModelToolReference,
  type ChatParticipantToolToken,
  type LanguageModelChat,
}

///|
/// A chat request handler is a callback that will be invoked when a request is made to a chat participant.
pub type ChatRequestHandler

///|
/// A chat participant can be invoked by the user in a chat session, using the `@` prefix. When it is invoked, it handles the chat request and is solely
/// responsible for providing a response to the user. A ChatParticipant is created using {@link chat.createChatParticipant}.
pub(all) struct ChatParticipant {
  id : String
  mut icon_path : IconPath?
  mut request_handler : ChatRequestHandler
  mut followup_provider : ChatFollowupProvider?
  on_did_receive_feedback : Event[ChatResultFeedback]
}

///|
pub type ChatTurn

///|
/// Represents a user request in chat history.
pub type ChatRequestTurn

///|
pub fn ChatRequestTurn::new(
  prompt : String,
  participant : String,
  references : Array[ChatPromptReference],
  tool_references : Array[ChatLanguageModelToolReference],
  command? : String,
) -> ChatRequestTurn {
  chat_request_turn_ffi(
    prompt,
    participant,
    references,
    tool_references,
    option_to_js(command),
  )
}

///|
/// Represents a chat participant's response in chat history.
pub type ChatResponseTurn

///|
pub fn ChatResponseTurn::new(
  response : Array[ChatResponsePart],
  result : ChatResult,
  participant : String,
  command? : String,
) -> ChatResponseTurn {
  chat_response_turn_ffi(response, result, participant, option_to_js(command))
}

///|
/// A request to a chat participant.
pub struct ChatRequest {
  prompt : String
  command : String?
  references : Array[ChatPromptReference]
  tool_references : Array[ChatLanguageModelToolReference]
  tool_invocation_token : ChatParticipantToolToken
  model : LanguageModelChat
}

///|
/// Extra context passed to a participant.
pub struct ChatContext {
  history : Array[ChatTurn]
}

///|
/// The ChatResponseStream is how a participant is able to return content to the chat view. It provides several methods for streaming different types of content
/// which will be rendered in an appropriate way in the chat view. A participant can use the helper method for the type of content it wants to return, or it
/// can instantiate a {@link ChatResponsePart} and use the generic {@link ChatResponseStream.push} method to return it.
pub type ChatResponseStream

///|
/// Represents an error result from a chat request.
pub(all) struct ChatErrorDetails {
  mut message : String
  mut response_is_filtered : Bool?
}

///|
/// The result of a chat request.
pub(all) struct ChatResult {
  mut error_details : ChatErrorDetails?
  metadata : Any?
}

///|
/// Represents user feedback for a result.
pub struct ChatResultFeedback {
  result : ChatResult
  kind : ChatResultFeedbackKind
}

///|
/// A followup question suggested by the participant.
pub(all) struct ChatFollowup {
  mut prompt : String
  mut label : String?
  mut participant : String?
  mut command : String?
}

///|
/// Will be invoked once after each request to get suggested followup questions to show the user. The user can click the followup to send it to the chat.
pub type ChatFollowupProvider

///|
/// A reference to a value that the user added to their chat request.
pub struct ChatPromptReference {
  id : String
  range : (Int, Int)?
  model_description : String?
  value : ChatPromptReferenceValue
}

///|
pub type ChatPromptReferenceValue

///|
pub type ChatMarkdownValue

///|
pub type ChatAnchorValue

///|
/// Represents a file tree structure in a chat response.
pub(all) struct ChatResponseFileTree {
  mut name : String
  mut children : Array[ChatResponseFileTree]?
}

///|
/// Represents the different chat response types.
pub type ChatResponsePart

///|
/// Represents a part of a chat response that is formatted as Markdown.
pub type ChatResponseMarkdownPart

///|
/// Represents a part of a chat response that is a file tree.
pub type ChatResponseFileTreePart

///|
/// Represents a part of a chat response that is an anchor, that is rendered as a link to a target.
pub type ChatResponseAnchorPart

///|
/// Represents a part of a chat response that is a progress message.
pub type ChatResponseProgressPart

///|
/// Represents a part of a chat response that is a reference, rendered separately from the content.
pub type ChatResponseReferencePart

///|
/// Represents a part of a chat response that is a button that executes a command.
pub type ChatResponseCommandButtonPart

///|
pub(all) enum ChatResultFeedbackKind {
  Unhelpful = 0
  Helpful = 1
} derive(Eq)

///|
fn[T] option_to_js(value : T?) -> @v.JsValue {
  @v.option_to_js(value)
}

///|
fn option_icon_path_to_js(value : IconPath?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => icon_path_to_js(value)
  }
}

///|
fn icon_path_to_js(value : IconPath) -> @v.JsValue {
  match value {
    UriValue(value) => @v.JsValue::make(value)
    LightDarkValue(value) =>
      chat_icon_path_light_dark_to_js_ffi(value.light, value.dark)
    ThemeIconValue(value) => @v.JsValue::make(value)
  }
}

///|
fn document_selector_to_js(selector : DocumentSelector) -> @v.JsValue {
  match selector {
    Filter(value) =>
      chat_document_filter_to_js_ffi(
        option_to_js(value.language),
        option_to_js(value.notebook_type),
        option_to_js(value.scheme),
        option_glob_pattern_to_js(value.pattern),
      )
    Language(value) => @v.JsValue::make(value)
    Entries(values) => {
      let encoded : Array[@v.JsValue] = []
      for value in values {
        encoded.push(document_selector_entry_to_js(value))
      }
      @v.JsValue::make(encoded)
    }
  }
}

///|
fn document_selector_entry_to_js(
  value : @vscode.DocumentSelectorEntry,
) -> @v.JsValue {
  match value {
    Filter(value) =>
      chat_document_filter_to_js_ffi(
        option_to_js(value.language),
        option_to_js(value.notebook_type),
        option_to_js(value.scheme),
        option_glob_pattern_to_js(value.pattern),
      )
    Language(value) => @v.JsValue::make(value)
  }
}

///|
fn option_glob_pattern_to_js(value : @vscode.GlobPattern?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) =>
      match value {
        Text(value) => @v.JsValue::make(value)
        Relative(value) => @v.JsValue::make(value)
      }
  }
}

///|
extern "js" fn chat_icon_path_light_dark_to_js_ffi(
  light : Uri,
  dark : Uri,
) -> @v.JsValue =
  #| (light, dark) => ({ light, dark })

///|
extern "js" fn chat_document_filter_to_js_ffi(
  language : @v.JsValue,
  notebook_type : @v.JsValue,
  scheme : @v.JsValue,
  pattern : @v.JsValue,
) -> @v.JsValue =
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
pub fn ChatMarkdownValue::text(value : String) -> ChatMarkdownValue {
  @v.JsValue::make(value).cast()
}

///|
pub fn ChatMarkdownValue::markdown(value : MarkdownString) -> ChatMarkdownValue {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] ChatMarkdownValue::from_value(value : T) -> ChatMarkdownValue {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] ChatMarkdownValue::as_value(value : ChatMarkdownValue) -> T {
  @v.JsValue::make(value).cast()
}

///|
pub fn ChatAnchorValue::uri(value : Uri) -> ChatAnchorValue {
  @v.JsValue::make(value).cast()
}

///|
pub fn ChatAnchorValue::location(value : Location) -> ChatAnchorValue {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] ChatAnchorValue::from_value(value : T) -> ChatAnchorValue {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] ChatAnchorValue::as_value(value : ChatAnchorValue) -> T {
  @v.JsValue::make(value).cast()
}

///|
pub fn ChatPromptReferenceValue::text(
  value : String,
) -> ChatPromptReferenceValue {
  @v.JsValue::make(value).cast()
}

///|
pub fn ChatPromptReferenceValue::uri(value : Uri) -> ChatPromptReferenceValue {
  @v.JsValue::make(value).cast()
}

///|
pub fn ChatPromptReferenceValue::location(
  value : Location,
) -> ChatPromptReferenceValue {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] ChatPromptReferenceValue::from_value(
  value : T,
) -> ChatPromptReferenceValue {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] ChatPromptReferenceValue::as_value(
  value : ChatPromptReferenceValue,
) -> T {
  @v.JsValue::make(value).cast()
}

///|
pub fn available() -> Bool {
  chat_available_ffi()
}

///|
pub fn ChatRequestHandler::new(
  handler : async (
    ChatRequest,
    ChatContext,
    ChatResponseStream,
    CancellationToken,
  ) -> ChatResult?,
) -> ChatRequestHandler {
  chat_request_handler_ffi((request, context, response, token) => {
    @js_async.Promise::from_async(async fn() {
      option_to_js(handler(request, context, response, token))
    })
  })
}

///|
/// Create a new {@link ChatParticipant chat participant} instance.
///
/// @param id A unique identifier for the participant.
/// @param handler A request handler for the participant.
/// @returns A new chat participant
pub fn create_chat_participant_with_handler(
  id : String,
  handler : ChatRequestHandler,
) -> ChatParticipant {
  chat_create_chat_participant_ffi(id, handler)
}

///|
/// Create a new {@link ChatParticipant chat participant} instance.
///
/// @param id A unique identifier for the participant.
/// @param handler A request handler for the participant.
/// @returns A new chat participant
pub fn create_chat_participant(
  id : String,
  handler : async (
    ChatRequest,
    ChatContext,
    ChatResponseStream,
    CancellationToken,
  ) -> ChatResult?,
) -> ChatParticipant {
  create_chat_participant_with_handler(id, ChatRequestHandler::new(handler))
}

///|
/// Create a new {@link ChatParticipant chat participant} instance.
///
/// @param id A unique identifier for the participant.
/// @param handler A request handler for the participant.
/// @returns A new chat participant
pub fn try_create_chat_participant_with_handler(
  id : String,
  handler : ChatRequestHandler,
) -> ChatParticipant? {
  let raw = chat_try_create_chat_participant_ffi(id, handler)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Create a new {@link ChatParticipant chat participant} instance.
///
/// @param id A unique identifier for the participant.
/// @param handler A request handler for the participant.
/// @returns A new chat participant
pub fn try_create_chat_participant(
  id : String,
  handler : async (
    ChatRequest,
    ChatContext,
    ChatResponseStream,
    CancellationToken,
  ) -> ChatResult?,
) -> ChatParticipant? {
  try_create_chat_participant_with_handler(id, ChatRequestHandler::new(handler))
}

///|
pub fn register_chat_context_provider(
  selector : DocumentSelector,
  provider_id : String,
  provide_chat_context_for_resource : (Uri, CancellationToken) -> Any?,
  resolve_chat_context? : (Any, CancellationToken) -> Any?,
) -> @vscode.Disposable {
  let resolve_callback : ((Any, CancellationToken) -> @v.JsValue)? = match
    resolve_chat_context {
    None => None
    Some(resolve_fn) =>
      Some((context, token) => option_to_js(resolve_fn(context, token)))
  }

  chat_register_chat_context_provider_ffi(
    document_selector_to_js(selector),
    provider_id,
    (resource, token) => {
      option_to_js(provide_chat_context_for_resource(resource, token))
    },
    option_to_js(resolve_callback),
  )
}

///|
/// A unique ID for this participant.

///|
/// An icon for the participant shown in UI.

///|
/// An icon for the participant shown in UI.

///|
/// An icon for the participant shown in UI.

///|
/// The handler for requests to this participant.

///|
/// The handler for requests to this participant.

///|
/// The handler for requests to this participant.
pub fn ChatParticipant::set_request_handler_async(
  self : ChatParticipant,
  handler : async (
    ChatRequest,
    ChatContext,
    ChatResponseStream,
    CancellationToken,
  ) -> ChatResult?,
) -> Unit {
  self.request_handler = ChatRequestHandler::new(handler)
}

///|
/// This provider will be called once after each request to retrieve suggested followup questions.

///|
/// This provider will be called once after each request to retrieve suggested followup questions.

///|
/// This provider will be called once after each request to retrieve suggested followup questions.

///|
/// An event that fires whenever feedback for a result is received, e.g. when a user up- or down-votes
/// a result.
///
/// The passed {@link ChatResultFeedback.result result} is guaranteed to have the same properties as the result that was
/// previously returned from this chat participant's handler.

///|
/// Dispose this participant and free resources.
extern "js" fn chat_participant_dispose_raw(
  participant : ChatParticipant,
) -> Unit =
  #| (participant) => participant.dispose()

///|
pub fn ChatParticipant::dispose(self : ChatParticipant) -> Unit {
  chat_participant_dispose_raw(self)
}

///|
pub impl @vscode.AsDisposable for ChatParticipant with as_disposable(self) {
  @v.JsValue::make(self).cast()
}

///|
/// All of the chat messages so far in the current chat session. Currently, only chat messages for the current participant are included.

///|
pub fn ChatTurn::as_request_turn(self : ChatTurn) -> ChatRequestTurn? {
  let raw = chat_turn_as_request_turn_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn ChatTurn::as_response_turn(self : ChatTurn) -> ChatResponseTurn? {
  let raw = chat_turn_as_response_turn_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The prompt as entered by the user.
///
/// Information about references used in this request is stored in {@link ChatRequestTurn.references}.
///
/// *Note* that the {@link ChatParticipant.name name} of the participant and the {@link ChatCommand.name command}
/// are not part of the prompt.
pub extern "js" fn ChatRequestTurn::prompt(self : ChatRequestTurn) -> String =
  #| (turn) => turn.prompt

///|
/// The id of the chat participant to which this request was directed.
pub extern "js" fn ChatRequestTurn::participant(
  self : ChatRequestTurn,
) -> String =
  #| (turn) => turn.participant

///|
/// The name of the {@link ChatCommand command} that was selected for this request.
pub fn ChatRequestTurn::command(self : ChatRequestTurn) -> String? {
  let raw = chat_request_turn_command_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The references that were used in this message.
pub extern "js" fn ChatRequestTurn::references(
  self : ChatRequestTurn,
) -> Array[ChatPromptReference] =
  #| (turn) => turn.references

///|
/// The list of tools were attached to this request.
pub extern "js" fn ChatRequestTurn::tool_references(
  self : ChatRequestTurn,
) -> Array[ChatLanguageModelToolReference] =
  #| (turn) => turn.toolReferences

///|
/// The content that was received from the chat participant. Only the stream parts that represent actual content (not metadata) are represented.
pub extern "js" fn ChatResponseTurn::response(
  self : ChatResponseTurn,
) -> Array[ChatResponsePart] =
  #| (turn) => turn.response

///|
/// The result that was received from the chat participant.
pub extern "js" fn ChatResponseTurn::result(
  self : ChatResponseTurn,
) -> ChatResult =
  #| (turn) => turn.result

///|
/// The id of the chat participant that this response came from.
pub extern "js" fn ChatResponseTurn::participant(
  self : ChatResponseTurn,
) -> String =
  #| (turn) => turn.participant

///|
/// The name of the command that this response came from.
pub fn ChatResponseTurn::command(self : ChatResponseTurn) -> String? {
  let raw = chat_response_turn_command_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn ChatErrorDetails::new(
  message : String,
  response_is_filtered? : Bool,
) -> ChatErrorDetails {
  chat_error_details_ffi(message, option_to_js(response_is_filtered))
}

///|
/// An error message that is shown to the user.

///|
/// An error message that is shown to the user.

///|
/// If set to true, the response will be partly blurred out.

///|
/// If set to true, the response will be partly blurred out.

///|
/// If set to true, the response will be partly blurred out.

///|
pub fn ChatResult::new(
  error_details? : ChatErrorDetails,
  metadata? : Any,
) -> ChatResult {
  chat_result_ffi(option_to_js(error_details), option_to_js(metadata))
}

///|
pub fn[T] ChatResult::from_value(value : T) -> ChatResult {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] ChatResult::as_value(value : ChatResult) -> T {
  @v.JsValue::make(value).cast()
}

///|
/// If the request resulted in an error, this property defines the error details.

///|
/// If the request resulted in an error, this property defines the error details.

///|
/// If the request resulted in an error, this property defines the error details.

///|
/// Arbitrary metadata for this result. Can be anything, but must be JSON-stringifyable.

///|
/// Arbitrary metadata for this result. Can be anything, but must be JSON-stringifyable.

///|
/// Arbitrary metadata for this result. Can be anything, but must be JSON-stringifyable.

///|
/// The ChatResult for which the user is providing feedback.
/// This object has the same properties as the result returned from the participant callback, including `metadata`, but is not the same instance.

///|
/// The kind of feedback that was received.

///|
pub fn ChatFollowup::new(
  prompt : String,
  label? : String,
  participant? : String,
  command? : String,
) -> ChatFollowup {
  chat_followup_ffi(
    prompt,
    option_to_js(label),
    option_to_js(participant),
    option_to_js(command),
  )
}

///|
/// The message to send to the chat.

///|
/// The message to send to the chat.

///|
/// A title to show the user. The prompt will be shown by default, when this is unspecified.

///|
/// A title to show the user. The prompt will be shown by default, when this is unspecified.

///|
/// A title to show the user. The prompt will be shown by default, when this is unspecified.

///|
/// By default, the followup goes to the same participant/command. But this property can be set to invoke a different participant by ID.
/// Followups can only invoke a participant that was contributed by the same extension.

///|
/// By default, the followup goes to the same participant/command. But this property can be set to invoke a different participant by ID.
/// Followups can only invoke a participant that was contributed by the same extension.

///|
/// By default, the followup goes to the same participant/command. But this property can be set to invoke a different participant by ID.
/// Followups can only invoke a participant that was contributed by the same extension.

///|
/// By default, the followup goes to the same participant/command. But this property can be set to invoke a different command.

///|
/// By default, the followup goes to the same participant/command. But this property can be set to invoke a different command.

///|
/// By default, the followup goes to the same participant/command. But this property can be set to invoke a different command.

///|
pub fn ChatFollowupProvider::new(
  provide_followups : async (ChatResult, ChatContext, CancellationToken) -> Array[
    ChatFollowup,
  ]?,
) -> ChatFollowupProvider {
  chat_followup_provider_ffi((result, context, token) => {
    @js_async.Promise::from_async(async fn() {
      option_to_js(provide_followups(result, context, token))
    })
  })
}

///|
/// A unique identifier for this kind of reference.

///|
/// The start and end index of the reference in the {@link ChatRequest.prompt prompt}. When undefined, the reference was not part of the prompt text.
///
/// *Note* that the indices take the leading `#`-character into account which means they can
/// used to modify the prompt as-is.

///|
/// A description of this value that could be used in an LLM prompt.

///|
/// The value of this reference. The `string | Uri | Location` types are used today, but this could expand in the future.

///|
/// The prompt as entered by the user.
///
/// Information about references used in this request is stored in {@link ChatRequest.references}.
///
/// *Note* that the {@link ChatParticipant.name name} of the participant and the {@link ChatCommand.name command}
/// are not part of the prompt.

///|
/// The name of the {@link ChatCommand command} that was selected for this request.

///|
/// The list of references and their values that are referenced in the prompt.
///
/// *Note* that the prompt contains references as authored and that it is up to the participant
/// to further modify the prompt, for instance by inlining reference values or creating links to
/// headings which contain the resolved values. References are sorted in reverse by their range
/// in the prompt. That means the last reference in the prompt is the first in this list. This simplifies
/// string-manipulation of the prompt.

///|
/// The list of tools that the user attached to their request.
///
/// When a tool reference is present, the chat participant should make a chat request using
/// {@link LanguageModelChatToolMode.Required} to force the language model to generate input for the tool. Then, the
/// participant can use {@link lm.invokeTool} to use the tool attach the result to its request for the user's prompt. The
/// tool may contribute useful extra context for the user's request.

///|
/// A token that can be passed to {@link lm.invokeTool} when invoking a tool inside the context of handling a chat request.
/// This associates the tool invocation to a chat session.

///|
/// This is the model that is currently selected in the UI. Extensions can use this or use {@link lm.selectChatModels} to
/// pick another model. Don't hold onto this past the lifetime of the request.

///|
pub fn ChatResponseFileTree::new(
  name : String,
  children? : Array[ChatResponseFileTree],
) -> ChatResponseFileTree {
  chat_response_file_tree_ffi(name, option_to_js(children))
}

///|
/// The name of the file or directory.

///|
/// The name of the file or directory.

///|
/// An array of child file trees, if the current file tree is a directory.

///|
/// An array of child file trees, if the current file tree is a directory.

///|
/// An array of child file trees, if the current file tree is a directory.

///|
/// Push a markdown part to this stream. Short-hand for
/// `push(new ChatResponseMarkdownPart(value))`.
///
/// @see {@link ChatResponseStream.push}
/// @param value A markdown string or a string that should be interpreted as markdown. The boolean form of {@link MarkdownString.isTrusted} is NOT supported.
pub extern "js" fn ChatResponseStream::markdown(
  self : ChatResponseStream,
  value : ChatMarkdownValue,
) -> Unit =
  #| (response, value) => response.markdown(value)

///|
/// Push an anchor part to this stream. Short-hand for
/// `push(new ChatResponseAnchorPart(value, title))`.
/// An anchor is an inline reference to some type of resource.
///
/// @param value A uri or location.
/// @param title An optional title that is rendered with value.
pub extern "js" fn ChatResponseStream::anchor(
  self : ChatResponseStream,
  value : ChatAnchorValue,
  title? : String,
) -> Unit =
  #| (response, value, title) =>
  #|   response.anchor(
  #|     value,
  #|     title === undefined || title === null ? undefined : title
  #|   )

///|
/// Push a command button part to this stream. Short-hand for
/// `push(new ChatResponseCommandButtonPart(value, title))`.
///
/// @param command A Command that will be executed when the button is clicked.
pub extern "js" fn ChatResponseStream::button(
  self : ChatResponseStream,
  command : Command,
) -> Unit =
  #| (response, command) => response.button(command)

///|
/// Push a filetree part to this stream. Short-hand for
/// `push(new ChatResponseFileTreePart(value))`.
///
/// @param value File tree data.
/// @param baseUri The base uri to which this file tree is relative.
pub extern "js" fn ChatResponseStream::filetree(
  self : ChatResponseStream,
  value : Array[ChatResponseFileTree],
  base_uri : Uri,
) -> Unit =
  #| (response, value, baseUri) => response.filetree(value, baseUri)

///|
/// Push a progress part to this stream. Short-hand for
/// `push(new ChatResponseProgressPart(value))`.
///
/// @param value A progress message
pub extern "js" fn ChatResponseStream::progress(
  self : ChatResponseStream,
  value : String,
) -> Unit =
  #| (response, value) => response.progress(value)

///|
/// Push a reference to this stream. Short-hand for
/// `push(new ChatResponseReferencePart(value))`.
///
/// *Note* that the reference is not rendered inline with the response.
///
/// @param value A uri or location
/// @param iconPath Icon for the reference shown in UI
pub fn ChatResponseStream::reference(
  self : ChatResponseStream,
  value : ChatAnchorValue,
  icon_path? : IconPath,
) -> Unit {
  chat_response_stream_reference_raw(
    self,
    value,
    option_icon_path_to_js(icon_path),
  )
}

///|
extern "js" fn chat_response_stream_reference_raw(
  response : ChatResponseStream,
  value : ChatAnchorValue,
  icon_path : @v.JsValue,
) -> Unit =
  #| (response, value, iconPath) =>
  #|   response.reference(
  #|     value,
  #|     iconPath === undefined || iconPath === null ? undefined : iconPath
  #|   )

///|
/// Pushes a part to this stream.
///
/// @param part A response part, rendered or metadata
pub extern "js" fn ChatResponseStream::push(
  self : ChatResponseStream,
  part : ChatResponsePart,
) -> Unit =
  #| (response, part) => response.push(part)

///|
pub fn ChatResponsePart::from_markdown_part(
  value : ChatResponseMarkdownPart,
) -> ChatResponsePart {
  @v.JsValue::make(value).cast()
}

///|
pub fn ChatResponsePart::from_file_tree_part(
  value : ChatResponseFileTreePart,
) -> ChatResponsePart {
  @v.JsValue::make(value).cast()
}

///|
pub fn ChatResponsePart::from_anchor_part(
  value : ChatResponseAnchorPart,
) -> ChatResponsePart {
  @v.JsValue::make(value).cast()
}

///|
pub fn ChatResponsePart::from_progress_part(
  value : ChatResponseProgressPart,
) -> ChatResponsePart {
  @v.JsValue::make(value).cast()
}

///|
pub fn ChatResponsePart::from_reference_part(
  value : ChatResponseReferencePart,
) -> ChatResponsePart {
  @v.JsValue::make(value).cast()
}

///|
pub fn ChatResponsePart::from_command_button_part(
  value : ChatResponseCommandButtonPart,
) -> ChatResponsePart {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] ChatResponsePart::from_value(value : T) -> ChatResponsePart {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] ChatResponsePart::as_value(value : ChatResponsePart) -> T {
  @v.JsValue::make(value).cast()
}

///|
pub fn ChatResponsePart::as_markdown_part(
  self : ChatResponsePart,
) -> ChatResponseMarkdownPart? {
  let raw = chat_response_part_as_markdown_part_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Create a new ChatResponseMarkdownPart.
///
/// @param value A markdown string or a string that should be interpreted as markdown. The boolean form of {@link MarkdownString.isTrusted} is NOT supported.
pub extern "js" fn ChatResponseMarkdownPart::new(
  value : ChatMarkdownValue,
) -> ChatResponseMarkdownPart =
  #| (value) => new (require("vscode").ChatResponseMarkdownPart)(value)

///|
/// A markdown string or a string that should be interpreted as markdown.

///|
/// Create a new ChatResponseFileTreePart.
/// @param value File tree data.
/// @param baseUri The base uri to which this file tree is relative.
pub extern "js" fn ChatResponseFileTreePart::new(
  value : Array[ChatResponseFileTree],
  base_uri : Uri,
) -> ChatResponseFileTreePart =
  #| (value, baseUri) => new (require("vscode").ChatResponseFileTreePart)(value, baseUri)

///|
/// File tree data.

///|
/// The base uri to which this file tree is relative

///|
/// Create a new ChatResponseAnchorPart.
/// @param value A uri or location.
/// @param title An optional title that is rendered with value.
pub extern "js" fn ChatResponseAnchorPart::new(
  value : ChatAnchorValue,
  title? : String,
) -> ChatResponseAnchorPart =
  #| (value, title) =>
  #|   new (require("vscode").ChatResponseAnchorPart)(
  #|     value,
  #|     title === undefined || title === null ? undefined : title
  #|   )

///|
/// The target of this anchor.

///|
/// An optional title that is rendered with value.

///|
/// Create a new ChatResponseProgressPart.
/// @param value A progress message
pub extern "js" fn ChatResponseProgressPart::new(
  value : String,
) -> ChatResponseProgressPart =
  #| (value) => new (require("vscode").ChatResponseProgressPart)(value)

///|
/// The progress message

///|
/// Create a new ChatResponseReferencePart.
/// @param value A uri or location
/// @param iconPath Icon for the reference shown in UI
pub fn ChatResponseReferencePart::new(
  value : ChatAnchorValue,
  icon_path? : IconPath,
) -> ChatResponseReferencePart {
  chat_response_reference_part_new_raw(value, option_icon_path_to_js(icon_path))
}

///|
extern "js" fn chat_response_reference_part_new_raw(
  value : ChatAnchorValue,
  icon_path : @v.JsValue,
) -> ChatResponseReferencePart =
  #| (value, iconPath) =>
  #|   new (require("vscode").ChatResponseReferencePart)(
  #|     value,
  #|     iconPath === undefined || iconPath === null ? undefined : iconPath
  #|   )

///|
/// The reference target.

///|
/// The icon for the reference.
pub extern "js" fn ChatResponseReferencePart::value(
  self : ChatResponseReferencePart,
) -> ChatAnchorValue =
  #| (value) => value.value

///|
pub extern "js" fn ChatResponseReferencePart::set_value(
  self : ChatResponseReferencePart,
  value : ChatAnchorValue,
) -> Unit =
  #| (part, value) => { part.value = value; }

///|
pub fn ChatResponseReferencePart::icon_path(
  self : ChatResponseReferencePart,
) -> IconPath? {
  let raw = chat_response_reference_part_icon_path_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub fn ChatResponseReferencePart::set_icon_path(
  self : ChatResponseReferencePart,
  value : IconPath?,
) -> Unit {
  chat_response_reference_part_set_icon_path_raw(
    self,
    option_icon_path_to_js(value),
  )
}

///|
pub fn ChatResponseReferencePart::clear_icon_path(
  self : ChatResponseReferencePart,
) -> Unit {
  chat_response_reference_part_set_icon_path_raw(self, @v.JsValue::make(()))
}

///|
/// Create a new ChatResponseCommandButtonPart.
/// @param value A Command that will be executed when the button is clicked.
pub extern "js" fn ChatResponseCommandButtonPart::new(
  value : Command,
) -> ChatResponseCommandButtonPart =
  #| (value) => new (require("vscode").ChatResponseCommandButtonPart)(value)

///|
/// The command that will be executed when the button is clicked.
pub extern "js" fn ChatResponseCommandButtonPart::value(
  self : ChatResponseCommandButtonPart,
) -> Command =
  #| (value) => value.value

///|
pub extern "js" fn ChatResponseCommandButtonPart::set_value(
  self : ChatResponseCommandButtonPart,
  value : Command,
) -> Unit =
  #| (part, value) => { part.value = value; }

///|
pub extern "js" fn ChatResponseMarkdownPart::value(
  self : ChatResponseMarkdownPart,
) -> MarkdownString =
  #| (value) => value.value

///|
pub extern "js" fn ChatResponseMarkdownPart::set_value(
  self : ChatResponseMarkdownPart,
  value : MarkdownString,
) -> Unit =
  #| (part, value) => { part.value = value; }

///|
pub extern "js" fn ChatResponseFileTreePart::value(
  self : ChatResponseFileTreePart,
) -> Array[ChatResponseFileTree] =
  #| (value) => value.value

///|
pub extern "js" fn ChatResponseFileTreePart::set_value(
  self : ChatResponseFileTreePart,
  value : Array[ChatResponseFileTree],
) -> Unit =
  #| (part, value) => { part.value = value; }

///|
pub extern "js" fn ChatResponseFileTreePart::base_uri(
  self : ChatResponseFileTreePart,
) -> Uri =
  #| (value) => value.baseUri

///|
pub extern "js" fn ChatResponseFileTreePart::set_base_uri(
  self : ChatResponseFileTreePart,
  value : Uri,
) -> Unit =
  #| (part, value) => { part.baseUri = value; }

///|
pub extern "js" fn ChatResponseAnchorPart::value(
  self : ChatResponseAnchorPart,
) -> ChatAnchorValue =
  #| (value) => value.value

///|
pub extern "js" fn ChatResponseAnchorPart::set_value(
  self : ChatResponseAnchorPart,
  value : ChatAnchorValue,
) -> Unit =
  #| (part, value) => { part.value = value; }

///|
pub fn ChatResponseAnchorPart::title(self : ChatResponseAnchorPart) -> String? {
  let raw = chat_response_anchor_part_title_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
pub extern "js" fn ChatResponseAnchorPart::set_title(
  self : ChatResponseAnchorPart,
  value : String,
) -> Unit =
  #| (part, value) => { part.title = value; }

///|
pub extern "js" fn ChatResponseAnchorPart::clear_title(
  self : ChatResponseAnchorPart,
) -> Unit =
  #| (part) => { part.title = undefined; }

///|
pub extern "js" fn ChatResponseProgressPart::value(
  self : ChatResponseProgressPart,
) -> String =
  #| (value) => value.value

///|
pub extern "js" fn ChatResponseProgressPart::set_value(
  self : ChatResponseProgressPart,
  value : String,
) -> Unit =
  #| (part, value) => { part.value = value; }

///|
extern "js" fn chat_turn_as_request_turn_raw(turn : ChatTurn) -> @v.JsValue =
  #| (turn) =>
  #|   turn && typeof turn === "object" && typeof turn.prompt === "string"
  #|     ? turn
  #|     : undefined

///|
extern "js" fn chat_turn_as_response_turn_raw(turn : ChatTurn) -> @v.JsValue =
  #| (turn) =>
  #|   turn && typeof turn === "object" && Array.isArray(turn.response)
  #|     ? turn
  #|     : undefined

///|
extern "js" fn chat_request_turn_command_raw(
  turn : ChatRequestTurn,
) -> @v.JsValue =
  #| (turn) => turn.command

///|
extern "js" fn chat_response_turn_command_raw(
  turn : ChatResponseTurn,
) -> @v.JsValue =
  #| (turn) => turn.command

///|
extern "js" fn chat_response_anchor_part_title_raw(
  value : ChatResponseAnchorPart,
) -> @v.JsValue =
  #| (value) => value.title

///|
extern "js" fn chat_response_reference_part_icon_path_raw(
  value : ChatResponseReferencePart,
) -> @v.JsValue =
  #| (value) => value.iconPath

///|
extern "js" fn chat_response_reference_part_set_icon_path_raw(
  value : ChatResponseReferencePart,
  icon_path : @v.JsValue,
) -> Unit =
  #| (value, iconPath) => {
  #|   value.iconPath =
  #|     iconPath === undefined || iconPath === null ? undefined : iconPath;
  #| }
