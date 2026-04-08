///|
/// MoonBit port of `terminal-sample`.
priv struct TerminalState {
  mut next_id : Int
  mut current : @vscode.Terminal?
  mut link_provider : &@vscode.Disposable?
}

let terminal_state : TerminalState = {
  next_id: 1,
  current: None,
  link_provider: None,
}

fn current_or_new() -> @vscode.Terminal {
  match terminal_state.current {
    Some(terminal) => terminal
    None => {
      let terminal = @window.create_terminal_named(
        "Ext Terminal #\{terminal_state.next_id}",
      )
      terminal_state.next_id = terminal_state.next_id + 1
      terminal_state.current = Some(terminal)
      terminal
    }
  }
}

fn http_offset(line : String) -> Int {
  match line.find("http") {
    Some(offset) => offset
    None => -1
  }
}

priv struct SampleTerminalLinkProvider {}

impl @vscode.TerminalLinkProvider for SampleTerminalLinkProvider with provide_terminal_links(
  _self,
  context,
  _token,
) {
  let offset = http_offset(context.line)
  if offset < 0 {
    None
  } else {
    Some([
      @vscode.TerminalLink::new(
        offset,
        20,
        tooltip="Open sample link",
      ),
    ])
  }
}

impl @vscode.TerminalLinkProvider for SampleTerminalLinkProvider with handle_terminal_link(
  _self,
  _link,
) {
  ignore(@window.show_information_message("Terminal link clicked."))
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  subscriptions.push(@window.on_did_open_terminal().subscribe(fn(terminal) {
    terminal_state.current = Some(terminal)
  }))
  subscriptions.push(@window.on_did_close_terminal().subscribe(fn(_terminal) {
    terminal_state.current = None
  }))

  let create_terminal = @commands.register_command(
    "terminalTest.createTerminal",
    fn(_args) {
      let terminal = @window.create_terminal_named(
        "Ext Terminal #\{terminal_state.next_id}",
      )
      terminal_state.next_id = terminal_state.next_id + 1
      terminal_state.current = Some(terminal)
      terminal.show()
    },
  )
  subscriptions.push(create_terminal)

  let create_hidden = @commands.register_command_async(
    "terminalTest.createTerminalHideFromUser",
    async fn(_args) {
      let terminal = @window.create_terminal_with_options(
        @vscode.TerminalOptions::new(
          name="Hidden Terminal",
          hide_from_user=true,
        ),
      )
      terminal_state.current = Some(terminal)
      ignore(@window.show_information_message("Created hidden terminal."))
    },
  )
  subscriptions.push(create_hidden)

  let create_send = @commands.register_command(
    "terminalTest.createAndSend",
    fn(_args) {
      let terminal = current_or_new()
      terminal.show()
      terminal.send_text("echo hello from terminal-sample")
    },
  )
  subscriptions.push(create_send)

  let create_zsh = @commands.register_command(
    "terminalTest.createZshLoginShell",
    fn(_args) {
      let terminal = @window.create_terminal_with_options(
        @vscode.TerminalOptions::new(
          name="zsh login shell",
          shell_path="zsh",
          shell_args=@vscode.ShellArgs::ArrayValue(["-l"]),
        ),
      )
      terminal_state.current = Some(terminal)
      terminal.show()
    },
  )
  subscriptions.push(create_zsh)

  let dimensions = @commands.register_command_async(
    "terminalTest.dimensions",
    async fn(_args) {
      match terminal_state.current {
        None => ignore(@window.show_information_message("No terminal."))
        Some(terminal) => {
          let interacted = if terminal.state().isInteractedWith {
            "true"
          } else {
            "false"
          }
          ignore(
            @window.show_information_message(
              "Terminal interacted=\{interacted}",
            ),
          )
        }
      }
    },
  )
  subscriptions.push(dimensions)

  let dispose = @commands.register_command(
    "terminalTest.dispose",
    fn(_args) {
      match terminal_state.current {
        None => ()
        Some(terminal) => {
          terminal.dispose()
          terminal_state.current = None
        }
      }
    },
  )
  subscriptions.push(dispose)

  let hide = @commands.register_command(
    "terminalTest.hide",
    fn(_args) {
      match terminal_state.current {
        None => ()
        Some(terminal) => terminal.hide()
      }
    },
  )
  subscriptions.push(hide)

  let on_write = @commands.register_command_async(
    "terminalTest.onDidWriteTerminalData",
    async fn(_args) {
      ignore(
        @window.show_information_message(
          "onDidWriteTerminalData is not yet bound in this port.",
        ),
      )
    },
  )
  subscriptions.push(on_write)

  let on_dimensions = @commands.register_command_async(
    "terminalTest.onDidChangeTerminalDimensions",
    async fn(_args) {
      let disposable = @window.on_did_change_terminal_state().subscribe(fn(_terminal) {
        ()
      })
      subscriptions.push(disposable)
      ignore(@window.show_information_message("Subscribed to terminal state changes."))
    },
  )
  subscriptions.push(on_dimensions)

  let process_id = @commands.register_command_async(
    "terminalTest.processId",
    async fn(_args) {
      match terminal_state.current {
        None => ignore(@window.show_information_message("No terminal."))
        Some(terminal) => {
          let id = terminal.process_id()
          match id {
            None => ignore(@window.show_information_message("No process id available."))
            Some(id) => ignore(@window.show_information_message("Process id: \{id}"))
          }
        }
      }
    },
  )
  subscriptions.push(process_id)

  let send_text = @commands.register_command(
    "terminalTest.sendText",
    fn(_args) {
      current_or_new().send_text("echo sendText")
    },
  )
  subscriptions.push(send_text)

  let send_text_no_newline = @commands.register_command(
    "terminalTest.sendTextNoNewLine",
    fn(_args) {
      current_or_new().send_text("echo sendTextNoNewLine", should_execute=false)
    },
  )
  subscriptions.push(send_text_no_newline)

  let show = @commands.register_command(
    "terminalTest.show",
    fn(_args) {
      current_or_new().show()
    },
  )
  subscriptions.push(show)

  let show_preserve_focus = @commands.register_command(
    "terminalTest.showPreserveFocus",
    fn(_args) {
      current_or_new().show(preserve_focus=true)
    },
  )
  subscriptions.push(show_preserve_focus)

  let terminals = @commands.register_command_async(
    "terminalTest.terminals",
    async fn(_args) {
      ignore(
        @window.show_information_message(
          "Terminal count: \{@window.terminals().length()}",
        ),
      )
    },
  )
  subscriptions.push(terminals)

  let update_env = @commands.register_command_async(
    "terminalTest.updateEnvironment",
    async fn(_args) {
      let env = ctx.environment_variable_collection()
      env.replace("MOONBIT_TERMINAL_SAMPLE", "updated")
      ignore(@window.show_information_message("Updated terminal environment variable."))
    },
  )
  subscriptions.push(update_env)

  let clear_env = @commands.register_command_async(
    "terminalTest.clearEnvironment",
    async fn(_args) {
      let env = ctx.environment_variable_collection()
      env.clear()
      ignore(@window.show_information_message("Cleared terminal environment variables."))
    },
  )
  subscriptions.push(clear_env)

  let link_provider_command = @commands.register_command_async(
    "terminalTest.registerTerminalLinkProvider",
    async fn(_args) {
      match terminal_state.link_provider {
        Some(disposable) => disposable.dispose()
        None => ()
      }

      let provider = SampleTerminalLinkProvider::{}
      let registration = @window.register_terminal_link_provider(provider)
      terminal_state.link_provider = Some(registration)
      subscriptions.push(registration)
      ignore(@window.show_information_message("Registered terminal link provider."))
    },
  )
  subscriptions.push(link_provider_command)
}

pub fn deactivate() -> Unit {
  ()
}
