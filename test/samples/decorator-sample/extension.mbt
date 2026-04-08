///|
/// MoonBit port of `decorator-sample`.
priv struct NumberMatch {
  start : Int
  end_ : Int
  value : String
}

priv struct DecoratorState {
  mut active_editor : @vscode.TextEditor?
  mut update_generation : Int
}

let decorator_state : DecoratorState = {
  active_editor: None,
  update_generation: 0,
}

fn find_number_matches(text : String) -> Array[NumberMatch] {
  let matches : Array[NumberMatch] = []
  let mut offset = 0
  let mut rest = text[:]
  let mut done = false

  while !done {
    lexmatch rest {
      ((".*?" as prefix) ("[[:digit:]]+" as value) (".*" as suffix)) => {
        let start = offset + prefix.length()
        let end_ = start + value.length()
        matches.push({
          start,
          end_,
          value: value.to_string(),
        })
        offset = end_
        rest = suffix
      }
      _ => done = true
    }
  }

  matches
}

fn log_console(message : String) -> Unit {
  ignore(message)
}

fn hover_message(value : String) -> @vscode.HoverMessage {
  @vscode.HoverMessage::Single(
    @vscode.MarkdownStringOrMarkedString::Markdown(
      @vscode.MarkdownString::new(value="Number **\{value}**"),
    ),
  )
}

fn update_decorations(
  small_type : @vscode.TextEditorDecorationType,
  large_type : @vscode.TextEditorDecorationType,
) -> Unit {
  match decorator_state.active_editor {
    None => ()
    Some(editor) => {
      let document = editor.document()
      let matches = find_number_matches(document.get_text())
      let small_numbers : Array[@vscode.DecorationOptions] = []
      let large_numbers : Array[@vscode.DecorationOptions] = []

      for number_match in matches {
        let start = document.position_at(number_match.start)
        let end_ = document.position_at(number_match.end_)
        let decoration = @vscode.DecorationOptions::new(
          @vscode.Range::new(start, end_),
          hover_message=hover_message(number_match.value),
        )
        if number_match.value.length() < 3 {
          small_numbers.push(decoration)
        } else {
          large_numbers.push(decoration)
        }
      }

      editor.set_decorations_options(small_type, small_numbers)
      editor.set_decorations_options(large_type, large_numbers)
    }
  }
}

fn trigger_update_decorations(
  small_type : @vscode.TextEditorDecorationType,
  large_type : @vscode.TextEditorDecorationType,
  throttle? : Bool = false,
) -> Unit {
  decorator_state.update_generation = decorator_state.update_generation + 1
  let update_generation = decorator_state.update_generation

  if throttle {
    let _ = @js_async.Promise::from_async(async fn() {
      @async.sleep(500)
      if update_generation == decorator_state.update_generation {
        update_decorations(small_type, large_type)
      }
    })
  } else {
    update_decorations(small_type, large_type)
  }
}

pub fn activate(context : @vscode.ExtensionContext) -> Unit {
  log_console("decorator sample is activated")
  let subscriptions = context.subscriptions()

  let small_type = @window.create_text_editor_decoration_type(
    @vscode.DecorationRenderOptions::new(
      border_width="1px",
      border_style="solid",
      overview_ruler_color=@vscode.ColorValue::Text("blue"),
      overview_ruler_lane=@vscode.OverviewRulerLane::Right,
      light=@vscode.ThemableDecorationRenderOptions::new(
        border_color=@vscode.ColorValue::Text("darkblue"),
      ),
      dark=@vscode.ThemableDecorationRenderOptions::new(
        border_color=@vscode.ColorValue::Text("lightblue"),
      ),
    ),
  )

  let large_type = @window.create_text_editor_decoration_type(
    @vscode.DecorationRenderOptions::new(
      cursor="crosshair",
      background_color=@vscode.ColorValue::Theme(
        @vscode.ThemeColor::new("myextension.largeNumberBackground"),
      ),
    ),
  )

  decorator_state.active_editor = @window.active_text_editor()
  match decorator_state.active_editor {
    None => ()
    Some(_) => trigger_update_decorations(small_type, large_type)
  }

  subscriptions.push(
    @window.on_did_change_active_text_editor().subscribe(fn(editor) {
      decorator_state.active_editor = editor
      match editor {
        None => ()
        Some(_) => trigger_update_decorations(small_type, large_type)
      }
    }),
  )

  subscriptions.push(
    @workspace.on_did_change_text_document().subscribe(fn(event) {
      match decorator_state.active_editor {
        None => ()
        Some(editor) =>
          if event.document.uri().to_string() == editor.document().uri().to_string() {
            trigger_update_decorations(small_type, large_type, throttle=true)
          }
      }
    }),
  )
}

pub fn deactivate() -> Unit {
  decorator_state.update_generation = decorator_state.update_generation + 1
}
