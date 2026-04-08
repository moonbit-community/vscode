///|
/// MoonBit port of `lm-api-tutorial`.
let annotation_prompt =
  "You are a code tutor who helps students learn how to write better code. Your job is to evaluate a block of code that the user gives you. The user is writing You will then annotate any lines that could be improved with a brief suggestion and the reason why you are making that suggestion. Only make suggestions when you feel the severity is enough that it will impact the readibility and maintainability of the code. Be friendly with your suggestions and remember that these are students so they need gentle guidance. Format each suggestion as a single JSON object. It is not necessary to wrap your response in triple backticks. Here is an example of what your response should look like:\n\n{ \"line\": 1, \"suggestion\": \"I think you should use a for loop instead of a while loop. A for loop is more concise and easier to read.\" }{ \"line\": 12, \"suggestion\": \"I think you should use a for loop instead of a while loop. A for loop is more concise and easier to read.\" }\n"

priv struct Annotation {
  line : Int
  suggestion : String
}

fn has_closing_brace(value : String) -> Bool {
  value.find("}") is Some(_)
}

fn parse_annotation_json(value : String) -> Annotation? {
  try {
    let parsed = @json.parse(value)
    match parsed {
      { "line": line_json, "suggestion": suggestion_json, .. } =>
        Some({
          line: @json.from_json(line_json),
          suggestion: @json.from_json(suggestion_json),
        })
      _ => None
    }
  } catch {
    _ => None
  }
}

fn preview_suggestion(value : String) -> String {
  if value.length() > 25 {
    "\{value.unsafe_substring(start=0, end=25)}..."
  } else {
    value
  }
}

fn apply_decoration(
  editor : @vscode.TextEditor,
  line : Int,
  suggestion : String,
) -> Unit {
  let line_index = line - 1
  let document = editor.document()
  if line_index < 0 || line_index >= document.line_count() {
    return
  }

  let decoration_type = @window.create_text_editor_decoration_type(
    @vscode.DecorationRenderOptions::new(
      after=@vscode.ThemableDecorationAttachmentRenderOptions::new(
        content_text=" \{preview_suggestion(suggestion)}",
        color=@vscode.ColorValue::Text("grey"),
      ),
    ),
  )

  let line_length = document.line_at_line(line_index).text.length()
  let position = @vscode.Position::new(line_index, line_length)
  let range = @vscode.Range::new(position, position)
  let hover = @vscode.HoverMessage::Single(
    @vscode.MarkdownStringOrMarkedString::Markdown(
      @vscode.MarkdownString::new(value=suggestion),
    ),
  )
  let decoration = @vscode.DecorationOptions::new(range, hover_message=hover)
  editor.set_decorations_options(decoration_type, [decoration])
}

async fn parse_chat_response(
  chat_response : @lm.LanguageModelChatResponse,
  text_editor : @vscode.TextEditor,
) -> Unit {
  let iterator = chat_response.text.iterator()
  let mut accumulated_response = ""
  let mut done = false

  while !done {
    let next = iterator.next()
    if next.done() {
      done = true
    } else {
      let fragment = next.value()
      accumulated_response = "\{accumulated_response}\{fragment}"
      if has_closing_brace(fragment) {
        match parse_annotation_json(accumulated_response) {
          None => ()
          Some(annotation) => {
            apply_decoration(text_editor, annotation.line, annotation.suggestion)
            accumulated_response = ""
          }
        }
      }
    }
  }
}

fn visible_code_with_line_numbers(text_editor : @vscode.TextEditor) -> String {
  let visible_ranges = text_editor.visible_ranges()
  if visible_ranges.length() == 0 {
    return ""
  }

  let visible = visible_ranges[0]
  let mut current_line = visible.start().line()
  let end_line = visible.end().line()
  let document = text_editor.document()
  let lines : Array[String] = []

  while current_line < end_line {
    lines.push("\{current_line + 1}: \{document.line_at_line(current_line).text} ")
    current_line = current_line + 1
  }

  lines.join("\n")
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let annotate = @commands.register_text_editor_command_async(
    "code-tutor.annotate",
    async fn(text_editor, _edit_builder, _args) {
      let code_with_line_numbers = visible_code_with_line_numbers(text_editor)
      let models = @lm.select_chat_models(
        selector=@lm.LanguageModelChatSelector::new(
          vendor="copilot",
          family="gpt-4o",
        ),
      )
      match models {
        [model, ..] => {
          let messages = [
            @lm.LanguageModelChatMessage::user_text(annotation_prompt),
            @lm.LanguageModelChatMessage::user_text(code_with_line_numbers),
          ]
          let token_source = @vscode.CancellationTokenSource::new()
          let chat_response = model.send_request(messages, token=token_source.token())
          parse_chat_response(chat_response, text_editor)
          token_source.dispose()
        }
        _ => ()
      }
    },
  )
  subscriptions.push(annotate)
}

pub fn deactivate() -> Unit {
  ()
}
