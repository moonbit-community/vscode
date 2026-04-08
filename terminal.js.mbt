///|
/// Terminal-related option helpers and types.

///|
pub(all) enum TerminalLocation {
  Panel = 1
  Editor = 2
} derive(Eq)

///|
/// Assumes a {@link TerminalLocation} of editor and allows specifying a {@link ViewColumn} and
/// {@link TerminalEditorLocationOptions.preserveFocus preserveFocus } property
pub(all) struct TerminalEditorLocationOptions {
  mut view_column : ViewColumn
  mut preserve_focus : Bool?
}

///|
/// Uses the parent {@link Terminal}'s location for the terminal
pub(all) struct TerminalSplitLocationOptions {
  mut parent_terminal : Terminal
}

///|
pub(all) enum TerminalLocationValue {
  Location(TerminalLocation)
  Editor(TerminalEditorLocationOptions)
  Split(TerminalSplitLocationOptions)
}

///|
/// Defines the interface of a terminal pty, enabling extensions to control a terminal.
pub(all) struct Pseudoterminal {
  mut on_did_write : Event[String]
  mut on_did_override_dimensions : Event[TerminalDimensions?]?
  mut on_did_close : Event[Int?]?
  mut on_did_change_name : Event[String]?
  open : (TerminalDimensions?) -> Unit
  close : () -> Unit
  handle_input : ((String) -> Unit)?
  set_dimensions : ((TerminalDimensions) -> Unit)?
}

///|
pub fn TerminalEditorLocationOptions::new(
  view_column : ViewColumn,
  preserve_focus? : Bool,
) -> TerminalEditorLocationOptions {
  TerminalEditorLocationOptions::{ view_column, preserve_focus }
}

///|
pub fn TerminalSplitLocationOptions::new(
  parent_terminal : Terminal,
) -> TerminalSplitLocationOptions {
  TerminalSplitLocationOptions::{ parent_terminal, }
}

///|
fn TerminalLocationValue::to_js(self : TerminalLocationValue) -> JsValue {
  match self {
    Location(location) => JsValue::make(location)
    Editor(options) => terminal_editor_location_options_to_js(options)
    Split(options) => terminal_split_location_options_to_js(options)
  }
}

///|
fn option_terminal_location_value_to_js(
  value : TerminalLocationValue?,
) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
}

///|
fn terminal_view_column_to_js_value(value : ViewColumn) -> JsValue {
  let raw = match value {
    Active => -1
    Beside => -2
    One => 1
    Two => 2
    Three => 3
    Four => 4
    Five => 5
    Six => 6
    Seven => 7
    Eight => 8
    Nine => 9
    Custom(value) => value
  }
  JsValue::make(raw)
}

///|
fn terminal_editor_location_options_to_js(
  value : TerminalEditorLocationOptions,
) -> JsValue {
  terminal_editor_location_options_to_js_ffi(
    terminal_view_column_to_js_value(value.view_column),
    option_to_js(value.preserve_focus),
  )
}

///|
fn terminal_split_location_options_to_js(
  value : TerminalSplitLocationOptions,
) -> JsValue {
  terminal_split_location_options_to_js_ffi(value.parent_terminal)
}

///|
pub fn TerminalOptions::new(
  name? : String,
  shell_path? : String,
  shell_args? : ShellArgs,
  cwd? : UriOrString,
  env? : Array[(String, String?)],
  strict_env? : Bool,
  hide_from_user? : Bool,
  message? : String,
  icon_path? : IconPath,
  color? : ThemeColor,
  location? : TerminalLocationValue,
  is_transient? : Bool,
  shell_integration_nonce? : String,
) -> TerminalOptions {
  let cwd_js = match cwd {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
  terminal_options_ffi(
    option_to_js(name),
    option_to_js(shell_path),
    option_shell_args_to_js(shell_args),
    cwd_js,
    env_to_js(env),
    option_to_js(strict_env),
    option_to_js(hide_from_user),
    option_to_js(message),
    option_icon_path_to_js(icon_path),
    option_to_js(color),
    option_terminal_location_value_to_js(location),
    option_to_js(is_transient),
    option_to_js(shell_integration_nonce),
  )
}

///|
pub fn ExtensionTerminalOptions::new(
  name : String,
  pty : Pseudoterminal,
  icon_path? : IconPath,
  color? : ThemeColor,
  location? : TerminalLocationValue,
  is_transient? : Bool,
  shell_integration_nonce? : String,
) -> ExtensionTerminalOptions {
  extension_terminal_options_ffi(
    name,
    pty,
    option_icon_path_to_js(icon_path),
    option_to_js(color),
    option_terminal_location_value_to_js(location),
    option_to_js(is_transient),
    option_to_js(shell_integration_nonce),
  )
}

///|
pub(all) enum TerminalCreationOptions {
  Terminal(TerminalOptions)
  Extension(ExtensionTerminalOptions)
}

///|
fn TerminalCreationOptions::from_js(value : JsValue) -> TerminalCreationOptions {
  if terminal_creation_options_is_extension(value) {
    Extension(JsValue::make(value).cast())
  } else {
    Terminal(JsValue::make(value).cast())
  }
}

///|
pub fn TerminalCreationOptions::as_terminal(
  value : TerminalCreationOptions,
) -> TerminalOptions? {
  match value {
    Terminal(value) => Some(value)
    Extension(_) => None
  }
}

///|
pub fn TerminalCreationOptions::as_extension(
  value : TerminalCreationOptions,
) -> ExtensionTerminalOptions? {
  match value {
    Terminal(_) => None
    Extension(value) => Some(value)
  }
}

///|
/// Whether the {@link Terminal} has been interacted with. Interaction means that the
/// terminal has sent data to the process which depending on the terminal's _mode_. By
/// default input is sent when a key is pressed or when a command or extension sends text,
/// but based on the terminal's mode it can also happen on:
///
/// - a pointer click event
/// - a pointer scroll event
/// - a pointer move event
/// - terminal focus in/out
///
/// For more information on events that can send data see "DEC Private Mode Set (DECSET)" on
/// https://invisible-island.net/xterm/ctlseqs/ctlseqs.html
pub fn TerminalState::new(
  is_interacted_with : Bool,
  shell? : String,
) -> TerminalState {
  TerminalState::{ isInteractedWith: is_interacted_with, shell }
}

///|
/// Whether the {@link Terminal} has been interacted with. Interaction means that the
/// terminal has sent data to the process which depending on the terminal's _mode_. By
/// default input is sent when a key is pressed or when a command or extension sends text,
/// but based on the terminal's mode it can also happen on:
///
/// - a pointer click event
/// - a pointer scroll event
/// - a pointer move event
/// - terminal focus in/out
///
/// For more information on events that can send data see "DEC Private Mode Set (DECSET)" on
/// https://invisible-island.net/xterm/ctlseqs/ctlseqs.html

///|
/// The detected shell type of the {@link Terminal}. This will be `undefined` when there is
/// not a clear signal as to what the shell is, or the shell is not supported yet. This
/// value should change to the shell type of a sub-shell when launched (for example, running
/// `bash` inside `zsh`).
///
/// Note that the possible values are currently defined as any of the following:
/// 'bash', 'cmd', 'csh', 'fish', 'gitbash', 'julia', 'ksh', 'node', 'nu', 'pwsh', 'python',
/// 'sh', 'wsl', 'xonsh', 'zsh'.

///|
fn env_to_js(values : Array[(String, String?)]?) -> JsValue {
  match values {
    None => JsValue::make(())
    Some(entries) => terminal_env_map_ffi(entries)
  }
}

///|

///|
extern "js" fn terminal_editor_location_options_to_js_ffi(
  view_column : JsValue,
  preserve_focus : JsValue,
) -> JsValue =
  #| (viewColumn, preserveFocus) => {
  #|   const options = { viewColumn };
  #|   if (preserveFocus !== undefined && preserveFocus !== null) options.preserveFocus = preserveFocus;
  #|   return options;
  #| }

///|
extern "js" fn terminal_split_location_options_to_js_ffi(
  parent_terminal : Terminal,
) -> JsValue =
  #| (parentTerminal) => ({ parentTerminal })

///|
extern "js" fn terminal_env_map_ffi(
  entries : Array[(String, String?)],
) -> JsValue =
  #| (entries) => {
  #|   const env = {};
  #|   for (const entry of entries) {
  #|     const key = entry._0 ?? entry[0];
  #|     const value = entry._1 ?? entry[1];
  #|     env[key] = value === undefined ? null : value;
  #|   }
  #|   return env;
  #| }

///|
extern "js" fn terminal_options_ffi(
  name : JsValue,
  shell_path : JsValue,
  shell_args : JsValue,
  cwd : JsValue,
  env : JsValue,
  strict_env : JsValue,
  hide_from_user : JsValue,
  message : JsValue,
  icon_path : JsValue,
  color : JsValue,
  location : JsValue,
  is_transient : JsValue,
  shell_integration_nonce : JsValue,
) -> TerminalOptions =
  #| (name, shellPath, shellArgs, cwd, env, strictEnv, hideFromUser, message, iconPath, color, location, isTransient, shellIntegrationNonce) => {
  #|   const options = {};
  #|   if (name !== undefined && name !== null) options.name = name;
  #|   if (shellPath !== undefined && shellPath !== null) options.shellPath = shellPath;
  #|   if (shellArgs !== undefined && shellArgs !== null) options.shellArgs = shellArgs;
  #|   if (cwd !== undefined && cwd !== null) options.cwd = cwd;
  #|   if (env !== undefined && env !== null) options.env = env;
  #|   if (strictEnv !== undefined && strictEnv !== null) options.strictEnv = strictEnv;
  #|   if (hideFromUser !== undefined && hideFromUser !== null) options.hideFromUser = hideFromUser;
  #|   if (message !== undefined && message !== null) options.message = message;
  #|   if (iconPath !== undefined && iconPath !== null) options.iconPath = iconPath;
  #|   if (color !== undefined && color !== null) options.color = color;
  #|   if (location !== undefined && location !== null) options.location = location;
  #|   if (isTransient !== undefined && isTransient !== null) options.isTransient = isTransient;
  #|   if (shellIntegrationNonce !== undefined && shellIntegrationNonce !== null) {
  #|     options.shellIntegrationNonce = shellIntegrationNonce;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn extension_terminal_options_ffi(
  name : String,
  pty : Pseudoterminal,
  icon_path : JsValue,
  color : JsValue,
  location : JsValue,
  is_transient : JsValue,
  shell_integration_nonce : JsValue,
) -> ExtensionTerminalOptions =
  #| (name, pty, iconPath, color, location, isTransient, shellIntegrationNonce) => {
  #|   const options = { name, pty };
  #|   if (iconPath !== undefined && iconPath !== null) options.iconPath = iconPath;
  #|   if (color !== undefined && color !== null) options.color = color;
  #|   if (location !== undefined && location !== null) options.location = location;
  #|   if (isTransient !== undefined && isTransient !== null) options.isTransient = isTransient;
  #|   if (shellIntegrationNonce !== undefined && shellIntegrationNonce !== null) {
  #|     options.shellIntegrationNonce = shellIntegrationNonce;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn terminal_creation_options_is_extension(value : JsValue) -> Bool =
  #| (value) => value && typeof value === 'object' && value.pty !== undefined
