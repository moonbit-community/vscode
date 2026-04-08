///|
/// JS entrypoint for window namespace binding checks.

///|
priv struct WindowUiState {
  mut output : @vscode.OutputChannel?
  mut run_index : Int
}

///|
priv struct TerminalLinkContextData {
  line : String
  terminal : @vscode.Terminal
}

///|
let ui_state : WindowUiState = {
  output: None,
  run_index: 0,
}

///|
fn output_channel() -> @vscode.OutputChannel {
  match ui_state.output {
    Some(channel) => channel
    None => {
      let channel = @window.create_output_channel("MoonBit Window")
      ui_state.output = Some(channel)
      channel
    }
  }
}

///|
fn output_append(line : String) -> Unit {
  let channel = output_channel()
  channel.append_line(line)
  channel.show()
}

///|
fn output_reset(line : String) -> Unit {
  let channel = output_channel()
  channel.clear()
  channel.append_line(line)
  channel.show()
}

///|
fn next_run_tag(prefix : String) -> String {
  let index = ui_state.run_index
  ui_state.run_index = index + 1
  "\{prefix}-\{index}"
}

///|
fn workspace_root() -> @vscode.Uri {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => folder.uri()
    _ => @vscode.Uri::file("/tmp/moonbit-window-fixture")
  }
}

///|
fn fixture_uri(root : @vscode.Uri, name : String) -> @vscode.Uri {
  @vscode.Uri::join_path(root, [name])
}

///|
fn[T] optional_presence(value : T?) -> String {
  match value {
    Some(_) => "some"
    None => "none"
  }
}

///|
fn int_optional_text(value : Int?) -> String {
  match value {
    Some(actual) => "\{actual}"
    None => "none"
  }
}

///|
fn string_optional_text(value : String?) -> String {
  match value {
    Some(actual) => actual
    None => "none"
  }
}

///|
fn view_column_value(column : @vscode.ViewColumn) -> Int {
  match column {
    @vscode.ViewColumn::Active => -1
    @vscode.ViewColumn::Beside => -2
    @vscode.ViewColumn::One => 1
    @vscode.ViewColumn::Two => 2
    @vscode.ViewColumn::Three => 3
    @vscode.ViewColumn::Four => 4
    @vscode.ViewColumn::Five => 5
    @vscode.ViewColumn::Six => 6
    @vscode.ViewColumn::Seven => 7
    @vscode.ViewColumn::Eight => 8
    @vscode.ViewColumn::Nine => 9
    @vscode.ViewColumn::Custom(value) => value
  }
}

///|
fn view_column_optional_text(value : @vscode.ViewColumn?) -> String {
  match value {
    Some(column) => "\{view_column_value(column)}"
    None => "none"
  }
}

///|
fn theme_kind_text(value : @vscode.ColorThemeKind) -> String {
  match value {
    @vscode.ColorThemeKind::Light => "light"
    @vscode.ColorThemeKind::Dark => "dark"
    @vscode.ColorThemeKind::HighContrast => "high-contrast"
    @vscode.ColorThemeKind::HighContrastLight => "high-contrast-light"
  }
}

///|
fn quick_pick_optional_label(value : @vscode.QuickPickItem?) -> String {
  match value {
    Some(item) => item.label
    None => "none"
  }
}

///|
fn quick_pick_many_count(value : Array[@vscode.QuickPickItem]?) -> Int {
  match value {
    Some(items) => items.length()
    None => 0
  }
}

///|
fn quick_pick_strings_count(value : Array[String]?) -> Int {
  match value {
    Some(items) => items.length()
    None => 0
  }
}

///|
fn[A, B] disposable_cast(value : A) -> B {
  let args = @commands.command_args1(value)
  match args.get(0) {
    Some(casted) => casted
    None => panic()
  }
}

///|
fn dispose_all(disposables : Array[&@vscode.Disposable]) -> Unit {
  for disposable in disposables {
    disposable.dispose()
  }
}

///|
priv struct FixtureTerminalProfileProvider {
  run_tag : String
}

///|
priv struct FixtureCustomTextEditorProvider {
  run_tag : String
}

///|
priv struct FixtureWebviewViewProvider {
  run_tag : String
}

///|
priv struct FixtureTerminalLinkProvider {
  run_tag : String
}

///|
priv struct FixtureFileDecorationProvider {
  run_tag : String
  on_did_change : @vscode.Event[@vscode.FileDecorationChange]
}

///|
impl @vscode.CustomTextEditorProvider for FixtureCustomTextEditorProvider with resolve_custom_text_editor(
  self,
  document,
  panel,
  _token,
) {
  output_append(
    "window.providers \{self.run_tag} callback custom_editor uri=\{document.uri().fs_path()}",
  )
  panel.webview().set_html("<html><body>MoonBit custom editor</body></html>")
}

///|
impl @vscode.TerminalProfileProvider for FixtureTerminalProfileProvider with provide_terminal_profile(
  self,
  _token,
) {
  output_append(
    "window.providers \{self.run_tag} callback terminal_profile_provider.provide",
  )
  Some(
    @vscode.TerminalProfile::from_terminal(
      @vscode.TerminalOptions::new(
        name="MoonBit Terminal Profile",
        hide_from_user=true,
      ),
    ),
  )
}

///|
impl @vscode.WebviewViewProvider for FixtureWebviewViewProvider with resolve_webview_view(
  self,
  view,
  context,
  _token,
) {
  output_append(
    "window.providers \{self.run_tag} callback webview_view_provider",
  )
  view.webview().set_html("<html><body>MoonBit webview view</body></html>")
  ignore(context.state)
}

///|
impl @vscode.TerminalLinkProvider for FixtureTerminalLinkProvider with provide_terminal_links(
  self,
  context,
  _token,
) {
  output_append(
    "window.providers \{self.run_tag} callback terminal_link_provider.provide line=\{context.line}",
  )
  Some([@vscode.TerminalLink::new(0, 6, tooltip="moonbit-link")])
}

///|
impl @vscode.TerminalLinkProvider for FixtureTerminalLinkProvider with handle_terminal_link(
  self,
  link,
) {
  output_append(
    "window.providers \{self.run_tag} callback terminal_link_provider.handle length=\{link.length()}",
  )
}

///|
impl @vscode.FileDecorationProvider for FixtureFileDecorationProvider with on_did_change_file_decorations(
  self,
) {
  Some(self.on_did_change)
}

///|
impl @vscode.FileDecorationProvider for FixtureFileDecorationProvider with provide_file_decoration(
  self,
  uri,
  _token,
) {
  output_append(
    "window.providers \{self.run_tag} callback file_decoration_provider.provide uri=\{uri.fs_path()}",
  )
  Some(
    @vscode.FileDecoration::new(
      badge="M",
      tooltip="MoonBit file decoration",
      color=@vscode.ThemeColor::new("statusBar.foreground"),
    ),
  )
}

///|
async fn close_active_editor() -> Unit {
  try {
    let _ : Unit = @commands.execute_command(
      "workbench.action.revertAndCloseActiveEditor",
    )
    ()
  } catch {
    _ => ()
  }
}

///|
async fn run_check_core(root : @vscode.Uri) -> Unit {
  let run_tag = next_run_tag("core")
  output_reset("window.core \{run_tag} start")

  let disposables : Array[&@vscode.Disposable] = []
  let tab_groups = @window.tab_groups()

  disposables.push(
    tab_groups.on_did_change_tab_groups().subscribe(_ => {
      output_append("window.core \{run_tag} event tab_groups_change")
    }),
  )
  disposables.push(
    tab_groups.on_did_change_tabs().subscribe(_ => {
      output_append("window.core \{run_tag} event tabs_change")
    }),
  )
  disposables.push(
    @window.on_did_change_window_state().subscribe(state => {
      output_append(
        "window.core \{run_tag} event window_state active=\{state.active} focused=\{state.focused}",
      )
    }),
  )
  disposables.push(
    @window.on_did_change_active_color_theme().subscribe(theme => {
      output_append(
        "window.core \{run_tag} event color_theme kind=\{theme_kind_text(theme.kind())}",
      )
    }),
  )
  disposables.push(
    @window.on_did_change_active_text_editor().subscribe(editor => {
      output_append(
        "window.core \{run_tag} event active_text_editor value=\{optional_presence(editor)}",
      )
    }),
  )
  disposables.push(
    @window.on_did_change_visible_text_editors().subscribe(editors => {
      output_append(
        "window.core \{run_tag} event visible_text_editors count=\{editors.length()}",
      )
    }),
  )
  disposables.push(
    @window.on_did_change_text_editor_selection().subscribe(event => {
      output_append(
        "window.core \{run_tag} event text_editor_selection count=\{event.selections.length()}",
      )
    }),
  )
  disposables.push(
    @window.on_did_change_text_editor_visible_ranges().subscribe(event => {
      output_append(
        "window.core \{run_tag} event text_editor_visible_ranges count=\{event.visibleRanges.length()}",
      )
    }),
  )
  disposables.push(
    @window.on_did_change_text_editor_options().subscribe(_ => {
      output_append("window.core \{run_tag} event text_editor_options")
    }),
  )
  disposables.push(
    @window.on_did_change_text_editor_view_column().subscribe(event => {
      output_append(
        "window.core \{run_tag} event text_editor_view_column value=\{view_column_value(event.viewColumn)}",
      )
    }),
  )
  disposables.push(
    @window.on_did_change_active_notebook_editor().subscribe(editor => {
      output_append(
        "window.core \{run_tag} event active_notebook_editor value=\{optional_presence(editor)}",
      )
    }),
  )
  disposables.push(
    @window.on_did_change_visible_notebook_editors().subscribe(editors => {
      output_append(
        "window.core \{run_tag} event visible_notebook_editors count=\{editors.length()}",
      )
    }),
  )
  disposables.push(
    @window.on_did_change_notebook_editor_selection().subscribe(event => {
      output_append(
        "window.core \{run_tag} event notebook_editor_selection count=\{event.selections.length()}",
      )
    }),
  )
  disposables.push(
    @window.on_did_change_notebook_editor_visible_ranges().subscribe(event => {
      output_append(
        "window.core \{run_tag} event notebook_editor_visible_ranges count=\{event.visibleRanges.length()}",
      )
    }),
  )

  let state = @window.state()
  let theme = @window.active_color_theme()
  output_append(
    "window.core \{run_tag} value api=window_state active=\{state.active} focused=\{state.focused} theme=\{theme_kind_text(theme.kind())}",
  )
  output_append(
    "window.core \{run_tag} value api=tab_groups groups=\{tab_groups.all().length()}",
  )
  output_append(
    "window.core \{run_tag} value api=editor_snapshot active=\{optional_presence(@window.active_text_editor())} visible=\{@window.visible_text_editors().length()}",
  )
  output_append(
    "window.core \{run_tag} value api=notebook_snapshot active=\{optional_presence(@window.active_notebook_editor())} visible=\{@window.visible_notebook_editors().length()}",
  )

  let text_uri = fixture_uri(root, "moonbit-window-text.txt")
  @workspace.fs().write_file(text_uri, @workspace.encode("alpha\nbeta"))

  let text_show_options = @vscode.TextDocumentShowOptions::new(
    view_column=@vscode.ViewColumn::One,
    preserve_focus=false,
    preview=false,
  )
  let text_doc = @workspace.open_text_document_uri(text_uri, encoding="utf8")
  let editor_from_doc = @window.show_text_document(text_doc, options=text_show_options)
  let editor_from_uri = @window.show_text_document_uri(
    text_uri,
    options=text_show_options,
  )

  let selection = @vscode.Selection::new(
    @vscode.Position::new(0, 0),
    @vscode.Position::new(0, 5),
  )
  editor_from_uri.set_selection(selection)
  editor_from_uri.set_options(@vscode.TextEditorOptions::new(
      line_numbers=@vscode.TextEditorLineNumbersStyle::Relative,
    ))
  let highlighted_range = @vscode.Range::new(
    @vscode.Position::new(0, 0),
    @vscode.Position::new(0, 5),
  )
  editor_from_uri.reveal_range(highlighted_range)

  let decoration_type = @window.create_text_editor_decoration_type(
    @vscode.DecorationRenderOptions::new(
      border="1px solid #00aa00",
      is_whole_line=true,
    ),
  )
  editor_from_uri.set_decorations_ranges(decoration_type, [highlighted_range])

  output_append(
    "window.core \{run_tag} value api=show_text_document scheme=\{editor_from_doc.document().uri().scheme()} column=\{view_column_optional_text(editor_from_doc.view_column())}",
  )
  output_append(
    "window.core \{run_tag} value api=show_text_document_uri scheme=\{editor_from_uri.document().uri().scheme()} column=\{view_column_optional_text(editor_from_uri.view_column())}",
  )
  output_append(
    "window.core \{run_tag} value api=create_text_editor_decoration_type key=\{decoration_type.key}",
  )

  let notebook_serializer = @vscode.NotebookSerializer::new(
    async fn(content, _token) {
      output_append("window.core \{run_tag} callback notebook.deserialize")
      @vscode.NotebookData::new([
        @vscode.NotebookCellData::new(
          @vscode.NotebookCellKind::Code,
          @workspace.decode(content),
          "plaintext",
        ),
      ])
    },
    async fn(data, _token) {
      output_append("window.core \{run_tag} callback notebook.serialize")
      let text = match data.cells() {
        [cell, ..] => cell.value()
        [] => ""
      }
      @workspace.encode(text)
    },
  )
  let notebook_serializer_registration = @workspace.register_notebook_serializer(
    "moonbit-window-notebook",
    notebook_serializer,
    options=@vscode.NotebookDocumentContentOptions::new(transient_outputs=true),
  )

  let notebook_uri = fixture_uri(root, "moonbit-window-notebook.moonbitwindow-nb")
  @workspace.fs().write_file(notebook_uri, @workspace.encode("window notebook"))
  let notebook_doc = @workspace.open_notebook_document_uri(notebook_uri)
  let notebook_editor = @window.show_notebook_document(
    notebook_doc,
    options=@vscode.NotebookDocumentShowOptions::new(
      view_column=@vscode.ViewColumn::Two,
      preserve_focus=false,
      preview=false,
      selections=[@vscode.NotebookRange::new(0, 1)],
    ),
  )
  notebook_editor.set_selection(@vscode.NotebookRange::new(0, 1))
  notebook_editor.reveal_range(@vscode.NotebookRange::new(0, 1))
  let notebook_saved = notebook_doc.save()

  output_append(
    "window.core \{run_tag} value api=show_notebook_document type=\{notebook_doc.notebook_type()} cells=\{notebook_doc.cell_count()} column=\{view_column_optional_text(notebook_editor.view_column())} saved=\{notebook_saved}",
  )

  close_active_editor()
  close_active_editor()

  output_append(
    "window.core \{run_tag} value api=post_close active_text=\{optional_presence(@window.active_text_editor())} active_notebook=\{optional_presence(@window.active_notebook_editor())}",
  )

  notebook_serializer_registration.dispose()
  decoration_type.dispose()
  dispose_all(disposables)

  output_append("window.core \{run_tag} done")
}

///|
async fn run_check_quick_input() -> Unit {
  let run_tag = next_run_tag("quickinput")
  output_reset("window.quickinput \{run_tag} start")

  let canceled_source = @vscode.CancellationTokenSource::new()
  canceled_source.cancel()
  let canceled_token = canceled_source.token()

  let input_box = @window.create_input_box()
  let input_box_hide = input_box.on_did_hide().subscribe(_ => {
    output_append("window.quickinput \{run_tag} event input_box_hide")
  })
  input_box.set_title("MoonBit Window Input")
  input_box.set_prompt("MoonBit prompt")
  input_box.set_value("MoonBit value")
  input_box.set_placeholder("MoonBit placeholder")
  input_box.show()
  input_box.hide()

  output_append(
    "window.quickinput \{run_tag} value api=create_input_box title=\{string_optional_text(input_box.title())} prompt=\{string_optional_text(input_box.prompt())}",
  )

  let quick_pick = @window.create_quick_pick()
  quick_pick.set_items([
    @vscode.QuickPickItem::new(
      "MoonBit quick item",
      description="quick-description",
      detail="quick-detail",
    ),
  ])
  quick_pick.set_placeholder("MoonBit quick placeholder")
  quick_pick.set_prompt("MoonBit quick prompt")
  quick_pick.set_value("MoonBit")
  quick_pick.set_can_select_many(true)
  quick_pick.show()
  quick_pick.hide()

  output_append(
    "window.quickinput \{run_tag} value api=create_quick_pick items=\{quick_pick.items().length()} value=\{quick_pick.value()} can_many=\{quick_pick.can_select_many()}",
  )

  let input_result = @window.show_input_box(
    options=@vscode.InputBoxOptions::new(
      title="MoonBit canceled input",
      value="seed",
      prompt="type a value",
      place_holder="value",
      validate_input=(value : String) =>
        if value.length() == 0 {
          Some(@vscode.InputBoxValidationResult::Text("required"))
        } else {
          None
        },
    ),
    token=canceled_token,
  )

  let pick_items : Array[@vscode.QuickPickItem] = [
    @vscode.QuickPickItem::new("MoonBit pick A"),
    @vscode.QuickPickItem::new("MoonBit pick B"),
  ]
  let pick_options = @vscode.QuickPickOptions::new(
    title="MoonBit pick",
    place_holder="choose a pick",
    can_pick_many=false,
  )
  let pick_result = @window.show_quick_pick(
    pick_items,
    options=pick_options,
    token=canceled_token,
  )
  let pick_many_result = @window.show_quick_pick_many(
    pick_items,
    options=@vscode.QuickPickOptions::new(
      title="MoonBit pick many",
      place_holder="choose many picks",
      can_pick_many=true,
    ),
    token=canceled_token,
  )

  let string_options = @vscode.QuickPickOptions::from_strings(
    title="MoonBit string pick",
    place_holder="choose a string",
    can_pick_many=false,
  )
  let string_pick_result = @window.show_quick_pick_strings(
    ["MoonBit string A", "MoonBit string B"],
    options=string_options,
    token=canceled_token,
  )
  let string_pick_many_result = @window.show_quick_pick_strings_many(
    ["MoonBit string A", "MoonBit string B"],
    options=@vscode.QuickPickOptions::from_strings(
      title="MoonBit string pick many",
      place_holder="choose many strings",
      can_pick_many=true,
    ),
    token=canceled_token,
  )

  output_append(
    "window.quickinput \{run_tag} value api=show_input_box canceled=\{optional_presence(input_result)}",
  )
  output_append(
    "window.quickinput \{run_tag} value api=show_quick_pick value=\{quick_pick_optional_label(pick_result)}",
  )
  output_append(
    "window.quickinput \{run_tag} value api=show_quick_pick_many count=\{quick_pick_many_count(pick_many_result)}",
  )
  output_append(
    "window.quickinput \{run_tag} value api=show_quick_pick_strings value=\{string_optional_text(string_pick_result)}",
  )
  output_append(
    "window.quickinput \{run_tag} value api=show_quick_pick_strings_many count=\{quick_pick_strings_count(string_pick_many_result)}",
  )
  output_append(
    "window.quickinput \{run_tag} value api=show_information_message skipped_non_interactive=true",
  )
  output_append(
    "window.quickinput \{run_tag} value api=show_information_message_items skipped_non_interactive=true",
  )
  output_append(
    "window.quickinput \{run_tag} value api=show_warning_message skipped_non_interactive=true",
  )
  output_append(
    "window.quickinput \{run_tag} value api=show_warning_message_items skipped_non_interactive=true",
  )
  output_append(
    "window.quickinput \{run_tag} value api=show_error_message skipped_non_interactive=true",
  )
  output_append(
    "window.quickinput \{run_tag} value api=show_error_message_items skipped_non_interactive=true",
  )
  output_append(
    "window.quickinput \{run_tag} value api=show_workspace_folder_pick skipped_non_interactive=true",
  )
  output_append(
    "window.quickinput \{run_tag} value api=show_open_dialog skipped_non_interactive=true",
  )
  output_append(
    "window.quickinput \{run_tag} value api=show_save_dialog skipped_non_interactive=true",
  )

  input_box_hide.dispose()
  input_box.dispose()
  quick_pick.dispose()
  canceled_source.dispose()

  output_append("window.quickinput \{run_tag} done")
}

///|
async fn run_check_terminal() -> Unit {
  let run_tag = next_run_tag("terminal")
  output_reset("window.terminal \{run_tag} start")

  let disposables : Array[&@vscode.Disposable] = []
  disposables.push(
    @window.on_did_change_active_terminal().subscribe(terminal => {
      output_append(
        "window.terminal \{run_tag} event active_terminal value=\{optional_presence(terminal)}",
      )
    }),
  )
  disposables.push(
    @window.on_did_open_terminal().subscribe(terminal => {
      output_append(
        "window.terminal \{run_tag} event open_terminal name=\{terminal.name()}",
      )
    }),
  )
  disposables.push(
    @window.on_did_close_terminal().subscribe(terminal => {
      output_append(
        "window.terminal \{run_tag} event close_terminal name=\{terminal.name()}",
      )
    }),
  )
  disposables.push(
    @window.on_did_change_terminal_state().subscribe(terminal => {
      output_append(
        "window.terminal \{run_tag} event terminal_state name=\{terminal.name()} interacted=\{terminal.state().isInteractedWith}",
      )
    }),
  )
  disposables.push(
    @window.on_did_change_terminal_shell_integration().subscribe(event => {
      output_append(
        "window.terminal \{run_tag} event terminal_shell_integration name=\{event.terminal.name()}",
      )
    }),
  )
  disposables.push(
    @window.on_did_start_terminal_shell_execution().subscribe(event => {
      output_append(
        "window.terminal \{run_tag} event terminal_shell_start name=\{event.terminal.name()}",
      )
    }),
  )
  disposables.push(
    @window.on_did_end_terminal_shell_execution().subscribe(event => {
      output_append(
        "window.terminal \{run_tag} event terminal_shell_end name=\{event.terminal.name()} exit=\{int_optional_text(event.exitCode)}",
      )
    }),
  )

  let scratch_output = @window.create_output_channel(
    "MoonBit Window Scratch",
    language_id="plaintext",
  )
  scratch_output.append_line("window scratch output")
  scratch_output.show()
  scratch_output.hide()

  let log_output = @window.create_log_output_channel("MoonBit Window Log")
  let log_level_change = log_output.on_did_change_log_level().subscribe(_ => {
    output_append("window.terminal \{run_tag} event log_level_change")
  })
  log_output.trace("window trace")
  log_output.debug("window debug")
  log_output.info("window info")
  log_output.warn("window warn")
  log_output.error("window error")

  let status_item = @window.create_status_bar_item(
    alignment=@vscode.StatusBarAlignment::Left,
    priority=100,
  )
  status_item.set_text("MoonBit Window Status")
  status_item.show()

  let status_item_with_id = @window.create_status_bar_item_with_id(
    "moonbit.window.status",
    alignment=@vscode.StatusBarAlignment::Right,
    priority=80,
  )
  status_item_with_id.set_text("MoonBit Window Status Id")
  status_item_with_id.show()

  let status_message = @window.set_status_bar_message("MoonBit status message")
  let status_timeout = @window.set_status_bar_message_timeout(
    "MoonBit status timeout",
    200,
  )
  let status_until = @window.set_status_bar_message_until(
    "MoonBit status until",
    fn() {
      ()
    },
  )

  let _notification_location = @window.progress_location_notification()
  let _window_location = @window.progress_location_window()
  let _scm_location = @window.progress_location_source_control()
  let progress_options = @window.progress_options(
    @window.progress_location_window(),
    title="MoonBit Window Progress",
    cancellable=true,
  )
  let progress_result = @window.with_progress(
    progress_options,
    fn(progress, token) {
      @window.progress_report_message_increment(
        progress,
        "window progress",
        increment=40,
      )
      progress.report(99)
      if token.is_cancellation_requested {
        output_append("window.terminal \{run_tag} event with_progress_canceled")
      } else {
        ()
      }
      7
    },
  )
  let scm_result = @window.with_scm_progress(fn(progress) {
    progress.report(1)
    @window.progress_report_message_increment(
      progress,
      "scm progress",
      increment=60,
    )
    9
  })

  let terminal_default = @window.create_terminal()
  let terminal_named = @window.create_terminal_named("MoonBit Named Terminal")
  let terminal_options = @window.create_terminal_with_options(
    @vscode.TerminalOptions::new(
      name="MoonBit Options Terminal",
      hide_from_user=true,
      is_transient=true,
    ),
  )

  let pty_emitter : @vscode.EventEmitter[String] = @vscode.EventEmitter::new()
  let extension_terminal = @window.create_terminal_with_extension_options(
    @vscode.ExtensionTerminalOptions::new(
      "MoonBit Extension Terminal",
      @vscode.Pseudoterminal::new(
        pty_emitter.event(),
        _ => {
          pty_emitter.fire("MoonBit extension terminal ready\\r\\n")
        },
        () => (),
      ),
      is_transient=true,
    ),
  )

  terminal_named.show(preserve_focus=true)
  terminal_named.send_text("echo MoonBit window terminal")
  extension_terminal.show(preserve_focus=true)

  let active_terminal_name = match @window.active_terminal() {
    Some(terminal) => terminal.name()
    None => "none"
  }
  let terminal_count = @window.terminals().length()
  let named_process = terminal_named.process_id()
  let extension_creation_kind = match extension_terminal.creation_options() {
    Some(options) => match @vscode.TerminalCreationOptions::as_extension(options) {
      Some(_) => "extension"
      None => "terminal"
    }
    None => "none"
  }

  output_append(
    "window.terminal \{run_tag} value api=create_output_channel name=\{scratch_output.name()}",
  )
  output_append(
    "window.terminal \{run_tag} value api=create_log_output_channel level_set=true",
  )
  output_append(
    "window.terminal \{run_tag} value api=create_status_bar_item text=\{status_item.text()}",
  )
  output_append(
    "window.terminal \{run_tag} value api=create_status_bar_item_with_id id=\{status_item_with_id.id()}",
  )
  output_append(
    "window.terminal \{run_tag} value api=set_status_bar_message immediate=true timeout=true until=true",
  )
  output_append(
    "window.terminal \{run_tag} value api=progress progress=\{progress_result} scm=\{scm_result}",
  )
  output_append(
    "window.terminal \{run_tag} value api=terminal_snapshot count=\{terminal_count} active=\{active_terminal_name} process=\{int_optional_text(named_process)} extension_kind=\{extension_creation_kind}",
  )

  extension_terminal.dispose()
  terminal_options.dispose()
  terminal_named.dispose()
  terminal_default.dispose()
  pty_emitter.dispose()

  status_until.dispose()
  status_timeout.dispose()
  status_message.dispose()
  status_item_with_id.hide()
  status_item_with_id.dispose()
  status_item.hide()
  status_item.dispose()
  log_level_change.dispose()
  log_output.dispose()
  scratch_output.dispose()

  dispose_all(disposables)

  output_append("window.terminal \{run_tag} done")
}

///|
async fn run_check_providers(root : @vscode.Uri) -> Unit {
  let run_tag = next_run_tag("providers")
  output_reset("window.providers \{run_tag} start")

  let registrations : Array[&@vscode.Disposable] = []

  let tree_change_emitter : @vscode.EventEmitter[String?] = @vscode.EventEmitter::new()
  let tree_get_item : async (String) -> @vscode.TreeItem =
    fn(element) {
      @vscode.TreeItem::from_label(
        @vscode.TreeItemLabelValue::Text(element),
        collapsible_state=@vscode.TreeItemCollapsibleState::Collapsed,
      )
    }
  let tree_get_children : async (String?) -> Array[String]? =
    fn(parent) {
      match parent {
        None => Some(["root"])
        Some("root") => Some(["child"])
        Some(_) => Some([])
      }
    }
  let tree_get_parent : async (String) -> String? =
    fn(element) {
      if element == "child" {
        Some("root")
      } else {
        None
      }
    }
  let tree_resolve_item :
    async (
      @vscode.TreeItem,
      String,
      @vscode.CancellationToken,
    ) -> @vscode.TreeItem? =
    fn(item, _element, _token) {
      Some(item)
    }
  let tree_registration = @window.register_tree_data_provider(
    "moonbit.window.treeView",
    tree_get_item,
    tree_get_children,
    on_did_change_tree_data=tree_change_emitter.event(),
    get_parent=tree_get_parent,
    resolve_tree_item=tree_resolve_item,
  )
  registrations.push(tree_registration)

  let tree_view = @window.create_tree_view(
    "moonbit.window.treeView",
    @window.tree_view_options(
      tree_get_item,
      tree_get_children,
      on_did_change_tree_data=tree_change_emitter.event(),
      get_parent=tree_get_parent,
      resolve_tree_item=tree_resolve_item,
    ),
  )
  tree_view.set_title("MoonBit Window Tree")
  tree_view.set_description("Window provider tree")
  tree_view.set_message("MoonBit tree message")
  tree_view.set_badge(@vscode.ViewBadge::new(1, "MoonBit tree badge"))
  tree_view.reveal("root", expand=true)
  tree_change_emitter.fire(None)

  let tree_root_item = tree_get_item("root")
  let tree_children = tree_get_children(None)
  let tree_parent = tree_get_parent("child")

  let uri_handler = @vscode.UriHandler::new(fn(uri) {
    output_append(
      "window.providers \{run_tag} callback uri_handler value=\{uri.to_string()}",
    )
  })
  let uri_registration = @window.register_uri_handler(uri_handler)
  registrations.push(uri_registration)
  uri_handler.handle_uri(@vscode.Uri::parse("vscode://moonbit.window/providers"))

  let serializer = @vscode.WebviewPanelSerializer::new(fn(panel, _state) {
    output_append("window.providers \{run_tag} callback webview_panel_serializer")
    panel.webview().set_html("<html><body>MoonBit serializer panel</body></html>")
  })
  let serializer_registration = @window.register_webview_panel_serializer(
    "moonbit.window.serializerPanel",
    serializer,
  )
  registrations.push(serializer_registration)

  let panel = @window.create_webview_panel(
    "moonbit.window.serializerPanel",
    "MoonBit Panel",
    @vscode.ViewColumn::One,
    options=@vscode.WebviewPanelOptions::new(
      enable_find_widget=true,
      retain_context_when_hidden=true,
    ),
  )
  panel.webview().set_html("<html><body>MoonBit panel body</body></html>")
  let panel_state = panel.on_did_change_view_state().subscribe(_ => {
    output_append("window.providers \{run_tag} event webview_panel_state")
  })
  let panel_dispose = panel.on_did_dispose().subscribe(_ => {
    output_append("window.providers \{run_tag} event webview_panel_dispose")
  })
  serializer.deserialize_webview_panel(panel, @vscode.Any::from("manual"))

  let panel_show_options = @window.create_webview_panel_show_options(
    "moonbit.window.extraPanel",
    "MoonBit Panel Show Options",
    view_column=@vscode.ViewColumn::Two,
    preserve_focus=true,
    options=@vscode.WebviewPanelOptions::new(enable_find_widget=true),
  )
  panel_show_options.webview().set_html("<html><body>MoonBit panel show options body</body></html>")

  let webview_view_provider = FixtureWebviewViewProvider::{ run_tag }
  let webview_view_registration = @window.register_webview_view_provider(
    "moonbit.window.webviewView",
    webview_view_provider,
    options=@vscode.WebviewViewOptions::new(retain_context_when_hidden=true),
  )
  registrations.push(webview_view_registration)

  let custom_text_provider = FixtureCustomTextEditorProvider::{ run_tag }
  let custom_registration = @window.register_custom_text_editor_provider(
    "moonbit.window.customEditor",
    custom_text_provider,
  )
  registrations.push(custom_registration)

  let custom_uri = fixture_uri(root, "moonbit-window-custom.moonbitwindow")
  @workspace.fs().write_file(custom_uri, @workspace.encode("custom editor body"))
  let _ : Unit = @commands.execute_command(
    "vscode.openWith",
    args=@commands.command_args2(custom_uri, "moonbit.window.customEditor"),
  )
  close_active_editor()

  let terminal_link_provider = FixtureTerminalLinkProvider::{ run_tag }
  let terminal_link_registration = @window.register_terminal_link_provider(
    terminal_link_provider,
  )
  registrations.push(terminal_link_registration)

  let link_terminal = @window.create_terminal_named("MoonBit Link Terminal")
  let link_context_data : TerminalLinkContextData = {
    line: "moonbit-link",
    terminal: link_terminal,
  }
  let link_context : @vscode.TerminalLinkContext = disposable_cast(link_context_data)
  let link_token_source = @vscode.CancellationTokenSource::new()
  let provided_links = terminal_link_provider.provide_terminal_links(
    link_context,
    link_token_source.token(),
  )
  terminal_link_provider.handle_terminal_link(
    @vscode.TerminalLink::new(0, 6, tooltip="manual-link"),
  )
  link_token_source.dispose()
  link_terminal.dispose()

  let terminal_profile_provider = FixtureTerminalProfileProvider::{ run_tag }
  let terminal_profile_registration = @window.register_terminal_profile_provider(
    "moonbit.window.terminalProfile",
    terminal_profile_provider,
  )
  registrations.push(terminal_profile_registration)
  let profile_token_source = @vscode.CancellationTokenSource::new()
  let profile = terminal_profile_provider.provide_terminal_profile(
    profile_token_source.token(),
  )
  profile_token_source.dispose()

  let decoration_emitter : @vscode.EventEmitter[
    @vscode.FileDecorationChange
  ] = @vscode.EventEmitter::new()
  let file_decoration_provider = FixtureFileDecorationProvider::{
    run_tag,
    on_did_change: decoration_emitter.event(),
  }
  let file_decoration_registration = @window.register_file_decoration_provider(
    file_decoration_provider,
  )
  registrations.push(file_decoration_registration)

  let decoration_token_source = @vscode.CancellationTokenSource::new()
  let file_decoration = file_decoration_provider.provide_file_decoration(
    custom_uri,
    decoration_token_source.token(),
  )
  decoration_token_source.dispose()
  decoration_emitter.fire(@vscode.FileDecorationChange::from_uri(custom_uri))

  let tree_root_label = optional_presence(tree_root_item.label())
  let tree_children_count = match tree_children {
    Some(values) => values.length()
    None => 0
  }
  let tree_parent_text = string_optional_text(tree_parent)
  let provided_links_count = match provided_links {
    Some(links) => links.length()
    None => 0
  }
  let link_context_line = link_context_data.line
  let link_context_terminal_name = link_context_data.terminal.name()
  let decoration_badge = match file_decoration {
    Some(decoration) => string_optional_text(decoration.badge())
    None => "none"
  }

  output_append(
    "window.providers \{run_tag} value api=tree_view root=\{tree_root_label} children=\{tree_children_count} parent=\{tree_parent_text}",
  )
  output_append(
    "window.providers \{run_tag} value api=register_uri_handler ok=true",
  )
  output_append(
    "window.providers \{run_tag} value api=create_webview_panel type=\{panel.view_type()} title=\{panel.title()}",
  )
  output_append(
    "window.providers \{run_tag} value api=create_webview_panel_show_options type=\{panel_show_options.view_type()} title=\{panel_show_options.title()}",
  )
  output_append(
    "window.providers \{run_tag} value api=register_webview_view_provider ok=true",
  )
  output_append(
    "window.providers \{run_tag} value api=register_custom_text_editor_provider ok=true",
  )
  output_append(
    "window.providers \{run_tag} value api=register_terminal_link_provider links=\{provided_links_count}",
  )
  output_append(
    "window.providers \{run_tag} value api=terminal_link_context line=\{link_context_line} terminal=\{link_context_terminal_name}",
  )
  output_append(
    "window.providers \{run_tag} value api=register_terminal_profile_provider profile=\{optional_presence(profile)}",
  )
  output_append(
    "window.providers \{run_tag} value api=register_file_decoration_provider badge=\{decoration_badge}",
  )

  panel_state.dispose()
  panel_dispose.dispose()
  panel_show_options.dispose()
  panel.dispose()
  tree_change_emitter.dispose()
  decoration_emitter.dispose()
  dispose_all(registrations)

  output_append("window.providers \{run_tag} done")
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let root = workspace_root()
  let subscriptions = ctx.subscriptions()

  let core_disposable = @commands.register_command_async(
    "moonbit.window.checkCore",
    async fn(_args) {
      try run_check_core(root) catch {
        _ => output_reset("window.core error")
      }
    },
  )
  subscriptions.push(core_disposable)

  let quick_input_disposable = @commands.register_command_async(
    "moonbit.window.checkQuickInput",
    async fn(_args) {
      try run_check_quick_input() catch {
        _ => output_reset("window.quickinput error")
      }
    },
  )
  subscriptions.push(quick_input_disposable)

  let terminal_disposable = @commands.register_command_async(
    "moonbit.window.checkTerminal",
    async fn(_args) {
      try run_check_terminal() catch {
        _ => output_reset("window.terminal error")
      }
    },
  )
  subscriptions.push(terminal_disposable)

  let providers_disposable = @commands.register_command_async(
    "moonbit.window.checkProviders",
    async fn(_args) {
      try run_check_providers(root) catch {
        _ => output_reset("window.providers error")
      }
    },
  )
  subscriptions.push(providers_disposable)
}

///|
pub fn deactivate() -> Unit {
  match ui_state.output {
    Some(channel) => {
      channel.dispose()
      ui_state.output = None
    }
    None => ()
  }
}
