///|
/// MoonBit port of `chat-tutorial`.
let base_prompt =
  "You are a helpful code tutor. Your job is to teach the user with simple descriptions and sample code of the concept. Respond with a guided overview of the concept in a series of messages. Do not give the user the answer directly, but guide them to find the answer themselves. If the user asks a non-programming question, politely decline to respond."

let exercises_prompt =
  "You are a helpful tutor. Your job is to teach the user with fun, simple exercises that they can complete in the editor. Your exercises should start simple and get more complex as the user progresses. Move one concept at a time, and do not move on to the next concept until the user provides the correct answer. Give hints in your exercises to help the user learn. If the user is stuck, you can provide the answer and explain why it is the answer. If the user asks a non-programming question, politely decline to respond."

fn response_turn_markdown(turn : @chat.ChatResponseTurn) -> String {
  let full = StringBuilder::new()
  for part in turn.response() {
    match part.as_markdown_part() {
      None => ()
      Some(markdown_part) => full.write_string(markdown_part.value().value())
    }
  }
  full.to_string()
}

async fn stream_model_response(
  response : @lm.LanguageModelChatResponse,
  stream : @chat.ChatResponseStream,
) -> Unit {
  let iterator = response.text.iterator()
  let mut done = false
  while !done {
    let next = iterator.next()
    if next.done() {
      done = true
    } else {
      stream.markdown(@chat.ChatMarkdownValue::text(next.value()))
    }
  }
}

pub fn activate(context : @vscode.ExtensionContext) -> Unit {
  let subscriptions = context.subscriptions()

  let tutor = @chat.create_chat_participant(
    "chat-tutorial.code-tutor",
    async fn(request, chat_context, stream, token) {
      let mut prompt = base_prompt
      match request.command {
        Some("exercise") => prompt = exercises_prompt
        _ => ()
      }

      let messages = [
        @lm.LanguageModelChatMessage::user_text(prompt),
      ]

      for turn in chat_context.history {
        match turn.as_response_turn() {
          None => ()
          Some(response_turn) => {
            let full_message = response_turn_markdown(response_turn)
            messages.push(@lm.LanguageModelChatMessage::assistant_text(full_message))
          }
        }
      }

      messages.push(@lm.LanguageModelChatMessage::user_text(request.prompt))
      let response = request.model.send_request(messages, token=token)
      stream_model_response(response, stream)
      None
    },
  )
  tutor.icon_path = Some(@vscode.IconPath::UriValue(
      @vscode.Uri::join_path(context.extension_uri(), ["tutor.jpeg"]),
    ))
  subscriptions.push(tutor.as_disposable())
}

pub fn deactivate() -> Unit {
  ()
}
