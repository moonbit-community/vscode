///|
/// JS FFI bindings for VS Code chat namespace.

///|
extern "js" fn chat_available_ffi() -> Bool =
  #| () => {
  #|   const chat = require("vscode").chat;
  #|   return chat !== undefined && chat !== null && typeof chat.createChatParticipant === "function";
  #| }

///|
extern "js" fn chat_request_handler_ffi(
  handler : (ChatRequest, ChatContext, ChatResponseStream, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> ChatRequestHandler =
  #| (handler) => handler

///|
extern "js" fn chat_create_chat_participant_ffi(
  id : String,
  handler : ChatRequestHandler,
) -> ChatParticipant =
  #| (id, handler) => require("vscode").chat.createChatParticipant(id, handler)

///|
extern "js" fn chat_try_create_chat_participant_ffi(
  id : String,
  handler : ChatRequestHandler,
) -> @v.JsValue =
  #| (id, handler) => {
  #|   try {
  #|     return require("vscode").chat.createChatParticipant(id, handler);
  #|   } catch (_) {
  #|     return undefined;
  #|   }
  #| }

///|
extern "js" fn chat_register_chat_context_provider_ffi(
  selector : @v.JsValue,
  provider_id : String,
  provide_chat_context_for_resource : (Uri, CancellationToken) -> @v.JsValue,
  resolve_chat_context : @v.JsValue,
) -> &@vscode.Disposable =
  #| (selector, providerId, provideChatContextForResource, resolveChatContext) => {
  #|   const provider = {
  #|     provideChatContextForResource: (options, token) =>
  #|       Promise.resolve(provideChatContextForResource(options.resource, token)),
  #|   };
  #|   if (resolveChatContext !== undefined && resolveChatContext !== null) {
  #|     provider.resolveChatContext = (context, token) =>
  #|       Promise.resolve(resolveChatContext(context, token));
  #|   }
  #|   return require("vscode").chat.registerChatContextProvider(
  #|     selector,
  #|     providerId,
  #|     provider,
  #|   );
  #| }

///|
extern "js" fn chat_followup_provider_ffi(
  provide_followups : (ChatResult, ChatContext, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
) -> ChatFollowupProvider =
  #| (provideFollowups) => ({
  #|   provideFollowups: (result, context, token) => provideFollowups(result, context, token),
  #| })

///|
extern "js" fn chat_request_turn_ffi(
  prompt : String,
  participant : String,
  references : Array[ChatPromptReference],
  tool_references : Array[ChatLanguageModelToolReference],
  command : @v.JsValue,
) -> ChatRequestTurn =
  #| (prompt, participant, references, toolReferences, command) => {
  #|   const value = { prompt, participant, references, toolReferences };
  #|   if (command !== undefined && command !== null) {
  #|     value.command = command;
  #|   }
  #|   return value;
  #| }

///|
extern "js" fn chat_response_turn_ffi(
  response : Array[ChatResponsePart],
  result : ChatResult,
  participant : String,
  command : @v.JsValue,
) -> ChatResponseTurn =
  #| (response, result, participant, command) => {
  #|   const value = { response, result, participant };
  #|   if (command !== undefined && command !== null) {
  #|     value.command = command;
  #|   }
  #|   return value;
  #| }

///|
extern "js" fn chat_error_details_ffi(
  message : String,
  response_is_filtered : @v.JsValue,
) -> ChatErrorDetails =
  #| (message, responseIsFiltered) => {
  #|   const value = { message };
  #|   if (responseIsFiltered !== undefined && responseIsFiltered !== null) {
  #|     value.responseIsFiltered = responseIsFiltered;
  #|   }
  #|   return value;
  #| }

///|
extern "js" fn chat_result_ffi(
  error_details : @v.JsValue,
  metadata : @v.JsValue,
) -> ChatResult =
  #| (errorDetails, metadata) => {
  #|   const value = {};
  #|   if (errorDetails !== undefined && errorDetails !== null) {
  #|     value.errorDetails = errorDetails;
  #|   }
  #|   if (metadata !== undefined && metadata !== null) {
  #|     value.metadata = metadata;
  #|   }
  #|   return value;
  #| }

///|
extern "js" fn chat_followup_ffi(
  prompt : String,
  label : @v.JsValue,
  participant : @v.JsValue,
  command : @v.JsValue,
) -> ChatFollowup =
  #| (prompt, label, participant, command) => {
  #|   const value = { prompt };
  #|   if (label !== undefined && label !== null) {
  #|     value.label = label;
  #|   }
  #|   if (participant !== undefined && participant !== null) {
  #|     value.participant = participant;
  #|   }
  #|   if (command !== undefined && command !== null) {
  #|     value.command = command;
  #|   }
  #|   return value;
  #| }

///|
extern "js" fn chat_response_file_tree_ffi(
  name : String,
  children : @v.JsValue,
) -> ChatResponseFileTree =
  #| (name, children) => {
  #|   const value = { name };
  #|   if (children !== undefined && children !== null) {
  #|     value.children = children;
  #|   }
  #|   return value;
  #| }

///|
extern "js" fn chat_response_part_as_markdown_part_raw(
  part : ChatResponsePart,
) -> @v.JsValue =
  #| (part) =>
  #|   part instanceof require("vscode").ChatResponseMarkdownPart ? part : undefined
