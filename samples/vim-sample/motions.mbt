///|
pub struct MotionState {
  mut anchor : @vscode.Position?
  mut cursor_desired_character : Int
  mut word_character_class : WordCharacters
}

///|
pub fn MotionState::new() -> MotionState {
  MotionState::{
    anchor: None,
    cursor_desired_character: -1,
    word_character_class: [],
  }
}

///|
pub(all) enum Motion {
  NextCharacter
  Left
  Right
  Down
  Up
  EndOfLine
  StartOfLine
  NextWordStart
  NextWordEnd
  GoToLineUndefined
  GoToFirstLine
  GoToLastLine
  GoToLineDefined(Int)
  Repeating(Motion, Int)
}

///|
pub(all) enum MotionCommandDescriptor {
  CursorMove(String, String?)
  EditorScroll(String, String?)
  RevealCurrentLine(String)
  MoveActiveEditorByPosition
  MoveActiveEditor(String)
  Fold
  Unfold
}

///|
pub struct MotionCommandRequest {
  is_visual : Bool
  repeat : Int?
}

///|
fn motion_line_length(doc : @vscode.TextDocument, line : Int) -> Int {
  doc.line_at_line(line).text.length()
}

///|
fn min_int(left : Int, right : Int) -> Int {
  if left < right {
    left
  } else {
    right
  }
}

///|
fn first_non_whitespace_char(doc : @vscode.TextDocument, line : Int) -> Int {
  let line_content = doc.line_at_line(line).text
  let mut character = 0
  while character < line_content.length() {
    let ch = line_content[character].to_int()
    if ch != ' '.to_int() && ch != '\t'.to_int() {
      return character
    }
    character += 1
  }
  character
}

///|
pub fn Motion::repeat(
  self : Motion,
  has_repeat_count : Bool,
  count : Int,
) -> Motion {
  if !has_repeat_count {
    self
  } else {
    match self {
      GoToLineUndefined => GoToLineDefined(count)
      _ => Repeating(self, count)
    }
  }
}

///|
pub fn Motion::run(
  self : Motion,
  doc : @vscode.TextDocument,
  pos : @vscode.Position,
  state : MotionState,
) -> @vscode.Position {
  match self {
    NextCharacter => {
      let line_length = motion_line_length(doc, pos.line())
      if pos.character() == line_length {
        if pos.line() + 1 < doc.line_count() {
          @vscode.Position::new(pos.line() + 1, 0)
        } else {
          pos
        }
      } else {
        @vscode.Position::new(pos.line(), pos.character() + 1)
      }
    }
    Left =>
      if pos.character() > 0 {
        state.cursor_desired_character = pos.character() - 1
        @vscode.Position::new(pos.line(), state.cursor_desired_character)
      } else {
        pos
      }
    Down => {
      let desired = if state.cursor_desired_character == -1 {
        pos.character()
      } else {
        state.cursor_desired_character
      }
      state.cursor_desired_character = desired
      if pos.line() < doc.line_count() - 1 {
        let line = pos.line() + 1
        @vscode.Position::new(
          line,
          min_int(desired, motion_line_length(doc, line)),
        )
      } else {
        pos
      }
    }
    Up => {
      let desired = if state.cursor_desired_character == -1 {
        pos.character()
      } else {
        state.cursor_desired_character
      }
      state.cursor_desired_character = desired
      if pos.line() > 0 {
        let line = pos.line() - 1
        @vscode.Position::new(
          line,
          min_int(desired, motion_line_length(doc, line)),
        )
      } else {
        pos
      }
    }
    Right => {
      let max_character = motion_line_length(doc, pos.line())
      if pos.character() < max_character {
        state.cursor_desired_character = pos.character() + 1
        @vscode.Position::new(pos.line(), state.cursor_desired_character)
      } else {
        pos
      }
    }
    EndOfLine =>
      @vscode.Position::new(pos.line(), motion_line_length(doc, pos.line()))
    StartOfLine => @vscode.Position::new(pos.line(), 0)
    NextWordStart => {
      let line_content = doc.line_at_line(pos.line()).text
      if pos.character() >= line_content.length() - 1 {
        if pos.line() + 1 < doc.line_count() {
          @vscode.Position::new(pos.line() + 1, 0)
        } else {
          pos
        }
      } else {
        match find_next_word(doc, pos, state.word_character_class) {
          Some(next_word) =>
            if next_word.start <= pos.character() &&
              pos.character() < next_word.end_index {
              match
                find_next_word(
                  doc,
                  @vscode.Position::new(pos.line(), next_word.end_index),
                  state.word_character_class,
                ) {
                Some(next_next_word) =>
                  @vscode.Position::new(pos.line(), next_next_word.start)
                None => Motion::EndOfLine.run(doc, pos, state)
              }
            } else {
              @vscode.Position::new(pos.line(), next_word.start)
            }
          None => Motion::EndOfLine.run(doc, pos, state)
        }
      }
    }
    NextWordEnd => {
      let line_content = doc.line_at_line(pos.line()).text
      if pos.character() >= line_content.length() - 1 {
        if pos.line() + 1 < doc.line_count() {
          @vscode.Position::new(pos.line() + 1, 0)
        } else {
          pos
        }
      } else {
        match find_next_word(doc, pos, state.word_character_class) {
          Some(next_word) =>
            @vscode.Position::new(pos.line(), next_word.end_index)
          None => Motion::EndOfLine.run(doc, pos, state)
        }
      }
    }
    GoToLineUndefined => Motion::GoToLastLine.run(doc, pos, state)
    GoToFirstLine => @vscode.Position::new(0, first_non_whitespace_char(doc, 0))
    GoToLastLine => {
      let last_line = doc.line_count() - 1
      @vscode.Position::new(
        last_line,
        first_non_whitespace_char(doc, last_line),
      )
    }
    GoToLineDefined(line_number) => {
      let line = min_int(
        doc.line_count() - 1,
        if line_number <= 0 {
          0
        } else {
          line_number - 1
        },
      )
      @vscode.Position::new(line, first_non_whitespace_char(doc, line))
    }
    Repeating(actual, repeat_count) => {
      let mut current = pos
      for _ in 0..<repeat_count {
        current = actual.run(doc, current, state)
      }
      current
    }
  }
}

///|
pub fn MotionCommandDescriptor::create_command(
  self : MotionCommandDescriptor,
  request : MotionCommandRequest,
) -> EditorCommand {
  match self {
    CursorMove(to, by) =>
      editor_command(
        "cursorMove",
        args=@commands.command_args1(CursorMoveArgs::{
          to,
          by,
          value: match request.repeat {
            Some(repeat) => repeat
            None => 1
          },
          select: request.is_visual,
        }),
      )
    EditorScroll(to, by) =>
      editor_command(
        "editorScroll",
        args=@commands.command_args1(EditorScrollArgs::{
          to,
          by,
          value: match request.repeat {
            Some(repeat) => repeat
            None => 1
          },
          revealCursor: true,
        }),
      )
    RevealCurrentLine(at) => {
      let line_number = match @window.active_text_editor() {
        Some(editor) =>
          @vscode.Range::new(
            editor.selection().anchor(),
            editor.selection().active(),
          )
          .start()
          .line()
        None => 0
      }
      editor_command(
        "revealLine",
        args=@commands.command_args1(RevealLineArgs::{
          lineNumber: line_number,
          at,
        }),
      )
    }
    MoveActiveEditorByPosition =>
      editor_command(
        "moveActiveEditor",
        args=@commands.command_args1(MoveActiveEditorArgs::{
          to: match request.repeat {
            Some(_) => "position"
            None => "last"
          },
          value: match request.repeat {
            Some(repeat) => Some(repeat + 1)
            None => None
          },
        }),
      )
    MoveActiveEditor(to) =>
      editor_command(
        "moveActiveEditor",
        args=@commands.command_args1(MoveActiveEditorArgs::{
          to,
          value: Some(
            match request.repeat {
              Some(repeat) => repeat
              None => 1
            },
          ),
        }),
      )
    Fold =>
      editor_command(
        "editor.fold",
        args=@commands.command_args1(FoldCommandArgs::{
          levels: match request.repeat {
            Some(repeat) => repeat
            None => 1
          },
          direction: "up",
        }),
      )
    Unfold =>
      editor_command(
        "editor.unfold",
        args=@commands.command_args1(FoldCommandArgs::{
          levels: match request.repeat {
            Some(repeat) => repeat
            None => 1
          },
          direction: "up",
        }),
      )
  }
}
