///|
/// VS Code ExtensionContext helpers for the JS backend.

///|
pub(all) enum ExtensionMode {
  Production = 1
  Development = 2
  Test = 3
} derive(Eq)

///|
pub(all) enum EnvironmentVariableMutatorType {
  Replace = 1
  Append = 2
  Prepend = 3
} derive(Eq)

///|
/// The event data that is fired when a secret is added or removed.
pub struct SecretStorageChangeEvent {
  key : String
}

///|
/// Represents a storage utility for secrets (or any information that is sensitive)
/// that will be stored encrypted. The implementation of the secret storage will
/// be different on each platform and the secrets will not be synced across
/// machines.
pub type SecretStorage

///|
/// Options applied to the mutator.
pub(all) struct EnvironmentVariableMutatorOptions {
  mut apply_at_process_creation : Bool?
  mut apply_at_shell_integration : Bool?
}

///|
/// A type of mutation and its value to be applied to an environment variable.
pub struct EnvironmentVariableMutator {
  type_ : EnvironmentVariableMutatorType
  value_ : String
  options_ : EnvironmentVariableMutatorOptions
}

///|
/// A collection of mutations that an extension can apply to a process environment.
pub type EnvironmentVariableCollection

///|
/// A collection of mutations that an extension can apply to a process environment. Applies to all scopes.
pub type GlobalEnvironmentVariableCollection

///|
/// The scope object to which the environment variable collection applies.
pub(all) struct EnvironmentVariableScope {
  mut workspace_folder : WorkspaceFolder?
}

///|
fn[T] extension_js_to_option(value : JsValue) -> T? {
  if value.is_null_or_undefined() {
    None
  } else {
    Some(value.cast())
  }
}

///|
/// Add a disposable resource to this extension context.
pub fn[T : AsDisposable] ExtensionContext::subscribe(
  self : ExtensionContext,
  disposable : T,
) -> Unit {
  extension_context_subscribe_ffi(self, disposable.as_disposable())
}

///|
extern "js" fn extension_context_subscribe_ffi(
  ctx : ExtensionContext,
  disposable : Disposable,
) -> Unit =
  #| (ctx, disposable) => {
  #|   ctx.subscriptions.push(disposable);
  #| }

///|
/// Access workspace state memento.
pub extern "js" fn ExtensionContext::workspace_state(
  self : ExtensionContext,
) -> Memento =
  #| (ctx) => ctx.workspaceState

///|
/// Access global state memento.
pub extern "js" fn ExtensionContext::global_state(
  self : ExtensionContext,
) -> Memento =
  #| (ctx) => ctx.globalState

///|
/// Get extension path.
pub extern "js" fn ExtensionContext::extension_path(
  self : ExtensionContext,
) -> String =
  #| (ctx) => ctx.extensionPath

///|
/// Get extension URI.
pub extern "js" fn ExtensionContext::extension_uri(
  self : ExtensionContext,
) -> Uri =
  #| (ctx) => ctx.extensionUri

///|
/// The mode the extension is running in. See {@link ExtensionMode}
/// for possible values and scenarios.
pub extern "js" fn ExtensionContext::extension_mode(
  self : ExtensionContext,
) -> ExtensionMode =
  #| (ctx) => ctx.extensionMode

///|
/// A secret storage object that stores state independent
/// of the current opened {@link workspace.workspaceFolders workspace}.
pub extern "js" fn ExtensionContext::secrets(
  self : ExtensionContext,
) -> SecretStorage =
  #| (ctx) => ctx.secrets

///|
/// Gets the extension's global environment variable collection for this workspace, enabling changes to be
/// applied to terminal environment variables.
pub extern "js" fn ExtensionContext::environment_variable_collection(
  self : ExtensionContext,
) -> GlobalEnvironmentVariableCollection =
  #| (ctx) => ctx.environmentVariableCollection

///|
/// Resolve a path relative to the extension.
pub extern "js" fn ExtensionContext::as_absolute_path(
  self : ExtensionContext,
  relative_path : String,
) -> String =
  #| (ctx, rel) => ctx.asAbsolutePath(rel)

///|
/// Get a stored value, if present.
pub fn[T] Memento::get(memento : Memento, key : String) -> T? {
  let raw = memento_get_ffi(memento, key, JsValue::make(()))
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Get a stored value or return the provided default.
pub fn[T] Memento::get_or(
  memento : Memento,
  key : String,
  default_value : T,
) -> T {
  memento_get_ffi(memento, key, JsValue::make(default_value)).cast()
}

///|
fn memento_update_promise(
  memento : Memento,
  key : String,
  value : JsValue,
) -> @js_async.Promise[Unit] {
  memento_update_ffi(memento, key, value)
}

///|
/// Store a value. The value must be JSON-stringifyable.
///
/// *Note* that using `undefined` as value removes the key from the underlying
/// storage.
///
/// @param key A string.
/// @param value A value. MUST not contain cyclic references.
pub async fn[T] Memento::update(
  memento : Memento,
  key : String,
  value : T,
) -> Unit {
  @js_async.Promise::wait(
    memento_update_promise(memento, key, JsValue::make(value)),
  )
}

///|
/// The key of the secret that has changed.
pub fn SecretStorageChangeEvent::new(key : String) -> SecretStorageChangeEvent {
  SecretStorageChangeEvent::{ key, }
}

///|
/// The key of the secret that has changed.

///|
/// Fires when a secret is stored or deleted.
pub extern "js" fn SecretStorage::on_did_change(
  self : SecretStorage,
) -> Event[SecretStorageChangeEvent] =
  #| (storage) => storage.onDidChange

///|
/// Retrieve the keys of all the secrets stored by this extension.
pub async fn SecretStorage::keys(self : SecretStorage) -> Array[String] {
  @js_async.Promise::wait(secret_storage_keys_ffi(self))
}

///|
/// Retrieve a secret that was stored with key. Returns undefined if there
/// is no password matching that key.
/// @param key The key the secret was stored under.
/// @returns The stored value or `undefined`.
pub async fn SecretStorage::get(self : SecretStorage, key : String) -> String? {
  let raw : JsValue = @js_async.Promise::wait(secret_storage_get_ffi(self, key))
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Store a secret under a given key.
/// @param key The key to store the secret under.
/// @param value The secret.
pub async fn SecretStorage::store(
  self : SecretStorage,
  key : String,
  value : String,
) -> Unit {
  @js_async.Promise::wait(secret_storage_store_ffi(self, key, value))
}

///|
/// Remove a secret from storage.
/// @param key The key the secret was stored under.
pub async fn SecretStorage::delete(self : SecretStorage, key : String) -> Unit {
  @js_async.Promise::wait(secret_storage_delete_ffi(self, key))
}

///|
pub fn EnvironmentVariableMutatorOptions::new(
  apply_at_process_creation? : Bool,
  apply_at_shell_integration? : Bool,
) -> EnvironmentVariableMutatorOptions {
  EnvironmentVariableMutatorOptions::{
    apply_at_process_creation,
    apply_at_shell_integration,
  }
}

///|
fn environment_variable_mutator_options_to_js(
  value : EnvironmentVariableMutatorOptions,
) -> JsValue {
  environment_variable_mutator_options_to_js_ffi(
    option_to_js(value.apply_at_process_creation),
    option_to_js(value.apply_at_shell_integration),
  )
}

///|
fn option_environment_variable_mutator_options_to_js(
  value : EnvironmentVariableMutatorOptions?,
) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(options) => environment_variable_mutator_options_to_js(options)
  }
}

///|
/// Apply to the environment just before the process is created. Defaults to false.

///|
/// Apply to the environment in the shell integration script. Note that this _will not_ apply
/// the mutator if shell integration is disabled or not working for some reason. Defaults to
/// false.

///|
/// The type of mutation that will occur to the variable.

///|
/// The value to use for the variable.

///|
/// Options applied to the mutator.

///|
/// Whether the collection should be cached for the workspace and applied to the terminal
/// across window reloads. When true the collection will be active immediately such when the
/// window reloads. Additionally, this API will return the cached version if it exists. The
/// collection will be invalidated when the extension is uninstalled or when the collection
/// is cleared. Defaults to true.
pub extern "js" fn EnvironmentVariableCollection::persistent(
  self : EnvironmentVariableCollection,
) -> Bool =
  #| (collection) => collection.persistent

///|
/// Whether the collection should be cached for the workspace and applied to the terminal
/// across window reloads. When true the collection will be active immediately such when the
/// window reloads. Additionally, this API will return the cached version if it exists. The
/// collection will be invalidated when the extension is uninstalled or when the collection
/// is cleared. Defaults to true.
pub extern "js" fn EnvironmentVariableCollection::set_persistent(
  self : EnvironmentVariableCollection,
  value : Bool,
) -> Unit =
  #| (collection, value) => { collection.persistent = value; }

///|
/// A description for the environment variable collection, this will be used to describe the
/// changes in the UI.
pub fn EnvironmentVariableCollection::description(
  self : EnvironmentVariableCollection,
) -> MarkdownStringValue? {
  extension_js_to_option(environment_variable_collection_description_raw(self))
}

///|
/// A description for the environment variable collection, this will be used to describe the
/// changes in the UI.
pub fn EnvironmentVariableCollection::set_description_text(
  self : EnvironmentVariableCollection,
  value : String,
) -> Unit {
  environment_variable_collection_set_description_raw(
    self,
    JsValue::make(value),
  )
}

///|
/// A description for the environment variable collection, this will be used to describe the
/// changes in the UI.
pub fn EnvironmentVariableCollection::set_description_markdown(
  self : EnvironmentVariableCollection,
  value : MarkdownString,
) -> Unit {
  environment_variable_collection_set_description_raw(
    self,
    JsValue::make(value),
  )
}

///|
/// Clears the description for this environment variable collection.
pub fn EnvironmentVariableCollection::clear_description(
  self : EnvironmentVariableCollection,
) -> Unit {
  environment_variable_collection_set_description_raw(self, JsValue::make(()))
}

///|
/// Clears all mutators from this collection.

///|
/// Replace an environment variable with a value.
///
/// Note that an extension can only make a single change to any one variable, so this will
/// overwrite any previous calls to replace, append or prepend.
///
/// @param variable The variable to replace.
/// @param value The value to replace the variable with.
/// @param options Options applied to the mutator, when no options are provided this will
/// default to `{ applyAtProcessCreation: true }`.
pub fn EnvironmentVariableCollection::replace(
  self : EnvironmentVariableCollection,
  variable : String,
  value : String,
  options? : EnvironmentVariableMutatorOptions,
) -> Unit {
  environment_variable_collection_replace_ffi(
    self,
    variable,
    value,
    option_environment_variable_mutator_options_to_js(options),
  )
}

///|
/// Append a value to an environment variable.
///
/// Note that an extension can only make a single change to any one variable, so this will
/// overwrite any previous calls to replace, append or prepend.
///
/// @param variable The variable to append to.
/// @param value The value to append to the variable.
/// @param options Options applied to the mutator, when no options are provided this will
/// default to `{ applyAtProcessCreation: true }`.
pub fn EnvironmentVariableCollection::append(
  self : EnvironmentVariableCollection,
  variable : String,
  value : String,
  options? : EnvironmentVariableMutatorOptions,
) -> Unit {
  environment_variable_collection_append_ffi(
    self,
    variable,
    value,
    option_environment_variable_mutator_options_to_js(options),
  )
}

///|
/// Prepend a value to an environment variable.
///
/// Note that an extension can only make a single change to any one variable, so this will
/// overwrite any previous calls to replace, append or prepend.
///
/// @param variable The variable to prepend.
/// @param value The value to prepend to the variable.
/// @param options Options applied to the mutator, when no options are provided this will
/// default to `{ applyAtProcessCreation: true }`.
pub fn EnvironmentVariableCollection::prepend(
  self : EnvironmentVariableCollection,
  variable : String,
  value : String,
  options? : EnvironmentVariableMutatorOptions,
) -> Unit {
  environment_variable_collection_prepend_ffi(
    self,
    variable,
    value,
    option_environment_variable_mutator_options_to_js(options),
  )
}

///|
/// Gets the mutator that this collection applies to a variable, if any.
///
/// @param variable The variable to get the mutator for.
pub fn EnvironmentVariableCollection::get(
  self : EnvironmentVariableCollection,
  variable : String,
) -> EnvironmentVariableMutator? {
  let raw = environment_variable_collection_get_raw(self, variable)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(environment_variable_mutator_from_js(raw))
  }
}

///|
/// Deletes this collection's mutator for a variable.
///
/// @param variable The variable to delete the mutator for.
pub extern "js" fn EnvironmentVariableCollection::delete(
  self : EnvironmentVariableCollection,
  variable : String,
) -> Unit =
  #| (collection, variable) => collection.delete(variable)

///|
/// Clears all mutators from this collection.
pub extern "js" fn EnvironmentVariableCollection::clear(
  self : EnvironmentVariableCollection,
) -> Unit =
  #| (collection) => collection.clear()

///|
fn GlobalEnvironmentVariableCollection::as_collection(
  self : GlobalEnvironmentVariableCollection,
) -> EnvironmentVariableCollection {
  global_environment_variable_collection_as_collection_ffi(self)
}

///|
pub fn GlobalEnvironmentVariableCollection::persistent(
  self : GlobalEnvironmentVariableCollection,
) -> Bool {
  self.as_collection().persistent()
}

///|
pub fn GlobalEnvironmentVariableCollection::set_persistent(
  self : GlobalEnvironmentVariableCollection,
  value : Bool,
) -> Unit {
  self.as_collection().set_persistent(value)
}

///|
pub fn GlobalEnvironmentVariableCollection::description(
  self : GlobalEnvironmentVariableCollection,
) -> MarkdownStringValue? {
  self.as_collection().description()
}

///|
pub fn GlobalEnvironmentVariableCollection::set_description_text(
  self : GlobalEnvironmentVariableCollection,
  value : String,
) -> Unit {
  self.as_collection().set_description_text(value)
}

///|
pub fn GlobalEnvironmentVariableCollection::set_description_markdown(
  self : GlobalEnvironmentVariableCollection,
  value : MarkdownString,
) -> Unit {
  self.as_collection().set_description_markdown(value)
}

///|
pub fn GlobalEnvironmentVariableCollection::clear_description(
  self : GlobalEnvironmentVariableCollection,
) -> Unit {
  self.as_collection().clear_description()
}

///|
pub fn GlobalEnvironmentVariableCollection::replace(
  self : GlobalEnvironmentVariableCollection,
  variable : String,
  value : String,
  options? : EnvironmentVariableMutatorOptions,
) -> Unit {
  environment_variable_collection_replace_ffi(
    self.as_collection(),
    variable,
    value,
    option_environment_variable_mutator_options_to_js(options),
  )
}

///|
pub fn GlobalEnvironmentVariableCollection::append(
  self : GlobalEnvironmentVariableCollection,
  variable : String,
  value : String,
  options? : EnvironmentVariableMutatorOptions,
) -> Unit {
  environment_variable_collection_append_ffi(
    self.as_collection(),
    variable,
    value,
    option_environment_variable_mutator_options_to_js(options),
  )
}

///|
pub fn GlobalEnvironmentVariableCollection::prepend(
  self : GlobalEnvironmentVariableCollection,
  variable : String,
  value : String,
  options? : EnvironmentVariableMutatorOptions,
) -> Unit {
  environment_variable_collection_prepend_ffi(
    self.as_collection(),
    variable,
    value,
    option_environment_variable_mutator_options_to_js(options),
  )
}

///|
pub fn GlobalEnvironmentVariableCollection::get(
  self : GlobalEnvironmentVariableCollection,
  variable : String,
) -> EnvironmentVariableMutator? {
  self.as_collection().get(variable)
}

///|
pub fn GlobalEnvironmentVariableCollection::delete(
  self : GlobalEnvironmentVariableCollection,
  variable : String,
) -> Unit {
  self.as_collection().delete(variable)
}

///|
pub fn GlobalEnvironmentVariableCollection::clear(
  self : GlobalEnvironmentVariableCollection,
) -> Unit {
  self.as_collection().clear()
}

///|
pub fn EnvironmentVariableScope::new(
  workspace_folder? : WorkspaceFolder,
) -> EnvironmentVariableScope {
  EnvironmentVariableScope::{ workspace_folder, }
}

///|
fn environment_variable_scope_to_js(
  value : EnvironmentVariableScope,
) -> JsValue {
  environment_variable_scope_to_js_ffi(option_to_js(value.workspace_folder))
}

///|
/// Any specific workspace folder to get collection for.

///|
/// Gets scope-specific environment variable collection for the extension. This enables alterations to
/// terminal environment variables solely within the designated scope, and is applied in addition to (and
/// after) the global collection.
///
/// Each object obtained through this method is isolated and does not impact objects for other scopes,
/// including the global collection.
///
/// @param scope The scope to which the environment variable collection applies to.
///
/// If a scope parameter is omitted, collection applicable to all relevant scopes for that parameter is
/// returned. For instance, if the 'workspaceFolder' parameter is not specified, the collection that applies
/// across all workspace folders will be returned.
///
/// @returns Environment variable collection for the passed in scope.
pub fn GlobalEnvironmentVariableCollection::get_scoped(
  self : GlobalEnvironmentVariableCollection,
  scope : EnvironmentVariableScope,
) -> EnvironmentVariableCollection {
  global_environment_variable_collection_get_scoped_ffi(
    self,
    environment_variable_scope_to_js(scope),
  )
}

///|
/// Externs.
extern "js" fn memento_get_ffi(
  memento : Memento,
  key : String,
  default_value : JsValue,
) -> JsValue =
  #| (memento, key, defaultValue) => {
  #|   if (defaultValue === undefined || defaultValue === null) {
  #|     return memento.get(key);
  #|   }
  #|   return memento.get(key, defaultValue);
  #| }

///|
extern "js" fn memento_update_ffi(
  memento : Memento,
  key : String,
  value : JsValue,
) -> @js_async.Promise[Unit] =
  #| (memento, key, value) => memento.update(key, value)

///|
extern "js" fn secret_storage_keys_ffi(
  secrets : SecretStorage,
) -> @js_async.Promise[Array[String]] =
  #| (secrets) => secrets.keys()

///|
extern "js" fn secret_storage_get_ffi(
  secrets : SecretStorage,
  key : String,
) -> @js_async.Promise[JsValue] =
  #| (secrets, key) => secrets.get(key)

///|
extern "js" fn secret_storage_store_ffi(
  secrets : SecretStorage,
  key : String,
  value : String,
) -> @js_async.Promise[Unit] =
  #| (secrets, key, value) => secrets.store(key, value)

///|
extern "js" fn secret_storage_delete_ffi(
  secrets : SecretStorage,
  key : String,
) -> @js_async.Promise[Unit] =
  #| (secrets, key) => secrets.delete(key)

///|
extern "js" fn environment_variable_mutator_options_to_js_ffi(
  apply_at_process_creation : JsValue,
  apply_at_shell_integration : JsValue,
) -> JsValue =
  #| (applyAtProcessCreation, applyAtShellIntegration) => {
  #|   const options = {};
  #|   if (applyAtProcessCreation !== undefined && applyAtProcessCreation !== null) {
  #|     options.applyAtProcessCreation = applyAtProcessCreation;
  #|   }
  #|   if (applyAtShellIntegration !== undefined && applyAtShellIntegration !== null) {
  #|     options.applyAtShellIntegration = applyAtShellIntegration;
  #|   }
  #|   return options;
  #| }

///|
extern "js" fn environment_variable_collection_set_description_raw(
  collection : EnvironmentVariableCollection,
  value : JsValue,
) -> Unit =
  #| (collection, value) => {
  #|   collection.description = value === undefined || value === null ? undefined : value;
  #| }

///|
extern "js" fn environment_variable_collection_description_raw(
  collection : EnvironmentVariableCollection,
) -> JsValue =
  #| (collection) => collection.description

///|
extern "js" fn environment_variable_collection_replace_ffi(
  collection : EnvironmentVariableCollection,
  variable : String,
  value : String,
  options : JsValue,
) -> Unit =
  #| (collection, variable, value, options) =>
  #|   options === undefined || options === null
  #|     ? collection.replace(variable, value)
  #|     : collection.replace(variable, value, options)

///|
extern "js" fn environment_variable_collection_append_ffi(
  collection : EnvironmentVariableCollection,
  variable : String,
  value : String,
  options : JsValue,
) -> Unit =
  #| (collection, variable, value, options) =>
  #|   options === undefined || options === null
  #|     ? collection.append(variable, value)
  #|     : collection.append(variable, value, options)

///|
extern "js" fn environment_variable_collection_prepend_ffi(
  collection : EnvironmentVariableCollection,
  variable : String,
  value : String,
  options : JsValue,
) -> Unit =
  #| (collection, variable, value, options) =>
  #|   options === undefined || options === null
  #|     ? collection.prepend(variable, value)
  #|     : collection.prepend(variable, value, options)

///|
extern "js" fn environment_variable_collection_get_raw(
  collection : EnvironmentVariableCollection,
  variable : String,
) -> JsValue =
  #| (collection, variable) => collection.get(variable)

///|
extern "js" fn environment_variable_mutator_type_raw(
  mutator : JsValue,
) -> EnvironmentVariableMutatorType =
  #| (mutator) => mutator.type

///|
extern "js" fn environment_variable_mutator_value_raw(
  mutator : JsValue,
) -> String =
  #| (mutator) => mutator.value

///|
extern "js" fn environment_variable_mutator_options_raw(
  mutator : JsValue,
) -> EnvironmentVariableMutatorOptions =
  #| (mutator) => mutator.options

///|
fn environment_variable_mutator_from_js(
  raw : JsValue,
) -> EnvironmentVariableMutator {
  EnvironmentVariableMutator::{
    type_: environment_variable_mutator_type_raw(raw),
    value_: environment_variable_mutator_value_raw(raw),
    options_: environment_variable_mutator_options_raw(raw),
  }
}

///|
extern "js" fn environment_variable_scope_to_js_ffi(
  workspace_folder : JsValue,
) -> JsValue =
  #| (workspaceFolder) => {
  #|   const scope = {};
  #|   if (workspaceFolder !== undefined && workspaceFolder !== null) {
  #|     scope.workspaceFolder = workspaceFolder;
  #|   }
  #|   return scope;
  #| }

///|
extern "js" fn global_environment_variable_collection_as_collection_ffi(
  collection : GlobalEnvironmentVariableCollection,
) -> EnvironmentVariableCollection =
  #| (collection) => collection

///|
extern "js" fn global_environment_variable_collection_get_scoped_ffi(
  collection : GlobalEnvironmentVariableCollection,
  scope : JsValue,
) -> EnvironmentVariableCollection =
  #| (collection, scope) => collection.getScoped(scope)
