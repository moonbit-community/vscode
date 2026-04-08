///|
/// Terminal helpers and extra types.

///|
/// Represents the dimensions of a terminal.
pub struct TerminalDimensions {
  columns : Int
  rows : Int
}

///|
/// A command line that was executed in a terminal.
pub struct TerminalShellExecutionCommandLine {
  value : String
  isTrusted : Bool
  confidence : TerminalShellExecutionCommandLineConfidence
}

///|
pub(all) enum TerminalShellExecutionCommandLineConfidence {
  Low = 0
  Medium = 1
  High = 2
} derive(Eq)

///|
pub(all) enum TerminalExitReason {
  Unknown = 0
  Shutdown = 1
  Process = 2
  User = 3
  Extension = 4
} derive(Eq)

///|
pub fn TerminalDimensions::new(columns : Int, rows : Int) -> TerminalDimensions {
  TerminalDimensions::{ columns, rows }
}

///|
/// The number of columns in the terminal.

///|
/// The number of rows in the terminal.

///|
fn terminal_dimensions_from_js(value : JsValue) -> TerminalDimensions? {
  let columns_raw = terminal_dimensions_columns_raw(value)
  let rows_raw = terminal_dimensions_rows_raw(value)
  if columns_raw.is_null_or_undefined() || rows_raw.is_null_or_undefined() {
    None
  } else {
    Some(TerminalDimensions::new(columns_raw.cast(), rows_raw.cast()))
  }
}

///|
/// The exit code that a terminal exited with, it can have the following values:
/// - Zero: the terminal process or custom execution succeeded.
/// - Non-zero: the terminal process or custom execution failed.
/// - `undefined`: the user forcibly closed the terminal or a custom execution exited
///   without providing an exit code.
pub fn TerminalExitStatus::new(
  reason : TerminalExitReason,
  code? : Int,
) -> TerminalExitStatus {
  TerminalExitStatus::{ code, reason }
}

///|
/// The exit code that a terminal exited with, it can have the following values:
/// - Zero: the terminal process or custom execution succeeded.
/// - Non-zero: the terminal process or custom execution failed.
/// - `undefined`: the user forcibly closed the terminal or a custom execution exited
///   without providing an exit code.

///|
/// The reason that triggered the exit of a terminal.

///|
/// The full command line that was executed, including both the command and its arguments.
pub fn TerminalShellExecutionCommandLine::new(
  value : String,
  is_trusted : Bool,
  confidence : TerminalShellExecutionCommandLineConfidence,
) -> TerminalShellExecutionCommandLine {
  TerminalShellExecutionCommandLine::{
    value,
    isTrusted: is_trusted,
    confidence,
  }
}

///|
/// The full command line that was executed, including both the command and its arguments.

///|
/// Whether the command line value came from a trusted source and is therefore safe to
/// execute without user additional confirmation, such as a notification that asks "Do you
/// want to execute (command)?". This verification is likely only needed if you are going to
/// execute the command again.
///
/// This is `true` only when the command line was reported explicitly by the shell
/// integration script (ie. {@link TerminalShellExecutionCommandLineConfidence.High high confidence})
/// and it used a nonce for verification.

///|
/// The confidence of the command line value which is determined by how the value was
/// obtained. This depends upon the implementation of the shell integration script.

///|
/// The command line that was executed. The {@link TerminalShellExecutionCommandLineConfidence confidence}
/// of this value depends on the specific shell's shell integration implementation. This
/// value may become more accurate after {@link window.onDidEndTerminalShellExecution} is
/// fired.
///
/// @example
/// // Log the details of the command line on start and end
/// window.onDidStartTerminalShellExecution(event => {
///   const commandLine = event.execution.commandLine;
///   console.log(`Command started\n${summarizeCommandLine(commandLine)}`);
/// });
/// window.onDidEndTerminalShellExecution(event => {
///   const commandLine = event.execution.commandLine;
///   console.log(`Command ended\n${summarizeCommandLine(commandLine)}`);
/// });
/// function summarizeCommandLine(commandLine: TerminalShellExecutionCommandLine) {
///   return [
///     `  Command line: ${command.commandLine.value}`,
///     `  Confidence: ${command.commandLine.confidence}`,
///     `  Trusted: ${command.commandLine.isTrusted}
///   ].join('\n');
/// }
pub fn TerminalShellExecution::new(
  command_line : TerminalShellExecutionCommandLine,
  cwd? : Uri,
) -> TerminalShellExecution {
  TerminalShellExecution::{ commandLine: command_line, cwd }
}

///|

///|
/// The working directory that was reported by the shell when this command executed. This
/// {@link Uri} may represent a file on another machine (eg. ssh into another machine). This
/// requires the shell integration to support working directory reporting.

///|
/// The current working directory of the terminal. This {@link Uri} may represent a file on
/// another machine (eg. ssh into another machine). This requires the shell integration to
/// support working directory reporting.

///|
/// Execute a command, sending ^C as necessary to interrupt any running command if needed.
///
/// @param commandLine The command line to execute, this is the exact text that will be sent
/// to the terminal.
///
/// @throws When run on a terminal doesn't support this API, such as task terminals.
///
/// @example
/// // Execute a command in a terminal immediately after being created
/// const myTerm = window.createTerminal();
/// window.onDidChangeTerminalShellIntegration(async ({ terminal, shellIntegration }) => {
///   if (terminal === myTerm) {
///     const execution = shellIntegration.executeCommand('echo "Hello world"');
///     window.onDidEndTerminalShellExecution(event => {
///       if (event.execution === execution) {
///         console.log(`Command exited with code ${event.exitCode}`);
///       }
///     });
///   }
/// }));
/// // Fallback to sendText if there is no shell integration within 3 seconds of launching
/// setTimeout(() => {
///   if (!myTerm.shellIntegration) {
///     myTerm.sendText('echo "Hello world"');
///     // Without shell integration, we can't know when the command has finished or what the
///     // exit code was.
///   }
/// }, 3000);
///
/// @example
/// // Send command to terminal that has been alive for a while
/// const commandLine = 'echo "Hello world"';
/// if (term.shellIntegration) {
///   const execution = shellIntegration.executeCommand({ commandLine });
///   window.onDidEndTerminalShellExecution(event => {
///     if (event.execution === execution) {
///       console.log(`Command exited with code ${event.exitCode}`);
///     }
///   });
/// } else {
///   term.sendText(commandLine);
///   // Without shell integration, we can't know when the command has finished or what the
///   // exit code was.
/// }
pub extern "js" fn TerminalShellIntegration::execute_command_line(
  self : TerminalShellIntegration,
  command_line : String,
) -> TerminalShellExecution =
  #| (integration, commandLine) => integration.executeCommand(commandLine)

///|
/// Execute a command, sending ^C as necessary to interrupt any running command if needed.
///
/// @param commandLine The command line to execute, this is the exact text that will be sent
/// to the terminal.
///
/// @throws When run on a terminal doesn't support this API, such as task terminals.
///
/// @example
/// // Execute a command in a terminal immediately after being created
/// const myTerm = window.createTerminal();
/// window.onDidChangeTerminalShellIntegration(async ({ terminal, shellIntegration }) => {
///   if (terminal === myTerm) {
///     const execution = shellIntegration.executeCommand('echo "Hello world"');
///     window.onDidEndTerminalShellExecution(event => {
///       if (event.execution === execution) {
///         console.log(`Command exited with code ${event.exitCode}`);
///       }
///     });
///   }
/// }));
/// // Fallback to sendText if there is no shell integration within 3 seconds of launching
/// setTimeout(() => {
///   if (!myTerm.shellIntegration) {
///     myTerm.sendText('echo "Hello world"');
///     // Without shell integration, we can't know when the command has finished or what the
///     // exit code was.
///   }
/// }, 3000);
///
/// @example
/// // Send command to terminal that has been alive for a while
/// const commandLine = 'echo "Hello world"';
/// if (term.shellIntegration) {
///   const execution = shellIntegration.executeCommand({ commandLine });
///   window.onDidEndTerminalShellExecution(event => {
///     if (event.execution === execution) {
///       console.log(`Command exited with code ${event.exitCode}`);
///     }
///   });
/// } else {
///   term.sendText(commandLine);
///   // Without shell integration, we can't know when the command has finished or what the
///   // exit code was.
/// }
pub extern "js" fn TerminalShellIntegration::execute_command(
  self : TerminalShellIntegration,
  executable : String,
  args : Array[String],
) -> TerminalShellExecution =
  #| (integration, executable, args) => integration.executeCommand(executable, args)

///|
pub fn TerminalProfile::from_terminal(
  options : TerminalOptions,
) -> TerminalProfile {
  terminal_profile_from_terminal_ffi(options)
}

///|
pub fn TerminalProfile::from_extension(
  options : ExtensionTerminalOptions,
) -> TerminalProfile {
  terminal_profile_from_extension_ffi(options)
}

///|
extern "js" fn terminal_profile_from_terminal_ffi(
  options : TerminalOptions,
) -> TerminalProfile =
  #| (options) => ({ options })

///|
extern "js" fn terminal_profile_from_extension_ffi(
  options : ExtensionTerminalOptions,
) -> TerminalProfile =
  #| (options) => ({ options })

///|
/// The options that the terminal will launch with.

///|
/// Creates a new terminal link.
/// @param startIndex The start index of the link on {@link TerminalLinkContext.line}.
/// @param length The length of the link on {@link TerminalLinkContext.line}.
/// @param tooltip The tooltip text when you hover over this link.
///
/// If a tooltip is provided, is will be displayed in a string that includes instructions on
/// how to trigger the link, such as `{0} (ctrl + click)`. The specific instructions vary
/// depending on OS, user settings, and localization.
pub fn TerminalLink::new(
  start_index : Int,
  length : Int,
  tooltip? : String,
) -> TerminalLink {
  terminal_link_ffi(start_index, length, option_to_js(tooltip))
}

///|
/// The start index of the link on {@link TerminalLinkContext.line}.
pub extern "js" fn TerminalLink::start_index(self : TerminalLink) -> Int =
  #| (value) => value.startIndex

///|
/// The length of the link on {@link TerminalLinkContext.line}.
pub extern "js" fn TerminalLink::length(self : TerminalLink) -> Int =
  #| (value) => value.length

///|
/// The tooltip text when you hover over this link.
///
/// If a tooltip is provided, is will be displayed in a string that includes instructions on
/// how to trigger the link, such as `{0} (ctrl + click)`. The specific instructions vary
/// depending on OS, user settings, and localization.
pub fn TerminalLink::tooltip(self : TerminalLink) -> String? {
  let raw = TerminalLink::terminal_link_tooltip_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// The tooltip text when you hover over this link.
///
/// If a tooltip is provided, is will be displayed in a string that includes instructions on
/// how to trigger the link, such as `{0} (ctrl + click)`. The specific instructions vary
/// depending on OS, user settings, and localization.
pub fn TerminalLink::set_tooltip(self : TerminalLink, value : String) -> Unit {
  TerminalLink::terminal_link_set_tooltip_raw(self, JsValue::make(value))
}

///|
/// The tooltip text when you hover over this link.
///
/// If a tooltip is provided, is will be displayed in a string that includes instructions on
/// how to trigger the link, such as `{0} (ctrl + click)`. The specific instructions vary
/// depending on OS, user settings, and localization.
pub fn TerminalLink::clear_tooltip(self : TerminalLink) -> Unit {
  TerminalLink::terminal_link_set_tooltip_raw(self, JsValue::make(()))
}

///|
pub fn TerminalLinkContext::new(
  line : String,
  terminal : Terminal,
) -> TerminalLinkContext {
  TerminalLinkContext::{ line, terminal }
}

///|
extern "js" fn terminal_link_ffi(
  start_index : Int,
  length : Int,
  tooltip : JsValue,
) -> TerminalLink =
  #| (startIndex, length, tooltip) =>
  #|   tooltip === undefined || tooltip === null
  #|     ? new (require("vscode").TerminalLink)(startIndex, length)
  #|     : new (require("vscode").TerminalLink)(startIndex, length, tooltip)

///|
extern "js" fn TerminalLink::terminal_link_tooltip_raw(
  self : TerminalLink,
) -> JsValue =
  #| (value) => value.tooltip

///|
extern "js" fn TerminalLink::terminal_link_set_tooltip_raw(
  self : TerminalLink,
  value : JsValue,
) -> Unit =
  #| (item, value) => { item.tooltip = value === undefined || value === null ? undefined : value; }

///|
/// This is the text from the unwrapped line in the terminal.

///|
/// The terminal the link belongs to.

///|
pub fn Pseudoterminal::new(
  on_did_write : Event[String],
  open : (TerminalDimensions?) -> Unit,
  close : () -> Unit,
  on_did_override_dimensions? : Event[TerminalDimensions?],
  on_did_close? : Event[Int?],
  on_did_change_name? : Event[String],
  handle_input? : (String) -> Unit,
  set_dimensions? : (TerminalDimensions) -> Unit,
) -> Pseudoterminal {
  let open_raw = (value : JsValue) => {
    let dimensions : TerminalDimensions? = if value.is_null_or_undefined() {
      None
    } else {
      terminal_dimensions_from_js(value)
    }
    open(dimensions)
  }
  let set_dimensions_raw : ((JsValue) -> Unit)? = match set_dimensions {
    None => None
    Some(callback) =>
      Some(value => {
        match terminal_dimensions_from_js(value) {
          Some(dimensions) => callback(dimensions)
          None => ()
        }
      })
  }
  pseudoterminal_ffi(
    on_did_write,
    option_to_js(on_did_override_dimensions),
    option_to_js(on_did_close),
    option_to_js(on_did_change_name),
    open_raw,
    close,
    option_to_js(handle_input),
    option_to_js(set_dimensions_raw),
  )
}

///|
extern "js" fn pseudoterminal_ffi(
  on_did_write : Event[String],
  on_did_override_dimensions : JsValue,
  on_did_close : JsValue,
  on_did_change_name : JsValue,
  open : (JsValue) -> Unit,
  close : () -> Unit,
  handle_input : JsValue,
  set_dimensions : JsValue,
) -> Pseudoterminal =
  #| (
  #|   onDidWrite,
  #|   onDidOverrideDimensions,
  #|   onDidClose,
  #|   onDidChangeName,
  #|   open,
  #|   close,
  #|   handleInput,
  #|   setDimensions
  #| ) => {
  #|   const pty = { onDidWrite, open, close };
  #|   if (onDidOverrideDimensions !== undefined && onDidOverrideDimensions !== null) {
  #|     pty.onDidOverrideDimensions = onDidOverrideDimensions;
  #|   }
  #|   if (onDidClose !== undefined && onDidClose !== null) pty.onDidClose = onDidClose;
  #|   if (onDidChangeName !== undefined && onDidChangeName !== null) {
  #|     pty.onDidChangeName = onDidChangeName;
  #|   }
  #|   if (handleInput !== undefined && handleInput !== null) pty.handleInput = handleInput;
  #|   if (setDimensions !== undefined && setDimensions !== null) {
  #|     pty.setDimensions = setDimensions;
  #|   }
  #|   return pty;
  #| }

///|
extern "js" fn terminal_dimensions_columns_raw(value : JsValue) -> JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.columns

///|
extern "js" fn terminal_dimensions_rows_raw(value : JsValue) -> JsValue =
  #| (value) => value === undefined || value === null ? undefined : value.rows
