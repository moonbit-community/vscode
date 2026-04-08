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
fn progress_options(title : String) -> @vscode.ProgressOptions {
  @vscode.ProgressOptions::new(
    @window.progress_location_notification(),
    title=title,
    cancellable=true,
  )
}

///|
pub async fn run_progress_demo() -> Unit {
  let _ = @window.with_progress(progress_options("I am long running!"), async fn(
    progress,
    token,
  ) {
    let _ = token.on_cancellation_requested.subscribe(_ => {
      println("User canceled the long running operation")
    })

    progress.report(step(increment=0))
    @async.sleep(1000)
    progress.report(
      step(increment=10, message="I am long running! - still going..."),
    )
    @async.sleep(1000)
    progress.report(
      step(
        increment=40,
        message="I am long running! - still going even more...",
      ),
    )
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
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  subscriptions.push(@commands.register_command_async("extension.startTask", async fn(
    _args,
  ) {
    run_progress_demo()
  }))
}
