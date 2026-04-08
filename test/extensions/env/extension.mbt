///|
/// JS entrypoint for env namespace binding checks.

///|
fn fixture_root() -> @vscode.Uri {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => folder.uri()
    _ => @vscode.Uri::file("/tmp/moonbit-env-fixture")
  }
}

///|
fn fixture_uri(root : @vscode.Uri, name : String) -> @vscode.Uri {
  @vscode.Uri::join_path(root, [name])
}

///|
async fn write_result(
  root : @vscode.Uri,
  name : String,
  content : String,
) -> Unit {
  let fs = @workspace.fs()
  fs.write_file(fixture_uri(root, name), @workspace.encode(content))
}

///|
fn[A, B] cast_value(value : A) -> B {
  let args = @commands.command_args1(value)
  match args.get(0) {
    Some(actual) => actual
    None => panic()
  }
}

///|
async fn run_check_env(
  root : @vscode.Uri,
  ctx : @vscode.ExtensionContext,
) -> Unit {
  let app = @env.app_name()
  let app_root = @env.app_root()
  let app_host = @env.app_host()
  let uri_scheme = @env.uri_scheme()
  let language = @env.language()
  let machine_len = @env.machine_id().length()
  let session_len = @env.session_id().length()
  let is_new_install = if @env.is_new_app_install() { "true" } else { "false" }
  let telemetry = if @env.is_telemetry_enabled() { "true" } else { "false" }
  let remote_name = match @env.remote_name() {
    Some(value) => value
    None => "none"
  }
  let shell = @env.shell()
  let vscode_version = @vscode.version()
  let _ = @env.ui_kind()
  let _ = @env.log_level()
  let telemetry_change = @env.on_did_change_telemetry_enabled().subscribe(_ => ())
  let shell_change = @env.on_did_change_shell().subscribe(_ => ())
  let log_level_change = @env.on_did_change_log_level().subscribe(_ => ())
  let mode = match ctx.extension_mode() {
    @vscode.ExtensionMode::Production => "production"
    @vscode.ExtensionMode::Development => "development"
    @vscode.ExtensionMode::Test => "test"
  }

  let secrets = ctx.secrets()
  let secret_key = "moonbit.env.secret"
  let _ = secrets.delete(secret_key)
  secrets.store(secret_key, "moonbit-secret")
  let secret_value = match secrets.get(secret_key) {
    Some(value) => value
    None => ""
  }
  let secret_keys = secrets.keys()
  let secret_change_disposable = secrets.on_did_change().subscribe(event => {
    ignore(event.key)
  })
  secrets.delete(secret_key)
  secret_change_disposable.dispose()

  let env_collection = ctx.environment_variable_collection()
  env_collection.set_persistent(true)
  env_collection.set_description_text("MoonBit env mutators")
  let mutator_options = @vscode.EnvironmentVariableMutatorOptions::new(
    apply_at_process_creation=true,
  )
  env_collection.replace(
    "MOONBIT_ENV_BINDING",
    "replace",
    options=mutator_options,
  )
  let mutator_type = match env_collection.get("MOONBIT_ENV_BINDING") {
    Some(mutator) => match mutator.type_ {
      @vscode.EnvironmentVariableMutatorType::Replace => "replace"
      @vscode.EnvironmentVariableMutatorType::Append => "append"
      @vscode.EnvironmentVariableMutatorType::Prepend => "prepend"
    }
    None => "none"
  }
  let scoped = env_collection.get_scoped(@vscode.EnvironmentVariableScope::new())
  scoped.append("MOONBIT_ENV_BINDING_SCOPED", "scoped")
  let scoped_mutator = match scoped.get("MOONBIT_ENV_BINDING_SCOPED") {
    Some(_) => "some"
    None => "none"
  }
  env_collection.clear()
  scoped.clear()

  telemetry_change.dispose()
  shell_change.dispose()
  log_level_change.dispose()

  let clipboard = @env.clipboard()
  clipboard.write_text("moonbit-clipboard")
  let clipboard_text = clipboard.read_text()
  let external_uri = try {
    @env.as_external_uri(@vscode.Uri::parse("https://example.com/moonbit"))
  } catch {
    _ => @vscode.Uri::parse("moonbit:error")
  }
  if false {
    ignore(
      @env.open_external(
        @vscode.Uri::parse("https://example.com/moonbit"),
      ),
    )
  } else {
    ()
  }
  let open_external = "skipped_non_interactive"
  if false {
    let sender : @vscode.TelemetrySender = cast_value(())
    let logger = @env.create_telemetry_logger(sender)
    logger.dispose()
  } else {
    ()
  }
  let telemetry_logger_state = "skipped_sender_unavailable"

  write_result(
    root,
    "env-result.txt",
    "env ok app=\{app} app_root=\{app_root} app_host=\{app_host} uri_scheme=\{uri_scheme} language=\{language} machine=\{machine_len} session=\{session_len} new_install=\{is_new_install} telemetry=\{telemetry} remote=\{remote_name} shell=\{shell} clipboard=\{clipboard_text} external_uri=\{external_uri.scheme()} open_external=\{open_external} telemetry_logger=\{telemetry_logger_state} version=\{vscode_version} mode=\{mode} secret=\{secret_value} secret_keys=\{secret_keys.length()} mutator=\{mutator_type} scoped=\{scoped_mutator}",
  )
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let root = fixture_root()
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "moonbit.env.checkBindings",
    async fn(_args) {
      run_check_env(root, ctx)
    },
  )
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
