///|
pub struct NumberAndString {
  has_repeat_count : Bool
  repeat_count : Int
  input : String
}

///|
pub struct FoundOperator {
  operator : OperatorKind
  repeat_count : Int
  args : String
}

///|
fn is_digit(ch : UInt16) -> Bool {
  let value = ch.to_int()
  value >= '0'.to_int() && value <= '9'.to_int()
}

///|
fn is_non_zero_digit(ch : UInt16) -> Bool {
  let value = ch.to_int()
  value >= '1'.to_int() && value <= '9'.to_int()
}

///|
fn parse_positive_int(input : String, start : Int, end_index : Int) -> Int {
  let mut value = 0
  for i in start..<end_index {
    value = value * 10 + input[i].to_int() - '0'.to_int()
  }
  value
}

///|
fn slice_string(input : String, start : Int, end_index : Int) -> String {
  let len = input.length()
  let safe_start = if start < 0 { 0 } else if start > len { len } else { start }
  let safe_end = if end_index < safe_start {
    safe_start
  } else if end_index > len {
    len
  } else {
    end_index
  }
  input[safe_start:safe_end].to_string()
}

///|
fn parse_number_and_string(
  input : String,
  number_at_beginning? : Bool = true,
) -> NumberAndString {
  if number_at_beginning {
    if input.length() > 0 && is_non_zero_digit(input[0]) {
      let mut end_index = 1
      while end_index < input.length() && is_digit(input[end_index]) {
        end_index += 1
      }
      NumberAndString::{
        has_repeat_count: true,
        repeat_count: parse_positive_int(input, 0, end_index),
        input: input[end_index:].to_string(),
      }
    } else {
      NumberAndString::{ has_repeat_count: false, repeat_count: 1, input }
    }
  } else {
    let len = input.length()
    let mut start = len
    while start > 0 && is_digit(input[start - 1]) {
      start -= 1
    }
    if start < len {
      NumberAndString::{
        has_repeat_count: true,
        repeat_count: parse_positive_int(input, start, len),
        input: input[:start].to_string(),
      }
    } else {
      NumberAndString::{ has_repeat_count: false, repeat_count: 1, input }
    }
  }
}

///|
fn find_command_binding(
  input : String,
  modifier_keys : ModifierKeys,
) -> EditorCommand? {
  if modifier_keys.ctrl {
    None
  } else {
    match input {
      "u" => Some(editor_command("undo"))
      "U" => Some(editor_command("undo"))
      _ => None
    }
  }
}

///|
fn find_operator_binding(
  input : String,
  modifier_keys : ModifierKeys,
) -> OperatorKind? {
  if modifier_keys.ctrl {
    None
  } else {
    match input {
      "x" => Some(OperatorKind::DeleteCharUnderCursor)
      "i" => Some(OperatorKind::Insert)
      "a" => Some(OperatorKind::Append)
      "A" => Some(OperatorKind::AppendEndOfLine)
      "d" => Some(OperatorKind::DeleteTo)
      "p" => Some(OperatorKind::Put)
      "r" => Some(OperatorKind::Replace)
      "R" => Some(OperatorKind::ReplaceMode)
      "c" => Some(OperatorKind::Change)
      "v" => Some(OperatorKind::Visual)
      _ => None
    }
  }
}

///|
fn find_motion_binding(input : String) -> Motion? {
  match input {
    "0" => Some(Motion::StartOfLine)
    "$" => Some(Motion::EndOfLine)
    "w" => Some(Motion::NextWordStart)
    "e" => Some(Motion::NextWordEnd)
    "G" => Some(Motion::GoToLineUndefined)
    "gg" => Some(Motion::GoToFirstLine)
    _ => None
  }
}

///|
fn find_motion_command_binding(
  input : String,
  modifier_keys : ModifierKeys,
) -> MotionCommandDescriptor? {
  if modifier_keys.ctrl {
    match input {
      "e" => Some(MotionCommandDescriptor::EditorScroll("down", Some("line")))
      "d" =>
        Some(MotionCommandDescriptor::EditorScroll("down", Some("halfPage")))
      "f" => Some(MotionCommandDescriptor::EditorScroll("down", Some("page")))
      "y" => Some(MotionCommandDescriptor::EditorScroll("up", Some("line")))
      "u" => Some(MotionCommandDescriptor::EditorScroll("up", Some("halfPage")))
      "b" => Some(MotionCommandDescriptor::EditorScroll("up", Some("page")))
      _ => None
    }
  } else {
    match input {
      "h" => Some(MotionCommandDescriptor::CursorMove("left", None))
      "l" => Some(MotionCommandDescriptor::CursorMove("right", None))
      "g0" =>
        Some(MotionCommandDescriptor::CursorMove("wrappedLineStart", None))
      "g^" =>
        Some(
          MotionCommandDescriptor::CursorMove(
            "wrappedLineFirstNonWhitespaceCharacter",
            None,
          ),
        )
      "gm" =>
        Some(
          MotionCommandDescriptor::CursorMove("wrappedLineColumnCenter", None),
        )
      "g$" => Some(MotionCommandDescriptor::CursorMove("wrappedLineEnd", None))
      "g_" =>
        Some(
          MotionCommandDescriptor::CursorMove(
            "wrappedLineLastNonWhitespaceCharacter",
            None,
          ),
        )
      "zh" => Some(MotionCommandDescriptor::CursorMove("left", None))
      "zl" => Some(MotionCommandDescriptor::CursorMove("right", None))
      "zH" =>
        Some(MotionCommandDescriptor::CursorMove("left", Some("halfLine")))
      "zL" =>
        Some(MotionCommandDescriptor::CursorMove("right", Some("halfLine")))
      "j" => Some(MotionCommandDescriptor::CursorMove("down", None))
      "k" => Some(MotionCommandDescriptor::CursorMove("up", None))
      "gj" =>
        Some(MotionCommandDescriptor::CursorMove("down", Some("wrappedLine")))
      "gk" =>
        Some(MotionCommandDescriptor::CursorMove("up", Some("wrappedLine")))
      "H" => Some(MotionCommandDescriptor::CursorMove("viewPortTop", None))
      "M" => Some(MotionCommandDescriptor::CursorMove("viewPortCenter", None))
      "L" => Some(MotionCommandDescriptor::CursorMove("viewPortBottom", None))
      "tabm" => Some(MotionCommandDescriptor::MoveActiveEditorByPosition)
      "tabm<" => Some(MotionCommandDescriptor::MoveActiveEditor("left"))
      "tabm>" => Some(MotionCommandDescriptor::MoveActiveEditor("right"))
      "tabm<<" => Some(MotionCommandDescriptor::MoveActiveEditor("first"))
      "tabm>>" => Some(MotionCommandDescriptor::MoveActiveEditor("last"))
      "tabm." => Some(MotionCommandDescriptor::MoveActiveEditor("center"))
      "zt" => Some(MotionCommandDescriptor::RevealCurrentLine("top"))
      "zz" => Some(MotionCommandDescriptor::RevealCurrentLine("center"))
      "zb" => Some(MotionCommandDescriptor::RevealCurrentLine("bottom"))
      "zc" => Some(MotionCommandDescriptor::Fold)
      "zo" => Some(MotionCommandDescriptor::Unfold)
      _ => None
    }
  }
}

///|
pub fn find_motion(input : String) -> Motion? {
  let parsed = parse_number_and_string(input)
  let first = slice_string(parsed.input, 0, 1)
  let second = slice_string(parsed.input, 0, 2)
  match find_motion_binding(first) {
    Some(motion) =>
      Some(motion.repeat(parsed.has_repeat_count, parsed.repeat_count))
    None =>
      match find_motion_binding(second) {
        Some(motion) =>
          Some(motion.repeat(parsed.has_repeat_count, parsed.repeat_count))
        None => None
      }
  }
}

///|
fn make_motion_request(
  is_visual : Bool,
  parsed : NumberAndString,
) -> MotionCommandRequest {
  MotionCommandRequest::{
    is_visual,
    repeat: if parsed.has_repeat_count {
      Some(parsed.repeat_count)
    } else {
      None
    },
  }
}

///|
fn find_motion_command_from_number_and_string(
  parsed : NumberAndString,
  is_visual : Bool,
  modifier_keys : ModifierKeys,
) -> EditorCommand? {
  let candidates = [
    slice_string(parsed.input, 0, 1),
    slice_string(parsed.input, 0, 2),
    slice_string(parsed.input, 1, 3),
    slice_string(parsed.input, 1, 4),
    parsed.input,
  ]
  let request = make_motion_request(is_visual, parsed)
  for candidate in candidates {
    match find_motion_command_binding(candidate, modifier_keys) {
      Some(descriptor) => return Some(descriptor.create_command(request))
      None => ()
    }
  }
  None
}

///|
pub fn find_motion_command(
  input : String,
  is_visual : Bool,
  modifier_keys : ModifierKeys,
) -> EditorCommand? {
  let parsed_beginning = parse_number_and_string(input)
  match
    find_motion_command_from_number_and_string(
      parsed_beginning, is_visual, modifier_keys,
    ) {
    Some(command) => Some(command)
    None =>
      find_motion_command_from_number_and_string(
        parse_number_and_string(input, number_at_beginning=false),
        is_visual,
        modifier_keys,
      )
  }
}

///|
pub fn find_operator(
  input : String,
  modifier_keys : ModifierKeys,
) -> FoundOperator? {
  let parsed = parse_number_and_string(input)
  match find_operator_binding(slice_string(parsed.input, 0, 1), modifier_keys) {
    Some(operator) =>
      Some(FoundOperator::{
        operator,
        repeat_count: parsed.repeat_count,
        args: parsed.input[1:].to_string(),
      })
    None => None
  }
}

///|
pub fn find_command(
  input : String,
  modifier_keys : ModifierKeys,
) -> EditorCommand? {
  find_command_binding(input, modifier_keys)
}

///|
pub fn is_motion_prefix(input : String) -> Bool {
  if input.length() == 0 || input == "g" || input == "v" || input == "z" {
    return true
  }
  if input.length() == 0 || !is_non_zero_digit(input[0]) {
    return false
  }
  let mut index = 1
  while index < input.length() && is_digit(input[index]) {
    index += 1
  }
  if index < input.length() && input[index].to_int() == 'v'.to_int() {
    index += 1
  }
  if index < input.length() && input[index].to_int() == 'g'.to_int() {
    index += 1
  }
  if index < input.length() && input[index].to_int() == 'z'.to_int() {
    index += 1
  }
  index == input.length()
}
