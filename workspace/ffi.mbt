///|
/// JS FFI bindings for VS Code workspace.

///|
#external
priv type Uint8Array

///|
extern "js" fn workspace_fs_ffi() -> FileSystem =
  #| () => require("vscode").workspace.fs

///|
extern "js" fn workspace_root_path_ffi() -> @v.JsValue =
  #| () => require("vscode").workspace.rootPath

///|
extern "js" fn workspace_workspace_folders_ffi() -> @v.JsValue =
  #| () => require("vscode").workspace.workspaceFolders

///|
extern "js" fn workspace_name_ffi() -> @v.JsValue =
  #| () => require("vscode").workspace.name

///|
extern "js" fn workspace_workspace_file_ffi() -> @v.JsValue =
  #| () => require("vscode").workspace.workspaceFile

///|
extern "js" fn workspace_on_did_change_workspace_folders_ffi() -> Event[
  WorkspaceFoldersChangeEvent,
] =
  #| () => require("vscode").workspace.onDidChangeWorkspaceFolders

///|
extern "js" fn workspace_get_workspace_folder_ffi(uri : Uri) -> @v.JsValue =
  #| (uri) => require("vscode").workspace.getWorkspaceFolder(uri)

///|
extern "js" fn workspace_as_relative_path_path_ffi(
  path : String,
  include_workspace_folder : @v.JsValue,
) -> String =
  #| (path, includeWorkspaceFolder) => {
  #|   const vscode = require("vscode");
  #|   return includeWorkspaceFolder === undefined || includeWorkspaceFolder === null
  #|     ? vscode.workspace.asRelativePath(path)
  #|     : vscode.workspace.asRelativePath(path, includeWorkspaceFolder);
  #| }

///|
extern "js" fn workspace_as_relative_path_uri_ffi(
  uri : Uri,
  include_workspace_folder : @v.JsValue,
) -> String =
  #| (uri, includeWorkspaceFolder) => {
  #|   const vscode = require("vscode");
  #|   return includeWorkspaceFolder === undefined || includeWorkspaceFolder === null
  #|     ? vscode.workspace.asRelativePath(uri)
  #|     : vscode.workspace.asRelativePath(uri, includeWorkspaceFolder);
  #| }

///|
extern "js" fn workspace_update_workspace_folders_ffi(
  start : Int,
  delete_count : @v.JsValue,
  folders_to_add : Array[@v.JsValue],
) -> Bool =
  #| (start, deleteCount, foldersToAdd) =>
  #|   require("vscode").workspace.updateWorkspaceFolders(start, deleteCount, ...foldersToAdd)

///|
extern "js" fn workspace_create_file_system_watcher_ffi(
  glob_pattern : @v.JsValue,
  ignore_create_events : @v.JsValue,
  ignore_change_events : @v.JsValue,
  ignore_delete_events : @v.JsValue,
) -> FileSystemWatcher =
  #| (pattern, ignoreCreate, ignoreChange, ignoreDelete) =>
  #|   require("vscode").workspace.createFileSystemWatcher(pattern, ignoreCreate, ignoreChange, ignoreDelete)

///|
extern "js" fn workspace_find_files_ffi(
  include_pattern : @v.JsValue,
  exclude : @v.JsValue,
  max_results : @v.JsValue,
  token : @v.JsValue,
) -> @js_async.Promise[Array[Uri]] =
  #| (includePattern, exclude, maxResults, token) =>
  #|   require("vscode").workspace.findFiles(includePattern, exclude, maxResults, token)

///|
extern "js" fn workspace_find_files_no_excludes_ffi(
  include_pattern : @v.JsValue,
  max_results : @v.JsValue,
  token : @v.JsValue,
) -> @js_async.Promise[Array[Uri]] =
  #| (includePattern, maxResults, token) =>
  #|   require("vscode").workspace.findFiles(includePattern, null, maxResults, token)

///|
extern "js" fn workspace_save_ffi(uri : Uri) -> @js_async.Promise[Uri?] =
  #| (uri) => require("vscode").workspace.save(uri)

///|
extern "js" fn workspace_save_as_ffi(uri : Uri) -> @js_async.Promise[Uri?] =
  #| (uri) => require("vscode").workspace.saveAs(uri)

///|
extern "js" fn workspace_save_all_ffi(
  include_untitled : @v.JsValue,
) -> @js_async.Promise[Bool] =
  #| (includeUntitled) => require("vscode").workspace.saveAll(includeUntitled)

///|
extern "js" fn workspace_apply_edit_ffi(
  edit : WorkspaceEdit,
  metadata : @v.JsValue,
) -> @js_async.Promise[Bool] =
  #| (edit, metadata) => require("vscode").workspace.applyEdit(edit, metadata)

///|
extern "js" fn workspace_text_documents_ffi() -> Array[TextDocument] =
  #| () => require("vscode").workspace.textDocuments

///|
extern "js" fn workspace_open_text_document_uri_ffi(
  uri : Uri,
  encoding : @v.JsValue,
) -> @js_async.Promise[TextDocument] =
  #| (uri, encoding) => {
  #|   const vscode = require("vscode");
  #|   return encoding === undefined || encoding === null
  #|     ? vscode.workspace.openTextDocument(uri)
  #|     : vscode.workspace.openTextDocument(uri, { encoding });
  #| }

///|
extern "js" fn workspace_open_text_document_path_ffi(
  path : String,
  encoding : @v.JsValue,
) -> @js_async.Promise[TextDocument] =
  #| (path, encoding) => {
  #|   const vscode = require("vscode");
  #|   return encoding === undefined || encoding === null
  #|     ? vscode.workspace.openTextDocument(path)
  #|     : vscode.workspace.openTextDocument(path, { encoding });
  #| }

///|
extern "js" fn workspace_open_text_document_untitled_ffi(
  language : @v.JsValue,
  content : @v.JsValue,
  encoding : @v.JsValue,
) -> @js_async.Promise[TextDocument] =
  #| (language, content, encoding) => {
  #|   const options = {};
  #|   if (language !== undefined && language !== null) {
  #|     options.language = language;
  #|   }
  #|   if (content !== undefined && content !== null) {
  #|     options.content = content;
  #|   }
  #|   if (encoding !== undefined && encoding !== null) {
  #|     options.encoding = encoding;
  #|   }
  #|   return Object.keys(options).length === 0
  #|     ? require("vscode").workspace.openTextDocument()
  #|     : require("vscode").workspace.openTextDocument(options);
  #| }

///|
extern "js" fn workspace_register_text_document_content_provider_ffi(
  scheme : String,
  provider : @providers.TextDocumentContentProviderObject,
) -> &@vscode.Disposable =
  #| (scheme, provider) =>
  #|   require("vscode").workspace.registerTextDocumentContentProvider(scheme, provider)

///|
extern "js" fn workspace_on_did_open_text_document_ffi() -> Event[TextDocument] =
  #| () => require("vscode").workspace.onDidOpenTextDocument

///|
extern "js" fn workspace_on_did_close_text_document_ffi() -> Event[TextDocument] =
  #| () => require("vscode").workspace.onDidCloseTextDocument

///|
extern "js" fn workspace_on_did_change_text_document_ffi() -> Event[
  TextDocumentChangeEvent,
] =
  #| () => require("vscode").workspace.onDidChangeTextDocument

///|
extern "js" fn workspace_on_will_save_text_document_ffi() -> Event[
  TextDocumentWillSaveEvent,
] =
  #| () => require("vscode").workspace.onWillSaveTextDocument

///|
extern "js" fn workspace_on_did_save_text_document_ffi() -> Event[TextDocument] =
  #| () => require("vscode").workspace.onDidSaveTextDocument

///|
extern "js" fn workspace_notebook_documents_ffi() -> Array[NotebookDocument] =
  #| () => require("vscode").workspace.notebookDocuments

///|
extern "js" fn workspace_open_notebook_document_uri_ffi(
  uri : Uri,
) -> @js_async.Promise[NotebookDocument] =
  #| (uri) => require("vscode").workspace.openNotebookDocument(uri)

///|
extern "js" fn workspace_open_notebook_document_type_ffi(
  notebook_type : String,
  content : @v.JsValue,
) -> @js_async.Promise[NotebookDocument] =
  #| (notebookType, content) => {
  #|   const vscode = require("vscode");
  #|   return content === undefined || content === null
  #|     ? vscode.workspace.openNotebookDocument(notebookType)
  #|     : vscode.workspace.openNotebookDocument(notebookType, content);
  #| }

///|
extern "js" fn workspace_on_did_change_notebook_document_ffi() -> Event[
  NotebookDocumentChangeEvent,
] =
  #| () => require("vscode").workspace.onDidChangeNotebookDocument

///|
extern "js" fn workspace_on_will_save_notebook_document_ffi() -> Event[
  NotebookDocumentWillSaveEvent,
] =
  #| () => require("vscode").workspace.onWillSaveNotebookDocument

///|
extern "js" fn workspace_on_did_save_notebook_document_ffi() -> Event[
  NotebookDocument,
] =
  #| () => require("vscode").workspace.onDidSaveNotebookDocument

///|
extern "js" fn workspace_register_notebook_serializer_ffi(
  notebook_type : String,
  serializer : @vscode.NotebookSerializer,
  options : @v.JsValue,
) -> &@vscode.Disposable =
  #| (notebookType, serializer, options) =>
  #|   require("vscode").workspace.registerNotebookSerializer(notebookType, serializer, options)

///|
extern "js" fn workspace_on_did_open_notebook_document_ffi() -> Event[
  NotebookDocument,
] =
  #| () => require("vscode").workspace.onDidOpenNotebookDocument

///|
extern "js" fn workspace_on_did_close_notebook_document_ffi() -> Event[
  NotebookDocument,
] =
  #| () => require("vscode").workspace.onDidCloseNotebookDocument

///|
extern "js" fn workspace_on_will_create_files_ffi() -> Event[
  FileWillCreateEvent,
] =
  #| () => require("vscode").workspace.onWillCreateFiles

///|
extern "js" fn workspace_on_did_create_files_ffi() -> Event[FileCreateEvent] =
  #| () => require("vscode").workspace.onDidCreateFiles

///|
extern "js" fn workspace_on_will_delete_files_ffi() -> Event[
  FileWillDeleteEvent,
] =
  #| () => require("vscode").workspace.onWillDeleteFiles

///|
extern "js" fn workspace_on_did_delete_files_ffi() -> Event[FileDeleteEvent] =
  #| () => require("vscode").workspace.onDidDeleteFiles

///|
extern "js" fn workspace_on_will_rename_files_ffi() -> Event[
  FileWillRenameEvent,
] =
  #| () => require("vscode").workspace.onWillRenameFiles

///|
extern "js" fn workspace_on_did_rename_files_ffi() -> Event[FileRenameEvent] =
  #| () => require("vscode").workspace.onDidRenameFiles

///|
extern "js" fn workspace_get_configuration_ffi(
  section : @v.JsValue,
  scope : @v.JsValue,
) -> WorkspaceConfiguration =
  #| (section, scope) => {
  #|   const vscode = require("vscode");
  #|   if (section === undefined || section === null) {
  #|     return vscode.workspace.getConfiguration();
  #|   }
  #|   if (scope === undefined || scope === null) {
  #|     return vscode.workspace.getConfiguration(section);
  #|   }
  #|   return vscode.workspace.getConfiguration(section, scope);
  #| }

///|
extern "js" fn workspace_on_did_change_configuration_ffi() -> Event[
  ConfigurationChangeEvent,
] =
  #| () => require("vscode").workspace.onDidChangeConfiguration

///|
extern "js" fn workspace_register_task_provider_ffi(
  task_type : String,
  provider : @providers.TaskProviderObject,
) -> &@vscode.Disposable =
  #| (type, provider) => require("vscode").workspace.registerTaskProvider(type, provider)

///|
extern "js" fn workspace_register_file_system_provider_ffi(
  scheme : String,
  provider : @providers.FileSystemProviderObject,
  is_case_sensitive : @v.JsValue,
  is_readonly : @v.JsValue,
  is_readonly_reason : @v.JsValue,
) -> &@vscode.Disposable =
  #| (scheme, provider, isCaseSensitive, isReadonly, isReadonlyReason) => {
  #|   const options = {};
  #|   if (isCaseSensitive !== undefined && isCaseSensitive !== null) {
  #|     options.isCaseSensitive = isCaseSensitive;
  #|   }
  #|   if (isReadonlyReason !== undefined && isReadonlyReason !== null) {
  #|     options.isReadonly = isReadonlyReason;
  #|   } else if (isReadonly !== undefined && isReadonly !== null) {
  #|     options.isReadonly = isReadonly;
  #|   }
  #|   const vscode = require("vscode");
  #|   return Object.keys(options).length === 0
  #|     ? vscode.workspace.registerFileSystemProvider(scheme, provider)
  #|     : vscode.workspace.registerFileSystemProvider(scheme, provider, options);
  #| }

///|
extern "js" fn workspace_is_trusted_ffi() -> Bool =
  #| () => require("vscode").workspace.isTrusted

///|
extern "js" fn workspace_on_did_grant_workspace_trust_ffi() -> Event[Unit] =
  #| () => require("vscode").workspace.onDidGrantWorkspaceTrust

///|
extern "js" fn workspace_decode_ffi(
  content : Uint8Array,
) -> @js_async.Promise[String] =
  #| (content) => require("vscode").workspace.decode(content)

///|
extern "js" fn workspace_decode_with_encoding_ffi(
  content : Uint8Array,
  encoding : String,
) -> @js_async.Promise[String] =
  #| (content, encoding) => require("vscode").workspace.decode(content, { encoding })

///|
extern "js" fn workspace_decode_with_uri_ffi(
  content : Uint8Array,
  uri : Uri,
) -> @js_async.Promise[String] =
  #| (content, uri) => require("vscode").workspace.decode(content, { uri })

///|
extern "js" fn workspace_encode_ffi(
  content : String,
) -> @js_async.Promise[Uint8Array] =
  #| (content) => require("vscode").workspace.encode(content)

///|
extern "js" fn workspace_encode_with_encoding_ffi(
  content : String,
  encoding : String,
) -> @js_async.Promise[Uint8Array] =
  #| (content, encoding) => require("vscode").workspace.encode(content, { encoding })

///|
extern "js" fn workspace_encode_with_uri_ffi(
  content : String,
  uri : Uri,
) -> @js_async.Promise[Uint8Array] =
  #| (content, uri) => require("vscode").workspace.encode(content, { uri })
