///|
/// JS entrypoint for lm namespace binding checks.

///|
fn fixture_root() -> @vscode.Uri {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => folder.uri()
    _ => @vscode.Uri::file("/tmp/moonbit-lm-fixture")
  }
}

///|
fn fixture_uri(root : @vscode.Uri, name : String) -> @vscode.Uri {
  @vscode.Uri::join_path(root, [name])
}

///|
async fn write_result(
  root : @vscode.Uri,
  name : String,
  content : String,
) -> Unit {
  let fs = @workspace.fs()
  fs.write_file(fixture_uri(root, name), @workspace.encode(content))
}

///|
fn role_to_string(value : @lm.LanguageModelChatMessageRole) -> String {
  match value {
    @lm.LanguageModelChatMessageRole::User => "user"
    @lm.LanguageModelChatMessageRole::Assistant => "assistant"
  }
}

///|
async fn run_check_lm_inner(
  ctx : @vscode.ExtensionContext,
  root : @vscode.Uri,
) -> Unit {
  let is_available = @lm.available()
  if !is_available {
    write_result(root, "lm-result.txt", "lm ok available=false")
  } else {
    let event_disposable = @lm.on_did_change_chat_models().subscribe(_ => ())
    event_disposable.dispose()

    let selector = @lm.LanguageModelChatSelector::new()
    let selector_vendor = match selector.vendor {
      None => "none"
      Some(value) => value
    }
    if false {
      ignore(@lm.select_chat_models(selector=selector))
      ignore(@lm.try_select_chat_models(selector=selector))
    } else {
      ()
    }
    let selected_models : Array[@lm.LanguageModelChat] = []
    let try_selected_models = "skipped_model_selection"

    let access_info = @lm.extension_context_language_model_access_information(
      ctx,
    )
    let access_event = access_info.on_did_change.subscribe(_ => ())
    access_event.dispose()
    let model_count = selected_models.length()
    let model_id = match selected_models {
      [model, ..] => model.id
      [] => "none"
    }
    let can_send = match selected_models {
      [model, ..] => match access_info.can_send_request(model) {
        Some(value) => "\{value}"
        None => "none"
      }
      [] => "none"
    }

    let chat_tool = @lm.LanguageModelChatTool::new(
      "moonbit.lm.tool",
      "MoonBit test tool",
      input_schema=@vscode.Any::from("schema"),
    )
    let request_options = @lm.LanguageModelChatRequestOptions::new(
      justification="MoonBit LM binding test",
      model_options=@vscode.Any::from("model-options"),
      tools=[chat_tool],
      tool_mode=@lm.LanguageModelChatToolMode::Auto,
    )
    let request_tool_mode = match request_options.tool_mode {
      Some(@lm.LanguageModelChatToolMode::Auto) => "auto"
      Some(@lm.LanguageModelChatToolMode::Required) => "required"
      None => "none"
    }

    let text_part = @lm.LanguageModelTextPart::new("moonbit-text")
    let prompt_part = @lm.LanguageModelPromptTsxPart::new(
      @vscode.Any::from("prompt"),
    )
    let data_part = @lm.LanguageModelDataPart::text("moonbit-data")
    let tool_result = @lm.LanguageModelToolResult::new([
      @lm.LanguageModelToolResultContentPart::text(text_part),
      @lm.LanguageModelToolResultContentPart::prompt_tsx(prompt_part),
      @lm.LanguageModelToolResultContentPart::data(data_part),
    ])

    let tool_call_part = @lm.LanguageModelToolCallPart::new(
      "call-1",
      "moonbit.lm.tool",
      @vscode.Any::from("payload"),
    )
    let tool_result_part = @lm.LanguageModelToolResultPart::new(
      "call-1",
      [@lm.LanguageModelToolResultContentPart::text(text_part)],
    )

    let user_message = @lm.LanguageModelChatMessage::user_parts(
      [
        @lm.LanguageModelInputPart::text(text_part),
        @lm.LanguageModelInputPart::tool_result(tool_result_part),
        @lm.LanguageModelInputPart::data(data_part),
      ],
      name="MoonBit User",
    )
    let assistant_message = @lm.LanguageModelChatMessage::assistant_parts(
      [
        @lm.LanguageModelInputPart::tool_call(tool_call_part),
        @lm.LanguageModelInputPart::text(text_part),
      ],
      name="MoonBit Assistant",
    )

    let tokenization_options = @lm.LanguageModelToolTokenizationOptions::new(
      128,
      fn(text, _token) {
        text.length()
      },
    )
    let token_count = tokenization_options.token_budget

    let invocation_options = @lm.LanguageModelToolInvocationOptions::new(
      "payload",
      tokenization_options=tokenization_options,
    )
    let prepare_options = @lm.LanguageModelToolInvocationPrepareOptions::new(
      "payload",
    )

    let tool = @lm.LanguageModelTool::new(
      fn(options, _token) {
        let input : String = options.input()
        Some(
          @lm.LanguageModelToolResult::new([
            @lm.LanguageModelToolResultContentPart::text(
              @lm.LanguageModelTextPart::new("tool-response:\{input}"),
            ),
          ]),
        )
      },
      prepare_invocation=fn(_options, _token) {
        Some(
          @lm.PreparedToolInvocation::new(
            invocation_message=@lm.LanguageModelConfirmationMessageValue::text(
              "Preparing tool invocation",
            ),
          ),
        )
      },
    )

    ignore(invocation_options)
    ignore(prepare_options)
    ignore(tool)
    let invocation_state = "not-run"
    let prepared_state = "not-run"

    let capabilities = @lm.LanguageModelChatCapabilities::new(
      image_input=true,
      tool_calling=@lm.LanguageModelToolCalling::supported(true),
    )
    let info = @lm.LanguageModelChatInformation::new(
      "moonbit-model",
      "MoonBit Model",
      "moonbit-family",
      "1.0",
      4096,
      1024,
      capabilities,
      tooltip="MoonBit LM",
      detail="detail",
    )

    let request_message = @lm.LanguageModelChatRequestMessage::new(
      @lm.LanguageModelChatMessageRole::User,
      [@lm.LanguageModelInputPart::text(text_part)],
      name="MoonBit Request",
    )
    let provide_options = @lm.ProvideLanguageModelChatResponseOptions::new(
      @lm.LanguageModelChatToolMode::Auto,
      model_options=@vscode.Any::from("provider-model-options"),
      tools=[chat_tool],
    )

    let chat_provider = @lm.LanguageModelChatProvider::new(
      fn(_options, _token) {
        Some([info])
      },
      fn(_model, _messages, _options, progress, _token) {
        progress.report(
          @lm.LanguageModelResponsePart::text(
            @lm.LanguageModelTextPart::new("provider-response"),
          ),
        )
      },
      fn(_model, _text, _token) {
        1
      },
    )
    ignore(chat_provider)

    let stdio_server = @lm.McpStdioServerDefinition::new(
      "MoonBit MCP Stdio",
      "echo",
      args=["moonbit"],
      env_entries=[("MOONBIT_TEST", Some(@vscode.Any::from("1")))],
      version="1.0",
    )
    let http_server = @lm.McpHttpServerDefinition::new(
      "MoonBit MCP HTTP",
      root,
      headers=[("x-moonbit", "true")],
      version="1.0",
    )

    let mcp_provider = @lm.McpServerDefinitionProvider::new(fn(_token) {
      Some([
        @lm.McpServerDefinition::from_stdio(stdio_server),
        @lm.McpServerDefinition::from_http(http_server),
      ])
    })
    if false {
      let mcp_registration = @lm.register_mcp_server_definition_provider(
        "moonbit.lm.mcp",
        mcp_provider,
      )
      mcp_registration.dispose()
      let chat_registration = @lm.register_language_model_chat_provider(
        "moonbit",
        chat_provider,
      )
      chat_registration.dispose()
      let tool_registration = @lm.register_tool("moonbit.lm.tool", tool)
      tool_registration.dispose()
      let invoke_registration = @lm.register_tool("moonbit.lm.invoke", tool)
      ignore(@lm.invoke_tool("moonbit.lm.invoke", invocation_options))
      invoke_registration.dispose()
    } else {
      ()
    }
    let mcp_provider_state = "skipped_runtime_registration"
    let chat_provider_state = "skipped_runtime_registration"
    let tool_registration_state = "skipped_runtime_registration"
    let invoke_tool_state = "skipped_runtime_registration"

    let tool_infos_count = @lm.tools().length()
    let error_code = @lm.LanguageModelError::not_found(
      message="missing-model",
    ).code()
    let provide_tool_mode = match provide_options.tool_mode {
      @lm.LanguageModelChatToolMode::Auto => "auto"
      @lm.LanguageModelChatToolMode::Required => "required"
    }
    let user_name = match user_message.name() {
      None => "none"
      Some(value) => value
    }
    let assistant_name = match assistant_message.name() {
      None => "none"
      Some(value) => value
    }
    let request_role = role_to_string(request_message.role)

    write_result(
      root,
      "lm-result.txt",
      "lm ok available=true models=\{model_count} try_models=\{try_selected_models} model_id=\{model_id} can_send=\{can_send} selector_vendor=\{selector_vendor} request_mode=\{request_tool_mode} token_count=\{token_count} invocation=\{invocation_state} prepared=\{prepared_state} tool_infos=\{tool_infos_count} tool_registration=\{tool_registration_state} invoke_tool=\{invoke_tool_state} chat_provider=\{chat_provider_state} mcp_provider=\{mcp_provider_state} info_name=\{info.name} request_role=\{request_role} provide_tool_mode=\{provide_tool_mode} user_name=\{user_name} assistant_name=\{assistant_name} tool_content=\{tool_result.content().length()} error_code=\{error_code} stdio_label=\{stdio_server.label()} http_label=\{http_server.label()}",
    )
  }
}

///|
async fn run_check_lm(
  ctx : @vscode.ExtensionContext,
  root : @vscode.Uri,
) -> Unit {
  try run_check_lm_inner(ctx, root) catch {
    err => {
      write_result(root, "lm-result.txt", "lm ok available=error err=\{err}")
    }
  }
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "moonbit.lm.checkBindings",
    async fn(_args) {
      run_check_lm(ctx, fixture_root())
    },
  )
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
