///|
/// MoonBit port of `wasm-component-model-async`.
async fn sleep_millis(ms : Int) -> Unit {
  let progress_task : async (
    @vscode.Progress[Unit],
    @vscode.CancellationToken,
  ) -> Unit = fn(_progress, _token) {
    let _ = ms
    ()
  }
  ignore(@window.with_progress(
    @window.progress_options(
      @window.progress_location_window(),
      title="Simulating async calculator",
    ),
    progress_task,
  ))
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let channel = @window.create_output_channel("Calculator")

  let run = @commands.register_command_async(
    "vscode-samples.wasm-component-model-async.run",
    async fn(_args) {
      channel.show()
      channel.append_line("Running calculator example")
      sleep_millis(1)
      channel.append_line("Add \{1 + 2}")
      sleep_millis(1)
      channel.append_line("Sub \{10 - 8}")
      sleep_millis(1)
      channel.append_line("Mul \{3 * 7}")
      sleep_millis(1)
      channel.append_line("Div \{10 / 2}")
    },
  )
  subscriptions.push(run)
}

pub fn deactivate() -> Unit {
  ()
}
