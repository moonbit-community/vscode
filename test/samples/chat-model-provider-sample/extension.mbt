///|
/// MoonBit port of `chat-model-provider-sample`.
fn chat_model_info(id : String, name : String) -> @lm.LanguageModelChatInformation {
  @lm.LanguageModelChatInformation::new(
    id,
    name,
    "sample-family",
    "1.0.0",
    120000,
    8192,
    @lm.LanguageModelChatCapabilities::new(
      image_input=true,
      tool_calling=@lm.LanguageModelToolCalling::supported(true),
    ),
    tooltip="A sample chat model for demonstration purposes.",
  )
}

pub fn activate(context : @vscode.ExtensionContext) -> Unit {
  let subscriptions = context.subscriptions()

  let provide_information : async (
    @lm.PrepareLanguageModelChatModelOptions,
    @vscode.CancellationToken,
  ) -> Array[@lm.LanguageModelChatInformation]? = fn(_options, _token) {
    Some(
      [
        chat_model_info("sample-dog-model", "Dog Model"),
        chat_model_info("sample-cat-model", "Cat Model"),
      ],
    )
  }

  let provide_response : async (
    @lm.LanguageModelChatInformation,
    Array[@lm.LanguageModelChatRequestMessage],
    @lm.ProvideLanguageModelChatResponseOptions,
    @vscode.Progress[@lm.LanguageModelResponsePart],
    @vscode.CancellationToken,
  ) -> Unit = fn(model, _messages, _options, progress, _token) {
    let text = if model.id == "sample-dog-model" {
      "Woof! This is a dog model response."
    } else if model.id == "sample-cat-model" {
      "Meow! This is a cat model response."
    } else {
      "Unknown model."
    }
    progress.report(
      @lm.LanguageModelResponsePart::text(
        @lm.LanguageModelTextPart::new(text),
      ),
    )
  }

  let provide_token_count : async (
    @lm.LanguageModelChatInformation,
    @lm.LanguageModelTokenCountInput,
    @vscode.CancellationToken,
  ) -> Int = fn(_model, _text, _token) {
    42
  }

  let provider = @lm.LanguageModelChatProvider::new(
    provide_information,
    provide_response,
    provide_token_count,
  )

  subscriptions.push(@lm.register_language_model_chat_provider("sample", provider))
}

pub fn deactivate() -> Unit {
  ()
}
