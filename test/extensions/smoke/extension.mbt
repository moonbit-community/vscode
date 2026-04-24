///|
let echo_command = "vscode-mbt-tests.echo"

///|
let has_command_command = "vscode-mbt-tests.hasCommand"

///|
let status_bar_command = "vscode-mbt-tests.statusBar"

///|
let workspace_edit_command = "vscode-mbt-tests.workspaceEdit"

///|
let event_command = "vscode-mbt-tests.event"

///|
priv struct SmokeDisposable {
  name : String
}

///|
priv struct EventState {
  mut sync_value : String
  mut sync_count : Int
  mut async_value : String
  mut async_count : Int
}

///|
impl @vscode.Disposable for SmokeDisposable with dispose(self) {
  write_disposable_marker(self.name)
}

///|
fn SmokeDisposable::new(name : String) -> &@vscode.Disposable {
  SmokeDisposable::{ name }
}

///|
extern "js" fn write_disposable_marker(name : String) -> Unit =
  #| (name) => {
  #|   const marker = process.env.VSCODE_MBT_SMOKE_DISPOSE_MARKER;
  #|   if (marker) {
  #|     require("fs").appendFileSync(marker, `${name}\n`, "utf8");
  #|   }
  #| }

///|
extern "js" fn wait_next_tick_ffi() -> @js_async.Promise[Unit] =
  #| () => new Promise(resolve => setTimeout(resolve, 0))

///|
async fn wait_next_tick() -> Unit {
  @js_async.Promise::wait(wait_next_tick_ffi())
}

///|
fn echo(args : @commands.CommandArgs) -> String {
  let value : String? = args.get(0)
  match value {
    Some(value) => "moonbit:\{value}"
    None => "moonbit:"
  }
}

///|
async fn has_command(args : @commands.CommandArgs) -> Bool {
  let command : String? = args.get(0)
  match command {
    Some(command) => @commands.get_commands_contains(command)
    None => false
  }
}

///|
fn status_bar_value(item : @vscode.StatusBarItem) -> String {
  item.set_text("MoonBit binding smoke")
  item.show()
  "\{item.id()}|\{item.text()}"
}

///|
async fn apply_workspace_edit(args : @commands.CommandArgs) -> String {
  let path : String? = args.get(0)
  match path {
    None => "missing path"
    Some(path) => {
      let document = @workspace.open_text_document_path(path)
      let edit = @vscode.WorkspaceEdit::new()
      edit.insert(document.uri(), @vscode.Position::new(0, 0), "moonbit:")
      let applied = @workspace.apply_edit(edit)
      if applied {
        document.get_text()
      } else {
        "apply_edit:false"
      }
    }
  }
}

///|
async fn event_behavior(_args : @commands.CommandArgs) -> String {
  let emitter : @vscode.EventEmitter[String] = @vscode.EventEmitter::new()
  let state = EventState::{
    sync_value: "none",
    sync_count: 0,
    async_value: "none",
    async_count: 0,
  }
  let sync_subscription = emitter.event().subscribe(value => {
    state.sync_value = value
    state.sync_count = state.sync_count + 1
  })
  emitter.fire("sync-1")
  @vscode.disposable_dispose(sync_subscription)
  emitter.fire("sync-ignored")
  let async_subscription = emitter.event().subscribe_async(async fn(value) {
    wait_next_tick()
    state.async_value = value
    state.async_count = state.async_count + 1
  })
  emitter.fire("async-1")
  wait_next_tick()
  wait_next_tick()
  @vscode.disposable_dispose(async_subscription)
  emitter.fire("async-ignored")
  wait_next_tick()
  wait_next_tick()
  emitter.dispose()
  "\{state.sync_count}|\{state.sync_value}|\{state.async_count}|\{state.async_value}"
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let status = @window.create_status_bar_item_with_id(
    "vscode-mbt-tests.status",
    alignment=@vscode.StatusBarAlignment::Left,
    priority=100,
  )
  ctx.subscribe(SmokeDisposable::{ name: "trait-disposable" })
  ctx.subscribe(@vscode.disposable_new(fn() {
    write_disposable_marker("callback-disposable")
  }))
  ctx.subscribe(
    @vscode.disposable_from([
      @vscode.disposable_new(fn() {
        write_disposable_marker("combined-callback-disposable")
      }),
      SmokeDisposable::new("combined-trait-disposable"),
    ]),
  )
  ctx.subscribe(status)
  ctx.subscribe(@commands.register_command(echo_command, echo))
  ctx.subscribe(@commands.register_command_async(has_command_command, has_command))
  ctx.subscribe(
    @commands.register_command(status_bar_command, fn(_args) {
      status_bar_value(status)
    }),
  )
  ctx.subscribe(
    @commands.register_command_async(workspace_edit_command, apply_workspace_edit),
  )
  ctx.subscribe(@commands.register_command_async(event_command, event_behavior))
}

///|
pub fn deactivate() -> Unit {
  ()
}
