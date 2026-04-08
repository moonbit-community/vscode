///|
pub(all) enum Mode {
  Insert
  Normal
  Replace
} derive(Eq)

///|
pub struct ModifierKeys {
  ctrl : Bool
  alt : Bool
  shift : Bool
}

///|
pub fn no_modifier_keys() -> ModifierKeys {
  ModifierKeys::{ ctrl: false, alt: false, shift: false }
}

///|
pub fn ctrl_modifier_keys() -> ModifierKeys {
  ModifierKeys::{ ctrl: true, alt: false, shift: false }
}

///|
pub struct DeleteRegister {
  is_whole_line : Bool
  content : String
}

///|
pub struct EditorCommand {
  command_id : String
  args : @commands.CommandArgs?
}

///|
pub fn editor_command(
  command_id : String,
  args? : @commands.CommandArgs,
) -> EditorCommand {
  EditorCommand::{ command_id, args }
}

///|
pub struct TypeResult {
  has_consumed_input : Bool
  execute_editor_command : EditorCommand?
}

///|
pub fn type_result(
  has_consumed_input : Bool,
  execute_editor_command? : EditorCommand,
) -> TypeResult {
  TypeResult::{ has_consumed_input, execute_editor_command }
}

///|
pub struct TypeCommandArgs {
  text : String
}

///|
pub struct ReplacePreviousCharCommandArgs {
  text : String
  replaceCharCnt : Int
}

///|
pub struct CursorMoveArgs {
  to : String
  by : String?
  value : Int
  select : Bool
}

///|
pub struct EditorScrollArgs {
  to : String
  by : String?
  value : Int
  revealCursor : Bool
}

///|
pub struct RevealLineArgs {
  lineNumber : Int
  at : String
}

///|
pub struct MoveActiveEditorArgs {
  to : String
  value : Int?
}

///|
pub struct FoldCommandArgs {
  levels : Int
  direction : String
}
