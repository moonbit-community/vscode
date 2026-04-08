///|
pub struct Controller {
  mut current_mode : Mode
  mut current_input : String
  motion_state : MotionState
  mut is_visual : Bool
  mut delete_register : DeleteRegister?
  mut is_in_composition : Bool
  mut composing_text : String
}

///|
pub fn Controller::new() -> Controller {
  Controller::{
    current_mode: Mode::Normal,
    current_input: "",
    motion_state: MotionState::new(),
    is_visual: false,
    delete_register: None,
    is_in_composition: false,
    composing_text: "",
  }
}

///|
pub fn Controller::set_word_separators(
  self : Controller,
  word_separators : String,
) -> Unit {
  self.motion_state.word_character_class = create_word_characters(
    word_separators,
  )
}

///|
pub fn Controller::find_motion(self : Controller, input : String) -> Motion? {
  let _ = self
  find_motion(input)
}

///|
pub fn Controller::is_motion_prefix(self : Controller, input : String) -> Bool {
  let _ = self
  is_motion_prefix(input)
}

///|
pub fn Controller::ensure_normal_mode_position(
  self : Controller,
  editor : @vscode.TextEditor,
) -> Unit {
  if self.current_mode != Mode::Normal || self.is_visual {
    return
  }
  let current_selection = editor.selection()
  let pos = current_selection.active()
  let line_content = editor.document().line_at_line(pos.line()).text
  if line_content.length() == 0 {
    return
  }
  let max_character = line_content.length() - 1
  if pos.character() > max_character {
    let selection = @vscode.Selection::from_numbers(
      pos.line(),
      max_character,
      pos.line(),
      max_character,
    )
    editor.set_selection(selection)
    editor.reveal_range(
      @vscode.Range::new(selection.anchor(), selection.active()),
      reveal_type=@vscode.TextEditorRevealType::Default,
    )
  }
}

///|
pub fn Controller::has_input(self : Controller) -> Bool {
  self.current_input.length() > 0
}

///|
pub fn Controller::clear_input(self : Controller) -> Unit {
  self.current_input = ""
}

///|
pub fn Controller::get_mode(self : Controller) -> Mode {
  self.current_mode
}

///|
pub fn Controller::set_mode(self : Controller, new_mode : Mode) -> Unit {
  if new_mode != self.current_mode {
    self.current_mode = new_mode
    self.motion_state.cursor_desired_character = -1
    self.current_input = ""
  }
}

///|
pub fn Controller::set_visual(self : Controller, new_visual : Bool) -> Unit {
  self.is_visual = new_visual
}

///|
pub fn Controller::get_visual(self : Controller) -> Bool {
  self.is_visual
}

///|
fn input_has_replace_prefix(input : String) -> Bool {
  let mut index = 0
  if input.length() > 0 &&
    input[0].to_int() >= '1'.to_int() &&
    input[0].to_int() <= '9'.to_int() {
    index = 1
    while index < input.length() &&
          input[index].to_int() >= '0'.to_int() &&
          input[index].to_int() <= '9'.to_int() {
      index += 1
    }
  }
  if index < input.length() {
    let ch = input[index].to_int()
    ch == 'r'.to_int() || ch == 'c'.to_int()
  } else {
    false
  }
}

///|
pub fn Controller::get_cursor_style(
  self : Controller,
) -> @vscode.TextEditorCursorStyle {
  if self.current_mode == Mode::Normal {
    if input_has_replace_prefix(self.current_input) {
      return @vscode.TextEditorCursorStyle::Underline
    }
    return @vscode.TextEditorCursorStyle::Block
  }
  if self.current_mode == Mode::Replace {
    @vscode.TextEditorCursorStyle::Underline
  } else {
    @vscode.TextEditorCursorStyle::Line
  }
}

///|
fn Controller::mode_label(self : Controller) -> String {
  if self.current_mode == Mode::Normal {
    if self.is_visual {
      "-- VISUAL --"
    } else {
      "-- NORMAL --"
    }
  } else if self.current_mode == Mode::Replace {
    if self.is_visual {
      "-- (replace) VISUAL --"
    } else {
      "-- REPLACE --"
    }
  } else if self.is_visual {
    "-- (insert) VISUAL --"
  } else {
    "-- INSERT --"
  }
}

///|
pub fn Controller::get_status_text(self : Controller) -> String {
  let label = self.mode_label()
  if self.current_input.length() > 0 {
    "VIM:> \{label} >\{self.current_input}"
  } else {
    "VIM:> \{label}"
  }
}

///|
pub fn Controller::composition_start(
  self : Controller,
  editor : @vscode.TextEditor,
) -> Unit {
  let _ = editor
  self.is_in_composition = true
  self.composing_text = ""
}

///|
pub async fn Controller::composition_end(
  self : Controller,
  editor : @vscode.TextEditor,
) -> TypeResult {
  self.is_in_composition = false
  let text = self.composing_text
  self.composing_text = ""
  if text.length() == 0 {
    return type_result(true)
  }
  self.handle_type(editor, text, no_modifier_keys())
}

///|
pub async fn Controller::handle_type(
  self : Controller,
  editor : @vscode.TextEditor,
  text : String,
  modifier_keys : ModifierKeys,
) -> TypeResult {
  if self.current_mode != Mode::Normal && self.current_mode != Mode::Replace {
    return type_result(false)
  }
  if self.is_in_composition {
    self.composing_text = self.composing_text + text
    return type_result(true)
  }
  if self.current_mode == Mode::Replace {
    let pos = editor.selection().active()
    ignore(
      editor.edit(edit => {
        edit.replace_range(
          @vscode.Range::from_numbers(
            pos.line(),
            pos.character(),
            pos.line(),
            pos.character() + 1,
          ),
          text,
        )
      }),
    )
    let next_selection = @vscode.Selection::from_numbers(
      pos.line(),
      pos.character() + 1,
      pos.line(),
      pos.character() + 1,
    )
    editor.set_selection(next_selection)
    editor.reveal_range(
      @vscode.Range::new(next_selection.anchor(), next_selection.active()),
      reveal_type=@vscode.TextEditorRevealType::Default,
    )
    return type_result(true)
  }
  self.current_input = self.current_input + text
  self.interpret_normal_mode_input(editor, modifier_keys)
}

///|
pub async fn Controller::replace_prev_char(
  self : Controller,
  editor : @vscode.TextEditor,
  text : String,
  replace_char_cnt : Int,
) -> Bool {
  if self.current_mode != Mode::Normal && self.current_mode != Mode::Replace {
    return false
  }
  if self.is_in_composition {
    let keep_len = self.composing_text.length() - replace_char_cnt
    let keep_prefix = if keep_len <= 0 {
      ""
    } else {
      self.composing_text[:keep_len].to_string()
    }
    self.composing_text = keep_prefix + text
    return true
  }
  if self.current_mode == Mode::Replace {
    let pos = editor.selection().active()
    ignore(
      editor.edit(edit => {
        edit.replace_range(
          @vscode.Range::from_numbers(
            pos.line(),
            pos.character() - replace_char_cnt,
            pos.line(),
            pos.character(),
          ),
          text,
        )
      }),
    )
    return true
  }
  true
}

///|
async fn Controller::interpret_normal_mode_input(
  self : Controller,
  editor : @vscode.TextEditor,
  modifier_keys : ModifierKeys,
) -> TypeResult {
  if self.current_input.length() > 0 &&
    self.current_input[0].to_int() == ':'.to_int() {
    let value = @window.show_input_box(
      options=@vscode.InputBoxOptions::new(value="tabm"),
    )
    let resolved_input = match value {
      Some(value) => value
      None => ""
    }
    self.find_mapping(resolved_input, editor, modifier_keys)
  } else {
    self.find_mapping(self.current_input, editor, modifier_keys)
  }
}

///|
async fn Controller::find_mapping(
  self : Controller,
  input : String,
  editor : @vscode.TextEditor,
  modifier_keys : ModifierKeys,
) -> TypeResult {
  match find_command(input, modifier_keys) {
    Some(command) => {
      self.current_input = ""
      return type_result(true, execute_editor_command=command)
    }
    None => ()
  }

  match find_operator(input, modifier_keys) {
    Some(found) => {
      let completed = if self.is_visual {
        run_operator_visual_mode(found.operator, self, editor, found.args)
      } else {
        run_operator_normal_mode(
          found.operator,
          self,
          editor,
          found.repeat_count,
          found.args,
        )
      }
      if completed {
        self.current_input = ""
      }
      return type_result(true)
    }
    None => ()
  }

  match find_motion_command(input, self.is_visual, modifier_keys) {
    Some(command) => {
      self.current_input = ""
      return type_result(true, execute_editor_command=command)
    }
    None => ()
  }

  match find_motion(input) {
    Some(motion) => {
      let new_pos = motion.run(
        editor.document(),
        editor.selection().active(),
        self.motion_state,
      )
      if self.is_visual {
        match self.motion_state.anchor {
          Some(anchor) => {
            let value = @vscode.Selection::new(anchor, new_pos)
            editor.set_selection(value)
            editor.reveal_range(
              @vscode.Range::new(value.anchor(), value.active()),
              reveal_type=@vscode.TextEditorRevealType::Default,
            )
          }
          None => ()
        }
      } else {
        let value = @vscode.Selection::new(new_pos, new_pos)
        editor.set_selection(value)
        editor.reveal_range(
          @vscode.Range::new(value.anchor(), value.active()),
          reveal_type=@vscode.TextEditorRevealType::Default,
        )
      }
      self.current_input = ""
      return type_result(true)
    }
    None => ()
  }

  if is_motion_prefix(input) {
    return type_result(true)
  }

  self.current_input = ""
  type_result(true)
}
