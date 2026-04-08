///|
/// MoonBit port of `getting-started-sample`.
fn sample_folder_uri(ctx : @vscode.ExtensionContext) -> @vscode.Uri {
  @vscode.Uri::join_path(ctx.extension_uri(), ["sample-folder"])
}

fn source_folder_uri(ctx : @vscode.ExtensionContext) -> @vscode.Uri {
  @vscode.Uri::join_path(ctx.extension_uri(), ["src"])
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let run_command = @commands.register_command_async(
    "getting-started-sample.runCommand",
    async fn(_args) {
      let sample_folder = sample_folder_uri(ctx)
      let _ : @vscode.Any = @commands.execute_command(
        "getting-started-sample.sayHello",
        args=@commands.command_args1(sample_folder),
      )
    },
  )
  subscriptions.push(run_command)

  let change_setting = @commands.register_command_async(
    "getting-started-sample.changeSetting",
    async fn(_args) {
      let config = @workspace.get_configuration(
        section="getting-started-sample",
      )
      ignore(config.update_bool("sampleSetting", true))
    },
  )
  subscriptions.push(change_setting)

  let set_context = @commands.register_command_async(
    "getting-started-sample.setContext",
    async fn(_args) {
      let _ : @vscode.Any = @commands.execute_command(
        "setContext",
        args=@commands.command_args2("gettingStartedContextKey", true),
      )
    },
  )
  subscriptions.push(set_context)

  let say_hello = @commands.register_command_async(
    "getting-started-sample.sayHello",
    async fn(_args) {
      ignore(@window.show_information_message("Hello"))
    },
  )
  subscriptions.push(say_hello)

  let view_sources = @commands.register_command_async(
    "getting-started-sample.viewSources",
    async fn(_args) {
      let _ : @vscode.Any = @commands.execute_command(
        "vscode.openFolder",
        args=@commands.command_args1(source_folder_uri(ctx)),
      )
    },
  )
  subscriptions.push(view_sources)
}

pub fn deactivate() -> Unit {
  ()
}
