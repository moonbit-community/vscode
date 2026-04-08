///|
/// MoonBit port of `chat-sample`.
fn is_ascii_upper(ch : Char) -> Bool {
  ch >= 'A' && ch <= 'Z'
}

fn is_ascii_lower(ch : Char) -> Bool {
  ch >= 'a' && ch <= 'z'
}

fn is_ascii_alpha(ch : Char) -> Bool {
  is_ascii_upper(ch) || is_ascii_lower(ch)
}

fn is_candidate_name(value : String) -> Bool {
  if value.length() < 3 {
    return false
  }

  let mut first = true
  for _, ch in value {
    if first {
      if !is_ascii_upper(ch) {
        return false
      }
      first = false
    } else if !is_ascii_lower(ch) {
      return false
    }
  }
  true
}

fn has_name(names : Array[String], value : String) -> Bool {
  for name in names {
    if name == value {
      return true
    }
  }
  false
}

fn consume_word(word : String, names : Array[String]) -> Unit {
  if is_candidate_name(word) && !has_name(names, word) {
    names.push(word)
  }
}

pub fn extract_names(text : String) -> Array[String] {
  let names : Array[String] = []
  let mut word = ""

  for _, ch in text {
    if is_ascii_alpha(ch) {
      word = "\{word}\{ch}"
    } else if word != "" {
      consume_word(word, names)
      word = ""
    }
  }

  if word != "" {
    consume_word(word, names)
  }

  names
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let participant_handler : async (
    @chat.ChatRequest,
    @chat.ChatContext,
    @chat.ChatResponseStream,
    @vscode.CancellationToken,
  ) -> @chat.ChatResult? = fn(request, _context, response, _token) {
    response.markdown(
      @chat.ChatMarkdownValue::text(
        "Meow! You asked: \{request.prompt}",
      ),
    )
    Some(@chat.ChatResult::new())
  }

  match @chat.try_create_chat_participant(
    "chat-sample.simple",
    participant_handler,
  ) {
    Some(participant) => subscriptions.push(participant.as_disposable())
    None => ()
  }

  let names = @commands.register_command_async(
    "cat.namesInEditor",
    async fn(_args) {
      match @window.active_text_editor() {
        None => ignore(@window.show_information_message("Open an editor first."))
        Some(editor) => {
          let found = extract_names(editor.document().get_text())
          if found.length() == 0 {
            ignore(@window.show_information_message("No candidate names found."))
          } else {
            let picked = @window.show_quick_pick_strings(
              found,
              options=@vscode.QuickPickOptions::new(place_holder="Pick a name"),
            )
            match picked {
              None => ()
              Some(value) =>
                ignore(@window.show_information_message("Selected: \{value}"))
            }
          }
        }
      }
    },
  )
  subscriptions.push(names)
}

pub fn deactivate() -> Unit {
  ()
}
