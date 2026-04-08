///|
pub struct ContextKey {
  name : String
  mut last_value : Bool?
}

///|
pub fn ContextKey::new(name : String) -> ContextKey {
  ContextKey::{ name, last_value: None }
}

///|
pub async fn ContextKey::set(self : ContextKey, value : Bool) -> Unit {
  if self.last_value == Some(value) {
    return
  }
  self.last_value = Some(value)
  run_command_unit("setContext", args=@commands.command_args2(self.name, value))
}

///|
pub struct StatusBar {
  actual : @vscode.StatusBarItem
  mut last_text : String?
}

///|
pub fn StatusBar::new() -> StatusBar {
  let actual = @window.create_status_bar_item(
    alignment=@vscode.StatusBarAlignment::Left,
  )
  actual.show()
  StatusBar::{ actual, last_text: None }
}

///|
pub fn StatusBar::set_text(self : StatusBar, text : String) -> Unit {
  if self.last_text == Some(text) {
    return
  }
  self.last_text = Some(text)
  self.actual.set_text(text)
}

///|
pub struct VimExt {
  in_normal_mode : ContextKey
  has_input : ContextKey
  status_bar : StatusBar
  controller : Controller
}

///|
pub fn VimExt::new() -> VimExt {
  VimExt::{
    in_normal_mode: ContextKey::new("vim.inNormalMode"),
    has_input: ContextKey::new("vim.hasInput"),
    status_bar: StatusBar::new(),
    controller: Controller::new(),
  }
}

///|
fn configured_word_separators() -> String {
  @workspace.get_configuration(section="editor").get_string_or(
    "wordSeparators", "",
  )
}

///|
async fn run_command_unit(
  command_id : String,
  args? : @commands.CommandArgs,
) -> Unit {
  match args {
    Some(args) => {
      let result : Unit = @commands.execute_command(command_id, args~)
      result
    }
    None => {
      let result : Unit = @commands.execute_command(command_id)
      result
    }
  }
}

///|
async fn execute_editor_command(command : EditorCommand) -> Unit {
  match command.args {
    Some(args) => run_command_unit(command.command_id, args~)
    None => run_command_unit(command.command_id)
  }
}

///|
pub async fn VimExt::go_to_normal_mode(self : VimExt) -> Unit {
  self.controller.set_mode(Mode::Normal)
  self.ensure_state()
}

///|
pub async fn VimExt::clear_input(self : VimExt) -> Unit {
  self.controller.clear_input()
  self.ensure_state()
}

///|
pub async fn VimExt::handle_type(
  self : VimExt,
  editor : @vscode.TextEditor,
  text : String,
  modifier_keys : ModifierKeys,
) -> Unit {
  let result = self.controller.handle_type(editor, text, modifier_keys)
  if result.has_consumed_input {
    self.ensure_state()
    match result.execute_editor_command {
      Some(command) => execute_editor_command(command)
      None => ()
    }
  } else {
    run_command_unit(
      "default:type",
      args=@commands.command_args1(TypeCommandArgs::{ text, }),
    )
  }
}

///|
pub async fn VimExt::replace_prev_char(
  self : VimExt,
  editor : @vscode.TextEditor,
  text : String,
  replace_char_cnt : Int,
) -> Unit {
  if self.controller.replace_prev_char(editor, text, replace_char_cnt) {
    self.ensure_state()
  } else {
    run_command_unit(
      "default:replacePreviousChar",
      args=@commands.command_args1(ReplacePreviousCharCommandArgs::{
        text,
        replaceCharCnt: replace_char_cnt,
      }),
    )
  }
}

///|
pub fn VimExt::composition_start(
  self : VimExt,
  editor : @vscode.TextEditor,
) -> Unit {
  self.controller.composition_start(editor)
}

///|
pub async fn VimExt::composition_end(
  self : VimExt,
  editor : @vscode.TextEditor,
) -> Unit {
  let result = self.controller.composition_end(editor)
  if result.has_consumed_input {
    self.ensure_state()
    match result.execute_editor_command {
      Some(command) => execute_editor_command(command)
      None => ()
    }
  }
}

///|
fn VimExt::ensure_position(self : VimExt) -> Unit {
  match @window.active_text_editor() {
    Some(editor) => self.controller.ensure_normal_mode_position(editor)
    None => ()
  }
}

///|
fn ensure_cursor_style(cursor_style : @vscode.TextEditorCursorStyle) -> Unit {
  match @window.active_text_editor() {
    Some(editor) =>
      if editor.options().cursor_style != Some(cursor_style) {
        editor.set_options(@vscode.TextEditorOptions::new(cursor_style~))
      }
    None => ()
  }
}

///|
pub async fn VimExt::ensure_state(self : VimExt) -> Unit {
  self.ensure_position()
  self.status_bar.set_text(self.controller.get_status_text())
  ensure_cursor_style(self.controller.get_cursor_style())
  self.in_normal_mode.set(self.controller.get_mode() == Mode::Normal)
  self.has_input.set(self.controller.has_input())
}

///|
fn selection_is_empty(selection : @vscode.Selection) -> Bool {
  @vscode.Range::new(selection.anchor(), selection.active()).is_empty()
}

///|
fn register_command_nice(
  subscriptions : Array[&@vscode.Disposable],
  command_id : String,
  run : async (@commands.CommandArgs) -> Unit,
) -> Unit {
  subscriptions.push(@commands.register_command_async(command_id, run))
}

///|
fn register_command_nice_sync(
  subscriptions : Array[&@vscode.Disposable],
  command_id : String,
  run : (@commands.CommandArgs) -> Unit,
) -> Unit {
  subscriptions.push(@commands.register_command(command_id, run))
}

///|
fn register_ctrl_key_binding(
  subscriptions : Array[&@vscode.Disposable],
  vim_ext : VimExt,
  key : String,
) -> Unit {
  register_command_nice(subscriptions, key, async fn(_args) {
    match @window.active_text_editor() {
      Some(editor) => vim_ext.handle_type(editor, key, ctrl_modifier_keys())
      None => ()
    }
  })
}

///|
async fn async_activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let vim_ext = VimExt::new()

  register_command_nice(subscriptions, "type", async fn(args) {
    let type_args : TypeCommandArgs? = args.get(0)
    match (@window.active_text_editor(), type_args) {
      (Some(editor), Some(type_args)) =>
        vim_ext.handle_type(editor, type_args.text, no_modifier_keys())
      _ => ()
    }
  })
  register_command_nice(subscriptions, "replacePreviousChar", async fn(args) {
    let replace_args : ReplacePreviousCharCommandArgs? = args.get(0)
    match (@window.active_text_editor(), replace_args) {
      (Some(editor), Some(replace_args)) =>
        vim_ext.replace_prev_char(
          editor,
          replace_args.text,
          replace_args.replaceCharCnt,
        )
      _ => ()
    }
  })
  register_command_nice_sync(subscriptions, "compositionStart", fn(_args) {
    match @window.active_text_editor() {
      Some(editor) => vim_ext.composition_start(editor)
      None => ()
    }
  })
  register_command_nice(subscriptions, "compositionEnd", async fn(_args) {
    match @window.active_text_editor() {
      Some(editor) => vim_ext.composition_end(editor)
      None => ()
    }
  })
  register_command_nice(subscriptions, "vim.goToNormalMode", async fn(_args) {
    vim_ext.go_to_normal_mode()
  })
  register_command_nice(subscriptions, "vim.clearInput", async fn(_args) {
    vim_ext.clear_input()
  })

  register_ctrl_key_binding(subscriptions, vim_ext, "e")
  register_ctrl_key_binding(subscriptions, vim_ext, "d")
  register_ctrl_key_binding(subscriptions, vim_ext, "f")
  register_ctrl_key_binding(subscriptions, vim_ext, "y")
  register_ctrl_key_binding(subscriptions, vim_ext, "u")
  register_ctrl_key_binding(subscriptions, vim_ext, "b")

  subscriptions.push(
    @window.on_did_change_active_text_editor().subscribe_async(async fn(
      editor,
    ) {
      match editor {
        Some(_) => vim_ext.ensure_state()
        None => ()
      }
    }),
  )

  subscriptions.push(
    @window.on_did_change_text_editor_selection().subscribe_async(async fn(
      event,
    ) {
      let is_visual = vim_ext.controller.get_visual()
      if !is_visual {
        let go_to_visual_mode = if event.selections.length() > 1 {
          true
        } else if event.selections.length() == 1 {
          !selection_is_empty(event.selections[0])
        } else {
          false
        }
        if go_to_visual_mode {
          vim_ext.controller.set_visual(true)
        }
      } else {
        let leave_visual_mode = if event.selections.length() == 1 {
          selection_is_empty(event.selections[0])
        } else {
          false
        }
        if leave_visual_mode {
          vim_ext.controller.set_visual(false)
        }
      }
      vim_ext.ensure_state()
    }),
  )

  vim_ext.controller.set_word_separators(configured_word_separators())
  subscriptions.push(
    @workspace.on_did_change_configuration().subscribe(_event => {
      vim_ext.controller.set_word_separators(configured_word_separators())
    }),
  )

  vim_ext.ensure_state()
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  @vscode.activate_async(ctx, async_activate)
}

///|
pub fn deactivate() -> Unit {
  ()
}
