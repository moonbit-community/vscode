///|
pub(all) enum OperatorKind {
  DeleteCharUnderCursor
  Insert
  Append
  AppendEndOfLine
  DeleteTo
  Put
  Replace
  ReplaceMode
  Change
  Visual
  DeleteLine
}

///|
fn selection_to_range(value : @vscode.Selection) -> @vscode.Range {
  @vscode.Range::new(value.anchor(), value.active())
}

///|
fn editor_position(editor : @vscode.TextEditor) -> @vscode.Position {
  editor.selection().active()
}

///|
fn editor_selection(editor : @vscode.TextEditor) -> @vscode.Selection {
  editor.selection()
}

///|
fn set_position_reveal(
  editor : @vscode.TextEditor,
  line : Int,
  character : Int,
) -> Unit {
  let current = @vscode.Selection::from_numbers(
    line, character, line, character,
  )
  editor.set_selection(current)
  editor.reveal_range(
    selection_to_range(current),
    reveal_type=@vscode.TextEditorRevealType::Default,
  )
}

///|
async fn delete_range(
  ctrl : Controller,
  editor : @vscode.TextEditor,
  is_whole_line : Bool,
  range : @vscode.Range,
) -> Unit {
  ctrl.delete_register = Some(DeleteRegister::{
    is_whole_line,
    content: editor.document().get_text_range(range),
  })
  ignore(editor.edit(edit => edit.delete_range(range)))
}

///|
async fn delete_selection(
  ctrl : Controller,
  editor : @vscode.TextEditor,
  is_whole_line : Bool,
  value : @vscode.Selection,
) -> Unit {
  ctrl.delete_register = Some(DeleteRegister::{
    is_whole_line,
    content: editor.document().get_text_range(selection_to_range(value)),
  })
  ignore(editor.edit(edit => edit.delete_selection(value)))
}

///|
fn repeat_string(value : String, repeat_count : Int) -> String {
  let mut result = ""
  for _ in 0..<repeat_count {
    result = result + value
  }
  result
}

///|
async fn run_delete_line(
  ctrl : Controller,
  editor : @vscode.TextEditor,
  repeat_count : Int,
) -> Bool {
  let current_pos = editor_position(editor)
  let doc = editor.document()
  let mut from_line = current_pos.line()
  let mut from_character = 0
  let mut to_line = from_line + repeat_count
  let mut to_character = 0
  if to_line >= doc.line_count() - 1 {
    to_line = doc.line_count() - 1
    to_character = doc.line_at_line(to_line).text.length()
    if from_line > 0 {
      from_line -= 1
      from_character = doc.line_at_line(from_line).text.length()
    }
  }
  delete_range(
    ctrl,
    editor,
    true,
    @vscode.Range::from_numbers(
      from_line, from_character, to_line, to_character,
    ),
  )
  true
}

///|
pub async fn run_operator_normal_mode(
  operator : OperatorKind,
  ctrl : Controller,
  editor : @vscode.TextEditor,
  repeat_count : Int,
  args : String,
) -> Bool {
  match operator {
    DeleteCharUnderCursor => {
      let from = editor_position(editor)
      let to = Motion::NextCharacter
        .repeat(repeat_count > 1, repeat_count)
        .run(editor.document(), from, ctrl.motion_state)
      delete_range(ctrl, editor, false, @vscode.Range::new(from, to))
      true
    }
    Insert => {
      ctrl.set_mode(Mode::Insert)
      true
    }
    Append => {
      let new_pos = Motion::Right.run(
        editor.document(),
        editor_position(editor),
        ctrl.motion_state,
      )
      set_position_reveal(editor, new_pos.line(), new_pos.character())
      ctrl.set_mode(Mode::Insert)
      true
    }
    AppendEndOfLine => {
      let new_pos = Motion::EndOfLine.run(
        editor.document(),
        editor_position(editor),
        ctrl.motion_state,
      )
      set_position_reveal(editor, new_pos.line(), new_pos.character())
      ctrl.set_mode(Mode::Insert)
      true
    }
    DeleteTo => {
      if args == "d" {
        return run_delete_line(ctrl, editor, repeat_count)
      }
      match ctrl.find_motion(args) {
        Some(motion) => {
          let from = editor_position(editor)
          let to = motion
            .repeat(repeat_count > 1, repeat_count)
            .run(editor.document(), from, ctrl.motion_state)
          delete_range(ctrl, editor, false, @vscode.Range::new(from, to))
          true
        }
        None => if ctrl.is_motion_prefix(args) { false } else { true }
      }
    }
    Put =>
      match ctrl.delete_register {
        None => true
        Some(register) => {
          let mut text = repeat_string(register.content, repeat_count)
          let current_pos = editor_position(editor)
          if !register.is_whole_line {
            ignore(
              editor.edit(edit => {
                edit.insert(
                  @vscode.Position::new(
                    current_pos.line(),
                    current_pos.character() + 1,
                  ),
                  text,
                )
              }),
            )
            return true
          }
          let doc = editor.document()
          let mut insert_line = current_pos.line() + 1
          let mut insert_character = 0
          if insert_line >= doc.line_count() {
            insert_line = doc.line_count() - 1
            insert_character = doc.line_at_line(insert_line).text.length()
            text = "\n" + text
          }
          ignore(
            editor.edit(edit => {
              edit.insert(
                @vscode.Position::new(insert_line, insert_character),
                text,
              )
            }),
          )
          true
        }
      }
    Replace => {
      if args.length() == 0 {
        return false
      }
      let doc = editor.document()
      let current_pos = editor_position(editor)
      let to_character = current_pos.character() + repeat_count
      if to_character > doc.line_at_position(current_pos).text.length() {
        return true
      }
      ignore(
        editor.edit(edit => {
          edit.replace_range(
            @vscode.Range::from_numbers(
              current_pos.line(),
              current_pos.character(),
              current_pos.line(),
              to_character,
            ),
            repeat_string(args, repeat_count),
          )
        }),
      )
      true
    }
    ReplaceMode => {
      ctrl.set_mode(Mode::Replace)
      true
    }
    Change =>
      match ctrl.find_motion(args) {
        Some(motion) => {
          let from = editor_position(editor)
          let to = motion.run(editor.document(), from, ctrl.motion_state)
          delete_range(ctrl, editor, false, @vscode.Range::new(from, to))
          ctrl.set_mode(Mode::Insert)
          true
        }
        None => if ctrl.is_motion_prefix(args) { false } else { true }
      }
    Visual => {
      ctrl.motion_state.anchor = Some(editor_position(editor))
      ctrl.set_visual(true)
      true
    }
    DeleteLine => run_delete_line(ctrl, editor, repeat_count)
  }
}

///|
pub async fn run_operator_visual_mode(
  operator : OperatorKind,
  ctrl : Controller,
  editor : @vscode.TextEditor,
  args : String,
) -> Bool {
  match operator {
    DeleteCharUnderCursor | DeleteTo => {
      delete_selection(ctrl, editor, false, editor_selection(editor))
      true
    }
    Insert => {
      ctrl.set_mode(Mode::Insert)
      true
    }
    Append => {
      let new_pos = Motion::Right.run(
        editor.document(),
        editor_position(editor),
        ctrl.motion_state,
      )
      set_position_reveal(editor, new_pos.line(), new_pos.character())
      ctrl.set_mode(Mode::Insert)
      true
    }
    AppendEndOfLine => {
      let new_pos = Motion::EndOfLine.run(
        editor.document(),
        editor_position(editor),
        ctrl.motion_state,
      )
      set_position_reveal(editor, new_pos.line(), new_pos.character())
      ctrl.set_mode(Mode::Insert)
      true
    }
    Put =>
      match ctrl.delete_register {
        None => false
        Some(register) => {
          ignore(
            editor.edit(edit => {
              edit.replace_selection(editor_selection(editor), register.content)
            }),
          )
          true
        }
      }
    Replace => {
      if args.length() == 0 {
        return false
      }
      let source = editor
        .document()
        .get_text_range(selection_to_range(editor_selection(editor)))
      let mut destination = ""
      for i in 0..<source.length() {
        let ch = source[i]
        if ch == '\r' || ch == '\n' {
          destination = destination + ch.to_string()
        } else {
          destination = destination + args
        }
      }
      ignore(
        editor.edit(edit => {
          edit.replace_selection(editor_selection(editor), destination)
        }),
      )
      true
    }
    ReplaceMode => {
      delete_selection(ctrl, editor, false, editor_selection(editor))
      ctrl.set_mode(Mode::Insert)
      true
    }
    Change => {
      delete_selection(ctrl, editor, false, editor_selection(editor))
      ctrl.set_mode(Mode::Insert)
      true
    }
    Visual => {
      ctrl.motion_state.anchor = Some(editor_position(editor))
      ctrl.set_visual(true)
      true
    }
    DeleteLine => {
      delete_selection(ctrl, editor, false, editor_selection(editor))
      true
    }
  }
}
