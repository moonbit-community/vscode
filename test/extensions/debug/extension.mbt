///|
/// JS entrypoint for debug namespace binding checks.

///|
fn fixture_root() -> @vscode.Uri {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => folder.uri()
    _ => @vscode.Uri::file("/tmp/moonbit-debug-fixture")
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
async fn run_check_debug(root : @vscode.Uri) -> Unit {
  let active_session = @debug.active_debug_session()
  @debug.active_debug_console().append_line("MoonBit debug binding check")

  let active_changed = @debug.on_did_change_active_debug_session().subscribe(_ => ())
  let started = @debug.on_did_start_debug_session().subscribe(_ => ())
  let custom = @debug.on_did_receive_debug_session_custom_event().subscribe(_ => ())
  let terminated = @debug.on_did_terminate_debug_session().subscribe(_ => ())
  let breakpoints_changed = @debug.on_did_change_breakpoints().subscribe(_ => ())
  let stack_changed = @debug.on_did_change_active_stack_item().subscribe(_ => ())

  let active_stack = @debug.active_stack_item()

  let source_uri = @debug.as_debug_source_uri(
    @debug.DebugProtocolSource::from_path("/tmp/moonbit-debug-source.txt"),
  )

  let executable_options = @debug.DebugAdapterExecutableOptions::new(
    env=[("MOONBIT_DEBUG_BINDING", "1")],
    cwd="/tmp",
  )
  let executable = @debug.DebugAdapterExecutable::new(
    "node",
    args=["--version"],
    options=executable_options,
  )
  let executable_env_count = match executable.options() {
    Some(options) => match options.env {
      Some(entries) => entries.length()
      None => 0
    }
    None => 0
  }
  let adapter_server = @debug.DebugAdapterServer::new(4711, host="127.0.0.1")
  let adapter_pipe = @debug.DebugAdapterNamedPipeServer::new(
    "moonbit-debug-pipe",
  )
  let message_emitter : @vscode.EventEmitter[@debug.DebugProtocolMessage] =
    @vscode.EventEmitter::new()
  let inline_adapter = @debug.DebugAdapter::new(
    message_emitter.event(),
    _message => (),
  )
  let _descriptor_executable = @debug.DebugAdapterDescriptor::from_executable(
    executable,
  )
  let _descriptor_server = @debug.DebugAdapterDescriptor::from_server(
    adapter_server,
  )
  let _descriptor_pipe = @debug.DebugAdapterDescriptor::from_named_pipe_server(
    adapter_pipe,
  )
  let inline_impl = @debug.DebugAdapterInlineImplementation::new(inline_adapter)
  let _descriptor_inline = @debug.DebugAdapterDescriptor::from_inline_implementation(
    inline_impl,
  )
  inline_adapter.handle_message(
    @debug.DebugProtocolMessage::from_json(@vscode.Any::from("moonbit")),
  )
  inline_adapter.dispose()
  message_emitter.dispose()

  let configuration_provider = @debug.DebugConfigurationProvider::new(
    provide_debug_configurations=fn(_folder, _token) {
      Some([
        @vscode.DebugConfiguration::new(
          "moonbit-debug-test",
          "MoonBit Debug Test",
          "launch",
        ),
      ])
    },
    resolve_debug_configuration=fn(_folder, configuration, _token) {
      Some(configuration)
    },
    resolve_debug_configuration_with_substituted_variables=fn(
      _folder,
      configuration,
      _token,
    ) {
      Some(configuration)
    },
  )
  let configuration_registration = @debug.register_debug_configuration_provider(
    "moonbit-debug-test",
    configuration_provider,
  )

  let descriptor_factory = @debug.DebugAdapterDescriptorFactory::new(
    fn(_session, _executable) {
      None
    },
  )
  let descriptor_registration = @debug.register_debug_adapter_descriptor_factory(
    "moonbit-debug-test",
    descriptor_factory,
  )

  let tracker_factory = @debug.DebugAdapterTrackerFactory::new(
    fn(_session) {
      Some(@debug.DebugAdapterTracker::new())
    },
  )
  let tracker_registration = @debug.register_debug_adapter_tracker_factory(
    "*",
    tracker_factory,
  )

  let uri = @vscode.Uri::join_path(root, ["debug-file.txt"])
  let range = @vscode.Range::new(
    @vscode.Position::new(0, 0),
    @vscode.Position::new(0, 1),
  )
  let location = @vscode.Location::new(uri, range)

  let source_breakpoint = @vscode.SourceBreakpoint::new(location)
  let function_breakpoint = @vscode.FunctionBreakpoint::new("moonbit_debug_test")
  let source_breakpoint_base : @vscode.Breakpoint = cast_value(source_breakpoint)

  let before_count = @debug.breakpoints().length()
  @debug.add_breakpoints([source_breakpoint_base])
  let after_add_base_count = @debug.breakpoints().length()
  @debug.remove_breakpoints([source_breakpoint_base])
  @debug.add_source_breakpoints([source_breakpoint])
  let after_source_add_count = @debug.breakpoints().length()
  @debug.remove_source_breakpoints([source_breakpoint])

  @debug.add_function_breakpoints([function_breakpoint])
  let after_function_add_count = @debug.breakpoints().length()
  @debug.remove_function_breakpoints([function_breakpoint])

  let after_remove_count = @debug.breakpoints().length()
  let debug_configuration = @vscode.DebugConfiguration::new(
    "moonbit-debug-test",
    "MoonBit Debug Test",
    "launch",
  )
  let debug_options = @vscode.DebugSessionOptions::new(
    no_debug=true,
    suppress_save_before_start=true,
  )
  if false {
    ignore(@debug.start_debugging_name("MoonBit Debug Test"))
    ignore(
      @debug.start_debugging_name_with_options(
        "MoonBit Debug Test",
        options=debug_options,
      ),
    )
    ignore(@debug.start_debugging_configuration(debug_configuration))
    ignore(
      @debug.start_debugging_configuration_with_options(
        debug_configuration,
        options=debug_options,
      ),
    )
    ignore(@debug.stop_debugging())
  } else {
    ()
  }
  let start_name = "skipped_requires_debug_adapter"
  let start_name_options = "skipped_requires_debug_adapter"
  let start_configuration = "skipped_requires_debug_adapter"
  let start_configuration_options = "skipped_requires_debug_adapter"
  let stop_state = "skipped_requires_debug_adapter"

  tracker_registration.dispose()
  descriptor_registration.dispose()
  configuration_registration.dispose()

  stack_changed.dispose()
  breakpoints_changed.dispose()
  terminated.dispose()
  custom.dispose()
  started.dispose()
  active_changed.dispose()

  let active_flag = match active_session {
    Some(_) => "true"
    None => "false"
  }
  let active_stack_flag = match active_stack {
    Some(_) => "true"
    None => "false"
  }
  let adapter_host = match adapter_server.host() {
    Some(value) => value
    None => "none"
  }

  write_result(
    root,
    "debug-result.txt",
    "debug ok active=\{active_flag} active_stack=\{active_stack_flag} source_scheme=\{source_uri.scheme()} before=\{before_count} after_add_base=\{after_add_base_count} after_source_add=\{after_source_add_count} after_function_add=\{after_function_add_count} after_remove=\{after_remove_count} start_name=\{start_name} start_name_options=\{start_name_options} start_configuration=\{start_configuration} start_configuration_options=\{start_configuration_options} stop=\{stop_state} executable=\{executable.command()} env=\{executable_env_count} server=\{adapter_server.port()} host=\{adapter_host} pipe=\{adapter_pipe.path()}",
  )
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let root = fixture_root()
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "moonbit.debug.checkBindings",
    async fn(_args) {
      run_check_debug(root)
    },
  )
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
