///|
/// MoonBit port of `chat-output-renderer-sample`.
fn create_mermaid_tool_result(markup : String) -> @lm.LanguageModelToolResult {
  @lm.LanguageModelToolResult::new([
    @lm.LanguageModelToolResultContentPart::text(
      @lm.LanguageModelTextPart::new(markup),
    ),
  ])
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let create_tool_handler : async (
    @lm.LanguageModelToolInvocationOptions,
    @vscode.CancellationToken,
  ) -> @lm.LanguageModelToolResult? = fn(options, _token) {
    let input : String = options.input()
    Some(
      create_mermaid_tool_result(
        "graph TD\nA[Start]-->B[\{input}]\nB-->C[Done]",
      ),
    )
  }

  let create_tool = @lm.LanguageModelTool::new(
    create_tool_handler,
  )
  subscriptions.push(@lm.register_tool("extSample_createMermaidDiagram", create_tool))

  let render_tool_handler : async (
    @lm.LanguageModelToolInvocationOptions,
    @vscode.CancellationToken,
  ) -> @lm.LanguageModelToolResult? = fn(options, _token) {
    let input : String = options.input()
    Some(create_mermaid_tool_result(input))
  }

  let render_tool = @lm.LanguageModelTool::new(
    render_tool_handler,
  )
  subscriptions.push(@lm.register_tool("extSample_renderMermaidDiagram", render_tool))

  let run = @commands.register_command_async(
    "moonbit.sample.chat-output-renderer-sample.run",
    async fn(_args) {
      ignore(
        @window.show_information_message(
          "Registered Mermaid chat tools for output rendering.",
        ),
      )
    },
  )
  subscriptions.push(run)
}

pub fn deactivate() -> Unit {
  ()
}
