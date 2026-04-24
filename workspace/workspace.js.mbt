///|
/// VS Code Workspace API bindings for the JS backend.
using @vscode {
  type CancellationToken,
  type ConfigurationScope,
  type ConfigurationChangeEvent,
  type Event,
  type FileCreateEvent,
  type FileDeleteEvent,
  type FileRenameEvent,
  type FileSystem,
  type FileSystemWatcher,
  type FileWillCreateEvent,
  type FileWillDeleteEvent,
  type FileWillRenameEvent,
  type GlobPattern,
  type MarkdownString,
  type NotebookData,
  type NotebookDocument,
  type NotebookDocumentChangeEvent,
  type NotebookDocumentContentOptions,
  type NotebookDocumentWillSaveEvent,
  type TextDocument,
  type TextDocumentChangeEvent,
  type TextDocumentWillSaveEvent,
  type Uri,
  type WorkspaceConfiguration,
  type WorkspaceEdit,
  type WorkspaceEditMetadata,
  type WorkspaceFolder,
  type WorkspaceFolderInput,
  type WorkspaceFoldersChangeEvent,
}

///|
fn[T : @vscode.TextDocumentContentProvider] text_document_content_provider_object(
  provider : T,
) -> @providers.TextDocumentContentProviderObject {
  match provider.on_did_change() {
    None =>
      @providers.TextDocumentContentProviderObject::new(async fn(uri, token) {
        provider.provide_text_document_content(uri, token)
      })
    Some(on_did_change) =>
      @providers.TextDocumentContentProviderObject::new(
        async fn(uri, token) {
          provider.provide_text_document_content(uri, token)
        },
        on_did_change~,
      )
  }
}

///|
fn[T : @vscode.TaskProvider] task_provider_object(
  provider : T,
) -> @providers.TaskProviderObject {
  @providers.TaskProviderObject::new(
    async fn(token) { provider.provide_tasks(token) },
    resolve_task=async fn(task, token) { provider.resolve_task(task, token) },
  )
}

///|
fn[T : @vscode.FileSystemProvider] file_system_provider_object(
  provider : T,
) -> @providers.FileSystemProviderObject {
  @providers.FileSystemProviderObject::new(
    provider.on_did_change_file(),
    fn(uri, recursive, excludes) { provider.watch(uri, recursive, excludes) },
    async fn(uri) { provider.stat(uri) },
    async fn(uri) { provider.read_directory(uri) },
    async fn(uri) { provider.create_directory(uri) },
    async fn(uri) { provider.read_file(uri) },
    async fn(uri, content, create, overwrite) {
      provider.write_file(uri, content, create, overwrite)
    },
    async fn(uri, recursive) { provider.delete(uri, recursive) },
    async fn(old_uri, new_uri, overwrite) {
      provider.rename(old_uri, new_uri, overwrite)
    },
    copy_file=async fn(source, destination, overwrite) {
      provider.copy(source, destination, overwrite)
    },
  )
}

///|
fn bytes_to_uint8_array(value : Bytes) -> Uint8Array {
  @v.JsValue::make(value).cast()
}

///|
fn bytes_from_uint8_array(value : Uint8Array) -> Bytes {
  @v.JsValue::make(value).cast()
}

///|
fn workspace_folder_input_to_js(value : WorkspaceFolderInput) -> @v.JsValue {
  workspace_folder_input_to_js_ffi(value.uri, @v.option_to_js(value.name))
}

///|
fn workspace_folder_input_array_to_js(
  values : Array[WorkspaceFolderInput],
) -> Array[@v.JsValue] {
  let encoded : Array[@v.JsValue] = []
  for value in values {
    encoded.push(workspace_folder_input_to_js(value))
  }
  encoded
}

///|
fn workspace_edit_metadata_to_js(value : WorkspaceEditMetadata?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(metadata) =>
      workspace_edit_metadata_to_js_ffi(
        @v.option_to_js(metadata.is_refactoring),
      )
  }
}

///|
fn option_notebook_document_content_options_to_js(
  value : NotebookDocumentContentOptions?,
) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => notebook_document_content_options_to_js(value)
  }
}

///|
fn option_glob_pattern_to_js(value : GlobPattern?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => glob_pattern_to_js(value)
  }
}

///|
fn option_configuration_scope_to_js(value : ConfigurationScope?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(value) => configuration_scope_to_js(value)
  }
}

///|
fn notebook_document_content_options_to_js(
  value : NotebookDocumentContentOptions,
) -> @v.JsValue {
  workspace_notebook_document_content_options_to_js_ffi(
    @v.option_to_js(value.transient_outputs),
    map_string_bool_pairs(value.transient_cell_metadata),
    map_string_bool_pairs(value.transient_document_metadata),
  )
}

///|
fn map_string_bool_pairs(values : Array[(String, Bool)]?) -> @v.JsValue {
  match values {
    None => @v.JsValue::make(())
    Some(entries) => workspace_string_bool_map_ffi(entries)
  }
}

///|
fn glob_pattern_to_js(value : GlobPattern) -> @v.JsValue {
  match value {
    Text(value) => @v.JsValue::make(value)
    Relative(value) => @v.JsValue::make(value)
  }
}

///|
fn configuration_scope_to_js(value : ConfigurationScope) -> @v.JsValue {
  match value {
    Uri(value) => @v.JsValue::make(value)
    WorkspaceFolderScope(value) => @v.JsValue::make(value)
    TextEditorScope(value) => @v.JsValue::make(value)
    TextDocumentScope(value) => @v.JsValue::make(value)
    LanguageId(value) => workspace_configuration_scope_language_ffi(value)
    Global => workspace_configuration_scope_null_ffi()
  }
}

///|
extern "js" fn workspace_notebook_document_content_options_to_js_ffi(
  transient_outputs : @v.JsValue,
  transient_cell_metadata : @v.JsValue,
  transient_document_metadata : @v.JsValue,
) -> @v.JsValue =
  #| (transientOutputs, transientCellMetadata, transientDocumentMetadata) => {
  #|   const options = {};
  #|   if (transientOutputs !== undefined && transientOutputs !== null) {
  #|     options.transientOutputs = transientOutputs;
  #|   }
  #|   if (transientCellMetadata !== undefined && transientCellMetadata !== null) {
  #|     options.transientCellMetadata = transientCellMetadata;
  #|   }
  #|   if (transientDocumentMetadata !== undefined && transientDocumentMetadata !== null) {
  #|     options.transientDocumentMetadata = transientDocumentMetadata;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn workspace_string_bool_map_ffi(
  entries : Array[(String, Bool)],
) -> @v.JsValue =
  #| (pairs) => {
  #|   const result = {};
  #|   for (const pair of pairs) {
  #|     const key = pair._0 ?? pair[0];
  #|     const value = pair._1 ?? pair[1];
  #|     result[key] = value;
  #|   }
  #|   return result;
  #| }

///|
extern "js" fn workspace_configuration_scope_language_ffi(
  language_id : String,
) -> @v.JsValue =
  #| (languageId) => ({ languageId })

///|
extern "js" fn workspace_configuration_scope_null_ffi() -> @v.JsValue =
  #| () => null

///|
/// A {@link FileSystem file system} instance that allows to interact with local and remote
/// files, e.g. `vscode.workspace.fs.readDirectory(someUri)` allows to retrieve all entries
/// of a directory or `vscode.workspace.fs.stat(anotherUri)` returns the meta data for a
/// file.
pub fn fs() -> FileSystem {
  workspace_fs_ffi()
}

///|
/// The uri of the first entry of {@linkcode workspace.workspaceFolders workspaceFolders}
/// as `string`. `undefined` if there is no first entry.
///
/// Refer to https://code.visualstudio.com/docs/editor/workspaces for more information
/// on workspaces.
///
/// @deprecated Use {@linkcode workspace.workspaceFolders workspaceFolders} instead.
pub fn root_path() -> String? {
  let value = workspace_root_path_ffi()
  if @v.JsValue::is_null_or_undefined(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
/// List of workspace folders (0-N) that are open in the editor. `undefined` when no workspace
/// has been opened.
///
/// Refer to https://code.visualstudio.com/docs/editor/workspaces for more information
/// on workspaces.
pub fn workspace_folders() -> Array[WorkspaceFolder]? {
  let value = workspace_workspace_folders_ffi()
  if @v.JsValue::is_null_or_undefined(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
/// The name of the workspace. `undefined` when no workspace
/// has been opened.
///
/// Refer to https://code.visualstudio.com/docs/editor/workspaces for more information on
/// the concept of workspaces.
pub fn name() -> String? {
  let value = workspace_name_ffi()
  if @v.JsValue::is_null_or_undefined(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
/// The location of the workspace file, for example:
///
/// `file:///Users/name/Development/myProject.code-workspace`
///
/// or
///
/// `untitled:1555503116870`
///
/// for a workspace that is untitled and not yet saved.
///
/// Depending on the workspace that is opened, the value will be:
///  * `undefined` when no workspace is opened
///  * the path of the workspace file as `Uri` otherwise. if the workspace
/// is untitled, the returned URI will use the `untitled:` scheme
///
/// The location can e.g. be used with the `vscode.openFolder` command to
/// open the workspace again after it has been closed.
///
/// **Example:**
/// ```typescript
/// vscode.commands.executeCommand('vscode.openFolder', uriOfWorkspace);
/// ```
///
/// Refer to https://code.visualstudio.com/docs/editor/workspaces for more information on
/// the concept of workspaces.
///
/// **Note:** it is not advised to use `workspace.workspaceFile` to write
/// configuration data into the file. You can use `workspace.getConfiguration().update()`
/// for that purpose which will work both when a single folder is opened as
/// well as an untitled or saved workspace.
pub fn workspace_file() -> Uri? {
  let value = workspace_workspace_file_ffi()
  if @v.JsValue::is_null_or_undefined(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
/// An event that is emitted when a workspace folder is added or removed.
///
/// **Note:** this event will not fire if the first workspace folder is added, removed or changed,
/// because in that case the currently executing extensions (including the one that listens to this
/// event) will be terminated and restarted so that the (deprecated) `rootPath` property is updated
/// to point to the first workspace folder.
pub fn on_did_change_workspace_folders() -> Event[WorkspaceFoldersChangeEvent] {
  workspace_on_did_change_workspace_folders_ffi()
}

///|
/// Returns the {@link WorkspaceFolder workspace folder} that contains a given uri.
/// * returns `undefined` when the given uri doesn't match any workspace folder
/// * returns the *input* when the given uri is a workspace folder itself
///
/// @param uri An uri.
/// @returns A workspace folder or `undefined`
pub fn get_workspace_folder(uri : Uri) -> WorkspaceFolder? {
  let value = workspace_get_workspace_folder_ffi(uri)
  if @v.JsValue::is_null_or_undefined(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
/// Returns a path that is relative to the workspace folder or folders.
///
/// When there are no {@link workspace.workspaceFolders workspace folders} or when the path
/// is not contained in them, the input is returned.
///
/// @param pathOrUri A path or uri. When a uri is given its {@link Uri.fsPath fsPath} is used.
/// @param includeWorkspaceFolder When `true` and when the given path is contained inside a
/// workspace folder the name of the workspace is prepended. Defaults to `true` when there are
/// multiple workspace folders and `false` otherwise.
/// @returns A path relative to the root or the input.
pub fn as_relative_path(
  path : String,
  include_workspace_folder? : Bool,
) -> String {
  workspace_as_relative_path_path_ffi(
    path,
    @v.option_to_js(include_workspace_folder),
  )
}

///|
/// Returns a path that is relative to the workspace folder or folders.
///
/// When there are no {@link workspace.workspaceFolders workspace folders} or when the path
/// is not contained in them, the input is returned.
///
/// @param pathOrUri A path or uri. When a uri is given its {@link Uri.fsPath fsPath} is used.
/// @param includeWorkspaceFolder When `true` and when the given path is contained inside a
/// workspace folder the name of the workspace is prepended. Defaults to `true` when there are
/// multiple workspace folders and `false` otherwise.
/// @returns A path relative to the root or the input.
pub fn as_relative_path_uri(
  uri : Uri,
  include_workspace_folder? : Bool,
) -> String {
  workspace_as_relative_path_uri_ffi(
    uri,
    @v.option_to_js(include_workspace_folder),
  )
}

///|
/// This method replaces `deleteCount` {@link workspace.workspaceFolders workspace folders} starting at index `start`
/// by an optional set of `workspaceFoldersToAdd` on the `vscode.workspace.workspaceFolders` array. This "splice"
/// behavior can be used to add, remove and change workspace folders in a single operation.
///
/// **Note:** in some cases calling this method may result in the currently executing extensions (including the
/// one that called this method) to be terminated and restarted. For example when the first workspace folder is
/// added, removed or changed the (deprecated) `rootPath` property is updated to point to the first workspace
/// folder. Another case is when transitioning from an empty or single-folder workspace into a multi-folder
/// workspace (see also: https://code.visualstudio.com/docs/editor/workspaces).
///
/// Use the {@linkcode onDidChangeWorkspaceFolders onDidChangeWorkspaceFolders()} event to get notified when the
/// workspace folders have been updated.
///
/// **Example:** adding a new workspace folder at the end of workspace folders
/// ```typescript
/// workspace.updateWorkspaceFolders(workspace.workspaceFolders ? workspace.workspaceFolders.length : 0, null, { uri: ...});
/// ```
///
/// **Example:** removing the first workspace folder
/// ```typescript
/// workspace.updateWorkspaceFolders(0, 1);
/// ```
///
/// **Example:** replacing an existing workspace folder with a new one
/// ```typescript
/// workspace.updateWorkspaceFolders(0, 1, { uri: ...});
/// ```
///
/// It is valid to remove an existing workspace folder and add it again with a different name
/// to rename that folder.
///
/// **Note:** it is not valid to call {@link updateWorkspaceFolders updateWorkspaceFolders()} multiple times
/// without waiting for the {@linkcode onDidChangeWorkspaceFolders onDidChangeWorkspaceFolders()} to fire.
///
/// @param start the zero-based location in the list of currently opened {@link WorkspaceFolder workspace folders}
/// from which to start deleting workspace folders.
/// @param deleteCount the optional number of workspace folders to remove.
/// @param workspaceFoldersToAdd the optional variable set of workspace folders to add in place of the deleted ones.
/// Each workspace is identified with a mandatory URI and an optional name.
/// @returns true if the operation was successfully started and false otherwise if arguments were used that would result
/// in invalid workspace folder state (e.g. 2 folders with the same URI).
pub fn update_workspace_folders(
  start : Int,
  delete_count? : Int,
  folders_to_add? : Array[WorkspaceFolderInput],
) -> Bool {
  let additions = match folders_to_add {
    None => []
    Some(values) => workspace_folder_input_array_to_js(values)
  }
  workspace_update_workspace_folders_ffi(
    start,
    @v.option_to_js(delete_count),
    additions,
  )
}

///|
/// Creates a file system watcher that is notified on file events (create, change, delete)
/// depending on the parameters provided.
///
/// By default, all opened {@link workspace.workspaceFolders workspace folders} will be watched
/// for file changes recursively.
///
/// Additional paths can be added for file watching by providing a {@link RelativePattern} with
/// a `base` path to watch. If the path is a folder and the `pattern` is complex (e.g. contains
/// `**` or path segments), it will be watched recursively and otherwise will be watched
/// non-recursively (i.e. only changes to the first level of the path will be reported).
///
/// *Note* that paths that do not exist in the file system will be monitored with a delay until
/// created and then watched depending on the parameters provided. If a watched path is deleted,
/// the watcher will suspend and not report any events until the path is created again.
///
/// If possible, keep the use of recursive watchers to a minimum because recursive file watching
/// is quite resource intense.
///
/// Providing a `string` as `globPattern` acts as convenience method for watching file events in
/// all opened workspace folders. It cannot be used to add more folders for file watching, nor will
/// it report any file events from folders that are not part of the opened workspace folders.
///
/// *Note* that case-sensitivity of the {@link globPattern} parameter will depend on the file system
/// where the watcher is running: on Windows and macOS the matching will be case-insensitive and
/// on Linux it will be case-sensitive.
///
/// Optionally, flags to ignore certain kinds of events can be provided.
///
/// To stop listening to events the watcher must be disposed.
///
/// *Note* that file events from deleting a folder may not include events for the contained files.
/// For example, when a folder is moved to the trash, only one event is reported because technically
/// this is a rename/move operation and not a delete operation for each files within.
/// On top of that, performance optimizations are in place to fold multiple events that all belong
/// to the same parent operation (e.g. delete folder) into one event for that parent. As such, if
/// you need to know about all deleted files, you have to watch with `**` and deal with all file
/// events yourself.
///
/// *Note* that file events from recursive file watchers may be excluded based on user configuration.
/// The setting `files.watcherExclude` helps to reduce the overhead of file events from folders
/// that are known to produce many file changes at once (such as `.git` folders). As such,
/// it is highly recommended to watch with simple patterns that do not require recursive watchers
/// where the exclude settings are ignored and you have full control over the events.
///
/// *Note* that symbolic links are not automatically followed for file watching unless the path to
/// watch itself is a symbolic link.
///
/// *Note* that the file paths that are reported for having changed may have a different path casing
/// compared to the actual casing on disk on case-insensitive platforms (typically macOS and Windows
/// but not Linux). We allow a user to open a workspace folder with any desired path casing and try
/// to preserve that. This means:
/// * if the path is within any of the workspace folders, the path will match the casing of the
///   workspace folder up to that portion of the path and match the casing on disk for children
/// * if the path is outside of any of the workspace folders, the casing will match the case of the
///   path that was provided for watching
/// In the same way, symbolic links are preserved, i.e. the file event will report the path of the
/// symbolic link as it was provided for watching and not the target.
///
/// ### Examples
///
/// The basic anatomy of a file watcher is as follows:
///
/// ```ts
/// const watcher = vscode.workspace.createFileSystemWatcher(new vscode.RelativePattern(<folder>, <pattern>));
///
/// watcher.onDidChange(uri => { ... }); // listen to files being changed
/// watcher.onDidCreate(uri => { ... }); // listen to files/folders being created
/// watcher.onDidDelete(uri => { ... }); // listen to files/folders getting deleted
///
/// watcher.dispose(); // dispose after usage
/// ```
///
/// #### Workspace file watching
///
/// If you only care about file events in a specific workspace folder:
///
/// ```ts
/// vscode.workspace.createFileSystemWatcher(new vscode.RelativePattern(vscode.workspace.workspaceFolders[0], '**​/*.js'));
/// ```
///
/// If you want to monitor file events across all opened workspace folders:
///
/// ```ts
/// vscode.workspace.createFileSystemWatcher('**​/*.js');
/// ```
///
/// *Note:* the array of workspace folders can be empty if no workspace is opened (empty window).
///
/// #### Out of workspace file watching
///
/// To watch a folder for changes to *.js files outside the workspace (non recursively), pass in a `Uri` to such
/// a folder:
///
/// ```ts
/// vscode.workspace.createFileSystemWatcher(new vscode.RelativePattern(vscode.Uri.file(<path to folder outside workspace>), '*.js'));
/// ```
///
/// And use a complex glob pattern to watch recursively:
///
/// ```ts
/// vscode.workspace.createFileSystemWatcher(new vscode.RelativePattern(vscode.Uri.file(<path to folder outside workspace>), '**​/*.js'));
/// ```
///
/// Here is an example for watching the active editor for file changes:
///
/// ```ts
/// vscode.workspace.createFileSystemWatcher(new vscode.RelativePattern(vscode.window.activeTextEditor.document.uri, '*'));
/// ```
///
/// @param globPattern A {@link GlobPattern glob pattern} that controls which file events the watcher should report.
/// @param ignoreCreateEvents Ignore when files have been created.
/// @param ignoreChangeEvents Ignore when files have been changed.
/// @param ignoreDeleteEvents Ignore when files have been deleted.
/// @returns A new file system watcher instance. Must be disposed when no longer needed.
pub fn create_file_system_watcher(
  glob_pattern : GlobPattern,
  ignore_create_events? : Bool,
  ignore_change_events? : Bool,
  ignore_delete_events? : Bool,
) -> FileSystemWatcher {
  workspace_create_file_system_watcher_ffi(
    glob_pattern_to_js(glob_pattern),
    @v.option_to_js(ignore_create_events),
    @v.option_to_js(ignore_change_events),
    @v.option_to_js(ignore_delete_events),
  )
}

///|

///|
fn find_files_promise(
  include_pattern : GlobPattern,
  exclude : GlobPattern?,
  max_results : Int?,
  token : CancellationToken?,
) -> @js_async.Promise[Array[Uri]] {
  workspace_find_files_ffi(
    glob_pattern_to_js(include_pattern),
    option_glob_pattern_to_js(exclude),
    @v.option_to_js(max_results),
    @v.option_to_js(token),
  )
}

///|
/// Find files across all {@link workspace.workspaceFolders workspace folders} in the workspace.
///
/// @example
/// findFiles('**​/*.js', '**​/node_modules/**', 10)
///
/// @param include A {@link GlobPattern glob pattern} that defines the files to search for. The glob pattern
/// will be matched against the file paths of resulting matches relative to their workspace. Use a {@link RelativePattern relative pattern}
/// to restrict the search results to a {@link WorkspaceFolder workspace folder}.
/// @param exclude  A {@link GlobPattern glob pattern} that defines files and folders to exclude. The glob pattern
/// will be matched against the file paths of resulting matches relative to their workspace. When `undefined`, default file-excludes (e.g. the `files.exclude`-setting
/// but not `search.exclude`) will apply. When `null`, no excludes will apply.
/// @param maxResults An upper-bound for the result.
/// @param token A token that can be used to signal cancellation to the underlying search engine.
/// @returns A thenable that resolves to an array of resource identifiers. Will return no results if no
/// {@link workspace.workspaceFolders workspace folders} are opened.
pub async fn find_files(
  include_pattern : GlobPattern,
  exclude? : GlobPattern,
  max_results? : Int,
  token? : CancellationToken,
) -> Array[Uri] {
  @js_async.Promise::wait(
    find_files_promise(include_pattern, exclude, max_results, token),
  )
}

///|
fn find_files_no_excludes_promise(
  include_pattern : GlobPattern,
  max_results : Int?,
  token : CancellationToken?,
) -> @js_async.Promise[Array[Uri]] {
  workspace_find_files_no_excludes_ffi(
    glob_pattern_to_js(include_pattern),
    @v.option_to_js(max_results),
    @v.option_to_js(token),
  )
}

///|
/// Find files across all {@link workspace.workspaceFolders workspace folders} in the workspace.
///
/// @example
/// findFiles('**​/*.js', '**​/node_modules/**', 10)
///
/// @param include A {@link GlobPattern glob pattern} that defines the files to search for. The glob pattern
/// will be matched against the file paths of resulting matches relative to their workspace. Use a {@link RelativePattern relative pattern}
/// to restrict the search results to a {@link WorkspaceFolder workspace folder}.
/// @param exclude  A {@link GlobPattern glob pattern} that defines files and folders to exclude. The glob pattern
/// will be matched against the file paths of resulting matches relative to their workspace. When `undefined`, default file-excludes (e.g. the `files.exclude`-setting
/// but not `search.exclude`) will apply. When `null`, no excludes will apply.
/// @param maxResults An upper-bound for the result.
/// @param token A token that can be used to signal cancellation to the underlying search engine.
/// @returns A thenable that resolves to an array of resource identifiers. Will return no results if no
/// {@link workspace.workspaceFolders workspace folders} are opened.
pub async fn find_files_no_excludes(
  include_pattern : GlobPattern,
  max_results? : Int,
  token? : CancellationToken,
) -> Array[Uri] {
  @js_async.Promise::wait(
    find_files_no_excludes_promise(include_pattern, max_results, token),
  )
}

///|
fn save_promise(uri : Uri) -> @js_async.Promise[Uri?] {
  workspace_save_ffi(uri)
}

///|
fn save_as_promise(uri : Uri) -> @js_async.Promise[Uri?] {
  workspace_save_as_ffi(uri)
}

///|
fn save_all_promise(include_untitled : @v.JsValue) -> @js_async.Promise[Bool] {
  workspace_save_all_ffi(include_untitled)
}

///|
fn apply_edit_promise(
  edit : WorkspaceEdit,
  metadata : WorkspaceEditMetadata?,
) -> @js_async.Promise[Bool] {
  workspace_apply_edit_ffi(edit, workspace_edit_metadata_to_js(metadata))
}

///|
/// Saves the editor identified by the given resource and returns the resulting resource or `undefined`
/// if save was not successful or no editor with the given resource was found.
///
/// **Note** that an editor with the provided resource must be opened in order to be saved.
///
/// @param uri the associated uri for the opened editor to save.
/// @returns A thenable that resolves when the save operation has finished.
pub async fn save(uri : Uri) -> Uri? {
  @js_async.Promise::wait(save_promise(uri))
}

///|
/// Saves the editor identified by the given resource to a new file name as provided by the user and
/// returns the resulting resource or `undefined` if save was not successful or cancelled or no editor
/// with the given resource was found.
///
/// **Note** that an editor with the provided resource must be opened in order to be saved as.
///
/// @param uri the associated uri for the opened editor to save as.
/// @returns A thenable that resolves when the save-as operation has finished.
pub async fn save_as(uri : Uri) -> Uri? {
  @js_async.Promise::wait(save_as_promise(uri))
}

///|
/// Save all dirty files.
///
/// @param includeUntitled Also save files that have been created during this session.
/// @returns A thenable that resolves when the files have been saved. Will return `false`
/// for any file that failed to save.
pub async fn save_all(include_untitled? : Bool) -> Bool {
  @js_async.Promise::wait(save_all_promise(@v.option_to_js(include_untitled)))
}

///|
/// Make changes to one or many resources or create, delete, and rename resources as defined by the given
/// {@link WorkspaceEdit workspace edit}.
///
/// All changes of a workspace edit are applied in the same order in which they have been added. If
/// multiple textual inserts are made at the same position, these strings appear in the resulting text
/// in the order the 'inserts' were made, unless that are interleaved with resource edits. Invalid sequences
/// like 'delete file a' -> 'insert text in file a' cause failure of the operation.
///
/// When applying a workspace edit that consists only of text edits an 'all-or-nothing'-strategy is used.
/// A workspace edit with resource creations or deletions aborts the operation, e.g. consecutive edits will
/// not be attempted, when a single edit fails.
///
/// @param edit A workspace edit.
/// @param metadata Optional {@link WorkspaceEditMetadata metadata} for the edit.
/// @returns A thenable that resolves when the edit could be applied.
pub async fn apply_edit(
  edit : WorkspaceEdit,
  metadata? : WorkspaceEditMetadata,
) -> Bool {
  @js_async.Promise::wait(apply_edit_promise(edit, metadata))
}

///|
/// All text documents currently known to the editor.
pub fn text_documents() -> Array[TextDocument] {
  workspace_text_documents_ffi()
}

///|
fn open_text_document_uri_promise(
  uri : Uri,
  encoding : String?,
) -> @js_async.Promise[TextDocument] {
  workspace_open_text_document_uri_ffi(uri, @v.option_to_js(encoding))
}

///|
fn open_text_document_path_promise(
  path : String,
  encoding : String?,
) -> @js_async.Promise[TextDocument] {
  workspace_open_text_document_path_ffi(path, @v.option_to_js(encoding))
}

///|
fn open_text_document_untitled_promise(
  language : String?,
  content : String?,
  encoding : String?,
) -> @js_async.Promise[TextDocument] {
  workspace_open_text_document_untitled_ffi(
    @v.option_to_js(language),
    @v.option_to_js(content),
    @v.option_to_js(encoding),
  )
}

///|
/// Opens a document. Will return early if this document is already open. Otherwise
/// the document is loaded and the {@link workspace.onDidOpenTextDocument didOpen}-event fires.
///
/// The document is denoted by an {@link Uri}. Depending on the {@link Uri.scheme scheme} the
/// following rules apply:
/// * `file`-scheme: Open a file on disk (`openTextDocument(Uri.file(path))`). Will be rejected if the file
/// does not exist or cannot be loaded.
/// * `untitled`-scheme: Open a blank untitled file with associated path (`openTextDocument(Uri.file(path).with({ scheme: 'untitled' }))`).
/// The language will be derived from the file name.
/// * For all other schemes contributed {@link TextDocumentContentProvider text document content providers} and
/// {@link FileSystemProvider file system providers} are consulted.
///
/// *Note* that the lifecycle of the returned document is owned by the editor and not by the extension. That means an
/// {@linkcode workspace.onDidCloseTextDocument onDidClose}-event can occur at any time after opening it.
///
/// @param uri Identifies the resource to open.
/// @returns A promise that resolves to a {@link TextDocument document}.
pub async fn open_text_document_uri(
  uri : Uri,
  encoding? : String,
) -> TextDocument {
  @js_async.Promise::wait(open_text_document_uri_promise(uri, encoding))
}

///|
/// Opens a document. Will return early if this document is already open. Otherwise
/// the document is loaded and the {@link workspace.onDidOpenTextDocument didOpen}-event fires.
///
/// The document is denoted by an {@link Uri}. Depending on the {@link Uri.scheme scheme} the
/// following rules apply:
/// * `file`-scheme: Open a file on disk (`openTextDocument(Uri.file(path))`). Will be rejected if the file
/// does not exist or cannot be loaded.
/// * `untitled`-scheme: Open a blank untitled file with associated path (`openTextDocument(Uri.file(path).with({ scheme: 'untitled' }))`).
/// The language will be derived from the file name.
/// * For all other schemes contributed {@link TextDocumentContentProvider text document content providers} and
/// {@link FileSystemProvider file system providers} are consulted.
///
/// *Note* that the lifecycle of the returned document is owned by the editor and not by the extension. That means an
/// {@linkcode workspace.onDidCloseTextDocument onDidClose}-event can occur at any time after opening it.
///
/// @param uri Identifies the resource to open.
/// @returns A promise that resolves to a {@link TextDocument document}.
pub async fn open_text_document_path(
  path : String,
  encoding? : String,
) -> TextDocument {
  @js_async.Promise::wait(open_text_document_path_promise(path, encoding))
}

///|
/// Opens a document. Will return early if this document is already open. Otherwise
/// the document is loaded and the {@link workspace.onDidOpenTextDocument didOpen}-event fires.
///
/// The document is denoted by an {@link Uri}. Depending on the {@link Uri.scheme scheme} the
/// following rules apply:
/// * `file`-scheme: Open a file on disk (`openTextDocument(Uri.file(path))`). Will be rejected if the file
/// does not exist or cannot be loaded.
/// * `untitled`-scheme: Open a blank untitled file with associated path (`openTextDocument(Uri.file(path).with({ scheme: 'untitled' }))`).
/// The language will be derived from the file name.
/// * For all other schemes contributed {@link TextDocumentContentProvider text document content providers} and
/// {@link FileSystemProvider file system providers} are consulted.
///
/// *Note* that the lifecycle of the returned document is owned by the editor and not by the extension. That means an
/// {@linkcode workspace.onDidCloseTextDocument onDidClose}-event can occur at any time after opening it.
///
/// @param uri Identifies the resource to open.
/// @returns A promise that resolves to a {@link TextDocument document}.
pub async fn open_text_document_untitled(
  language? : String,
  content? : String,
  encoding? : String,
) -> TextDocument {
  @js_async.Promise::wait(
    open_text_document_untitled_promise(language, content, encoding),
  )
}

///|
/// Register a text document content provider.
///
/// Only one provider can be registered per scheme.
///
/// @param scheme The uri-scheme to register for.
/// @param provider A content provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.TextDocumentContentProvider] register_text_document_content_provider(
  scheme : String,
  provider : T,
) -> @vscode.Disposable {
  workspace_register_text_document_content_provider_ffi(
    scheme,
    text_document_content_provider_object(provider),
  )
}

///|
/// An event that is emitted when a {@link TextDocument text document} is opened or when the language id
/// of a text document {@link languages.setTextDocumentLanguage has been changed}.
///
/// To add an event listener when a visible text document is opened, use the {@link TextEditor} events in the
/// {@link window} namespace. Note that:
///
/// - The event is emitted before the {@link TextDocument document} is updated in the
/// {@link window.activeTextEditor active text editor}
/// - When a {@link TextDocument text document} is already open (e.g.: open in another {@link window.visibleTextEditors visible text editor}) this event is not emitted
pub fn on_did_open_text_document() -> Event[TextDocument] {
  workspace_on_did_open_text_document_ffi()
}

///|
/// An event that is emitted when a {@link TextDocument text document} is disposed or when the language id
/// of a text document {@link languages.setTextDocumentLanguage has been changed}.
///
/// *Note 1:* There is no guarantee that this event fires when an editor tab is closed, use the
/// {@linkcode window.onDidChangeVisibleTextEditors onDidChangeVisibleTextEditors}-event to know when editors change.
///
/// *Note 2:* A document can be open but not shown in an editor which means this event can fire
/// for a document that has not been shown in an editor.
pub fn on_did_close_text_document() -> Event[TextDocument] {
  workspace_on_did_close_text_document_ffi()
}

///|
/// An event that is emitted when a {@link TextDocument text document} is changed. This usually happens
/// when the {@link TextDocument.getText contents} changes but also when other things like the
/// {@link TextDocument.isDirty dirty}-state changes.
pub fn on_did_change_text_document() -> Event[TextDocumentChangeEvent] {
  workspace_on_did_change_text_document_ffi()
}

///|
/// An event that is emitted when a {@link TextDocument text document} will be saved to disk.
///
/// *Note 1:* Subscribers can delay saving by registering asynchronous work. For the sake of data integrity the editor
/// might save without firing this event. For instance when shutting down with dirty files.
///
/// *Note 2:* Subscribers are called sequentially and they can {@link TextDocumentWillSaveEvent.waitUntil delay} saving
/// by registering asynchronous work. Protection against misbehaving listeners is implemented as such:
///  * there is an overall time budget that all listeners share and if that is exhausted no further listener is called
///  * listeners that take a long time or produce errors frequently will not be called anymore
///
/// The current thresholds are 1.5 seconds as overall time budget and a listener can misbehave 3 times before being ignored.
pub fn on_will_save_text_document() -> Event[TextDocumentWillSaveEvent] {
  workspace_on_will_save_text_document_ffi()
}

///|
/// An event that is emitted when a {@link TextDocument text document} is saved to disk.
pub fn on_did_save_text_document() -> Event[TextDocument] {
  workspace_on_did_save_text_document_ffi()
}

///|
/// All notebook documents currently known to the editor.
pub fn notebook_documents() -> Array[NotebookDocument] {
  workspace_notebook_documents_ffi()
}

///|
fn open_notebook_document_uri_promise(
  uri : Uri,
) -> @js_async.Promise[NotebookDocument] {
  workspace_open_notebook_document_uri_ffi(uri)
}

///|
fn open_notebook_document_type_promise(
  notebook_type : String,
  content : NotebookData?,
) -> @js_async.Promise[NotebookDocument] {
  workspace_open_notebook_document_type_ffi(
    notebook_type,
    @v.option_to_js(content),
  )
}

///|
/// Open a notebook. Will return early if this notebook is already {@link notebookDocuments loaded}. Otherwise
/// the notebook is loaded and the {@linkcode onDidOpenNotebookDocument}-event fires.
///
/// *Note* that the lifecycle of the returned notebook is owned by the editor and not by the extension. That means an
/// {@linkcode onDidCloseNotebookDocument}-event can occur at any time after.
///
/// *Note* that opening a notebook does not show a notebook editor. This function only returns a notebook document which
/// can be shown in a notebook editor but it can also be used for other things.
///
/// @param uri The resource to open.
/// @returns A promise that resolves to a {@link NotebookDocument notebook}
pub async fn open_notebook_document_uri(uri : Uri) -> NotebookDocument {
  @js_async.Promise::wait(open_notebook_document_uri_promise(uri))
}

///|
/// Open a notebook. Will return early if this notebook is already {@link notebookDocuments loaded}. Otherwise
/// the notebook is loaded and the {@linkcode onDidOpenNotebookDocument}-event fires.
///
/// *Note* that the lifecycle of the returned notebook is owned by the editor and not by the extension. That means an
/// {@linkcode onDidCloseNotebookDocument}-event can occur at any time after.
///
/// *Note* that opening a notebook does not show a notebook editor. This function only returns a notebook document which
/// can be shown in a notebook editor but it can also be used for other things.
///
/// @param uri The resource to open.
/// @returns A promise that resolves to a {@link NotebookDocument notebook}
pub async fn open_notebook_document_type(
  notebook_type : String,
  content? : NotebookData,
) -> NotebookDocument {
  @js_async.Promise::wait(
    open_notebook_document_type_promise(notebook_type, content),
  )
}

///|
/// An event that is emitted when a {@link NotebookDocument notebook} has changed.
pub fn on_did_change_notebook_document() -> Event[NotebookDocumentChangeEvent] {
  workspace_on_did_change_notebook_document_ffi()
}

///|
/// An event that is emitted when a {@link NotebookDocument notebook document} will be saved to disk.
///
/// *Note 1:* Subscribers can delay saving by registering asynchronous work. For the sake of data integrity the editor
/// might save without firing this event. For instance when shutting down with dirty files.
///
/// *Note 2:* Subscribers are called sequentially and they can {@link NotebookDocumentWillSaveEvent.waitUntil delay} saving
/// by registering asynchronous work. Protection against misbehaving listeners is implemented as such:
///  * there is an overall time budget that all listeners share and if that is exhausted no further listener is called
///  * listeners that take a long time or produce errors frequently will not be called anymore
///
/// The current thresholds are 1.5 seconds as overall time budget and a listener can misbehave 3 times before being ignored.
pub fn on_will_save_notebook_document() -> Event[NotebookDocumentWillSaveEvent] {
  workspace_on_will_save_notebook_document_ffi()
}

///|
/// An event that is emitted when a {@link NotebookDocument notebook} is saved.
pub fn on_did_save_notebook_document() -> Event[NotebookDocument] {
  workspace_on_did_save_notebook_document_ffi()
}

///|
/// An event that is emitted when a {@link NotebookDocument notebook} is opened.
pub fn on_did_open_notebook_document() -> Event[NotebookDocument] {
  workspace_on_did_open_notebook_document_ffi()
}

///|
/// An event that is emitted when a {@link NotebookDocument notebook} is disposed.
///
/// *Note 1:* There is no guarantee that this event fires when an editor tab is closed.
///
/// *Note 2:* A notebook can be open but not shown in an editor which means this event can fire
/// for a notebook that has not been shown in an editor.
pub fn on_did_close_notebook_document() -> Event[NotebookDocument] {
  workspace_on_did_close_notebook_document_ffi()
}

///|
/// Register a {@link NotebookSerializer notebook serializer}.
///
/// A notebook serializer must be contributed through the `notebooks` extension point. When opening a notebook file, the editor will send
/// the `onNotebook:<notebookType>` activation event, and extensions must register their serializer in return.
///
/// @param notebookType A notebook.
/// @param serializer A notebook serializer.
/// @param options Optional context options that define what parts of a notebook should be persisted
/// @returns A {@link Disposable} that unregisters this serializer when being disposed.
pub fn register_notebook_serializer(
  notebook_type : String,
  serializer : @vscode.NotebookSerializer,
  options? : NotebookDocumentContentOptions,
) -> @vscode.Disposable {
  workspace_register_notebook_serializer_ffi(
    notebook_type,
    serializer,
    option_notebook_document_content_options_to_js(options),
  )
}

///|
/// An event that is emitted when files are being created.
///
/// *Note 1:* This event is triggered by user gestures, like creating a file from the
/// explorer, or from the {@linkcode workspace.applyEdit}-api. This event is *not* fired when
/// files change on disk, e.g triggered by another application, or when using the
/// {@linkcode FileSystem workspace.fs}-api.
///
/// *Note 2:* When this event is fired, edits to files that are are being created cannot be applied.
pub fn on_will_create_files() -> Event[FileWillCreateEvent] {
  workspace_on_will_create_files_ffi()
}

///|
/// An event that is emitted when files have been created.
///
/// *Note:* This event is triggered by user gestures, like creating a file from the
/// explorer, or from the {@linkcode workspace.applyEdit}-api, but this event is *not* fired when
/// files change on disk, e.g triggered by another application, or when using the
/// {@linkcode FileSystem workspace.fs}-api.
pub fn on_did_create_files() -> Event[FileCreateEvent] {
  workspace_on_did_create_files_ffi()
}

///|
/// An event that is emitted when files are being deleted.
///
/// *Note 1:* This event is triggered by user gestures, like deleting a file from the
/// explorer, or from the {@linkcode workspace.applyEdit}-api, but this event is *not* fired when
/// files change on disk, e.g triggered by another application, or when using the
/// {@linkcode FileSystem workspace.fs}-api.
///
/// *Note 2:* When deleting a folder with children only one event is fired.
pub fn on_will_delete_files() -> Event[FileWillDeleteEvent] {
  workspace_on_will_delete_files_ffi()
}

///|
/// An event that is emitted when files have been deleted.
///
/// *Note 1:* This event is triggered by user gestures, like deleting a file from the
/// explorer, or from the {@linkcode workspace.applyEdit}-api, but this event is *not* fired when
/// files change on disk, e.g triggered by another application, or when using the
/// {@linkcode FileSystem workspace.fs}-api.
///
/// *Note 2:* When deleting a folder with children only one event is fired.
pub fn on_did_delete_files() -> Event[FileDeleteEvent] {
  workspace_on_did_delete_files_ffi()
}

///|
/// An event that is emitted when files are being renamed.
///
/// *Note 1:* This event is triggered by user gestures, like renaming a file from the
/// explorer, and from the {@linkcode workspace.applyEdit}-api, but this event is *not* fired when
/// files change on disk, e.g triggered by another application, or when using the
/// {@linkcode FileSystem workspace.fs}-api.
///
/// *Note 2:* When renaming a folder with children only one event is fired.
pub fn on_will_rename_files() -> Event[FileWillRenameEvent] {
  workspace_on_will_rename_files_ffi()
}

///|
/// An event that is emitted when files have been renamed.
///
/// *Note 1:* This event is triggered by user gestures, like renaming a file from the
/// explorer, and from the {@linkcode workspace.applyEdit}-api, but this event is *not* fired when
/// files change on disk, e.g triggered by another application, or when using the
/// {@linkcode FileSystem workspace.fs}-api.
///
/// *Note 2:* When renaming a folder with children only one event is fired.
pub fn on_did_rename_files() -> Event[FileRenameEvent] {
  workspace_on_did_rename_files_ffi()
}

///|
/// Get a workspace configuration object.
///
/// When a section-identifier is provided only that part of the configuration
/// is returned. Dots in the section-identifier are interpreted as child-access,
/// like `{ myExt: { setting: { doIt: true }}}` and `getConfiguration('myExt.setting').get('doIt') === true`.
///
/// When a scope is provided configuration confined to that scope is returned. Scope can be a resource or a language identifier or both.
///
/// @param section A dot-separated identifier.
/// @param scope A scope for which the configuration is asked for.
/// @returns The full configuration or a subset.
pub fn get_configuration(
  section? : String,
  scope? : ConfigurationScope,
) -> WorkspaceConfiguration {
  workspace_get_configuration_ffi(
    @v.option_to_js(section),
    option_configuration_scope_to_js(scope),
  )
}

///|
/// An event that is emitted when the {@link WorkspaceConfiguration configuration} changed.
pub fn on_did_change_configuration() -> Event[ConfigurationChangeEvent] {
  workspace_on_did_change_configuration_ffi()
}

///|
/// Register a task provider.
///
/// @deprecated Use the corresponding function on the `tasks` namespace instead
///
/// @param type The task kind type this provider is registered for.
/// @param provider A task provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.TaskProvider] register_task_provider(
  task_type : String,
  provider : T,
) -> @vscode.Disposable {
  workspace_register_task_provider_ffi(
    task_type,
    task_provider_object(provider),
  )
}

///|
/// Register a filesystem provider for a given scheme, e.g. `ftp`.
///
/// There can only be one provider per scheme and an error is being thrown when a scheme
/// has been claimed by another provider or when it is reserved.
///
/// @param scheme The uri-{@link Uri.scheme scheme} the provider registers for.
/// @param provider The filesystem provider.
/// @param options Immutable metadata about the provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.FileSystemProvider] register_file_system_provider(
  scheme : String,
  provider : T,
  is_case_sensitive? : Bool,
  is_readonly? : Bool,
) -> @vscode.Disposable {
  workspace_register_file_system_provider_ffi(
    scheme,
    file_system_provider_object(provider),
    @v.option_to_js(is_case_sensitive),
    @v.option_to_js(is_readonly),
    @v.JsValue::make(()),
  )
}

///|
/// Register a filesystem provider for a given scheme, e.g. `ftp`.
///
/// There can only be one provider per scheme and an error is being thrown when a scheme
/// has been claimed by another provider or when it is reserved.
///
/// @param scheme The uri-{@link Uri.scheme scheme} the provider registers for.
/// @param provider The filesystem provider.
/// @param options Immutable metadata about the provider.
/// @returns A {@link Disposable} that unregisters this provider when being disposed.
pub fn[T : @vscode.FileSystemProvider] register_file_system_provider_readonly_reason(
  scheme : String,
  provider : T,
  reason : MarkdownString,
  is_case_sensitive? : Bool,
) -> @vscode.Disposable {
  workspace_register_file_system_provider_ffi(
    scheme,
    file_system_provider_object(provider),
    @v.option_to_js(is_case_sensitive),
    @v.JsValue::make(()),
    @v.JsValue::make(reason),
  )
}

///|
/// When true, the user has explicitly trusted the contents of the workspace.
pub fn is_trusted() -> Bool {
  workspace_is_trusted_ffi()
}

///|
/// Event that fires when the current workspace has been trusted.
pub fn on_did_grant_workspace_trust() -> Event[Unit] {
  workspace_on_did_grant_workspace_trust_ffi()
}

///|
fn decode_promise(content : Bytes) -> @js_async.Promise[String] {
  workspace_decode_ffi(bytes_to_uint8_array(content))
}

///|
/// Decodes the content from a `Uint8Array` to a `string`. You MUST
/// provide the entire content at once to ensure that the encoding
/// can properly apply. Do not use this method to decode content
/// in chunks, as that may lead to incorrect results.
///
/// Will pick an encoding based on settings and the content of the
/// buffer (for example byte order marks).
///
/// *Note* that if you decode content that is unsupported by the
/// encoding, the result may contain substitution characters as
/// appropriate.
///
/// @throws This method will throw an error when the content is binary.
///
/// @param content The text content to decode as a `Uint8Array`.
/// @returns A thenable that resolves to the decoded `string`.
pub async fn decode(content : Bytes) -> String {
  @js_async.Promise::wait(decode_promise(content))
}

///|
fn decode_with_encoding_promise(
  content : Bytes,
  encoding : String,
) -> @js_async.Promise[String] {
  workspace_decode_with_encoding_ffi(bytes_to_uint8_array(content), encoding)
}

///|
/// Decodes the content from a `Uint8Array` to a `string`. You MUST
/// provide the entire content at once to ensure that the encoding
/// can properly apply. Do not use this method to decode content
/// in chunks, as that may lead to incorrect results.
///
/// Will pick an encoding based on settings and the content of the
/// buffer (for example byte order marks).
///
/// *Note* that if you decode content that is unsupported by the
/// encoding, the result may contain substitution characters as
/// appropriate.
///
/// @throws This method will throw an error when the content is binary.
///
/// @param content The text content to decode as a `Uint8Array`.
/// @returns A thenable that resolves to the decoded `string`.
pub async fn decode_with_encoding(content : Bytes, encoding : String) -> String {
  @js_async.Promise::wait(decode_with_encoding_promise(content, encoding))
}

///|
fn decode_with_uri_promise(
  content : Bytes,
  uri : Uri,
) -> @js_async.Promise[String] {
  workspace_decode_with_uri_ffi(bytes_to_uint8_array(content), uri)
}

///|
/// Decodes the content from a `Uint8Array` to a `string`. You MUST
/// provide the entire content at once to ensure that the encoding
/// can properly apply. Do not use this method to decode content
/// in chunks, as that may lead to incorrect results.
///
/// Will pick an encoding based on settings and the content of the
/// buffer (for example byte order marks).
///
/// *Note* that if you decode content that is unsupported by the
/// encoding, the result may contain substitution characters as
/// appropriate.
///
/// @throws This method will throw an error when the content is binary.
///
/// @param content The text content to decode as a `Uint8Array`.
/// @returns A thenable that resolves to the decoded `string`.
pub async fn decode_with_uri(content : Bytes, uri : Uri) -> String {
  @js_async.Promise::wait(decode_with_uri_promise(content, uri))
}

///|
fn encode_promise(content : String) -> @js_async.Promise[Uint8Array] {
  workspace_encode_ffi(content)
}

///|
/// Encodes the content of a `string` to a `Uint8Array`.
///
/// Will pick an encoding based on settings.
///
/// @param content The content to decode as a `string`.
/// @returns A thenable that resolves to the encoded `Uint8Array`.
pub async fn encode(content : String) -> Bytes {
  bytes_from_uint8_array(@js_async.Promise::wait(encode_promise(content)))
}

///|
fn encode_with_encoding_promise(
  content : String,
  encoding : String,
) -> @js_async.Promise[Uint8Array] {
  workspace_encode_with_encoding_ffi(content, encoding)
}

///|
/// Encodes the content of a `string` to a `Uint8Array`.
///
/// Will pick an encoding based on settings.
///
/// @param content The content to decode as a `string`.
/// @returns A thenable that resolves to the encoded `Uint8Array`.
pub async fn encode_with_encoding(content : String, encoding : String) -> Bytes {
  bytes_from_uint8_array(
    @js_async.Promise::wait(encode_with_encoding_promise(content, encoding)),
  )
}

///|
fn encode_with_uri_promise(
  content : String,
  uri : Uri,
) -> @js_async.Promise[Uint8Array] {
  workspace_encode_with_uri_ffi(content, uri)
}

///|
/// Encodes the content of a `string` to a `Uint8Array`.
///
/// Will pick an encoding based on settings.
///
/// @param content The content to decode as a `string`.
/// @returns A thenable that resolves to the encoded `Uint8Array`.
pub async fn encode_with_uri(content : String, uri : Uri) -> Bytes {
  bytes_from_uint8_array(
    @js_async.Promise::wait(encode_with_uri_promise(content, uri)),
  )
}

///|
extern "js" fn workspace_folder_input_to_js_ffi(
  uri : Uri,
  name : @v.JsValue,
) -> @v.JsValue =
  #| (uri, name) => {
  #|   const folder = { uri };
  #|   if (name !== undefined && name !== null) {
  #|     folder.name = name;
  #|   }
  #|   return folder;
  #| }

///|
extern "js" fn workspace_edit_metadata_to_js_ffi(
  is_refactoring : @v.JsValue,
) -> @v.JsValue =
  #| (isRefactoring) => {
  #|   const metadata = {};
  #|   if (isRefactoring !== undefined && isRefactoring !== null) {
  #|     metadata.isRefactoring = isRefactoring;
  #|   }
  #|   return metadata;
  #| }

///|
