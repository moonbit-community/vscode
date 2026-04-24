///|
/// JS FFI bindings for VS Code commands.

///|
extern "js" fn register_command_ffi(
  command : String,
  handler : CommandHandler,
) -> @vscode.Disposable =
  #| (command, handler) => require("vscode").commands.registerCommand(
  #|   command,
  #|   async (...args) => await handler(args),
  #| )

///|
extern "js" fn register_text_editor_command_ffi(
  command : String,
  handler : TextEditorCommandHandler,
) -> @vscode.Disposable =
  #| (command, handler) => require("vscode").commands.registerTextEditorCommand(
  #|   command,
  #|   async (editor, edit, ...args) => await handler(editor, edit, args),
  #| )

///|
extern "js" fn execute_command_ffi(
  command : String,
  args : Array[@vscode.Any],
) -> @js_async.Promise[@vscode.Any] =
  #| (command, args) => require("vscode").commands.executeCommand(command, ...args)

///|
extern "js" fn get_commands_ffi(
  filter_internal : Bool,
) -> @js_async.Promise[Array[String]] =
  #| (filterInternal) => require("vscode").commands.getCommands(filterInternal)

///|
extern "js" fn get_commands_contains_ffi(
  command : String,
  filter_internal : Bool,
) -> @js_async.Promise[Bool] =
  #| (command, filterInternal) =>
  #|   require("vscode").commands.getCommands(filterInternal).then(list => list.includes(command))
