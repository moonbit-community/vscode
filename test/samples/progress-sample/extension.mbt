///|
/// MoonBit port of `progress-sample`.
async fn run_progress_task() -> Unit {
  let options = @window.progress_options(
    @window.progress_location_notification(),
    title="I am long running!",
    cancellable=true,
  )

  let progress_task : async (
    @vscode.Progress[Unit],
    @vscode.CancellationToken,
  ) -> Unit = fn(progress, token) {
    let on_cancel = token.on_cancellation_requested.subscribe(fn(_value) {
      ()
    })
    @window.progress_report_message_increment(progress, "", increment=0)
    @window.progress_report_message_increment(
      progress,
      "I am long running! - still going...",
      increment=10,
    )
    @window.progress_report_message_increment(
      progress,
      "I am long running! - still going even more...",
      increment=40,
    )
    @window.progress_report_message_increment(
      progress,
      "I am long running! - almost there...",
      increment=50,
    )
    on_cancel.dispose()
    ()
  }
  let _ = @window.with_progress(options, progress_task)
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let disposable = @commands.register_command_async(
    "extension.startTask",
    async fn(_args) {
      run_progress_task()
    },
  )
  subscriptions.push(disposable)
}

pub fn deactivate() -> Unit {
  ()
}
