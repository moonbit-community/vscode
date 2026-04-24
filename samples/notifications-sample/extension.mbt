///|
pub struct ProgressStep {
  increment : Int?
  message : String?
}

///|
fn step(increment? : Int, message? : String) -> ProgressStep {
  ProgressStep::{ increment, message }
}

///|
fn modal_options() -> @vscode.MessageOptions {
  @vscode.MessageOptions::new(modal=true)
}

///|
fn progress_options() -> @vscode.ProgressOptions {
  @vscode.ProgressOptions::new(
    @window.progress_location_notification(),
    title="Progress Notification",
    cancellable=true,
  )
}

///|
async fn show_progress_notification() -> Unit {
  let _ = @window.with_progress(progress_options(), async fn(progress, token) {
    let _ = token.on_cancellation_requested.subscribe(_ => {
      println("User canceled the long running operation")
    })

    progress.report(step(increment=0))
    @async.sleep(1000)
    progress.report(step(increment=10, message="Still going..."))
    @async.sleep(1000)
    progress.report(step(increment=40, message="Still going even more..."))
    @async.sleep(1000)
    progress.report(
      step(increment=50, message="I am long running! - almost there..."),
    )
    @async.sleep(2000)
    step()
  })
  ()
}

///|
async fn show_warning_with_actions() -> Unit {
  let selection = @window.show_warning_message_items(
    "Warning Notification With Actions",
    ["Action 1", "Action 2", "Action 3"],
  )
  match selection {
    Some(selection) =>
      @window.show_information_message(
        "You selected: \{selection}",
        options=modal_options(),
      )
    None => ()
  }
}

///|
async fn execute_command_unit(command_id : String) -> Unit {
  let result : Unit = @commands.execute_command(command_id)
  result
}

///|
fn spawn_command(command_id : String) -> Unit {
  let _ = @js_async.Promise::from_async(async fn() {
    execute_command_unit(command_id)
  })
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  ctx.subscribe(@commands.register_command_async("notifications-sample.showInfo", async fn(
    _args,
  ) {
    @window.show_information_message("Info Notification")
  }))
  ctx.subscribe(@commands.register_command_async(
    "notifications-sample.showInfoAsModal",
    async fn(_args) {
      @window.show_information_message(
        "Info Notification As Modal",
        options=modal_options(),
      )
    },
  ))
  ctx.subscribe(@commands.register_command_async(
    "notifications-sample.showWarning",
    async fn(_args) {
      @window.show_warning_message("Warning Notification")
    },
  ))
  ctx.subscribe(@commands.register_command_async(
    "notifications-sample.showWarningWithActions",
    async fn(_args) {
      show_warning_with_actions()
    },
  ))
  ctx.subscribe(@commands.register_command_async(
    "notifications-sample.showError",
    async fn(_args) {
      @window.show_error_message("Error Notification")
    },
  ))
  ctx.subscribe(@commands.register_command_async(
    "notifications-sample.showProgress",
    async fn(_args) {
      show_progress_notification()
    },
  ))
  ctx.subscribe(@commands.register_command("notifications-sample.showAll", _args => {
    spawn_command("notifications-sample.showInfo")
    spawn_command("notifications-sample.showWarning")
    spawn_command("notifications-sample.showWarningWithActions")
    spawn_command("notifications-sample.showError")
    spawn_command("notifications-sample.showProgress")
    spawn_command("notifications-sample.showInfoAsModal")
  }))
}
