///|
/// VS Code language model namespace bindings for the JS backend.
using @vscode {
  type CancellationToken,
  type Event,
  type ExtensionContext,
  type Any,
  type MarkdownString,
  type Progress,
  type Uri,
}

///|
pub type AsyncIterable[T]

///|
pub type AsyncIterator[T]

///|
pub type AsyncIteratorResult[T]

///|
/// Represents a language model for making chat requests.
///
/// @see {@link lm.selectChatModels}
pub struct LanguageModelChat {
  name : String
  id : String
  vendor : String
  family : String
  version : String
  max_input_tokens : Int
}

///|
/// Describes how to select language models for chat requests.
///
/// @see {@link lm.selectChatModels}
pub(all) struct LanguageModelChatSelector {
  mut vendor : String?
  mut family : String?
  mut version : String?
  mut id : String?
}

///|
/// Options for making a chat request using a language model.
///
/// @see {@link LanguageModelChat.sendRequest}
pub(all) struct LanguageModelChatRequestOptions {
  mut justification : String?
  mut model_options : Any?
  mut tools : Array[LanguageModelChatTool]?
  mut tool_mode : LanguageModelChatToolMode?
}

///|
/// A tool that is available to the language model via {@link LanguageModelChatRequestOptions}. A language model uses all the
/// properties of this interface to decide which tool to call, and how to call it.
pub(all) struct LanguageModelChatTool {
  mut name : String
  mut description : String
  mut input_schema : Any?
}

///|
/// Represents a language model response.
///
/// @see {@link ChatRequest}
pub(all) struct LanguageModelChatResponse {
  mut stream : AsyncIterable[LanguageModelResponsePart]
  mut text : AsyncIterable[String]
}

///|
/// An error type for language model specific errors.
///
/// Consumers of language models should check the code property to determine specific
/// failure causes, like `if(someError.code === vscode.LanguageModelError.NotFound.name) {...}`
/// for the case of referring to an unknown language model. For unspecified errors the `cause`-property
/// will contain the actual error.
pub type LanguageModelError

///|
/// Represents a message in a chat. Can assume different roles, like user or assistant.
pub type LanguageModelChatMessage

///|
/// A language model response part indicating a tool call, returned from a {@link LanguageModelChatResponse}, and also can be
/// included as a content part on a {@link LanguageModelChatMessage}, to represent a previous tool call in a chat request.
pub type LanguageModelToolCallPart

///|
/// The result of a tool call. This is the counterpart of a {@link LanguageModelToolCallPart tool call} and
/// it can only be included in the content of a User message
pub type LanguageModelToolResultPart

///|
/// A language model response part containing a piece of text, returned from a {@link LanguageModelChatResponse}.
pub type LanguageModelTextPart

///|
/// A language model response part containing a PromptElementJSON from `@vscode/prompt-tsx`.
/// @see {@link LanguageModelToolResult}
pub type LanguageModelPromptTsxPart

///|
/// A result returned from a tool invocation. If using `@vscode/prompt-tsx`, this result may be rendered using a `ToolResult`.
pub type LanguageModelToolResult

///|
/// A language model response part containing arbitrary data. Can be used in {@link LanguageModelChatResponse responses},
/// {@link LanguageModelChatMessage chat messages}, {@link LanguageModelToolResult tool results}, and other language model interactions.
pub type LanguageModelDataPart

///|
/// The various message types which can be sent via {@linkcode LanguageModelChat.sendRequest } and processed by a {@linkcode LanguageModelChatProvider}
pub type LanguageModelInputPart

///|
/// The various message types which a {@linkcode LanguageModelChatProvider} can emit in the chat response stream
pub type LanguageModelResponsePart

///|
pub type LanguageModelToolResultContentPart

///|
/// A tool that can be invoked by a call to a {@link LanguageModelChat}.
pub type LanguageModelTool

///|
/// Information about a registered tool available in {@link lm.tools}.
pub struct LanguageModelToolInformation {
  name : String
  description : String
  input_schema : Any?
  tags : Array[String]
}

///|
/// Options provided for tool invocation.
pub(all) struct LanguageModelToolInvocationOptions {
  mut tool_invocation_token : ChatParticipantToolToken?
  mut input : Any
  mut tokenization_options : LanguageModelToolTokenizationOptions?
}

///|
/// Options related to tokenization for a tool invocation.
pub(all) struct LanguageModelToolTokenizationOptions {
  mut token_budget : Int
}

///|
/// Options for {@link LanguageModelTool.prepareInvocation}.
pub(all) struct LanguageModelToolInvocationPrepareOptions {
  mut input : Any
}

///|
/// When this is returned in {@link PreparedToolInvocation}, the user will be asked to confirm before running the tool. These
/// messages will be shown with buttons that say "Continue" and "Cancel".
pub(all) struct LanguageModelToolConfirmationMessages {
  mut title : String
  mut message : LanguageModelConfirmationMessageValue
}

///|
/// The result of a call to {@link LanguageModelTool.prepareInvocation}.
pub(all) struct PreparedToolInvocation {
  mut invocation_message : LanguageModelConfirmationMessageValue?
  mut confirmation_messages : LanguageModelToolConfirmationMessages?
}

///|
pub type LanguageModelConfirmationMessageValue

///|
pub type LanguageModelTokenCountInput

///|
/// A token that can be passed to {@link lm.invokeTool} when invoking a tool inside the context of handling a chat request.
pub type ChatParticipantToolToken

///|
/// A reference to a tool that the user manually attached to their request, either using the `#`-syntax inline, or as an
/// attachment via the paperclip button.
pub struct ChatLanguageModelToolReference {
  name : String
  range : (Int, Int)?
}

///|
pub fn ChatLanguageModelToolReference::new(
  name : String,
  range? : (Int, Int),
) -> ChatLanguageModelToolReference {
  { name, range }
}

///|
pub type LanguageModelToolCalling

///|
/// Represents extension specific information about the access to language models.
pub struct LanguageModelAccessInformation {
  on_did_change : Event[Unit]
}

///|
/// McpStdioServerDefinition represents an MCP server available by running
/// a local process and operating on its stdin and stdout streams. The process
/// will be spawned as a child process of the extension host and by default
/// will not run in a shell environment.
pub type McpStdioServerDefinition

///|
/// McpHttpServerDefinition represents an MCP server available using the
/// Streamable HTTP transport.
pub type McpHttpServerDefinition

///|
/// Definitions that describe different types of Model Context Protocol servers,
/// which can be returned from the {@link McpServerDefinitionProvider}.
pub type McpServerDefinition

///|
/// A type that can provide Model Context Protocol server definitions. This
/// should be registered using {@link lm.registerMcpServerDefinitionProvider}
/// during extension activation.
pub struct McpServerDefinitionProvider {
  on_did_change_mcp_server_definitions : Event[Unit]?
}

///|
/// Various features that the {@link LanguageModelChatInformation} supports such as tool calling or image input.
pub struct LanguageModelChatCapabilities {
  image_input : Bool?
  tool_calling : LanguageModelToolCalling?
}

///|
/// Represents a language model provided by a {@linkcode LanguageModelChatProvider}.
pub struct LanguageModelChatInformation {
  id : String
  name : String
  family : String
  tooltip : String?
  detail : String?
  version : String
  max_input_tokens : Int
  max_output_tokens : Int
  capabilities : LanguageModelChatCapabilities
}

///|
/// The provider version of {@linkcode LanguageModelChatMessage}.
pub struct LanguageModelChatRequestMessage {
  role : LanguageModelChatMessageRole
  content : Array[LanguageModelInputPart]
  name : String?
}

///|
/// The list of options passed into {@linkcode LanguageModelChatProvider.provideLanguageModelChatInformation}
pub struct PrepareLanguageModelChatModelOptions {
  silent : Bool?
}

///|
/// The provider version of {@linkcode LanguageModelChatRequestOptions}
pub struct ProvideLanguageModelChatResponseOptions {
  model_options : Any?
  tools : Array[LanguageModelChatTool]?
  tool_mode : LanguageModelChatToolMode
}

///|
/// A LanguageModelChatProvider implements access to language models, which users can then use through the chat view, or through extension API by acquiring a LanguageModelChat.
/// An example of this would be an OpenAI provider that provides models like gpt-5, o3, etc.
pub struct LanguageModelChatProvider {
  on_did_change_language_model_chat_information : Event[Unit]?
}

///|
pub(all) enum LanguageModelChatMessageRole {
  User = 1
  Assistant = 2
} derive(Eq)

///|
pub(all) enum LanguageModelChatToolMode {
  Auto = 1
  Required = 2
} derive(Eq)

///|
fn[T] option_to_js(value : T?) -> @v.JsValue {
  @v.option_to_js(value)
}

///|
fn[T] js_to_option(raw : @v.JsValue) -> T? {
  @v.js_to_option(raw)
}

///|
fn bytes_to_uint8_array(value : Bytes) -> Uint8Array {
  @v.JsValue::make(value).cast()
}

///|
pub fn available() -> Bool {
  lm_available_ffi()
}

///|
/// An event that is fired when the set of available chat models changes.
pub fn on_did_change_chat_models() -> Event[Unit] {
  lm_on_did_change_chat_models_ffi()
}

///|
/// Select chat models by a {@link LanguageModelChatSelector selector}. This can yield multiple or no chat models and
/// extensions must handle these cases, esp. when no chat model exists, gracefully.
///
/// ```ts
/// const models = await vscode.lm.selectChatModels({ family: 'gpt-3.5-turbo' });
/// if (models.length > 0) {
/// 	const [first] = models;
/// 	const response = await first.sendRequest(...)
/// 	// ...
/// } else {
/// 	// NO chat models available
/// }
/// ```
///
/// A selector can be written to broadly match all models of a given vendor or family, or it can narrowly select one model by ID.
/// Keep in mind that the available set of models will change over time, but also that prompts may perform differently in
/// different models.
///
/// *Note* that extensions can hold on to the results returned by this function and use them later. However, when the
/// {@link onDidChangeChatModels}-event is fired the list of chat models might have changed and extensions should re-query.
///
/// @param selector A chat model selector. When omitted all chat models are returned.
/// @returns An array of chat models, can be empty!
pub async fn select_chat_models(
  selector? : LanguageModelChatSelector,
) -> Array[LanguageModelChat] {
  @js_async.Promise::wait(lm_select_chat_models_ffi(option_to_js(selector)))
}

///|
/// Select chat models by a {@link LanguageModelChatSelector selector}. This can yield multiple or no chat models and
/// extensions must handle these cases, esp. when no chat model exists, gracefully.
///
/// ```ts
/// const models = await vscode.lm.selectChatModels({ family: 'gpt-3.5-turbo' });
/// if (models.length > 0) {
/// 	const [first] = models;
/// 	const response = await first.sendRequest(...)
/// 	// ...
/// } else {
/// 	// NO chat models available
/// }
/// ```
///
/// A selector can be written to broadly match all models of a given vendor or family, or it can narrowly select one model by ID.
/// Keep in mind that the available set of models will change over time, but also that prompts may perform differently in
/// different models.
///
/// *Note* that extensions can hold on to the results returned by this function and use them later. However, when the
/// {@link onDidChangeChatModels}-event is fired the list of chat models might have changed and extensions should re-query.
///
/// @param selector A chat model selector. When omitted all chat models are returned.
/// @returns An array of chat models, can be empty!
pub async fn try_select_chat_models(
  selector? : LanguageModelChatSelector,
) -> Array[LanguageModelChat]? {
  let raw = @js_async.Promise::wait(
    lm_try_select_chat_models_ffi(option_to_js(selector)),
  )
  js_to_option(raw)
}

///|
/// Register a LanguageModelTool. The tool must also be registered in the package.json `languageModelTools` contribution
/// point. A registered tool is available in the {@link lm.tools} list for any extension to see. But in order for it to
/// be seen by a language model, it must be passed in the list of available tools in {@link LanguageModelChatRequestOptions.tools}.
/// @returns A {@link Disposable} that unregisters the tool when disposed.
pub fn register_tool(
  name : String,
  tool : LanguageModelTool,
) -> @vscode.Disposable {
  lm_register_tool_ffi(name, tool)
}

///|
/// A list of all available tools that were registered by all extensions using {@link lm.registerTool}. They can be called
/// with {@link lm.invokeTool} with input that match their declared `inputSchema`.
pub fn tools() -> Array[LanguageModelToolInformation] {
  lm_tools_ffi()
}

///|
/// Invoke a tool listed in {@link lm.tools} by name with the given input. The input will be validated against
/// the schema declared by the tool
///
/// A tool can be invoked by a chat participant, in the context of handling a chat request, or globally by any extension in
/// any custom flow.
///
/// In the former case, the caller shall pass the
/// {@link LanguageModelToolInvocationOptions.toolInvocationToken toolInvocationToken}, which comes from a
/// {@link ChatRequest.toolInvocationToken chat request}. This makes sure the chat UI shows the tool invocation for the
/// correct conversation.
///
/// A tool {@link LanguageModelToolResult result} is an array of {@link LanguageModelTextPart text-} and
/// {@link LanguageModelPromptTsxPart prompt-tsx}-parts. If the tool caller is using `@vscode/prompt-tsx`, it can
/// incorporate the response parts into its prompt using a `ToolResult`. If not, the parts can be passed along to the
/// {@link LanguageModelChat} via a user message with a {@link LanguageModelToolResultPart}.
///
/// If a chat participant wants to preserve tool results for requests across multiple turns, it can store tool results in
/// the {@link ChatResult.metadata} returned from the handler and retrieve them on the next turn from
/// {@link ChatResponseTurn.result}.
///
/// @param name The name of the tool to call.
/// @param options The options to use when invoking the tool.
/// @param token A cancellation token. See {@link CancellationTokenSource} for how to create one.
/// @returns The result of the tool invocation.
pub async fn invoke_tool(
  name : String,
  options : LanguageModelToolInvocationOptions,
  token? : CancellationToken,
) -> LanguageModelToolResult {
  @js_async.Promise::wait(
    lm_invoke_tool_ffi(name, options, option_to_js(token)),
  )
}

///|
/// Registers a provider that publishes Model Context Protocol servers for the editor to
/// consume. This allows MCP servers to be dynamically provided to the editor in
/// addition to those the user creates in their configuration files.
///
/// Before calling this method, extensions must register the `contributes.mcpServerDefinitionProviders`
/// extension point with the corresponding {@link id}, for example:
///
/// ```js
/// 	"contributes": {
/// 		"mcpServerDefinitionProviders": [
/// 			{
/// 				"id": "cool-cloud-registry.mcp-servers",
/// 				"label": "Cool Cloud Registry",
/// 			}
/// 		]
/// 	}
/// ```
///
/// When a new McpServerDefinitionProvider is available, the editor will, by default,
/// automatically invoke it to discover new servers and tools when a chat message is
/// submitted. To enable this flow, extensions should call
/// `registerMcpServerDefinitionProvider` during activation.
///
/// @param id The ID of the provider, which is unique to the extension.
/// @param provider The provider to register
/// @returns A disposable that unregisters the provider when disposed.
pub fn register_mcp_server_definition_provider(
  id : String,
  provider : McpServerDefinitionProvider,
) -> @vscode.Disposable {
  lm_register_mcp_server_definition_provider_ffi(id, provider)
}

///|
/// Registers a {@linkcode LanguageModelChatProvider}
/// Note: You must also define the language model chat provider via the `languageModelChatProviders` contribution point in package.json
/// @param vendor The vendor for this provider. Must be globally unique. An example is `copilot` or `openai`.
/// @param provider The provider to register
/// @returns A disposable that unregisters the provider when disposed
pub fn register_language_model_chat_provider(
  vendor : String,
  provider : LanguageModelChatProvider,
) -> @vscode.Disposable {
  lm_register_language_model_chat_provider_ffi(vendor, provider)
}

///|
pub fn extension_context_language_model_access_information(
  ctx : ExtensionContext,
) -> LanguageModelAccessInformation {
  lm_extension_context_language_model_access_information_ffi(ctx)
}

///|
/// An event that fires when access information changes.

///|
/// Checks if a request can be made to a language model.
///
/// *Note* that calling this function will not trigger a consent UI but just checks for a persisted state.
///
/// @param chat A language model chat object.
/// @return `true` if a request can be made, `false` if not, `undefined` if the language
/// model does not exist or consent hasn't been asked for.
pub fn LanguageModelAccessInformation::can_send_request(
  self : LanguageModelAccessInformation,
  chat : LanguageModelChat,
) -> Bool? {
  js_to_option(
    language_model_access_information_can_send_request_raw(self, chat),
  )
}

///|
pub fn LanguageModelChatSelector::new(
  vendor? : String,
  family? : String,
  version? : String,
  id? : String,
) -> LanguageModelChatSelector {
  lm_language_model_chat_selector_ffi(
    option_to_js(vendor),
    option_to_js(family),
    option_to_js(version),
    option_to_js(id),
  )
}

///|
/// A vendor of language models.
/// @see {@link LanguageModelChat.vendor}

///|
/// A family of language models.
/// @see {@link LanguageModelChat.family}

///|
/// The version of a language model.
/// @see {@link LanguageModelChat.version}

///|
/// The identifier of a language model.
/// @see {@link LanguageModelChat.id}

///|
pub fn LanguageModelChatTool::new(
  name : String,
  description : String,
  input_schema? : Any,
) -> LanguageModelChatTool {
  lm_language_model_chat_tool_ffi(name, description, option_to_js(input_schema))
}

///|
/// The name of the tool.

///|
/// The name of the tool.

///|
/// The description of the tool.

///|
/// The description of the tool.

///|
/// A JSON schema for the input this tool accepts.

///|
/// A JSON schema for the input this tool accepts.

///|
/// A JSON schema for the input this tool accepts.

///|
pub fn LanguageModelChatRequestOptions::new(
  justification? : String,
  model_options? : Any,
  tools? : Array[LanguageModelChatTool],
  tool_mode? : LanguageModelChatToolMode,
) -> LanguageModelChatRequestOptions {
  lm_language_model_chat_request_options_ffi(
    option_to_js(justification),
    option_to_js(model_options),
    option_to_js(tools),
    option_to_js(tool_mode),
  )
}

///|
/// A human-readable message that explains why access to a language model is needed and what feature is enabled by it.

///|
/// A set of options that control the behavior of the language model. These options are specific to the language model
/// and need to be looked up in the respective documentation.

///|
/// An optional list of tools that are available to the language model. These could be registered tools available via
/// {@link lm.tools}, or private tools that are just implemented within the calling extension.
///
/// If the LLM requests to call one of these tools, it will return a {@link LanguageModelToolCallPart} in
/// {@link LanguageModelChatResponse.stream}. It's the caller's responsibility to invoke the tool. If it's a tool
/// registered in {@link lm.tools}, that means calling {@link lm.invokeTool}.
///
/// Then, the tool result can be provided to the LLM by creating an Assistant-type {@link LanguageModelChatMessage} with a
/// {@link LanguageModelToolCallPart}, followed by a User-type message with a {@link LanguageModelToolResultPart}.

///|
/// 	The tool-selecting mode to use. {@link LanguageModelChatToolMode.Auto} by default.

///|
pub fn LanguageModelInputPart::text(
  value : LanguageModelTextPart,
) -> LanguageModelInputPart {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelInputPart::tool_result(
  value : LanguageModelToolResultPart,
) -> LanguageModelInputPart {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelInputPart::tool_call(
  value : LanguageModelToolCallPart,
) -> LanguageModelInputPart {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelInputPart::data(
  value : LanguageModelDataPart,
) -> LanguageModelInputPart {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] LanguageModelInputPart::from_value(
  value : T,
) -> LanguageModelInputPart {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] LanguageModelInputPart::as_value(value : LanguageModelInputPart) -> T {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelResponsePart::text(
  value : LanguageModelTextPart,
) -> LanguageModelResponsePart {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelResponsePart::tool_result(
  value : LanguageModelToolResultPart,
) -> LanguageModelResponsePart {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelResponsePart::tool_call(
  value : LanguageModelToolCallPart,
) -> LanguageModelResponsePart {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelResponsePart::data(
  value : LanguageModelDataPart,
) -> LanguageModelResponsePart {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] LanguageModelResponsePart::from_value(
  value : T,
) -> LanguageModelResponsePart {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelToolResultContentPart::text(
  value : LanguageModelTextPart,
) -> LanguageModelToolResultContentPart {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelToolResultContentPart::prompt_tsx(
  value : LanguageModelPromptTsxPart,
) -> LanguageModelToolResultContentPart {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelToolResultContentPart::data(
  value : LanguageModelDataPart,
) -> LanguageModelToolResultContentPart {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] LanguageModelToolResultContentPart::from_value(
  value : T,
) -> LanguageModelToolResultContentPart {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelChatMessage::user_text(
  content : String,
  name? : String,
) -> LanguageModelChatMessage {
  language_model_chat_message_user_text_ffi(content, option_to_js(name))
}

///|
pub fn LanguageModelChatMessage::user_parts(
  content : Array[LanguageModelInputPart],
  name? : String,
) -> LanguageModelChatMessage {
  language_model_chat_message_user_parts_ffi(content, option_to_js(name))
}

///|
pub fn LanguageModelChatMessage::assistant_text(
  content : String,
  name? : String,
) -> LanguageModelChatMessage {
  language_model_chat_message_assistant_text_ffi(content, option_to_js(name))
}

///|
pub fn LanguageModelChatMessage::assistant_parts(
  content : Array[LanguageModelInputPart],
  name? : String,
) -> LanguageModelChatMessage {
  language_model_chat_message_assistant_parts_ffi(content, option_to_js(name))
}

///|
pub fn LanguageModelChatMessage::new_with_text(
  role : LanguageModelChatMessageRole,
  content : String,
  name? : String,
) -> LanguageModelChatMessage {
  language_model_chat_message_new_with_text_ffi(
    role,
    content,
    option_to_js(name),
  )
}

///|
pub extern "js" fn LanguageModelChatMessage::new_with_parts(
  role : LanguageModelChatMessageRole,
  content : Array[LanguageModelInputPart],
  name? : String,
) -> LanguageModelChatMessage =
  #| (role, content, name) =>
  #|   new (require("vscode").LanguageModelChatMessage)(
  #|     role,
  #|     content,
  #|     name === undefined || name === null ? undefined : name
  #|   )

///|
/// The role of this message.
pub extern "js" fn LanguageModelChatMessage::role(
  self : LanguageModelChatMessage,
) -> LanguageModelChatMessageRole =
  #| (value) => value.role

///|
/// The role of this message.

///|
/// A string or heterogeneous array of things that a message can contain as content. Some parts may be message-type
/// specific for some models.

///|
/// A string or heterogeneous array of things that a message can contain as content. Some parts may be message-type
/// specific for some models.

///|
/// The optional name of a user for this message.
pub fn LanguageModelChatMessage::name(
  self : LanguageModelChatMessage,
) -> String? {
  let raw = language_model_chat_message_name_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The optional name of a user for this message.

///|
/// The optional name of a user for this message.

///|
/// Human-readable name of the language model.

///|
/// Opaque identifier of the language model.

///|
/// A well-known identifier of the vendor of the language model. An example is `copilot`, but
/// values are defined by extensions contributing chat models and need to be looked up with them.

///|
/// Opaque family-name of the language model. Values might be `gpt-3.5-turbo`, `gpt4`, `phi2`, or `llama`
/// but they are defined by extensions contributing languages and subject to change.

///|
/// Opaque version string of the model. This is defined by the extension contributing the language model
/// and subject to change.

///|
/// The maximum number of tokens that can be sent to the model in a single request.

///|
/// Make a chat request using a language model.
///
/// *Note* that language model use may be subject to access restrictions and user consent. Calling this function
/// for the first time (for an extension) will show a consent dialog to the user and because of that this function
/// must _only be called in response to a user action!_ Extensions can use {@link LanguageModelAccessInformation.canSendRequest}
/// to check if they have the necessary permissions to make a request.
///
/// This function will return a rejected promise if making a request to the language model is not
/// possible. Reasons for this can be:
///
/// - user consent not given, see {@link LanguageModelError.NoPermissions `NoPermissions`}
/// - model does not exist anymore, see {@link LanguageModelError.NotFound `NotFound`}
/// - quota limits exceeded, see {@link LanguageModelError.Blocked `Blocked`}
/// - other issues in which case extension must check {@link LanguageModelError.cause `LanguageModelError.cause`}
///
/// An extension can make use of language model tool calling by passing a set of tools to
/// {@link LanguageModelChatRequestOptions.tools}. The language model will return a {@link LanguageModelToolCallPart} and
/// the extension can invoke the tool and make another request with the result.
///
/// @param messages An array of message instances.
/// @param options Options that control the request.
/// @param token A cancellation token which controls the request. See {@link CancellationTokenSource} for how to create one.
/// @returns A thenable that resolves to a {@link LanguageModelChatResponse}. The promise will reject when the request couldn't be made.
pub async fn LanguageModelChat::send_request(
  self : LanguageModelChat,
  messages : Array[LanguageModelChatMessage],
  options? : LanguageModelChatRequestOptions,
  token? : CancellationToken,
) -> LanguageModelChatResponse {
  @js_async.Promise::wait(
    language_model_chat_send_request_ffi(
      self,
      messages,
      option_to_js(options),
      option_to_js(token),
    ),
  )
}

///|
/// Count the number of tokens in a message using the model specific tokenizer-logic.
///
/// @param text A string or a message instance.
/// @param token Optional cancellation token.  See {@link CancellationTokenSource} for how to create one.
/// @returns A thenable that resolves to the number of tokens.
pub async fn LanguageModelChat::count_tokens_text(
  self : LanguageModelChat,
  text : String,
  token? : CancellationToken,
) -> Int {
  @js_async.Promise::wait(
    language_model_chat_count_tokens_text_ffi(self, text, option_to_js(token)),
  )
}

///|
/// Count the number of tokens in a message using the model specific tokenizer-logic.
///
/// @param text A string or a message instance.
/// @param token Optional cancellation token.  See {@link CancellationTokenSource} for how to create one.
/// @returns A thenable that resolves to the number of tokens.
pub async fn LanguageModelChat::count_tokens_message(
  self : LanguageModelChat,
  message : LanguageModelChatMessage,
  token? : CancellationToken,
) -> Int {
  @js_async.Promise::wait(
    language_model_chat_count_tokens_message_ffi(
      self,
      message,
      option_to_js(token),
    ),
  )
}

///|
/// An async iterable that is a stream of text and tool-call parts forming the overall response. A
/// {@link LanguageModelTextPart} is part of the assistant's response to be shown to the user. A
/// {@link LanguageModelToolCallPart} is a request from the language model to call a tool. The latter will
/// only be returned if tools were passed in the request via {@link LanguageModelChatRequestOptions.tools}. The
/// `unknown`-type is used as a placeholder for future parts, like image data parts.
///
/// *Note* that this stream will error when during data receiving an error occurs. Consumers of the stream should handle
/// the errors accordingly.
///
/// To cancel the stream, the consumer can {@link CancellationTokenSource.cancel cancel} the token that was used to make
/// the request or break from the for-loop.
///
/// @example
/// ```ts
/// try {
///   // consume stream
///   for await (const chunk of response.stream) {
///      if (chunk instanceof LanguageModelTextPart) {
///        console.log("TEXT", chunk);
///      } else if (chunk instanceof LanguageModelToolCallPart) {
///        console.log("TOOL CALL", chunk);
///      }
///   }
///
/// } catch(e) {
///   // stream ended with an error
///   console.error(e);
/// }
/// ```

///|
/// This is equivalent to filtering everything except for text parts from a {@link LanguageModelChatResponse.stream}.
///
/// @see {@link LanguageModelChatResponse.stream}

///|
pub fn[T] AsyncIterable::iterator(self : AsyncIterable[T]) -> AsyncIterator[T] {
  async_iterable_iterator_ffi(@v.JsValue::make(self)).cast()
}

///|
pub async fn[T] AsyncIterator::next(
  self : AsyncIterator[T],
) -> AsyncIteratorResult[T] {
  @js_async.Promise::wait(async_iterator_next_ffi(@v.JsValue::make(self))).cast()
}

///|
pub fn[T] AsyncIteratorResult::done(self : AsyncIteratorResult[T]) -> Bool {
  async_iterator_result_done_ffi(@v.JsValue::make(self))
}

///|
pub fn[T] AsyncIteratorResult::value(self : AsyncIteratorResult[T]) -> T {
  async_iterator_result_value_ffi(@v.JsValue::make(self)).cast()
}

///|
pub fn LanguageModelError::no_permissions(
  message? : String,
) -> LanguageModelError {
  language_model_error_no_permissions_ffi(option_to_js(message))
}

///|
pub fn LanguageModelError::blocked(message? : String) -> LanguageModelError {
  language_model_error_blocked_ffi(option_to_js(message))
}

///|
pub fn LanguageModelError::not_found(message? : String) -> LanguageModelError {
  language_model_error_not_found_ffi(option_to_js(message))
}

///|
/// A code that identifies this error.
///
/// Possible values are names of errors, like {@linkcode LanguageModelError.NotFound NotFound},
/// or `Unknown` for unspecified errors from the language model itself. In the latter case the
/// `cause`-property will contain the actual error.
pub extern "js" fn LanguageModelError::code(
  self : LanguageModelError,
) -> String =
  #| (value) => value.code

///|
pub extern "js" fn LanguageModelError::message(
  self : LanguageModelError,
) -> String =
  #| (value) => value.message

///|

///|
/// Create a new LanguageModelToolCallPart.
///
/// @param callId The ID of the tool call.
/// @param name The name of the tool to call.
/// @param input The input with which to call the tool.
pub extern "js" fn LanguageModelToolCallPart::new(
  call_id : String,
  name : String,
  input : Any,
) -> LanguageModelToolCallPart =
  #| (callId, name, input) => new (require("vscode").LanguageModelToolCallPart)(callId, name, input)

///|
/// The ID of the tool call. This is a unique identifier for the tool call within the chat request.

///|
/// The name of the tool to call.

///|
/// The input with which to call the tool.

///|
/// @param callId The ID of the tool call.
/// @param content The content of the tool result.
pub extern "js" fn LanguageModelToolResultPart::new(
  call_id : String,
  content : Array[LanguageModelToolResultContentPart],
) -> LanguageModelToolResultPart =
  #| (callId, content) => new (require("vscode").LanguageModelToolResultPart)(callId, content)

///|
/// The ID of the tool call.
///
/// *Note* that this should match the {@link LanguageModelToolCallPart.callId callId} of a tool call part.

///|
/// The value of the tool result.

///|
/// Construct a text part with the given content.
/// @param value The text content of the part.
pub extern "js" fn LanguageModelTextPart::new(
  value : String,
) -> LanguageModelTextPart =
  #| (value) => new (require("vscode").LanguageModelTextPart)(value)

///|
/// The text content of the part.

///|
/// Construct a prompt-tsx part with the given content.
/// @param value The value of the part, the result of `renderElementJSON` from `@vscode/prompt-tsx`.
pub extern "js" fn LanguageModelPromptTsxPart::new(
  value : Any,
) -> LanguageModelPromptTsxPart =
  #| (value) => new (require("vscode").LanguageModelPromptTsxPart)(value)

///|
/// The value of the part.

///|
/// Create a LanguageModelToolResult
/// @param content A list of tool result content parts
pub extern "js" fn LanguageModelToolResult::new(
  content : Array[LanguageModelToolResultContentPart],
) -> LanguageModelToolResult =
  #| (content) => new (require("vscode").LanguageModelToolResult)(content)

///|
/// A list of tool result content parts. Includes `unknown` because this list may be extended with new content types in
/// the future.
/// @see {@link lm.invokeTool}.
pub extern "js" fn LanguageModelToolResult::content(
  self : LanguageModelToolResult,
) -> Array[LanguageModelToolResultContentPart] =
  #| (value) => value.content

///|
/// Create a new {@linkcode LanguageModelDataPart} for an image.
/// @param data Binary image data
/// @param mime The MIME type of the image. Common values are `image/png` and `image/jpeg`.
pub fn LanguageModelDataPart::image(
  data : Bytes,
  mime : String,
) -> LanguageModelDataPart {
  language_model_data_part_image_ffi(bytes_to_uint8_array(data), mime)
}

///|
/// Create a new {@linkcode LanguageModelDataPart} for a json.
///
/// *Note* that this function is not expecting "stringified JSON" but
/// an object that can be stringified. This function will throw an error
/// when the passed value cannot be JSON-stringified.
/// @param value  A JSON-stringifyable value.
/// @param mime Optional MIME type, defaults to `application/json`
pub extern "js" fn LanguageModelDataPart::json_value(
  value : Any,
  mime? : String,
) -> LanguageModelDataPart =
  #| (value, mime) =>
  #|   require("vscode").LanguageModelDataPart.json(
  #|     value,
  #|     mime === undefined || mime === null ? undefined : mime
  #|   )

///|
/// Create a new {@linkcode LanguageModelDataPart} for text.
///
/// *Note* that an UTF-8 encoder is used to create bytes for the string.
/// @param value Text data
/// @param mime The MIME type if any. Common values are `text/plain` and `text/markdown`.
pub extern "js" fn LanguageModelDataPart::text(
  value : String,
  mime? : String,
) -> LanguageModelDataPart =
  #| (value, mime) =>
  #|   require("vscode").LanguageModelDataPart.text(
  #|     value,
  #|     mime === undefined || mime === null ? undefined : mime
  #|   )

///|
/// Construct a generic data part with the given content.
/// @param data The byte data for this part.
/// @param mimeType The mime type of the data.
pub fn LanguageModelDataPart::new(
  data : Bytes,
  mime_type : String,
) -> LanguageModelDataPart {
  language_model_data_part_new_ffi(bytes_to_uint8_array(data), mime_type)
}

///|
/// The mime type which determines how the data property is interpreted.

///|
/// The mime type which determines how the data property is interpreted.

///|
/// The byte data for this part.

///|
/// The byte data for this part.

///|
pub fn LanguageModelTokenCountInput::text(
  value : String,
) -> LanguageModelTokenCountInput {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelTokenCountInput::request_message(
  value : LanguageModelChatRequestMessage,
) -> LanguageModelTokenCountInput {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] LanguageModelTokenCountInput::from_value(
  value : T,
) -> LanguageModelTokenCountInput {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] LanguageModelToolInvocationOptions::new(
  input : T,
  tool_invocation_token? : ChatParticipantToolToken,
  tokenization_options? : LanguageModelToolTokenizationOptions,
) -> LanguageModelToolInvocationOptions {
  lm_language_model_tool_invocation_options_ffi(
    option_to_js(tool_invocation_token),
    @v.JsValue::make(input),
    option_to_js(tokenization_options),
  )
}

///|
/// An opaque object that ties a tool invocation to a chat request from a {@link ChatParticipant chat participant}.
///
/// The _only_ way to get a valid tool invocation token is using the provided {@link ChatRequest.toolInvocationToken toolInvocationToken}
/// from a chat request. In that case, a progress bar will be automatically shown for the tool invocation in the chat response view, and if
/// the tool requires user confirmation, it will show up inline in the chat view.
///
/// If the tool is being invoked outside of a chat request, `undefined` should be passed instead, and no special UI except for
/// confirmations will be shown.
///
/// *Note* that a tool that invokes another tool during its invocation, can pass along the `toolInvocationToken` that it received.

///|
/// The input with which to invoke the tool. The input must match the schema defined in
/// {@link LanguageModelToolInformation.inputSchema}
pub fn[T] LanguageModelToolInvocationOptions::input(
  self : LanguageModelToolInvocationOptions,
) -> T {
  language_model_tool_invocation_options_input_raw(self).cast()
}

///|
/// Options to hint at how many tokens the tool should return in its response, and enable the tool to count tokens
/// accurately.

///|
pub fn LanguageModelToolTokenizationOptions::new(
  token_budget : Int,
  count_tokens : async (String, CancellationToken?) -> Int,
) -> LanguageModelToolTokenizationOptions {
  lm_language_model_tool_tokenization_options_ffi(token_budget, (text, token) => {
    @js_async.Promise::from_async(async fn() {
      count_tokens(text, js_to_option(token))
    })
  })
}

///|
/// If known, the maximum number of tokens the tool should emit in its result.

///|
/// If known, the maximum number of tokens the tool should emit in its result.

///|
/// Count the number of tokens in a message using the model specific tokenizer-logic.
/// @param text A string.
/// @param token Optional cancellation token.  See {@link CancellationTokenSource} for how to create one.
/// @returns A thenable that resolves to the number of tokens.
pub async fn LanguageModelToolTokenizationOptions::count_tokens(
  self : LanguageModelToolTokenizationOptions,
  text : String,
  token? : CancellationToken,
) -> Int {
  @js_async.Promise::wait(
    language_model_tool_tokenization_options_count_tokens_ffi(
      self,
      text,
      option_to_js(token),
    ),
  )
}

///|
/// A JSON schema for the input this tool accepts.

///|
/// A unique name for the tool.

///|
/// A description of this tool that may be passed to a language model.

///|
/// A set of tags, declared by the tool, that roughly describe the tool's capabilities. A tool user may use these to filter
/// the set of tools to just ones that are relevant for the task at hand.

///|
pub fn[T] LanguageModelToolInvocationPrepareOptions::new(
  input : T,
) -> LanguageModelToolInvocationPrepareOptions {
  lm_language_model_tool_invocation_prepare_options_ffi(@v.JsValue::make(input))
}

///|
/// The input that the tool is being invoked with.
pub fn[T] LanguageModelToolInvocationPrepareOptions::input(
  self : LanguageModelToolInvocationPrepareOptions,
) -> T {
  language_model_tool_invocation_prepare_options_input_raw(self).cast()
}

///|
pub fn LanguageModelTool::new(
  invoke : async (LanguageModelToolInvocationOptions, CancellationToken) -> LanguageModelToolResult?,
  prepare_invocation? : async (
    LanguageModelToolInvocationPrepareOptions,
    CancellationToken,
  ) -> PreparedToolInvocation?,
) -> LanguageModelTool {
  let prepare_callback : ((
    LanguageModelToolInvocationPrepareOptions,
    CancellationToken,
  ) -> @js_async.Promise[@v.JsValue])? = match prepare_invocation {
    None => None
    Some(value) =>
      Some((options, token) => {
        @js_async.Promise::from_async(async fn() {
          option_to_js(value(options, token))
        })
      })
  }
  lm_language_model_tool_ffi(
    (options, token) => {
      @js_async.Promise::from_async(async fn() {
        option_to_js(invoke(options, token))
      })
    },
    option_to_js(prepare_callback),
  )
}

///|
/// Invoke the tool with the given input and return a result.
///
/// The provided {@link LanguageModelToolInvocationOptions.input} has been validated against the declared schema.
pub async fn LanguageModelTool::invoke(
  self : LanguageModelTool,
  options : LanguageModelToolInvocationOptions,
  token : CancellationToken,
) -> LanguageModelToolResult? {
  let raw = @js_async.Promise::wait(
    language_model_tool_invoke_ffi(self, options, token),
  )
  js_to_option(raw)
}

///|
/// Called once before a tool is invoked. It's recommended to implement this to customize the progress message that appears
/// while the tool is running, and to provide a more useful message with context from the invocation input. Can also
/// signal that a tool needs user confirmation before running, if appropriate.
///
/// * *Note 1:* Must be free of side-effects.
/// * *Note 2:* A call to `prepareInvocation` is not necessarily followed by a call to `invoke`.
pub async fn LanguageModelTool::prepare_invocation(
  self : LanguageModelTool,
  options : LanguageModelToolInvocationPrepareOptions,
  token : CancellationToken,
) -> PreparedToolInvocation? {
  let raw = @js_async.Promise::wait(
    language_model_tool_prepare_invocation_ffi(self, options, token),
  )
  js_to_option(raw)
}

///|
pub fn LanguageModelConfirmationMessageValue::text(
  value : String,
) -> LanguageModelConfirmationMessageValue {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelConfirmationMessageValue::markdown(
  value : MarkdownString,
) -> LanguageModelConfirmationMessageValue {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] LanguageModelConfirmationMessageValue::from_value(
  value : T,
) -> LanguageModelConfirmationMessageValue {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelToolConfirmationMessages::new(
  title : String,
  message : LanguageModelConfirmationMessageValue,
) -> LanguageModelToolConfirmationMessages {
  lm_language_model_tool_confirmation_messages_ffi(title, message)
}

///|
/// The title of the confirmation message.

///|
/// The title of the confirmation message.

///|
/// The body of the confirmation message.

///|
/// The body of the confirmation message.

///|
pub fn PreparedToolInvocation::new(
  invocation_message? : LanguageModelConfirmationMessageValue,
  confirmation_messages? : LanguageModelToolConfirmationMessages,
) -> PreparedToolInvocation {
  lm_prepared_tool_invocation_ffi(
    option_to_js(invocation_message),
    option_to_js(confirmation_messages),
  )
}

///|
/// A customized progress message to show while the tool runs.

///|
/// The presence of this property indicates that the user should be asked to confirm before running the tool. The user
/// should be asked for confirmation for any tool that has a side-effect or may potentially be dangerous.

///|
/// The start and end index of the reference in the {@link ChatRequest.prompt prompt}. When undefined, the reference was
/// not part of the prompt text.
///
/// *Note* that the indices take the leading `#`-character into account which means they can be used to modify the prompt
/// as-is.

///|
/// The tool name. Refers to a tool listed in {@link lm.tools}.

///|
pub fn LanguageModelToolCalling::supported(
  value : Bool,
) -> LanguageModelToolCalling {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelToolCalling::max_tools(
  value : Int,
) -> LanguageModelToolCalling {
  @v.JsValue::make(value).cast()
}

///|
pub fn LanguageModelChatCapabilities::new(
  image_input? : Bool,
  tool_calling? : LanguageModelToolCalling,
) -> LanguageModelChatCapabilities {
  lm_language_model_chat_capabilities_ffi(
    option_to_js(image_input),
    option_to_js(tool_calling),
  )
}

///|
/// Whether image input is supported by the model.
/// Common supported images are jpg and png, but each model will vary in supported mimetypes.

///|
/// Whether tool calling is supported by the model.
/// If a number is provided, that is the maximum number of tools that can be provided in a request to the model.

///|
pub fn LanguageModelChatInformation::new(
  id : String,
  name : String,
  family : String,
  version : String,
  max_input_tokens : Int,
  max_output_tokens : Int,
  capabilities : LanguageModelChatCapabilities,
  tooltip? : String,
  detail? : String,
) -> LanguageModelChatInformation {
  lm_language_model_chat_information_ffi(
    id,
    name,
    family,
    version,
    max_input_tokens,
    max_output_tokens,
    capabilities,
    option_to_js(tooltip),
    option_to_js(detail),
  )
}

///|
/// Unique identifier for the language model. Must be unique per provider, but not required to be globally unique.

///|
/// Human-readable name of the language model.

///|
/// Opaque family-name of the language model. Values might be `gpt-3.5-turbo`, `gpt4`, `phi2`, or `llama`

///|
/// Opaque version string of the model.
/// This is used as a lookup value in {@linkcode LanguageModelChatSelector.version}
/// An example is how GPT 4o has multiple versions like 2024-11-20 and 2024-08-06

///|
/// The maximum number of tokens the model can accept as input.

///|
/// The maximum number of tokens the model is capable of producing.

///|
/// Various features that the model supports such as tool calling or image input.

///|
/// The tooltip to render when hovering the model. Used to provide more information about the model.

///|
/// An optional, human-readable string which will be rendered alongside the model.
/// Useful for distinguishing models of the same name in the UI.

///|
pub fn LanguageModelChatRequestMessage::new(
  role : LanguageModelChatMessageRole,
  content : Array[LanguageModelInputPart],
  name? : String,
) -> LanguageModelChatRequestMessage {
  lm_language_model_chat_request_message_ffi(role, content, option_to_js(name))
}

///|
/// The role of this message.

///|
/// A heterogeneous array of things that a message can contain as content. Some parts may be message-type
/// specific for some models.

///|
/// The optional name of a user for this message.

///|
pub fn ProvideLanguageModelChatResponseOptions::new(
  tool_mode : LanguageModelChatToolMode,
  model_options? : Any,
  tools? : Array[LanguageModelChatTool],
) -> ProvideLanguageModelChatResponseOptions {
  lm_provide_language_model_chat_response_options_ffi(
    option_to_js(model_options),
    option_to_js(tools),
    tool_mode,
  )
}

///|
/// 	The tool-selecting mode to use. The provider must implement respecting this.

///|
/// A set of options that control the behavior of the language model. These options are specific to the language model.

///|
/// An optional list of tools that are available to the language model. These could be registered tools available via
/// {@link lm.tools}, or private tools that are just implemented within the calling extension.
///
/// If the LLM requests to call one of these tools, it will return a {@link LanguageModelToolCallPart} in
/// {@link LanguageModelChatResponse.stream}. It's the caller's responsibility to invoke the tool. If it's a tool
/// registered in {@link lm.tools}, that means calling {@link lm.invokeTool}.
///
/// Then, the tool result can be provided to the LLM by creating an Assistant-type {@link LanguageModelChatMessage} with a
/// {@link LanguageModelToolCallPart}, followed by a User-type message with a {@link LanguageModelToolResultPart}.

///|
/// @param label The human-readable name of the server.
/// @param command The command used to start the server.
/// @param args Additional command-line arguments passed to the server.
/// @param env Optional additional environment information for the server.
/// @param version Optional version identification for the server.
pub fn McpStdioServerDefinition::new(
  label : String,
  command : String,
  args? : Array[String],
  env_entries? : Array[(String, Any?)],
  version? : String,
) -> McpStdioServerDefinition {
  lm_mcp_stdio_server_definition_ffi(
    label,
    command,
    option_to_js(args),
    option_to_js(env_entries),
    option_to_js(version),
  )
}

///|
/// The human-readable name of the server.
pub extern "js" fn McpStdioServerDefinition::label(
  self : McpStdioServerDefinition,
) -> String =
  #| (value) => value.label

///|
/// The working directory used to start the server.

///|
/// The working directory used to start the server.

///|
/// The working directory used to start the server.

///|
/// The command used to start the server. Node.js-based servers may use
/// `process.execPath` to use the editor's version of Node.js to run the script.

///|
/// The command used to start the server. Node.js-based servers may use
/// `process.execPath` to use the editor's version of Node.js to run the script.

///|
/// Additional command-line arguments passed to the server.

///|
/// Additional command-line arguments passed to the server.

///|
/// Optional version identification for the server. If this changes, the
/// editor will indicate that tools have changed and prompt to refresh them.

///|
/// @param label The human-readable name of the server.
/// @param uri The URI of the server.
/// @param headers Optional additional heads included with each request to the server.
pub fn McpHttpServerDefinition::new(
  label : String,
  uri : Uri,
  headers? : Array[(String, String)],
  version? : String,
) -> McpHttpServerDefinition {
  lm_mcp_http_server_definition_ffi(
    label,
    uri,
    option_to_js(headers),
    option_to_js(version),
  )
}

///|
/// The human-readable name of the server.
pub extern "js" fn McpHttpServerDefinition::label(
  self : McpHttpServerDefinition,
) -> String =
  #| (value) => value.label

///|
/// The URI of the server. The editor will make a POST request to this URI
/// to begin each session.

///|
/// The URI of the server. The editor will make a POST request to this URI
/// to begin each session.

///|
pub fn McpServerDefinition::from_stdio(
  value : McpStdioServerDefinition,
) -> McpServerDefinition {
  @v.JsValue::make(value).cast()
}

///|
pub fn McpServerDefinition::from_http(
  value : McpHttpServerDefinition,
) -> McpServerDefinition {
  @v.JsValue::make(value).cast()
}

///|
pub fn[T] McpServerDefinition::from_value(value : T) -> McpServerDefinition {
  @v.JsValue::make(value).cast()
}

///|
pub fn McpServerDefinitionProvider::new(
  provide_mcp_server_definitions : async (CancellationToken) -> Array[
    McpServerDefinition,
  ]?,
  resolve_mcp_server_definition? : async (
    McpServerDefinition,
    CancellationToken,
  ) -> McpServerDefinition?,
  on_did_change_mcp_server_definitions? : Event[Unit],
) -> McpServerDefinitionProvider {
  let resolve_callback : ((McpServerDefinition, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ])? = match resolve_mcp_server_definition {
    None => None
    Some(value) =>
      Some((server, token) => {
        @js_async.Promise::from_async(async fn() {
          option_to_js(value(server, token))
        })
      })
  }
  lm_mcp_server_definition_provider_ffi(
    option_to_js(on_did_change_mcp_server_definitions),
    token => {
      @js_async.Promise::from_async(async fn() {
        option_to_js(provide_mcp_server_definitions(token))
      })
    },
    option_to_js(resolve_callback),
  )
}

///|
pub fn LanguageModelChatProvider::new(
  provide_language_model_chat_information : async (
    PrepareLanguageModelChatModelOptions,
    CancellationToken,
  ) -> Array[LanguageModelChatInformation]?,
  provide_language_model_chat_response : async (
    LanguageModelChatInformation,
    Array[LanguageModelChatRequestMessage],
    ProvideLanguageModelChatResponseOptions,
    Progress[LanguageModelResponsePart],
    CancellationToken,
  ) -> Unit,
  provide_token_count : async (
    LanguageModelChatInformation,
    LanguageModelTokenCountInput,
    CancellationToken,
  ) -> Int,
  on_did_change_language_model_chat_information? : Event[Unit],
) -> LanguageModelChatProvider {
  lm_language_model_chat_provider_ffi(
    option_to_js(on_did_change_language_model_chat_information),
    (options, token) => {
      @js_async.Promise::from_async(async fn() {
        option_to_js(provide_language_model_chat_information(options, token))
      })
    },
    (model, messages, options, progress, token) => {
      @js_async.Promise::from_async(async fn() {
        provide_language_model_chat_response(
          model, messages, options, progress, token,
        )
      })
    },
    (model, text, token) => {
      @js_async.Promise::from_async(async fn() {
        provide_token_count(model, text.cast(), token)
      })
    },
  )
}

///|
extern "js" fn language_model_access_information_can_send_request_raw(
  info : LanguageModelAccessInformation,
  chat : LanguageModelChat,
) -> @v.JsValue =
  #| (info, chat) => info.canSendRequest(chat)

///|
extern "js" fn language_model_chat_message_user_text_ffi(
  content : String,
  name : @v.JsValue,
) -> LanguageModelChatMessage =
  #| (content, name) =>
  #|   require("vscode").LanguageModelChatMessage.User(
  #|     content,
  #|     name === undefined || name === null ? undefined : name
  #|   )

///|
extern "js" fn language_model_chat_message_user_parts_ffi(
  content : Array[LanguageModelInputPart],
  name : @v.JsValue,
) -> LanguageModelChatMessage =
  #| (content, name) =>
  #|   require("vscode").LanguageModelChatMessage.User(
  #|     content,
  #|     name === undefined || name === null ? undefined : name
  #|   )

///|
extern "js" fn language_model_chat_message_assistant_text_ffi(
  content : String,
  name : @v.JsValue,
) -> LanguageModelChatMessage =
  #| (content, name) =>
  #|   require("vscode").LanguageModelChatMessage.Assistant(
  #|     content,
  #|     name === undefined || name === null ? undefined : name
  #|   )

///|
extern "js" fn language_model_chat_message_assistant_parts_ffi(
  content : Array[LanguageModelInputPart],
  name : @v.JsValue,
) -> LanguageModelChatMessage =
  #| (content, name) =>
  #|   require("vscode").LanguageModelChatMessage.Assistant(
  #|     content,
  #|     name === undefined || name === null ? undefined : name
  #|   )

///|
extern "js" fn language_model_chat_message_new_with_text_ffi(
  role : LanguageModelChatMessageRole,
  content : String,
  name : @v.JsValue,
) -> LanguageModelChatMessage =
  #| (role, content, name) =>
  #|   new (require("vscode").LanguageModelChatMessage)(
  #|     role,
  #|     content,
  #|     name === undefined || name === null ? undefined : name
  #|   )

///|
extern "js" fn language_model_chat_message_name_raw(
  value : LanguageModelChatMessage,
) -> @v.JsValue =
  #| (value) => value.name

///|
extern "js" fn language_model_chat_send_request_ffi(
  model : LanguageModelChat,
  messages : Array[LanguageModelChatMessage],
  options : @v.JsValue,
  token : @v.JsValue,
) -> @js_async.Promise[LanguageModelChatResponse] =
  #| (model, messages, options, token) => {
  #|   if (options === undefined || options === null) {
  #|     return token === undefined || token === null
  #|       ? model.sendRequest(messages)
  #|       : model.sendRequest(messages, undefined, token);
  #|   }
  #|   return token === undefined || token === null
  #|     ? model.sendRequest(messages, options)
  #|     : model.sendRequest(messages, options, token);
  #| }

///|
extern "js" fn language_model_chat_count_tokens_text_ffi(
  model : LanguageModelChat,
  text : String,
  token : @v.JsValue,
) -> @js_async.Promise[Int] =
  #| (model, text, token) => {
  #|   return token === undefined || token === null
  #|     ? model.countTokens(text)
  #|     : model.countTokens(text, token);
  #| }

///|
extern "js" fn language_model_chat_count_tokens_message_ffi(
  model : LanguageModelChat,
  message : LanguageModelChatMessage,
  token : @v.JsValue,
) -> @js_async.Promise[Int] =
  #| (model, message, token) => {
  #|   return token === undefined || token === null
  #|     ? model.countTokens(message)
  #|     : model.countTokens(message, token);
  #| }

///|
extern "js" fn async_iterable_iterator_ffi(value : @v.JsValue) -> @v.JsValue =
  #| (iterable) => iterable[Symbol.asyncIterator]()

///|
extern "js" fn async_iterator_next_ffi(
  iterator : @v.JsValue,
) -> @js_async.Promise[@v.JsValue] =
  #| (iterator) => iterator.next()

///|
extern "js" fn async_iterator_result_done_ffi(value : @v.JsValue) -> Bool =
  #| (result) => !!result.done

///|
extern "js" fn async_iterator_result_value_ffi(
  value : @v.JsValue,
) -> @v.JsValue =
  #| (result) => result.value

///|
extern "js" fn language_model_error_no_permissions_ffi(
  message : @v.JsValue,
) -> LanguageModelError =
  #| (message) =>
  #|   require("vscode").LanguageModelError.NoPermissions(
  #|     message === undefined || message === null ? undefined : message
  #|   )

///|
extern "js" fn language_model_error_blocked_ffi(
  message : @v.JsValue,
) -> LanguageModelError =
  #| (message) =>
  #|   require("vscode").LanguageModelError.Blocked(
  #|     message === undefined || message === null ? undefined : message
  #|   )

///|
extern "js" fn language_model_error_not_found_ffi(
  message : @v.JsValue,
) -> LanguageModelError =
  #| (message) =>
  #|   require("vscode").LanguageModelError.NotFound(
  #|     message === undefined || message === null ? undefined : message
  #|   )

///|
extern "js" fn language_model_data_part_image_ffi(
  data : Uint8Array,
  mime : String,
) -> LanguageModelDataPart =
  #| (data, mime) => require("vscode").LanguageModelDataPart.image(data, mime)

///|
extern "js" fn language_model_data_part_new_ffi(
  data : Uint8Array,
  mime_type : String,
) -> LanguageModelDataPart =
  #| (data, mimeType) => new (require("vscode").LanguageModelDataPart)(data, mimeType)

///|
extern "js" fn language_model_tool_invocation_options_input_raw(
  options : LanguageModelToolInvocationOptions,
) -> @v.JsValue =
  #| (options) => options.input

///|
extern "js" fn language_model_tool_tokenization_options_count_tokens_ffi(
  options : LanguageModelToolTokenizationOptions,
  text : String,
  token : @v.JsValue,
) -> @js_async.Promise[Int] =
  #| (options, text, token) => {
  #|   return token === undefined || token === null
  #|     ? options.countTokens(text)
  #|     : options.countTokens(text, token);
  #| }

///|
extern "js" fn language_model_tool_invocation_prepare_options_input_raw(
  options : LanguageModelToolInvocationPrepareOptions,
) -> @v.JsValue =
  #| (options) => options.input

///|
extern "js" fn language_model_tool_invoke_ffi(
  tool : LanguageModelTool,
  options : LanguageModelToolInvocationOptions,
  token : CancellationToken,
) -> @js_async.Promise[@v.JsValue] =
  #| (tool, options, token) => tool.invoke(options, token)

///|
extern "js" fn language_model_tool_prepare_invocation_ffi(
  tool : LanguageModelTool,
  options : LanguageModelToolInvocationPrepareOptions,
  token : CancellationToken,
) -> @js_async.Promise[@v.JsValue] =
  #| (tool, options, token) => {
  #|   if (typeof tool.prepareInvocation !== "function") {
  #|     return Promise.resolve(undefined);
  #|   }
  #|   return tool.prepareInvocation(options, token);
  #| }
