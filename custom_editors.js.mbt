///|
/// Custom editor helpers.

///|
/// The associated uri for this document.
pub extern "js" fn CustomDocument::uri(self : CustomDocument) -> Uri =
  #| (doc) => doc.uri

///|
/// Dispose of the custom document.
///
/// This is invoked by the editor when there are no more references to a given `CustomDocument` (for example when
/// all editors associated with the document have been closed.)
extern "js" fn custom_document_dispose_raw(doc : CustomDocument) -> Unit =
  #| (doc) => doc.dispose()

///|
pub fn CustomDocument::dispose(self : CustomDocument) -> Unit {
  custom_document_dispose_raw(self)
}

///|
pub impl AsDisposable for CustomDocument with fn as_disposable(self) {
  disposable_from_js(self)
}

///|
pub fn CustomDocument::new(uri : Uri, dispose : () -> Unit) -> CustomDocument {
  custom_document_ffi(uri, dispose)
}

///|
pub type CustomDocumentChangeEvent[T]

///|
pub fn[T] CustomDocumentChangeEvent::from_edit(
  value : CustomDocumentEditEvent[T],
) -> CustomDocumentChangeEvent[T] {
  JsValue::make(value).cast()
}

///|
pub fn[T] CustomDocumentChangeEvent::from_content(
  value : CustomDocumentContentChangeEvent[T],
) -> CustomDocumentChangeEvent[T] {
  JsValue::make(value).cast()
}

///|
/// The document that the change is for.
pub fn[T] CustomDocumentContentChangeEvent::document(
  self : CustomDocumentContentChangeEvent[T],
) -> T {
  custom_document_content_document_raw(custom_document_content_event_cast(self)).cast()
}

///|
/// The document that the edit is for.
pub fn[T] CustomDocumentEditEvent::document(
  self : CustomDocumentEditEvent[T],
) -> T {
  custom_document_edit_document_raw(custom_document_edit_event_cast(self)).cast()
}

///|
extern "js" fn custom_document_edit_undo_promise(
  event : CustomDocumentEditEvent[JsValue],
) -> @js_async.Promise[Unit] =
  #| (event) => Promise.resolve(event.undo())

///|
/// Undo the edit operation.
///
/// This is invoked by the editor when the user undoes this edit. To implement `undo`, your
/// extension should restore the document and editor to the state they were in just before this
/// edit was added to the editor's internal edit stack by `onDidChangeCustomDocument`.
pub async fn[T] CustomDocumentEditEvent::undo(
  self : CustomDocumentEditEvent[T],
) -> Unit {
  @js_async.Promise::wait(
    custom_document_edit_undo_promise(custom_document_edit_event_cast(self)),
  )
}

///|
extern "js" fn custom_document_edit_redo_promise(
  event : CustomDocumentEditEvent[JsValue],
) -> @js_async.Promise[Unit] =
  #| (event) => Promise.resolve(event.redo())

///|
/// Redo the edit operation.
///
/// This is invoked by the editor when the user redoes this edit. To implement `redo`, your
/// extension should restore the document and editor to the state they were in just after this
/// edit was added to the editor's internal edit stack by `onDidChangeCustomDocument`.
pub async fn[T] CustomDocumentEditEvent::redo(
  self : CustomDocumentEditEvent[T],
) -> Unit {
  @js_async.Promise::wait(
    custom_document_edit_redo_promise(custom_document_edit_event_cast(self)),
  )
}

///|
/// Display name describing the edit.
///
/// This will be shown to users in the UI for undo/redo operations.
pub fn[T] CustomDocumentEditEvent::label(
  self : CustomDocumentEditEvent[T],
) -> String? {
  let raw = custom_document_edit_event_label_raw(
    custom_document_edit_event_cast(self),
  )
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Unique identifier for the backup.
///
/// This id is passed back to your extension in `openCustomDocument` when opening a custom editor from a backup.
pub fn CustomDocumentBackup::id(self : CustomDocumentBackup) -> String {
  custom_document_backup_id_raw(self)
}

///|
/// Delete the current backup.
///
/// This is called by the editor when it is clear the current backup is no longer needed, such as when a new backup
/// is made or when the file is saved.
pub fn CustomDocumentBackup::delete(self : CustomDocumentBackup) -> Unit {
  custom_document_backup_delete_ffi(self)
}

///|
pub fn CustomDocumentBackup::new(
  id : String,
  delete_backup : () -> Unit,
) -> CustomDocumentBackup {
  custom_document_backup_ffi(id, delete_backup)
}

///|
/// Suggested file location to write the new backup.
///
/// Note that your extension is free to ignore this and use its own strategy for backup.
///
/// If the editor is for a resource from the current workspace, `destination` will point to a file inside
/// `ExtensionContext.storagePath`. The parent folder of `destination` may not exist, so make sure to created it
/// before writing the backup to this location.
pub fn CustomDocumentBackupContext::new(
  destination : Uri,
) -> CustomDocumentBackupContext {
  CustomDocumentBackupContext::{ destination, }
}

///|
/// Suggested file location to write the new backup.
///
/// Note that your extension is free to ignore this and use its own strategy for backup.
///
/// If the editor is for a resource from the current workspace, `destination` will point to a file inside
/// `ExtensionContext.storagePath`. The parent folder of `destination` may not exist, so make sure to created it
/// before writing the backup to this location.

///|
/// The id of the backup to restore the document from or `undefined` if there is no backup.
///
/// If this is provided, your extension should restore the editor from the backup instead of reading the file
/// from the user's workspace.
pub fn CustomDocumentOpenContext::new(
  backup_id? : String,
  untitled_document_data? : Bytes,
) -> CustomDocumentOpenContext {
  CustomDocumentOpenContext::{
    backupId: backup_id,
    untitledDocumentData: untitled_document_data,
  }
}

///|
/// The id of the backup to restore the document from or `undefined` if there is no backup.
///
/// If this is provided, your extension should restore the editor from the backup instead of reading the file
/// from the user's workspace.

///|
/// If the URI is an untitled file, this will be populated with the byte data of that file
///
/// If this is provided, your extension should utilize this byte data rather than executing fs APIs on the URI passed in

///|

///|
pub(open) trait CustomTextEditorProvider {
  async fn resolve_custom_text_editor(
    Self,
    TextDocument,
    WebviewPanel,
    CancellationToken,
  ) -> Unit
}

///|
pub(open) trait CustomReadonlyEditorProvider {
  async fn open_custom_document(
    Self,
    Uri,
    CustomDocumentOpenContext,
    CancellationToken,
  ) -> CustomDocument
  async fn resolve_custom_editor(
    Self,
    CustomDocument,
    WebviewPanel,
    CancellationToken,
  ) -> Unit
}

///|
pub(open) trait CustomEditorProvider {
  fn on_did_change_custom_document(Self) -> Event[
    CustomDocumentChangeEvent[CustomDocument],
  ]?
  async fn open_custom_document(
    Self,
    Uri,
    CustomDocumentOpenContext,
    CancellationToken,
  ) -> CustomDocument
  async fn resolve_custom_editor(
    Self,
    CustomDocument,
    WebviewPanel,
    CancellationToken,
  ) -> Unit
  async fn save_custom_document(Self, CustomDocument, CancellationToken) -> Unit
  async fn save_custom_document_as(Self, CustomDocument, Uri, CancellationToken) -> Unit
  async fn revert_custom_document(Self, CustomDocument, CancellationToken) -> Unit
  async fn backup_custom_document(
    Self,
    CustomDocument,
    CustomDocumentBackupContext,
    CancellationToken,
  ) -> CustomDocumentBackup
}

///|
fn[T] custom_document_content_event_cast(
  event : CustomDocumentContentChangeEvent[T],
) -> CustomDocumentContentChangeEvent[JsValue] {
  JsValue::make(event).cast()
}

///|
fn[T] custom_document_edit_event_cast(
  event : CustomDocumentEditEvent[T],
) -> CustomDocumentEditEvent[JsValue] {
  JsValue::make(event).cast()
}

///|
extern "js" fn custom_document_content_document_raw(
  event : CustomDocumentContentChangeEvent[JsValue],
) -> JsValue =
  #| (event) => event.document

///|
extern "js" fn custom_document_edit_document_raw(
  event : CustomDocumentEditEvent[JsValue],
) -> JsValue =
  #| (event) => event.document

///|
extern "js" fn custom_document_edit_event_label_raw(
  event : CustomDocumentEditEvent[JsValue],
) -> JsValue =
  #| (event) => event.label

///|
extern "js" fn custom_document_ffi(
  uri : Uri,
  dispose : () -> Unit,
) -> CustomDocument =
  #| (uri, dispose) => ({ uri, dispose })

///|
extern "js" fn custom_document_backup_ffi(
  id : String,
  delete_backup : () -> Unit,
) -> CustomDocumentBackup =
  #| (id, deleteBackup) => ({ id, delete: deleteBackup })

///|
extern "js" fn custom_document_backup_id_raw(
  backup : CustomDocumentBackup,
) -> String =
  #| (backup) => backup.id

///|
extern "js" fn custom_document_backup_delete_ffi(
  backup : CustomDocumentBackup,
) -> Unit =
  #| (backup) => backup.delete()
