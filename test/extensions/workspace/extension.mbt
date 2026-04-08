///|
/// JS entrypoint for workspace namespace binding checks.

///|
priv struct WorkspaceUiState {
  mut output : @vscode.OutputChannel?
  mut run_index : Int
}

///|
let ui_state : WorkspaceUiState = {
  output: None,
  run_index: 0,
}

///|
fn output_channel() -> @vscode.OutputChannel {
  match ui_state.output {
    Some(channel) => channel
    None => {
      let channel = @window.create_output_channel("MoonBit Workspace")
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
fn bool_optional_text(value : Bool?) -> String {
  match value {
    Some(bool_value) => "\{bool_value}"
    None => "none"
  }
}

///|
fn string_optional_text(value : String?) -> String {
  match value {
    Some(text) => text
    None => "none"
  }
}

///|
fn uri_optional_text(value : @vscode.Uri?) -> String {
  match value {
    Some(uri) => uri.fs_path()
    None => "none"
  }
}

///|
fn fixture_uri(root : @vscode.Uri, name : String) -> @vscode.Uri {
  @vscode.Uri::join_path(root, [name])
}

///|
fn fixture_root() -> (@vscode.Uri, String) {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => {
      let uri = folder.uri()
      (uri, uri.fs_path())
    }
    _ => {
      let path = "/tmp/moonbit-workspace-fixture"
      (@vscode.Uri::file(path), path)
    }
  }
}

///|
fn task_name(run_tag : String) -> String {
  "MoonBit Workspace Task \{run_tag}"
}

///|
priv struct FixtureTextDocumentContentProvider {
  run_tag : String
}

///|
priv struct FixtureTaskProvider {
  run_tag : String
}

///|
impl @vscode.TextDocumentContentProvider for FixtureTextDocumentContentProvider with on_did_change(
  _self,
) {
  None
}

///|
impl @vscode.TextDocumentContentProvider for FixtureTextDocumentContentProvider with provide_text_document_content(
  self,
  uri,
  _token,
) {
  output_append(
    "workspace.providers \{self.run_tag} callback content_provider \{uri.path()}",
  )
  "moonbit-content-provider:\{uri.path()}"
}

///|
impl @vscode.TaskProvider for FixtureTaskProvider with provide_tasks(
  self,
  _token,
) {
  output_append("workspace.providers \{self.run_tag} callback task_provider.provide")
  let task = @vscode.Task::new_typed(
    @vscode.TaskDefinition::new("moonbit-workspace-task-provider"),
    @vscode.TaskScope::ScopeKind(@vscode.TaskScopeKind::Workspace),
    task_name(self.run_tag),
    "moonbit-workspace",
  )
  Some([task])
}

///|
impl @vscode.TaskProvider for FixtureTaskProvider with resolve_task(
  self,
  task,
  _token,
) {
  output_append("workspace.providers \{self.run_tag} callback task_provider.resolve")
  Some(task)
}

///|
priv struct FixtureFileSystemProvider {
  run_tag : String
  root : @vscode.Uri
  text_uri : @vscode.Uri
  fs_provider_emitter : @vscode.EventEmitter[Array[@vscode.FileChangeEvent]]
}

///|
impl @vscode.FileSystemProvider for FixtureFileSystemProvider with on_did_change_file(
  self,
) {
  self.fs_provider_emitter.event()
}

///|
impl @vscode.FileSystemProvider for FixtureFileSystemProvider with watch(
  self,
  uri,
  recursive,
  excludes,
) {
  output_append(
    "workspace.providers \{self.run_tag} callback fs_provider.watch \{uri.path()} recursive=\{recursive} excludes=\{excludes.length()}",
  )
  @workspace.on_did_change_text_document().subscribe(_ => ())
}

///|
impl @vscode.FileSystemProvider for FixtureFileSystemProvider with stat(
  self,
  _uri,
) {
  output_append("workspace.providers \{self.run_tag} callback fs_provider.stat")
  @workspace.fs().stat(self.text_uri)
}

///|
impl @vscode.FileSystemProvider for FixtureFileSystemProvider with read_directory(
  self,
  _uri,
) {
  output_append(
    "workspace.providers \{self.run_tag} callback fs_provider.read_directory",
  )
  @workspace.fs().read_directory(self.root)
}

///|
impl @vscode.FileSystemProvider for FixtureFileSystemProvider with create_directory(
  self,
  uri,
) {
  output_append(
    "workspace.providers \{self.run_tag} callback fs_provider.create_directory",
  )
  @workspace.fs().create_directory(uri)
}

///|
impl @vscode.FileSystemProvider for FixtureFileSystemProvider with read_file(
  self,
  _uri,
) {
  output_append("workspace.providers \{self.run_tag} callback fs_provider.read_file")
  @workspace.fs().read_file(self.text_uri)
}

///|
impl @vscode.FileSystemProvider for FixtureFileSystemProvider with write_file(
  self,
  uri,
  content,
  _create,
  _overwrite,
) {
  output_append("workspace.providers \{self.run_tag} callback fs_provider.write_file")
  @workspace.fs().write_file(uri, content)
}

///|
impl @vscode.FileSystemProvider for FixtureFileSystemProvider with delete(
  self,
  uri,
  _recursive,
) {
  output_append("workspace.providers \{self.run_tag} callback fs_provider.delete")
  @workspace.fs().delete(uri)
}

///|
impl @vscode.FileSystemProvider for FixtureFileSystemProvider with rename(
  self,
  old_uri,
  new_uri,
  _overwrite,
) {
  output_append("workspace.providers \{self.run_tag} callback fs_provider.rename")
  @workspace.fs().rename(old_uri, new_uri, overwrite=true)
}

///|
impl @vscode.FileSystemProvider for FixtureFileSystemProvider with copy(
  self,
  source,
  destination,
  _overwrite,
) {
  output_append("workspace.providers \{self.run_tag} callback fs_provider.copy")
  @workspace.fs().copy(source, destination, overwrite=true)
}

///|
async fn write_text_file(
  root : @vscode.Uri,
  name : String,
  content : String,
) -> @vscode.Uri {
  let uri = fixture_uri(root, name)
  @workspace.fs().write_file(uri, @workspace.encode(content))
  uri
}

///|
async fn file_exists(uri : @vscode.Uri) -> Bool {
  try {
    let stat = @workspace.fs().stat(uri)
    stat.size >= 0
  } catch {
    _ => false
  }
}

///|
async fn delete_if_exists(uri : @vscode.Uri, recursive : Bool) -> Unit {
  let exists = file_exists(uri)
  if exists {
    @workspace.fs().delete(uri, recursive=recursive)
  } else {
    ()
  }
}

///|
async fn cleanup_fixture(root : @vscode.Uri) -> Unit {
  delete_if_exists(fixture_uri(root, "moonbit-workspace-created.txt"), false)
  delete_if_exists(fixture_uri(root, "moonbit-workspace-renamed.txt"), false)
  delete_if_exists(fixture_uri(root, "moonbit-workspace-watch-file.txt"), false)
  delete_if_exists(fixture_uri(root, "moonbit-workspace-fsp-write.txt"), false)
  delete_if_exists(fixture_uri(root, "moonbit-workspace-fsp-renamed.txt"), false)
  delete_if_exists(fixture_uri(root, "moonbit-workspace-fsp-copy.txt"), false)
  delete_if_exists(fixture_uri(root, "moonbit-workspace-fsp-dir"), true)
}

///|
async fn run_check_core(root : @vscode.Uri, root_path : String) -> Unit {
  let run_tag = next_run_tag("core")
  output_reset("workspace.core \{run_tag} start")
  cleanup_fixture(root)

  let text_uri = write_text_file(root, "moonbit-workspace-text.txt", "alpha")

  let text_open_event = @workspace.on_did_open_text_document().subscribe(_ => {
    output_append("workspace.core \{run_tag} event text_open")
  })
  let text_close_event = @workspace.on_did_close_text_document().subscribe(_ => {
    output_append("workspace.core \{run_tag} event text_close")
  })
  let text_change_event = @workspace.on_did_change_text_document().subscribe(_ => {
    output_append("workspace.core \{run_tag} event text_change")
  })
  let text_will_save_event = @workspace.on_will_save_text_document().subscribe(event => {
    output_append("workspace.core \{run_tag} event text_will_save")
    event.wait_until_edits(fn() -> Array[@vscode.TextEdit] { [] })
  })
  let text_save_event = @workspace.on_did_save_text_document().subscribe(_ => {
    output_append("workspace.core \{run_tag} event text_save")
  })
  let config_change_event = @workspace.on_did_change_configuration().subscribe(event => {
    if event.affects_configuration("moonbit.workspace") {
      output_append("workspace.core \{run_tag} event config_change")
    }
  })
  let workspace_folders_change_event =
    @workspace.on_did_change_workspace_folders().subscribe(_ => {
      output_append("workspace.core \{run_tag} event workspace_folders_change")
    })
  let trust_event = @workspace.on_did_grant_workspace_trust().subscribe(_ => {
    output_append("workspace.core \{run_tag} event trust_grant")
  })

  let workspace_name = string_optional_text(@workspace.name())
  let workspace_root_path = string_optional_text(@workspace.root_path())
  let workspace_file = uri_optional_text(@workspace.workspace_file())
  let workspace_folder_count = match @workspace.workspace_folders() {
    Some(folders) => folders.length()
    None => 0
  }
  output_append(
    "workspace.core \{run_tag} value workspace name=\{workspace_name} root=\{workspace_root_path} file=\{workspace_file} folders=\{workspace_folder_count}",
  )

  let config = @workspace.get_configuration()
  let section_config = @workspace.get_configuration(section="moonbit.workspace")
  let scoped_config = @workspace.get_configuration(
    section="moonbit.workspace",
    scope=@vscode.ConfigurationScope::Uri(text_uri),
  )
  let config_has_before = config.has("moonbit.workspace.value")
  let config_before = config.get_string_or("moonbit.workspace.value", "before")
  let config_update_ok = try {
    config.update_string(
      "moonbit.workspace.value",
      "after",
      target=@vscode.ConfigurationTarget::Workspace,
    )
    true
  } catch {
    _ => false
  }
  let config_after = config.get_string_or("moonbit.workspace.value", "missing")
  output_append(
    "workspace.core \{run_tag} value config section=\{section_config.key()} scoped=\{scoped_config.key()} has_before=\{config_has_before} before=\{config_before} update_ok=\{config_update_ok} after=\{config_after}",
  )

  let text_doc_by_uri = @workspace.open_text_document_uri(text_uri, encoding="utf8")
  let text_doc_by_path = @workspace.open_text_document_path(
    text_uri.fs_path(),
    encoding="utf8",
  )
  let text_doc_untitled = @workspace.open_text_document_untitled(
    language="plaintext",
    encoding="utf8",
  )
  let shown_text_editor = @window.show_text_document(text_doc_by_uri)
  let shown_untitled_editor = @window.show_text_document(text_doc_untitled)
  let untitled_dirty = text_doc_untitled.is_dirty()
  let _ : Unit = @commands.execute_command(
    "workbench.action.revertAndCloseActiveEditor",
  )
  let untitled_closed = true
  output_append(
    "workspace.core \{run_tag} value docs uri=\{text_doc_by_uri.uri().scheme()} path=\{text_doc_by_path.uri().scheme()} untitled=\{text_doc_untitled.uri().scheme()} shown_untitled=\{shown_untitled_editor.document().uri().scheme()} untitled_dirty=\{untitled_dirty} untitled_closed=\{untitled_closed} shown_uri=\{shown_text_editor.document().uri().scheme()}",
  )

  let edit = @vscode.WorkspaceEdit::new()
  edit.replace(
    text_uri,
    @vscode.Range::new(@vscode.Position::new(0, 0), @vscode.Position::new(0, 5)),
    "beta",
  )
  let apply_with_metadata = @workspace.apply_edit(
    edit,
    metadata=@vscode.WorkspaceEditMetadata::new(is_refactoring=true),
  )
  output_append("workspace.core \{run_tag} value apply_edit=\{apply_with_metadata}")

  let save_result = @workspace.save(text_uri)
  let save_ok = match save_result {
    Some(saved_uri) => {
      output_append("workspace.core \{run_tag} value save_uri=\{saved_uri.fs_path()}")
      true
    }
    None => false
  }
  let save_all_ok = @workspace.save_all(include_untitled=false)
  let text_doc_saved = save_ok
  output_append(
    "workspace.core \{run_tag} value save save_ok=\{save_ok} save_all=\{save_all_ok} text_doc_saved=\{text_doc_saved}",
  )
  output_append("workspace.core \{run_tag} value save_as skipped_non_interactive")

  let relative_path = @workspace.as_relative_path(text_uri.fs_path())
  let relative_uri = @workspace.as_relative_path_uri(
    text_uri,
    include_workspace_folder=true,
  )
  let workspace_folder = @workspace.get_workspace_folder(text_uri)
  let workspace_folder_name = match workspace_folder {
    Some(folder) => folder.name()
    None => "none"
  }
  let workspace_folder_index = match workspace_folder {
    Some(folder) => folder.index()
    None => -1
  }
  let update_workspace_folders_ok =
    @workspace.update_workspace_folders(999, delete_count=0, folders_to_add=[])
  output_append(
    "workspace.core \{run_tag} value paths relative_path=\{relative_path} relative_uri=\{relative_uri} folder=\{workspace_folder_name} folder_index=\{workspace_folder_index} update_workspace_folders=\{update_workspace_folders_ok}",
  )

  let find_pattern = @vscode.GlobPattern::Relative(
    @vscode.RelativePattern::from_path(root_path, "**/moonbit-workspace-text.txt"),
  )
  let exclude_pattern = @vscode.GlobPattern::Text("**/moonbit-workspace-ignore.txt")
  let find_token_source = @vscode.CancellationTokenSource::new()
  let found_with_exclude = @workspace.find_files(
    find_pattern,
    exclude=exclude_pattern,
    max_results=20,
    token=find_token_source.token(),
  )
  let found_no_excludes = @workspace.find_files_no_excludes(
    find_pattern,
    max_results=20,
    token=find_token_source.token(),
  )
  find_token_source.dispose()
  output_append(
    "workspace.core \{run_tag} value find with_exclude=\{found_with_exclude.length()} no_excludes=\{found_no_excludes.length()}",
  )

  let decode_value = @workspace.decode(@workspace.encode("moonbit-utf8"))
  let decode_with_encoding_value = @workspace.decode_with_encoding(
    @workspace.encode_with_encoding("moonbit-enc", "utf8"),
    "utf8",
  )
  let decode_with_uri_value = @workspace.decode_with_uri(
    @workspace.encode_with_uri("moonbit-uri", text_uri),
    text_uri,
  )
  output_append(
    "workspace.core \{run_tag} value decode plain=\{decode_value} encoding=\{decode_with_encoding_value} uri=\{decode_with_uri_value}",
  )

  let text_docs_count = @workspace.text_documents().length()
  let notebook_docs_count = @workspace.notebook_documents().length()
  output_append(
    "workspace.core \{run_tag} value docs_count text=\{text_docs_count} notebook=\{notebook_docs_count}",
  )

  let final_text = @workspace.decode(@workspace.fs().read_file(text_uri))
  output_append("workspace.core \{run_tag} value final_text=\{final_text}")

  trust_event.dispose()
  workspace_folders_change_event.dispose()
  config_change_event.dispose()
  text_save_event.dispose()
  text_will_save_event.dispose()
  text_change_event.dispose()
  text_close_event.dispose()
  text_open_event.dispose()

  output_append("workspace.core \{run_tag} done")
}

///|
async fn run_check_file_events(root : @vscode.Uri, root_path : String) -> Unit {
  let run_tag = next_run_tag("files")
  output_reset("workspace.files \{run_tag} start")
  cleanup_fixture(root)

  let will_create_event = @workspace.on_will_create_files().subscribe(event => {
    output_append(
      "workspace.files \{run_tag} event file_will_create \{event.files.length()}",
    )
    event.wait_until_edit(@vscode.WorkspaceEdit::new())
  })
  let did_create_event = @workspace.on_did_create_files().subscribe(event => {
    output_append(
      "workspace.files \{run_tag} event file_did_create \{event.files.length()}",
    )
  })
  let will_delete_event = @workspace.on_will_delete_files().subscribe(event => {
    output_append(
      "workspace.files \{run_tag} event file_will_delete \{event.files.length()}",
    )
    event.wait_until_edit(@vscode.WorkspaceEdit::new())
  })
  let did_delete_event = @workspace.on_did_delete_files().subscribe(event => {
    output_append(
      "workspace.files \{run_tag} event file_did_delete \{event.files.length()}",
    )
  })
  let will_rename_event = @workspace.on_will_rename_files().subscribe(event => {
    output_append(
      "workspace.files \{run_tag} event file_will_rename \{event.files.length()}",
    )
    event.wait_until_edit(@vscode.WorkspaceEdit::new())
  })
  let did_rename_event = @workspace.on_did_rename_files().subscribe(event => {
    output_append(
      "workspace.files \{run_tag} event file_did_rename \{event.files.length()}",
    )
  })

  let watcher_pattern = @vscode.GlobPattern::Relative(
    @vscode.RelativePattern::from_path(root_path, "**/moonbit-workspace-watch-*.txt"),
  )
  let watcher = @workspace.create_file_system_watcher(watcher_pattern)
  let watcher_create_event = watcher.on_did_create().subscribe(_ => {
    output_append("workspace.files \{run_tag} event watcher_create")
  })
  let watcher_change_event = watcher.on_did_change().subscribe(_ => {
    output_append("workspace.files \{run_tag} event watcher_change")
  })
  let watcher_delete_event = watcher.on_did_delete().subscribe(_ => {
    output_append("workspace.files \{run_tag} event watcher_delete")
  })

  let created_uri = fixture_uri(root, "moonbit-workspace-created.txt")
  let renamed_uri = fixture_uri(root, "moonbit-workspace-renamed.txt")
  let watch_uri = fixture_uri(root, "moonbit-workspace-watch-file.txt")

  let create_edit = @vscode.WorkspaceEdit::new()
  create_edit.create_file(
    created_uri,
    options=@vscode.WorkspaceEditCreateFileOptions::new(ignore_if_exists=true),
  )
  let create_ok = @workspace.apply_edit(create_edit)

  let rename_edit = @vscode.WorkspaceEdit::new()
  rename_edit.rename_file(
    created_uri,
    renamed_uri,
    options=@vscode.WorkspaceEditRenameFileOptions::new(overwrite=true),
  )
  let rename_ok = @workspace.apply_edit(rename_edit)

  let delete_edit = @vscode.WorkspaceEdit::new()
  delete_edit.delete_file(
    renamed_uri,
    options=@vscode.WorkspaceEditDeleteFileOptions::new(ignore_if_not_exists=false),
  )
  let delete_ok = @workspace.apply_edit(delete_edit)

  @workspace.fs().write_file(watch_uri, @workspace.encode("watch-create"))
  @workspace.fs().write_file(watch_uri, @workspace.encode("watch-change"))
  @workspace.fs().delete(watch_uri)

  let created_exists = file_exists(created_uri)
  let renamed_exists = file_exists(renamed_uri)
  let watch_exists = file_exists(watch_uri)
  output_append(
    "workspace.files \{run_tag} value file_edits create=\{create_ok} rename=\{rename_ok} delete=\{delete_ok} created_exists=\{created_exists} renamed_exists=\{renamed_exists} watch_exists=\{watch_exists}",
  )

  watcher_create_event.dispose()
  watcher_change_event.dispose()
  watcher_delete_event.dispose()
  watcher.dispose()

  did_rename_event.dispose()
  will_rename_event.dispose()
  did_delete_event.dispose()
  will_delete_event.dispose()
  did_create_event.dispose()
  will_create_event.dispose()

  output_append("workspace.files \{run_tag} done")
}

///|
async fn run_check_providers(root : @vscode.Uri) -> Unit {
  let run_tag = next_run_tag("providers")
  output_reset("workspace.providers \{run_tag} start")
  cleanup_fixture(root)

  let text_uri = write_text_file(root, "moonbit-workspace-text.txt", "beta")
  let content_provider = FixtureTextDocumentContentProvider::{ run_tag }
  let content_provider_registration = @workspace.register_text_document_content_provider(
    "moonbit-content",
    content_provider,
  )
  let content_uri = @vscode.Uri::parse("moonbit-content:/workspace/check")
  let content_doc = @workspace.open_text_document_uri(content_uri)
  let content_text = content_doc.get_text()
  output_append("workspace.providers \{run_tag} value content_doc=\{content_text}")

  let task_provider = FixtureTaskProvider::{ run_tag }
  let task_provider_registration = @workspace.register_task_provider(
    "moonbit-workspace-task-provider",
    task_provider,
  )
  let task_token_source = @vscode.CancellationTokenSource::new()
  let provided_tasks = match task_provider.provide_tasks(task_token_source.token()) {
    Some(tasks) => tasks
    None => []
  }
  let resolved_task_name = match provided_tasks {
    [task, ..] => match task_provider.resolve_task(task, task_token_source.token()) {
      Some(resolved) => resolved.name()
      None => "none"
    }
    [] => "none"
  }
  task_token_source.dispose()
  output_append(
    "workspace.providers \{run_tag} value tasks provided=\{provided_tasks.length()} resolved=\{resolved_task_name}",
  )

  let fs_provider_emitter : @vscode.EventEmitter[Array[@vscode.FileChangeEvent]] =
    @vscode.EventEmitter::new()
  let fs_provider = FixtureFileSystemProvider::{
    run_tag,
    root,
    text_uri,
    fs_provider_emitter,
  }
  let fs_provider_registration = @workspace.register_file_system_provider(
    "moonbitfs",
    fs_provider,
    is_case_sensitive=true,
    is_readonly=false,
  )
  let readonly_reason = @vscode.MarkdownString::new(value="MoonBit readonly provider")
  let readonly_fs_provider_registration =
    @workspace.register_file_system_provider_readonly_reason(
      "moonbitreadonly",
      fs_provider,
      readonly_reason,
      is_case_sensitive=true,
    )

  let fs_provider_watch_disposable = fs_provider.watch(text_uri, false, [])
  let fs_provider_stat = fs_provider.stat(text_uri)
  let fs_provider_entries = fs_provider.read_directory(root)
  let fs_provider_dir = fixture_uri(root, "moonbit-workspace-fsp-dir")
  let fs_provider_write_uri = fixture_uri(root, "moonbit-workspace-fsp-write.txt")
  let fs_provider_renamed_uri = fixture_uri(root, "moonbit-workspace-fsp-renamed.txt")
  let fs_provider_copy_uri = fixture_uri(root, "moonbit-workspace-fsp-copy.txt")
  fs_provider.create_directory(fs_provider_dir)
  let fs_provider_read = fs_provider.read_file(text_uri)
  fs_provider.write_file(fs_provider_write_uri, fs_provider_read, true, true)
  fs_provider.rename(fs_provider_write_uri, fs_provider_renamed_uri, true)
  fs_provider.copy(fs_provider_renamed_uri, fs_provider_copy_uri, true)
  fs_provider.delete(fs_provider_copy_uri, false)
  let fs_provider_event = fs_provider.on_did_change_file().subscribe(_ => {
    output_append("workspace.providers \{run_tag} event fs_provider_did_change_file")
  })
  fs_provider_emitter.fire([
    @vscode.FileChangeEvent::new(text_uri, @vscode.FileChangeType::Changed),
  ])
  output_append(
    "workspace.providers \{run_tag} value fs_provider stat_size=\{fs_provider_stat.size} entries=\{fs_provider_entries.length()} read_text=\{@workspace.decode(fs_provider_read)}",
  )
  fs_provider_event.dispose()
  fs_provider_watch_disposable.dispose()

  let is_trusted = @workspace.is_trusted()
  let writable_file = @workspace.fs().is_writable_file_system("file")
  let writable_custom = @workspace.fs().is_writable_file_system("moonbitfs")
  output_append(
    "workspace.providers \{run_tag} value trust trusted=\{is_trusted} writable_file=\{bool_optional_text(writable_file)} writable_custom=\{bool_optional_text(writable_custom)}",
  )

  content_provider_registration.dispose()
  task_provider_registration.dispose()
  fs_provider_registration.dispose()
  readonly_fs_provider_registration.dispose()
  fs_provider_emitter.dispose()

  output_append("workspace.providers \{run_tag} done")
}

///|
async fn run_check_notebook(root : @vscode.Uri) -> Unit {
  let run_tag = next_run_tag("notebook")
  output_reset("workspace.notebook \{run_tag} start")
  cleanup_fixture(root)

  let notebook_open_event = @workspace.on_did_open_notebook_document().subscribe(_ => {
    output_append("workspace.notebook \{run_tag} event notebook_open")
  })
  let notebook_close_event = @workspace.on_did_close_notebook_document().subscribe(_ => {
    output_append("workspace.notebook \{run_tag} event notebook_close")
  })
  let notebook_change_event = @workspace.on_did_change_notebook_document().subscribe(_ => {
    output_append("workspace.notebook \{run_tag} event notebook_change")
  })
  let notebook_will_save_event = @workspace.on_will_save_notebook_document().subscribe(
    event => {
      let notebook = event.notebook
      output_append(
        "workspace.notebook \{run_tag} event notebook_will_save \{notebook.notebook_type()}",
      )
    },
  )
  let notebook_save_event = @workspace.on_did_save_notebook_document().subscribe(_ => {
    output_append("workspace.notebook \{run_tag} event notebook_save")
  })

  let notebook_serializer = @vscode.NotebookSerializer::new(
    async fn(content, _token) {
      output_append("workspace.notebook \{run_tag} callback notebook.deserialize")
      let cell = @vscode.NotebookCellData::new(
        @vscode.NotebookCellKind::Code,
        @workspace.decode(content),
        "plaintext",
      )
      @vscode.NotebookData::new([cell])
    },
    async fn(data, _token) {
      output_append("workspace.notebook \{run_tag} callback notebook.serialize")
      let text = match data.cells() {
        [cell, ..] => cell.value()
        [] => ""
      }
      @workspace.encode(text)
    },
  )
  let notebook_serializer_registration = @workspace.register_notebook_serializer(
    "moonbit-workspace-notebook",
    notebook_serializer,
    options=@vscode.NotebookDocumentContentOptions::new(transient_outputs=true),
  )

  let notebook_uri = fixture_uri(root, "moonbit-workspace-notebook.moonbitworkspace")
  @workspace.fs().write_file(notebook_uri, @workspace.encode("workspace notebook"))
  let notebook_doc = @workspace.open_notebook_document_uri(notebook_uri)
  let notebook_editor = @window.show_notebook_document(notebook_doc)
  let notebook_doc_by_type = @workspace.open_notebook_document_type(
    "moonbit-workspace-notebook",
    content=@vscode.NotebookData::new([
      @vscode.NotebookCellData::new(
        @vscode.NotebookCellKind::Code,
        "workspace notebook type",
        "plaintext",
      ),
    ]),
  )
  let notebook_editor_by_type = @window.show_notebook_document(notebook_doc_by_type)
  let notebook_doc_by_uri = @workspace.open_notebook_document_uri(notebook_uri)
  let notebook_docs_count = @workspace.notebook_documents().length()
  let notebook_save_ok = notebook_doc.save()
  let _ : Unit = @commands.execute_command(
    "workbench.action.revertAndCloseActiveEditor",
  )
  let _ : Unit = @commands.execute_command(
    "workbench.action.revertAndCloseActiveEditor",
  )
  let notebook_closed = true
  let notebook_text = @workspace.decode(@workspace.fs().read_file(notebook_uri))
  output_append(
    "workspace.notebook \{run_tag} value notebook type=\{notebook_doc.notebook_type()} cells=\{notebook_doc.cell_count()} editor_type=\{notebook_editor.notebook().notebook_type()} type_editor=\{notebook_editor_by_type.notebook().notebook_type()} type_type=\{notebook_doc_by_type.notebook_type()} type_untitled=\{notebook_doc_by_type.is_untitled()} uri_type=\{notebook_doc_by_uri.notebook_type()} docs_count=\{notebook_docs_count} untitled=\{notebook_doc.is_untitled()} dirty=\{notebook_doc.is_dirty()} save=\{notebook_save_ok} closed=\{notebook_closed} text=\{notebook_text}",
  )

  notebook_serializer_registration.dispose()
  notebook_save_event.dispose()
  notebook_will_save_event.dispose()
  notebook_change_event.dispose()
  notebook_close_event.dispose()
  notebook_open_event.dispose()

  output_append("workspace.notebook \{run_tag} done")
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let core_disposable = @commands.register_command_async(
    "moonbit.workspace.checkCore",
    async fn(_args) {
      let (root, root_path) = fixture_root()
      try run_check_core(root, root_path) catch {
        _ => output_reset("workspace.core error")
      }
    },
  )
  subscriptions.push(core_disposable)

  let file_events_disposable = @commands.register_command_async(
    "moonbit.workspace.checkFileEvents",
    async fn(_args) {
      let (root, root_path) = fixture_root()
      try run_check_file_events(root, root_path) catch {
        _ => output_reset("workspace.files error")
      }
    },
  )
  subscriptions.push(file_events_disposable)

  let providers_disposable = @commands.register_command_async(
    "moonbit.workspace.checkProviders",
    async fn(_args) {
      let (root, _) = fixture_root()
      try run_check_providers(root) catch {
        _ => output_reset("workspace.providers error")
      }
    },
  )
  subscriptions.push(providers_disposable)

  let notebook_disposable = @commands.register_command_async(
    "moonbit.workspace.checkNotebook",
    async fn(_args) {
      let (root, _) = fixture_root()
      try run_check_notebook(root) catch {
        _ => output_reset("workspace.notebook error")
      }
    },
  )
  subscriptions.push(notebook_disposable)
}

///|
pub fn deactivate() -> Unit {
  match ui_state.output {
    None => ()
    Some(channel) => {
      channel.dispose()
      ui_state.output = None
    }
  }
}
