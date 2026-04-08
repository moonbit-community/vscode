///|
/// VS Code Commands API bindings for the JS backend.
using @vscode {type Any, type TextEditor, type TextEditorEdit}

///|
pub struct CommandArgs {
  values : Array[Any]
}

///|
type CommandHandler = (Array[Any]) -> Any

///|
type TextEditorCommandHandler = (TextEditor, TextEditorEdit, Array[Any]) -> Any

///|

///|
fn command_args_from_js(args : Array[Any]) -> CommandArgs {
  CommandArgs::{ values: args }
}

///|
fn command_args_to_js(args : CommandArgs) -> Array[Any] {
  args.values
}

///|
fn[T] to_json_value(value : T) -> Any {
  @v.JsValue::make(value).cast()
}

///|
fn[T] from_json_value(value : Any) -> T {
  @v.JsValue::make(value).cast()
}

///|

///|
pub fn command_args() -> CommandArgs {
  command_args_from_js([])
}

///|
pub fn[T] command_args_from_array(values : Array[T]) -> CommandArgs {
  let raw = values.map(value => to_json_value(value))
  command_args_from_js(raw)
}

///|
pub fn[T] command_args1(value : T) -> CommandArgs {
  command_args_from_js([to_json_value(value)])
}

///|
pub fn[A, B] command_args2(first : A, second : B) -> CommandArgs {
  command_args_from_js([to_json_value(first), to_json_value(second)])
}

///|
pub fn[A, B, C] command_args3(first : A, second : B, third : C) -> CommandArgs {
  command_args_from_js([
    to_json_value(first),
    to_json_value(second),
    to_json_value(third),
  ])
}

///|
pub fn CommandArgs::length(self : CommandArgs) -> Int {
  command_args_to_js(self).length()
}

///|
pub fn[X] CommandArgs::get(self : CommandArgs, index : Int) -> X? {
  let raw = command_args_to_js(self)
  if index < 0 || index >= raw.length() {
    None
  } else {
    Some(from_json_value(raw[index]))
  }
}

///|
/// Registers a command that can be invoked via a keyboard shortcut,
/// a menu item, an action, or directly.
///
/// Registering a command with an existing command identifier twice
/// will cause an error.
///
/// @param command A unique identifier for the command.
/// @param callback A command handler function.
/// @param thisArg The `this` context used when invoking the handler function.
/// @returns Disposable which unregisters this command on disposal.
pub fn[X] register_command(
  command : String,
  handler : (CommandArgs) -> X,
) -> &@vscode.Disposable {
  register_command_ffi(command, args => {
    to_json_value(handler(command_args_from_js(args)))
  })
}

///|
/// Registers a command that can be invoked via a keyboard shortcut,
/// a menu item, an action, or directly.
///
/// Registering a command with an existing command identifier twice
/// will cause an error.
///
/// @param command A unique identifier for the command.
/// @param callback A command handler function.
/// @param thisArg The `this` context used when invoking the handler function.
/// @returns Disposable which unregisters this command on disposal.
pub fn[X] register_command_async(
  command : String,
  handler : async (CommandArgs) -> X,
) -> &@vscode.Disposable {
  register_command_ffi(command, args => {
    let promise = @js_async.Promise::from_async(() => {
      handler(command_args_from_js(args))
    })
    to_json_value(promise)
  })
}

///|
/// Registers a text editor command that can be invoked via a keyboard shortcut,
/// a menu item, an action, or directly.
///
/// Text editor commands are different from ordinary {@link commands.registerCommand commands} as
/// they only execute when there is an active editor when the command is called. Also, the
/// command handler of an editor command has access to the active editor and to an
/// {@link TextEditorEdit edit}-builder. Note that the edit-builder is only valid while the
/// callback executes.
///
/// @param command A unique identifier for the command.
/// @param callback A command handler function with access to an {@link TextEditor editor} and an {@link TextEditorEdit edit}.
/// @param thisArg The `this` context used when invoking the handler function.
/// @returns Disposable which unregisters this command on disposal.
pub fn register_text_editor_command(
  command : String,
  handler : (TextEditor, TextEditorEdit, CommandArgs) -> Unit,
) -> &@vscode.Disposable {
  register_text_editor_command_ffi(command, (editor, edit, args) => {
    handler(editor, edit, command_args_from_js(args))
    to_json_value(())
  })
}

///|
/// Registers a text editor command that can be invoked via a keyboard shortcut,
/// a menu item, an action, or directly.
///
/// Text editor commands are different from ordinary {@link commands.registerCommand commands} as
/// they only execute when there is an active editor when the command is called. Also, the
/// command handler of an editor command has access to the active editor and to an
/// {@link TextEditorEdit edit}-builder. Note that the edit-builder is only valid while the
/// callback executes.
///
/// @param command A unique identifier for the command.
/// @param callback A command handler function with access to an {@link TextEditor editor} and an {@link TextEditorEdit edit}.
/// @param thisArg The `this` context used when invoking the handler function.
/// @returns Disposable which unregisters this command on disposal.
pub fn register_text_editor_command_async(
  command : String,
  handler : async (TextEditor, TextEditorEdit, CommandArgs) -> Unit,
) -> &@vscode.Disposable {
  register_text_editor_command_ffi(command, (editor, edit, args) => {
    let promise = @js_async.Promise::from_async(() => {
      handler(editor, edit, command_args_from_js(args))
    })
    to_json_value(promise)
  })
}

///|
/// Execute a VS Code command and return the raw JS promise.
fn execute_command_promise(
  command : String,
  args : Array[Any],
) -> @js_async.Promise[Any] {
  execute_command_ffi(command, args)
}

///|
/// Executes the command denoted by the given command identifier.
///
/// * *Note 1:* When executing an editor command not all types are allowed to
/// be passed as arguments. Allowed are the primitive types `string`, `boolean`,
/// `number`, `undefined`, and `null`, as well as {@linkcode Position}, {@linkcode Range}, {@linkcode Uri} and {@linkcode Location}.
/// * *Note 2:* There are no restrictions when executing commands that have been contributed
/// by extensions.
///
/// @param command Identifier of the command to execute.
/// @param rest Parameters passed to the command function.
/// @returns A thenable that resolves to the returned value of the given command. Returns `undefined` when
/// the command handler function doesn't return anything.
pub async fn[X] execute_command(command : String, args? : CommandArgs) -> X {
  let raw_args = match args {
    None => []
    Some(value) => command_args_to_js(value)
  }
  from_json_value(
    @js_async.Promise::wait(execute_command_promise(command, raw_args)),
  )
}

///|
/// Get all command ids, optionally including internal commands.
fn get_commands_promise(
  filter_internal? : Bool = false,
) -> @js_async.Promise[Array[String]] {
  get_commands_ffi(filter_internal)
}

///|
/// Retrieve the list of all available commands. Commands starting with an underscore are
/// treated as internal commands.
///
/// @param filterInternal Set `true` to not see internal commands (starting with an underscore)
/// @returns Thenable that resolves to a list of command ids.
pub async fn get_commands(filter_internal? : Bool = false) -> Array[String] {
  @js_async.Promise::wait(get_commands_promise(filter_internal~))
}

///|
/// Check if a command exists using the JS promise chain.
fn get_commands_contains_promise(
  command : String,
  filter_internal? : Bool = false,
) -> @js_async.Promise[Bool] {
  get_commands_contains_ffi(command, filter_internal)
}

///|
/// Retrieve the list of all available commands. Commands starting with an underscore are
/// treated as internal commands.
///
/// @param filterInternal Set `true` to not see internal commands (starting with an underscore)
/// @returns Thenable that resolves to a list of command ids.
pub async fn get_commands_contains(
  command : String,
  filter_internal? : Bool = false,
) -> Bool {
  @js_async.Promise::wait(
    get_commands_contains_promise(command, filter_internal~),
  )
}
