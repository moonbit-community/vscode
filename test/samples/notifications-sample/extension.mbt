///|
/// MoonBit port of `notifications-sample`.
fn modal_options() -> @vscode.MessageOptions {
  @vscode.MessageOptions::new(modal=true)
}

async fn run_progress_notification() -> Unit {
  let options = @window.progress_options(
    @window.progress_location_notification(),
    title="Progress Notification",
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
      "Still going...",
      increment=10,
    )
    @window.progress_report_message_increment(
      progress,
      "Still going even more...",
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

  let show_info = @commands.register_command_async(
    "notifications-sample.showInfo",
    async fn(_args) {
      ignore(@window.show_information_message("Info Notification"))
    },
  )
  subscriptions.push(show_info)

  let show_info_modal = @commands.register_command_async(
    "notifications-sample.showInfoAsModal",
    async fn(_args) {
      ignore(
        @window.show_information_message(
          "Info Notification As Modal",
          options=modal_options(),
        ),
      )
    },
  )
  subscriptions.push(show_info_modal)

  let show_warning = @commands.register_command_async(
    "notifications-sample.showWarning",
    async fn(_args) {
      ignore(@window.show_warning_message("Warning Notification"))
    },
  )
  subscriptions.push(show_warning)

  let show_error = @commands.register_command_async(
    "notifications-sample.showError",
    async fn(_args) {
      ignore(@window.show_error_message("Error Notification"))
    },
  )
  subscriptions.push(show_error)

  let show_warning_actions = @commands.register_command_async(
    "notifications-sample.showWarningWithActions",
    async fn(_args) {
      let selection = @window.show_warning_message_items(
        "Warning Notification With Actions",
        ["Action 1", "Action 2", "Action 3"],
      )

      match selection {
        None => ()
        Some(value) => {
          ignore(
            @window.show_information_message(
              "You selected: \{value}",
              options=modal_options(),
            ),
          )
        }
      }
    },
  )
  subscriptions.push(show_warning_actions)

  let show_progress = @commands.register_command_async(
    "notifications-sample.showProgress",
    async fn(_args) {
      run_progress_notification()
    },
  )
  subscriptions.push(show_progress)

  let show_all = @commands.register_command_async(
    "notifications-sample.showAll",
    async fn(_args) {
      let _ : @vscode.Any = @commands.execute_command(
        "notifications-sample.showInfo",
        args=@commands.command_args(),
      )
      let _ : @vscode.Any = @commands.execute_command(
        "notifications-sample.showWarning",
        args=@commands.command_args(),
      )
      let _ : @vscode.Any = @commands.execute_command(
        "notifications-sample.showWarningWithActions",
        args=@commands.command_args(),
      )
      let _ : @vscode.Any = @commands.execute_command(
        "notifications-sample.showError",
        args=@commands.command_args(),
      )
      let _ : @vscode.Any = @commands.execute_command(
        "notifications-sample.showProgress",
        args=@commands.command_args(),
      )
      let _ : @vscode.Any = @commands.execute_command(
        "notifications-sample.showInfoAsModal",
        args=@commands.command_args(),
      )
    },
  )
  subscriptions.push(show_all)
}

pub fn deactivate() -> Unit {
  ()
}
