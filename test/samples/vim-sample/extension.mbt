///|
/// MoonBit port of `vim-sample`.
priv struct VimState {
  mut in_normal_mode : Bool
  mut has_input : Bool
}

let vim_state : VimState = {
  in_normal_mode: false,
  has_input: false,
}

async fn set_context(key : String, value : Bool) -> Unit {
  let _ : Unit = @commands.execute_command(
    "setContext",
    args=@commands.command_args2(key, value),
  )
}

async fn sync_contexts() -> Unit {
  set_context("vim.inNormalMode", vim_state.in_normal_mode)
  set_context("vim.hasInput", vim_state.has_input)
}

async fn go_to_normal_mode() -> Unit {
  vim_state.in_normal_mode = true
  sync_contexts()
}

async fn clear_input() -> Unit {
  vim_state.has_input = false
  sync_contexts()
}

fn passthrough_command(name : String) -> Unit {
  ignore(@window.set_status_bar_message("vim-sample command: \{name}"))
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  @vscode.activate_async(ctx, async fn(_context) {
    sync_contexts()
  })

  subscriptions.push(
    @commands.register_command_async("vim.goToNormalMode", async fn(_args) {
      go_to_normal_mode()
    }),
  )

  subscriptions.push(
    @commands.register_command_async("vim.clearInput", async fn(_args) {
      clear_input()
    }),
  )

  subscriptions.push(
    @commands.register_command("e", fn(_args) {
      passthrough_command("e")
    }),
  )
  subscriptions.push(
    @commands.register_command("d", fn(_args) {
      passthrough_command("d")
    }),
  )
  subscriptions.push(
    @commands.register_command("f", fn(_args) {
      passthrough_command("f")
    }),
  )
  subscriptions.push(
    @commands.register_command("y", fn(_args) {
      passthrough_command("y")
    }),
  )
  subscriptions.push(
    @commands.register_command("u", fn(_args) {
      passthrough_command("u")
    }),
  )
  subscriptions.push(
    @commands.register_command("b", fn(_args) {
      passthrough_command("b")
    }),
  )
}

pub fn deactivate() -> Unit {
  vim_state.in_normal_mode = false
  vim_state.has_input = false
}
