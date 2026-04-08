///|
/// JS FFI bindings for VS Code lm namespace.

///|
#external
priv type Uint8Array

///|
extern "js" fn lm_available_ffi() -> Bool =
  #| () => {
  #|   const lm = require("vscode").lm;
  #|   return lm !== undefined && lm !== null && typeof lm.selectChatModels === "function";
  #| }

///|
extern "js" fn lm_on_did_change_chat_models_ffi() -> Event[Unit] =
  #| () => require("vscode").lm.onDidChangeChatModels

///|
extern "js" fn lm_select_chat_models_ffi(
  selector : @v.JsValue,
) -> @js_async.Promise[Array[LanguageModelChat]] =
  #| (selector) => {
  #|   const lm = require("vscode").lm;
  #|   return selector === undefined || selector === null
  #|     ? lm.selectChatModels()
  #|     : lm.selectChatModels(selector);
  #| }

///|
extern "js" fn lm_try_select_chat_models_ffi(
  selector : @v.JsValue,
) -> @js_async.Promise[@v.JsValue] =
  #| async (selector) => {
  #|   try {
  #|     const lm = require("vscode").lm;
  #|     return selector === undefined || selector === null
  #|       ? await lm.selectChatModels()
  #|       : await lm.selectChatModels(selector);
  #|   } catch (_) {
  #|     return undefined;
  #|   }
  #| }

///|
extern "js" fn lm_register_tool_ffi(
  name : String,
  tool : LanguageModelTool,
) -> &@vscode.Disposable =
  #| (name, tool) => require("vscode").lm.registerTool(name, tool)

///|
extern "js" fn lm_tools_ffi() -> Array[LanguageModelToolInformation] =
  #| () => {
  #|   const tools = require("vscode").lm.tools;
  #|   return Array.isArray(tools) ? tools : [];
  #| }

///|
extern "js" fn lm_invoke_tool_ffi(
  name : String,
  options : LanguageModelToolInvocationOptions,
  token : @v.JsValue,
) -> @js_async.Promise[LanguageModelToolResult] =
  #| (name, options, token) => {
  #|   const lm = require("vscode").lm;
  #|   return token === undefined || token === null
  #|     ? lm.invokeTool(name, options)
  #|     : lm.invokeTool(name, options, token);
  #| }

///|
extern "js" fn lm_register_mcp_server_definition_provider_ffi(
  id : String,
  provider : McpServerDefinitionProvider,
) -> &@vscode.Disposable =
  #| (id, provider) => require("vscode").lm.registerMcpServerDefinitionProvider(id, provider)

///|
extern "js" fn lm_register_language_model_chat_provider_ffi(
  vendor : String,
  provider : LanguageModelChatProvider,
) -> &@vscode.Disposable =
  #| (vendor, provider) => require("vscode").lm.registerLanguageModelChatProvider(vendor, provider)

///|
extern "js" fn lm_language_model_chat_selector_ffi(
  vendor : @v.JsValue,
  family : @v.JsValue,
  version : @v.JsValue,
  id : @v.JsValue,
) -> LanguageModelChatSelector =
  #| (vendor, family, version, id) => {
  #|   const selector = {};
  #|   if (vendor !== undefined && vendor !== null) selector.vendor = vendor;
  #|   if (family !== undefined && family !== null) selector.family = family;
  #|   if (version !== undefined && version !== null) selector.version = version;
  #|   if (id !== undefined && id !== null) selector.id = id;
  #|   return selector;
  #| }

///|
extern "js" fn lm_language_model_chat_request_options_ffi(
  justification : @v.JsValue,
  model_options : @v.JsValue,
  tools : @v.JsValue,
  tool_mode : @v.JsValue,
) -> LanguageModelChatRequestOptions =
  #| (justification, modelOptions, tools, toolMode) => {
  #|   const options = {};
  #|   if (justification !== undefined && justification !== null) {
  #|     options.justification = justification;
  #|   }
  #|   if (modelOptions !== undefined && modelOptions !== null) {
  #|     options.modelOptions = modelOptions;
  #|   }
  #|   if (tools !== undefined && tools !== null) {
  #|     options.tools = tools;
  #|   }
  #|   if (toolMode !== undefined && toolMode !== null) {
  #|     options.toolMode = toolMode;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn lm_language_model_chat_tool_ffi(
  name : String,
  description : String,
  input_schema : @v.JsValue,
) -> LanguageModelChatTool =
  #| (name, description, inputSchema) => {
  #|   const tool = { name, description };
  #|   if (inputSchema !== undefined && inputSchema !== null) {
  #|     tool.inputSchema = inputSchema;
  #|   }
  #|   return tool;
  #| }

///|
extern "js" fn lm_language_model_tool_invocation_options_ffi(
  tool_invocation_token : @v.JsValue,
  input : @v.JsValue,
  tokenization_options : @v.JsValue,
) -> LanguageModelToolInvocationOptions =
  #| (toolInvocationToken, input, tokenizationOptions) => {
  #|   const options = { toolInvocationToken, input };
  #|   if (tokenizationOptions !== undefined && tokenizationOptions !== null) {
  #|     options.tokenizationOptions = tokenizationOptions;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn lm_language_model_tool_tokenization_options_ffi(
  token_budget : Int,
  count_tokens : (String, @v.JsValue) -> @js_async.Promise[Int],
) -> LanguageModelToolTokenizationOptions =
  #| (tokenBudget, countTokens) => ({
  #|   tokenBudget,
  #|   countTokens: (text, token) => countTokens(text, token),
  #| })

///|
extern "js" fn lm_language_model_tool_invocation_prepare_options_ffi(
  input : @v.JsValue,
) -> LanguageModelToolInvocationPrepareOptions =
  #| (input) => ({ input })

///|
extern "js" fn lm_language_model_tool_ffi(
  invoke : (LanguageModelToolInvocationOptions, CancellationToken) -> @js_async.Promise[
    @v.JsValue,
  ],
  prepare_invocation : @v.JsValue,
) -> LanguageModelTool =
  #| (invoke, prepareInvocation) => {
  #|   const tool = {
  #|     invoke: (options, token) => invoke(options, token),
  #|   };
  #|   if (prepareInvocation !== undefined && prepareInvocation !== null) {
  #|     tool.prepareInvocation = (options, token) => prepareInvocation(options, token);
  #|   }
  #|   return tool;
  #| }

///|
extern "js" fn lm_language_model_tool_confirmation_messages_ffi(
  title : String,
  message : LanguageModelConfirmationMessageValue,
) -> LanguageModelToolConfirmationMessages =
  #| (title, message) => ({ title, message })

///|
extern "js" fn lm_prepared_tool_invocation_ffi(
  invocation_message : @v.JsValue,
  confirmation_messages : @v.JsValue,
) -> PreparedToolInvocation =
  #| (invocationMessage, confirmationMessages) => {
  #|   const value = {};
  #|   if (invocationMessage !== undefined && invocationMessage !== null) {
  #|     value.invocationMessage = invocationMessage;
  #|   }
  #|   if (confirmationMessages !== undefined && confirmationMessages !== null) {
  #|     value.confirmationMessages = confirmationMessages;
  #|   }
  #|   return value;
  #| }

///|
extern "js" fn lm_mcp_stdio_server_definition_ffi(
  label : String,
  command : String,
  args : @v.JsValue,
  env_entries : @v.JsValue,
  version : @v.JsValue,
) -> McpStdioServerDefinition =
  #| (label, command, args, envEntries, version) => {
  #|   const actualArgs = args === undefined || args === null ? undefined : args;
  #|   let env = undefined;
  #|   if (envEntries !== undefined && envEntries !== null) {
  #|     env = {};
  #|     for (const entry of envEntries) {
  #|       const key = Array.isArray(entry) ? entry[0] : entry._0;
  #|       const rawValue = Array.isArray(entry) ? entry[1] : entry._1;
  #|       let value = rawValue;
  #|       if (rawValue === undefined || rawValue === null) {
  #|         value = null;
  #|       } else if (typeof rawValue === "object" && rawValue.$tag === 0) {
  #|         value = null;
  #|       } else if (typeof rawValue === "object" && rawValue.$tag === 1) {
  #|         value = rawValue._0;
  #|       }
  #|       env[key] = value;
  #|     }
  #|   }
  #|   const actualVersion = version === undefined || version === null ? undefined : version;
  #|   return new (require("vscode").McpStdioServerDefinition)(label, command, actualArgs, env, actualVersion);
  #| }

///|
extern "js" fn lm_mcp_http_server_definition_ffi(
  label : String,
  uri : Uri,
  headers_entries : @v.JsValue,
  version : @v.JsValue,
) -> McpHttpServerDefinition =
  #| (label, uri, headersEntries, version) => {
  #|   let headers = undefined;
  #|   if (headersEntries !== undefined && headersEntries !== null) {
  #|     headers = {};
  #|     for (const entry of headersEntries) {
  #|       const key = Array.isArray(entry) ? entry[0] : entry._0;
  #|       const value = Array.isArray(entry) ? entry[1] : entry._1;
  #|       headers[key] = value;
  #|     }
  #|   }
  #|   const actualVersion = version === undefined || version === null ? undefined : version;
  #|   return new (require("vscode").McpHttpServerDefinition)(label, uri, headers, actualVersion);
  #| }

///|
extern "js" fn lm_mcp_server_definition_provider_ffi(
  on_did_change : @v.JsValue,
  provide : (CancellationToken) -> @js_async.Promise[@v.JsValue],
  resolve : @v.JsValue,
) -> McpServerDefinitionProvider =
  #| (onDidChange, provide, resolve) => {
  #|   const provider = {
  #|     provideMcpServerDefinitions: (token) => provide(token),
  #|   };
  #|   if (onDidChange !== undefined && onDidChange !== null) {
  #|     provider.onDidChangeMcpServerDefinitions = onDidChange;
  #|   }
  #|   if (resolve !== undefined && resolve !== null) {
  #|     provider.resolveMcpServerDefinition = (server, token) => resolve(server, token);
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn lm_language_model_chat_provider_ffi(
  on_did_change : @v.JsValue,
  provide_information : (
    PrepareLanguageModelChatModelOptions,
    CancellationToken,
  ) -> @js_async.Promise[@v.JsValue],
  provide_response : (
    LanguageModelChatInformation,
    Array[LanguageModelChatRequestMessage],
    ProvideLanguageModelChatResponseOptions,
    Progress[LanguageModelResponsePart],
    CancellationToken,
  ) -> @js_async.Promise[Unit],
  provide_token_count : (
    LanguageModelChatInformation,
    @v.JsValue,
    CancellationToken,
  ) -> @js_async.Promise[Int],
) -> LanguageModelChatProvider =
  #| (onDidChange, provideInformation, provideResponse, provideTokenCount) => {
  #|   const provider = {
  #|     provideLanguageModelChatInformation: (options, token) => provideInformation(options, token),
  #|     provideLanguageModelChatResponse: (model, messages, options, progress, token) =>
  #|       provideResponse(model, messages, options, progress, token),
  #|     provideTokenCount: (model, text, token) => provideTokenCount(model, text, token),
  #|   };
  #|   if (onDidChange !== undefined && onDidChange !== null) {
  #|     provider.onDidChangeLanguageModelChatInformation = onDidChange;
  #|   }
  #|   return provider;
  #| }

///|
extern "js" fn lm_language_model_chat_capabilities_ffi(
  image_input : @v.JsValue,
  tool_calling : @v.JsValue,
) -> LanguageModelChatCapabilities =
  #| (imageInput, toolCalling) => {
  #|   const value = {};
  #|   if (imageInput !== undefined && imageInput !== null) {
  #|     value.imageInput = imageInput;
  #|   }
  #|   if (toolCalling !== undefined && toolCalling !== null) {
  #|     value.toolCalling = toolCalling;
  #|   }
  #|   return value;
  #| }

///|
extern "js" fn lm_language_model_chat_information_ffi(
  id : String,
  name : String,
  family : String,
  version : String,
  max_input_tokens : Int,
  max_output_tokens : Int,
  capabilities : LanguageModelChatCapabilities,
  tooltip : @v.JsValue,
  detail : @v.JsValue,
) -> LanguageModelChatInformation =
  #| (id, name, family, version, maxInputTokens, maxOutputTokens, capabilities, tooltip, detail) => {
  #|   const value = {
  #|     id,
  #|     name,
  #|     family,
  #|     version,
  #|     maxInputTokens,
  #|     maxOutputTokens,
  #|     capabilities,
  #|   };
  #|   if (tooltip !== undefined && tooltip !== null) {
  #|     value.tooltip = tooltip;
  #|   }
  #|   if (detail !== undefined && detail !== null) {
  #|     value.detail = detail;
  #|   }
  #|   return value;
  #| }

///|
extern "js" fn lm_provide_language_model_chat_response_options_ffi(
  model_options : @v.JsValue,
  tools : @v.JsValue,
  tool_mode : LanguageModelChatToolMode,
) -> ProvideLanguageModelChatResponseOptions =
  #| (modelOptions, tools, toolMode) => {
  #|   const value = { toolMode };
  #|   if (modelOptions !== undefined && modelOptions !== null) {
  #|     value.modelOptions = modelOptions;
  #|   }
  #|   if (tools !== undefined && tools !== null) {
  #|     value.tools = tools;
  #|   }
  #|   return value;
  #| }

///|
extern "js" fn lm_language_model_chat_request_message_ffi(
  role : LanguageModelChatMessageRole,
  content : Array[LanguageModelInputPart],
  name : @v.JsValue,
) -> LanguageModelChatRequestMessage =
  #| (role, content, name) => ({
  #|   role,
  #|   content,
  #|   name: name === undefined || name === null ? undefined : name,
  #| })

///|
extern "js" fn lm_extension_context_language_model_access_information_ffi(
  ctx : ExtensionContext,
) -> LanguageModelAccessInformation =
  #| (ctx) => ctx.languageModelAccessInformation
