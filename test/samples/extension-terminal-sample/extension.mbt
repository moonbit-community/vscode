///|
/// MoonBit port of `extension-terminal-sample`.

priv struct State {
  mut emitter : @vscode.EventEmitter[String]?
  mut line : String
}

let state : State = {
  emitter: None,
  line: "",
}

fn trim_last_char(value : String) -> String {
  if value.length() == 0 {
    value
  } else {
    value.unsafe_substring(start=0, end=value.length() - 1)
  }
}

fn color_text(value : String) -> String {
  let output = StringBuilder::new()
  let mut color_index = 1
  for ch in value {
    if ch == ' ' || ch == '\r' || ch == '\n' {
      output.write_char(ch)
      continue
    }

    output.write_string("\u{001b}[3\{color_index}m")
    output.write_char(ch)
    output.write_string("\u{001b}[0m")
    color_index = if color_index >= 6 { 1 } else { color_index + 1 }
  }
  output.to_string()
}

fn write_emitter() -> @vscode.EventEmitter[String] {
  match state.emitter {
    Some(emitter) => emitter
    None => {
      let created = @vscode.EventEmitter::new()
      state.emitter = Some(created)
      created
    }
  }
}

fn write(value : String) -> Unit {
  write_emitter().fire(value)
}

fn handle_input(data : String) -> Unit {
  if data == "\r" {
    write("\r\necho: \"\{color_text(state.line)}\"\r\n\n")
    state.line = ""
    return
  }

  if data == "\u007f" {
    if state.line == "" {
      return
    }
    state.line = trim_last_char(state.line)
    write("\u001b[D")
    write("\u001b[P")
    return
  }

  state.line = "\{state.line}\{data}"
  write(data)
}

fn create_extension_terminal() -> Unit {
  let pty = @vscode.Pseudoterminal::new(
    write_emitter().event(),
    fn(_dims) {
      write("Type and press enter to echo the text\r\n\r\n")
    },
    fn() {
      ()
    },
    handle_input=handle_input,
  )

  let options = @vscode.ExtensionTerminalOptions::new(
    "My Extension REPL",
    pty,
  )
  let terminal = @window.create_terminal_with_extension_options(options)
  terminal.show()
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let create_disposable = @commands.register_command(
    "extensionTerminalSample.create",
    fn(_args) {
      create_extension_terminal()
    },
  )
  subscriptions.push(create_disposable)

  let clear_disposable = @commands.register_command(
    "extensionTerminalSample.clear",
    fn(_args) {
      write("\u001b[2J\u001b[3J\u001b[;H")
    },
  )
  subscriptions.push(clear_disposable)
}

pub fn deactivate() -> Unit {
  match state.emitter {
    None => ()
    Some(emitter) => {
      emitter.dispose()
      state.emitter = None
    }
  }
}
