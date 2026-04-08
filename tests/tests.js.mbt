///|
/// VS Code tests namespace bindings for the JS backend.
using @vscode {
  type CancellationToken,
  type Event,
  type Location,
  type MarkdownStringValue,
  type Position,
  type Range,
  type Uri,
}

///|
/// Entry point to discover and execute tests. It contains {@link TestController.items} which
/// are used to populate the editor UI, and is associated with
/// {@link TestController.createRunProfile run profiles} to allow
/// for tests to be executed.
pub type TestController

///|
/// A TestRunProfile describes one way to execute tests in a {@link TestController}.
pub type TestRunProfile

///|
/// A TestRunRequest is a precursor to a {@link TestRun}, which in turn is
/// created by passing a request to {@link TestController.createTestRun}. The
/// TestRunRequest contains information about which tests should be run, which
/// should not be run, and how they are run (via the {@link TestRunRequest.profile profile}).
///
/// In general, TestRunRequests are created by the editor and pass to
/// {@link TestRunProfile.runHandler}, however you can also create test
/// requests and runs outside of the `runHandler`.
pub type TestRunRequest

///|
/// A TestRun represents an in-progress or completed test run and
/// provides methods to report the state of individual tests in the run.
pub type TestRun

///|
/// Collection of test items, found in {@link TestItem.children} and
/// {@link TestController.items}.
pub type TestItemCollection

///|
/// An item shown in the "test explorer" view.
///
/// A `TestItem` can represent either a test suite or a test itself, since
/// they both have similar capabilities.
pub type TestItem

///|
/// Tags can be associated with {@link TestItem TestItems} and
/// {@link TestRunProfile TestRunProfiles}. A profile with a tag can only
/// execute tests that include that tag in their {@link TestItem.tags} array.
pub type TestTag

///|
/// A stack frame found in the {@link TestMessage.stackTrace}.
pub type TestMessageStackFrame

///|
/// Message associated with the test state. Can be linked to a specific
/// source range -- useful for assertion failures, for example.
pub type TestMessage

///|
/// A class that contains information about a covered resource. A count can
/// be give for lines, branches, and declarations in a file.
pub type TestCoverageCount

///|
/// Contains coverage metadata for a file.
pub type FileCoverage

///|
/// Contains coverage information for a single statement or line.
pub type StatementCoverage

///|
/// Contains coverage information for a branch of a {@link StatementCoverage}.
pub type BranchCoverage

///|
/// Contains coverage information for a declaration. Depending on the reporter
/// and language, this may be types such as functions, methods, or namespaces.
pub type DeclarationCoverage

///|
/// Coverage details returned from {@link TestRunProfile.loadDetailedCoverage}.
pub type FileCoverageDetail

///|
pub(all) enum IntOrBool {
  Numeric(Int)
  Boolean(Bool)
}

///|
pub(all) enum PositionOrRange {
  PositionValue(Position)
  RangeValue(Range)
}

///|
pub(all) enum TestMessageOrMany {
  Single(TestMessage)
  Many(Array[TestMessage])
}

///|
pub(all) enum TestItemOrMany {
  Single(TestItem)
  Many(Array[TestItem])
}

///|
pub(all) enum TestRunProfileKind {
  Run = 1
  Debug = 2
  Coverage = 3
} derive(Eq)

///|
fn[T] option_to_js(value : T?) -> @v.JsValue {
  @v.option_to_js(value)
}

///|
fn[T] js_to_option(value : @v.JsValue) -> T? {
  @v.js_to_option(value)
}

///|
pub fn FileCoverageDetail::from_statement(value : StatementCoverage) -> Self {
  @v.JsValue::make(value).cast()
}

///|
pub fn FileCoverageDetail::from_declaration(
  value : DeclarationCoverage,
) -> Self {
  @v.JsValue::make(value).cast()
}

///|
pub extern "js" fn TestController::id(self : TestController) -> String =
  #| (controller) => controller.id

///|
pub extern "js" fn TestController::label(self : TestController) -> String =
  #| (controller) => controller.label

///|
pub extern "js" fn TestRunProfile::kind(
  self : TestRunProfile,
) -> TestRunProfileKind =
  #| (profile) => profile.kind

///|
pub extern "js" fn TestRunProfile::on_did_change_default(
  self : TestRunProfile,
) -> @vscode.Event[Bool] =
  #| (profile) => profile.onDidChangeDefault

///|
pub fn TestRunProfile::tag(self : TestRunProfile) -> TestTag? {
  let raw = TestRunProfile::tag_raw(self)
  if raw.is_null_or_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
fn IntOrBool::to_js(self : IntOrBool) -> @v.JsValue {
  match self {
    Numeric(value) => @v.JsValue::make(value)
    Boolean(value) => @v.JsValue::make(value)
  }
}

///|
fn PositionOrRange::to_js(self : PositionOrRange) -> @v.JsValue {
  match self {
    PositionValue(value) => @v.JsValue::make(value)
    RangeValue(value) => @v.JsValue::make(value)
  }
}

///|
fn TestMessageOrMany::to_js(self : TestMessageOrMany) -> @v.JsValue {
  match self {
    Single(value) => @v.JsValue::make(value)
    Many(values) => @v.JsValue::make(values)
  }
}

///|
fn TestItemOrMany::to_js(self : TestItemOrMany) -> @v.JsValue {
  match self {
    Single(value) => @v.JsValue::make(value)
    Many(values) => @v.JsValue::make(values)
  }
}

///|
fn option_test_item_or_many_to_js(value : TestItemOrMany?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(items) => items.to_js()
  }
}

///|
fn option_position_or_range_to_js(value : PositionOrRange?) -> @v.JsValue {
  match value {
    None => @v.JsValue::make(())
    Some(location) => location.to_js()
  }
}

///|
/// Creates a new test controller.
///
/// @param id Identifier for the controller, must be globally unique.
/// @param label A human-readable label for the controller.
/// @returns An instance of the {@link TestController}.
pub fn create_test_controller(id : String, label : String) -> TestController {
  tests_create_test_controller_ffi(id, label)
}

///|
/// Creates a new TestTag instance.
/// @param id ID of the test tag.
pub fn TestTag::new(id : String) -> Self {
  test_tag_ffi(id)
}

///|
/// ID of the test tag. `TestTag` instances with the same ID are considered
/// to be identical.
pub extern "js" fn TestTag::id(self : TestTag) -> String =
  #| (value) => value.id

///|
extern "js" fn test_tag_ffi(id : String) -> TestTag =
  #| (id) => new (require("vscode").TestTag)(id)

///|
/// Creates a new managed {@link TestItem} instance. It can be added into
/// the {@link TestItem.children} of an existing item, or into the
/// {@link TestController.items}.
///
/// @param id Identifier for the TestItem. The test item's ID must be unique
/// in the {@link TestItemCollection} it's added to.
/// @param label Human-readable label of the test item.
/// @param uri URI this TestItem is associated with. May be a file or directory.
pub fn TestController::create_test_item(
  self : TestController,
  id : String,
  label : String,
  uri? : Uri,
) -> TestItem {
  tests_controller_create_test_item_ffi(self, id, label, option_to_js(uri))
}

///|
/// Creates a profile used for running tests. Extensions must create
/// at least one profile in order for tests to be run.
/// @param label A human-readable label for this profile.
/// @param kind Configures what kind of execution this profile manages.
/// @param runHandler Function called to start a test run.
/// @param isDefault Whether this is the default action for its kind.
/// @param tag Profile test tag.
/// @param supportsContinuousRun Whether the profile supports continuous running.
/// @returns An instance of a {@link TestRunProfile}, which is automatically
/// associated with this controller.
pub fn TestController::create_run_profile(
  self : TestController,
  label : String,
  kind : TestRunProfileKind,
  run_handler : (TestRunRequest, CancellationToken) -> Unit,
  is_default? : Bool,
  tag? : TestTag,
  supports_continuous_run? : Bool,
) -> TestRunProfile {
  tests_controller_create_run_profile_ffi(
    self,
    label,
    kind,
    run_handler,
    option_to_js(is_default),
    option_to_js(tag),
    option_to_js(supports_continuous_run),
  )
}

///|
/// Creates a {@link TestRun}. This should be called by the
/// {@link TestRunProfile} when a request is made to execute tests, and may
/// also be called if a test run is detected externally. Once created, tests
/// that are included in the request will be moved into the queued state.
///
/// All runs created using the same `request` instance will be grouped
/// together. This is useful if, for example, a single suite of tests is
/// run on multiple platforms.
///
/// @param request Test run request. Only tests inside the `include` may be
/// modified, and tests in its `exclude` are ignored.
/// @param name The human-readable name of the run. This can be used to
/// disambiguate multiple sets of results in a test run. It is useful if
/// tests are run across multiple platforms, for example.
/// @param persist Whether the results created by the run should be
/// persisted in the editor. This may be false if the results are coming from
/// a file already saved externally, such as a coverage information file.
/// @returns An instance of the {@link TestRun}. It will be considered "running"
/// from the moment this method is invoked until {@link TestRun.end} is called.
pub fn TestController::create_test_run(
  self : TestController,
  request : TestRunRequest,
  name? : String,
  persist? : Bool,
) -> TestRun {
  tests_controller_create_test_run_ffi(
    self,
    request,
    option_to_js(name),
    option_to_js(persist),
  )
}

///|
/// A function provided by the extension that the editor may call to request
/// children of a test item, if the {@link TestItem.canResolveChildren} is
/// `true`. When called, the item should discover children and call
/// {@link TestController.createTestItem} as children are discovered.
///
/// Generally the extension manages the lifecycle of test items, but under
/// certain conditions the editor may request the children of a specific
/// item to be loaded. For example, if the user requests to re-run tests
/// after reloading the editor, the editor may need to call this method
/// to resolve the previously-run tests.
///
/// The item in the explorer will automatically be marked as "busy" until
/// the function returns or the returned thenable resolves.
///
/// @param item An unresolved test item for which children are being
/// requested, or `undefined` to resolve the controller's initial {@link TestController.items items}.
pub fn TestController::set_resolve_handler(
  self : TestController,
  handler : (TestItem?) -> Unit,
) -> Unit {
  tests_controller_set_resolve_handler_ffi(self, fn(item) {
    handler(js_to_option(item))
  })
}

///|
/// A function provided by the extension that the editor may call to request
/// children of a test item, if the {@link TestItem.canResolveChildren} is
/// `true`. When called, the item should discover children and call
/// {@link TestController.createTestItem} as children are discovered.
///
/// Generally the extension manages the lifecycle of test items, but under
/// certain conditions the editor may request the children of a specific
/// item to be loaded. For example, if the user requests to re-run tests
/// after reloading the editor, the editor may need to call this method
/// to resolve the previously-run tests.
///
/// The item in the explorer will automatically be marked as "busy" until
/// the function returns or the returned thenable resolves.
///
/// @param item An unresolved test item for which children are being
/// requested, or `undefined` to resolve the controller's initial {@link TestController.items items}.
pub fn TestController::clear_resolve_handler(self : TestController) -> Unit {
  tests_controller_set_resolve_handler_raw(self, @v.JsValue::make(()))
}

///|
/// If this method is present, a refresh button will be present in the
/// UI, and this method will be invoked when it's clicked. When called,
/// the extension should scan the workspace for any new, changed, or
/// removed tests.
///
/// It's recommended that extensions try to update tests in realtime, using
/// a {@link FileSystemWatcher} for example, and use this method as a fallback.
///
/// @returns A thenable that resolves when tests have been refreshed.
pub fn TestController::set_refresh_handler(
  self : TestController,
  handler : (CancellationToken) -> Unit,
) -> Unit {
  tests_controller_set_refresh_handler_ffi(self, fn(token) { handler(token) })
}

///|
/// If this method is present, a refresh button will be present in the
/// UI, and this method will be invoked when it's clicked. When called,
/// the extension should scan the workspace for any new, changed, or
/// removed tests.
///
/// It's recommended that extensions try to update tests in realtime, using
/// a {@link FileSystemWatcher} for example, and use this method as a fallback.
///
/// @returns A thenable that resolves when tests have been refreshed.
pub fn TestController::clear_refresh_handler(self : TestController) -> Unit {
  tests_controller_set_refresh_handler_raw(self, @v.JsValue::make(()))
}

///|
/// Marks an item's results as being outdated. This is commonly called when
/// code or configuration changes and previous results should no longer
/// be considered relevant. The same logic used to mark results as outdated
/// may be used to drive {@link TestRunRequest.continuous continuous test runs}.
///
/// If an item is passed to this method, test results for the item and all of
/// its children will be marked as outdated. If no item is passed, then all
/// test owned by the TestController will be marked as outdated.
///
/// Any test runs started before the moment this method is called, including
/// runs which may still be ongoing, will be marked as outdated and deprioritized
/// in the editor's UI.
///
/// @param items Item to mark as outdated. If undefined, all the controller's items are marked outdated.
pub fn TestController::invalidate_test_results(
  self : TestController,
  items? : TestItemOrMany,
) -> Unit {
  tests_controller_invalidate_test_results_ffi(
    self,
    option_test_item_or_many_to_js(items),
  )
}

///|
/// A collection of "top-level" {@link TestItem} instances, which can in
/// turn have their own {@link TestItem.children children} to form the
/// "test tree."
///
/// The extension controls when to add tests. For example, extensions should
/// add tests for a file when {@link workspace.onDidOpenTextDocument}
/// fires in order for decorations for tests within a file to be visible.
///
/// However, the editor may sometimes explicitly request children using the
/// {@link resolveHandler} See the documentation on that method for more details.

///|
pub fn TestController::add_root_item(
  self : TestController,
  item : TestItem,
) -> Unit {
  tests_controller_add_root_item_ffi(self, item)
}

///|
pub fn TestController::remove_root_item(
  self : TestController,
  item_id : String,
) -> Unit {
  tests_controller_remove_root_item_ffi(self, item_id)
}

///|
pub fn TestController::root_items_size(self : TestController) -> Int {
  tests_controller_root_items_size_ffi(self)
}

///|
/// The id of the controller passed in {@link tests.createTestController}.
/// This must be globally unique.

///|
/// Human-readable label for the test controller.

///|
/// Human-readable label for the test controller.

///|
/// Unregisters the test controller, disposing of its associated tests
/// and unpersisted results.
extern "js" fn test_controller_dispose_raw(controller : TestController) -> Unit =
  #| (controller) => controller.dispose()

///|
pub impl @vscode.Disposable for TestController with dispose(self) {
  test_controller_dispose_raw(self)
}

///|
/// Configures what kind of execution this profile controls. If there
/// are no profiles for a kind, it will not be available in the UI.

///|
/// Label shown to the user in the UI.
///
/// Note that the label has some significance if the user requests that
/// tests be re-run in a certain way. For example, if tests were run
/// normally and the user requests to re-run them in debug mode, the editor
/// will attempt use a configuration with the same label of the `Debug`
/// kind. If there is no such configuration, the default will be used.

///|
/// Label shown to the user in the UI.
///
/// Note that the label has some significance if the user requests that
/// tests be re-run in a certain way. For example, if tests were run
/// normally and the user requests to re-run them in debug mode, the editor
/// will attempt use a configuration with the same label of the `Debug`
/// kind. If there is no such configuration, the default will be used.

///|
/// Controls whether this profile is the default action that will
/// be taken when its kind is actioned. For example, if the user clicks
/// the generic "run all" button, then the default profile for
/// {@link TestRunProfileKind.Run} will be executed, although the
/// user can configure this.
///
/// Changes the user makes in their default profiles will be reflected
/// in this property after a {@link onDidChangeDefault} event.

///|
/// Controls whether this profile is the default action that will
/// be taken when its kind is actioned. For example, if the user clicks
/// the generic "run all" button, then the default profile for
/// {@link TestRunProfileKind.Run} will be executed, although the
/// user can configure this.
///
/// Changes the user makes in their default profiles will be reflected
/// in this property after a {@link onDidChangeDefault} event.

///|
/// Fired when a user has changed whether this is a default profile. The
/// event contains the new value of {@link isDefault}

///|
/// Whether this profile supports continuous running of requests. If so,
/// then {@link TestRunRequest.continuous} may be set to `true`. Defaults
/// to false.

///|
/// Whether this profile supports continuous running of requests. If so,
/// then {@link TestRunRequest.continuous} may be set to `true`. Defaults
/// to false.

///|
/// Associated tag for the profile. If this is set, only {@link TestItem}
/// instances with the same tag will be eligible to execute in this profile.

///|
/// Associated tag for the profile. If this is set, only {@link TestItem}
/// instances with the same tag will be eligible to execute in this profile.

///|
/// Associated tag for the profile. If this is set, only {@link TestItem}
/// instances with the same tag will be eligible to execute in this profile.

///|
/// If this method is present, a configuration gear will be present in the
/// UI, and this method will be invoked when it's clicked. When called,
/// you can take other editor actions, such as showing a quick pick or
/// opening a configuration file.
pub fn TestRunProfile::set_configure_handler(
  self : TestRunProfile,
  handler : () -> Unit,
) -> Unit {
  test_run_profile_set_configure_handler_raw(self, @v.JsValue::make(handler))
}

///|
/// If this method is present, a configuration gear will be present in the
/// UI, and this method will be invoked when it's clicked. When called,
/// you can take other editor actions, such as showing a quick pick or
/// opening a configuration file.
pub fn TestRunProfile::clear_configure_handler(self : TestRunProfile) -> Unit {
  test_run_profile_set_configure_handler_raw(self, @v.JsValue::make(()))
}

///|
/// Deletes the run profile.
extern "js" fn test_run_profile_dispose_raw(profile : TestRunProfile) -> Unit =
  #| (profile) => profile.dispose()

///|
pub impl @vscode.Disposable for TestRunProfile with dispose(self) {
  test_run_profile_dispose_raw(self)
}

///|
/// @param include Array of specific tests to run, or undefined to run all tests
/// @param exclude An array of tests to exclude from the run.
/// @param profile The run profile used for this request.
/// @param continuous Whether to run tests continuously as source changes.
/// @param preserveFocus Whether to preserve the user's focus when the run is started
pub fn TestRunRequest::new(
  included_items? : Array[TestItem],
  exclude? : Array[TestItem],
  profile? : TestRunProfile,
  continuous? : Bool,
  preserve_focus? : Bool,
) -> Self {
  test_run_request_ffi(
    option_to_js(included_items),
    option_to_js(exclude),
    option_to_js(profile),
    option_to_js(continuous),
    option_to_js(preserve_focus),
  )
}

///|
pub fn TestRunRequest::included_items(self : Self) -> Array[TestItem]? {
  js_to_option(test_run_request_include_raw(self))
}

///|
/// An array of tests the user has marked as excluded from the test included
/// in this run; exclusions should apply after inclusions.
///
/// May be omitted if no exclusions were requested. Test controllers should
/// not run excluded tests or any children of excluded tests.
pub fn TestRunRequest::excluded_items(self : Self) -> Array[TestItem]? {
  js_to_option(test_run_request_exclude_raw(self))
}

///|
/// The profile used for this request. This will always be defined
/// for requests issued from the editor UI, though extensions may
/// programmatically create requests not associated with any profile.
pub fn TestRunRequest::profile(self : Self) -> TestRunProfile? {
  js_to_option(test_run_request_profile_raw(self))
}

///|
/// Whether the profile should run continuously as source code changes. Only
/// relevant for profiles that set {@link TestRunProfile.supportsContinuousRun}.
pub fn TestRunRequest::continuous(self : Self) -> Bool? {
  js_to_option(test_run_request_continuous_raw(self))
}

///|
/// Controls how test Test Results view is focused.  If true, the editor
/// will keep the maintain the user's focus. If false, the editor will
/// prefer to move focus into the Test Results view, although
/// this may be configured by users.
pub extern "js" fn TestRunRequest::preserve_focus(self : Self) -> Bool =
  #| (request) => request.preserveFocus

///|
/// The human-readable name of the run. This can be used to
/// disambiguate multiple sets of results in a test run. It is useful if
/// tests are run across multiple platforms, for example.
pub fn TestRun::name(self : TestRun) -> String? {
  js_to_option(test_run_name_raw(self))
}

///|
/// A cancellation token which will be triggered when the test run is
/// canceled from the UI.
pub extern "js" fn TestRun::token(self : TestRun) -> CancellationToken =
  #| (run) => run.token

///|
/// Whether the test run will be persisted across reloads by the editor.
pub extern "js" fn TestRun::is_persisted(self : TestRun) -> Bool =
  #| (run) => run.isPersisted

///|
/// Indicates a test is queued for later execution.
/// @param test Test item to update.
pub extern "js" fn TestRun::enqueued(self : TestRun, item : TestItem) -> Unit =
  #| (run, item) => run.enqueued(item)

///|
/// Indicates a test has started running.
/// @param test Test item to update.
pub extern "js" fn TestRun::started(self : TestRun, item : TestItem) -> Unit =
  #| (run, item) => run.started(item)

///|
/// Indicates a test has been skipped.
/// @param test Test item to update.
pub extern "js" fn TestRun::skipped(self : TestRun, item : TestItem) -> Unit =
  #| (run, item) => run.skipped(item)

///|
/// Indicates a test has failed. You should pass one or more
/// {@link TestMessage TestMessages} to describe the failure.
/// @param test Test item to update.
/// @param message Messages associated with the test failure.
/// @param duration How long the test took to execute, in milliseconds.
pub fn TestRun::failed(
  self : TestRun,
  item : TestItem,
  message : TestMessageOrMany,
  duration? : Int,
) -> Unit {
  test_run_failed_ffi(self, item, message.to_js(), option_to_js(duration))
}

///|
/// Indicates a test has errored. You should pass one or more
/// {@link TestMessage TestMessages} to describe the failure. This differs
/// from the "failed" state in that it indicates a test that couldn't be
/// executed at all, from a compilation error for example.
/// @param test Test item to update.
/// @param message Messages associated with the test failure.
/// @param duration How long the test took to execute, in milliseconds.
pub fn TestRun::errored(
  self : TestRun,
  item : TestItem,
  message : TestMessageOrMany,
  duration? : Int,
) -> Unit {
  test_run_errored_ffi(self, item, message.to_js(), option_to_js(duration))
}

///|
/// Indicates a test has passed.
/// @param test Test item to update.
/// @param duration How long the test took to execute, in milliseconds.
pub fn TestRun::passed(
  self : TestRun,
  item : TestItem,
  duration? : Int,
) -> Unit {
  test_run_passed_ffi(self, item, option_to_js(duration))
}

///|
/// Appends raw output from the test runner. On the user's request, the
/// output will be displayed in a terminal. ANSI escape sequences,
/// such as colors and text styles, are supported. New lines must be given
/// as CRLF (`\r\n`) rather than LF (`\n`).
///
/// @param output Output text to append.
/// @param location Indicate that the output was logged at the given
/// location.
/// @param test Test item to associate the output with.
pub fn TestRun::append_output(
  self : TestRun,
  output : String,
  location? : Location,
  test_item? : TestItem,
) -> Unit {
  test_run_append_output_ffi(
    self,
    output,
    option_to_js(location),
    option_to_js(test_item),
  )
}

///|
/// Adds coverage for a file in the run.
pub extern "js" fn TestRun::add_coverage(
  self : TestRun,
  file_coverage : FileCoverage,
) -> Unit =
  #| (run, fileCoverage) => run.addCoverage(fileCoverage)

///|
/// Signals the end of the test run. Any tests included in the run whose
/// states have not been updated will have their state reset.
pub extern "js" fn TestRun::end(self : TestRun) -> Unit =
  #| (run) => run.end()

///|
/// An event fired when the editor is no longer interested in data
/// associated with the test run.
pub extern "js" fn TestRun::on_did_dispose(self : TestRun) -> Event[Unit] =
  #| (run) => run.onDidDispose

///|
/// Gets the number of items in the collection.
pub extern "js" fn TestItemCollection::size(self : TestItemCollection) -> Int =
  #| (collection) => collection.size

///|
/// Replaces the items stored by the collection.
/// @param items Items to store.
pub extern "js" fn TestItemCollection::replace(
  self : TestItemCollection,
  items : Array[TestItem],
) -> Unit =
  #| (collection, items) => collection.replace(items)

///|
/// Adds the test item to the children. If an item with the same ID already
/// exists, it'll be replaced.
/// @param item Item to add.
pub extern "js" fn TestItemCollection::add(
  self : TestItemCollection,
  item : TestItem,
) -> Unit =
  #| (collection, item) => collection.add(item)

///|
/// Removes a single test item from the collection.
/// @param itemId Item ID to delete.
pub extern "js" fn TestItemCollection::delete(
  self : TestItemCollection,
  item_id : String,
) -> Unit =
  #| (collection, itemId) => collection.delete(itemId)

///|
/// Efficiently gets a test item by ID, if it exists, in the children.
/// @param itemId Item ID to get.
/// @returns The found item or undefined if it does not exist.
pub fn TestItemCollection::get(
  self : TestItemCollection,
  item_id : String,
) -> TestItem? {
  js_to_option(test_item_collection_get_raw(self, item_id))
}

///|
/// URI this `TestItem` is associated with. May be a file or directory.
pub fn TestItem::uri(self : TestItem) -> Uri? {
  js_to_option(test_item_uri_raw(self))
}

///|
/// Identifier for the `TestItem`. This is used to correlate
/// test results and tests in the document with those in the workspace
/// (test explorer). This cannot change for the lifetime of the `TestItem`,
/// and must be unique among its parent's direct children.
pub extern "js" fn TestItem::id(self : TestItem) -> String =
  #| (item) => item.id

///|
/// The children of this test item. For a test suite, this may contain the
/// individual test cases or nested suites.
pub extern "js" fn TestItem::children(self : TestItem) -> TestItemCollection =
  #| (item) => item.children

///|
/// The parent of this item. It's set automatically, and is undefined
/// top-level items in the {@link TestController.items} and for items that
/// aren't yet included in another item's {@link TestItem.children children}.
pub fn TestItem::parent(self : TestItem) -> TestItem? {
  js_to_option(test_item_parent_raw(self))
}

///|
/// Display name describing the test case.
pub extern "js" fn TestItem::label(self : TestItem) -> String =
  #| (item) => item.label

///|
/// Display name describing the test case.
pub extern "js" fn TestItem::set_label(self : TestItem, value : String) -> Unit =
  #| (item, value) => { item.label = value; }

///|
/// Tags associated with this test item. May be used in combination with
/// {@link TestRunProfile.tag tags}, or simply as an organizational feature.
pub extern "js" fn TestItem::tags(self : TestItem) -> Array[TestTag] =
  #| (item) => item.tags

///|
/// Tags associated with this test item. May be used in combination with
/// {@link TestRunProfile.tag tags}, or simply as an organizational feature.
pub extern "js" fn TestItem::set_tags(
  self : TestItem,
  value : Array[TestTag],
) -> Unit =
  #| (item, value) => { item.tags = value; }

///|
/// Indicates whether this test item may have children discovered by resolving.
///
/// If true, this item is shown as expandable in the Test Explorer view and
/// expanding the item will cause {@link TestController.resolveHandler}
/// to be invoked with the item.
///
/// Default to `false`.
pub extern "js" fn TestItem::can_resolve_children(self : TestItem) -> Bool =
  #| (item) => item.canResolveChildren

///|
/// Indicates whether this test item may have children discovered by resolving.
///
/// If true, this item is shown as expandable in the Test Explorer view and
/// expanding the item will cause {@link TestController.resolveHandler}
/// to be invoked with the item.
///
/// Default to `false`.
pub extern "js" fn TestItem::set_can_resolve_children(
  self : TestItem,
  value : Bool,
) -> Unit =
  #| (item, value) => { item.canResolveChildren = value; }

///|
/// Controls whether the item is shown as "busy" in the Test Explorer view.
/// This is useful for showing status while discovering children.
///
/// Defaults to `false`.
pub extern "js" fn TestItem::busy(self : TestItem) -> Bool =
  #| (item) => item.busy

///|
/// Controls whether the item is shown as "busy" in the Test Explorer view.
/// This is useful for showing status while discovering children.
///
/// Defaults to `false`.
pub extern "js" fn TestItem::set_busy(self : TestItem, value : Bool) -> Unit =
  #| (item, value) => { item.busy = value; }

///|
/// Optional description that appears next to the label.
pub fn TestItem::description(self : TestItem) -> String? {
  js_to_option(test_item_description_raw(self))
}

///|
/// Optional description that appears next to the label.
pub fn TestItem::set_description(self : TestItem, value : String?) -> Unit {
  test_item_set_description_raw(self, option_to_js(value))
}

///|
/// Optional description that appears next to the label.
pub fn TestItem::clear_description(self : TestItem) -> Unit {
  test_item_set_description_raw(self, @v.JsValue::make(()))
}

///|
/// A string that should be used when comparing this item
/// with other items. When `falsy` the {@link TestItem.label label}
/// is used.
pub fn TestItem::sort_text(self : TestItem) -> String? {
  js_to_option(test_item_sort_text_raw(self))
}

///|
/// A string that should be used when comparing this item
/// with other items. When `falsy` the {@link TestItem.label label}
/// is used.
pub fn TestItem::set_sort_text(self : TestItem, value : String?) -> Unit {
  test_item_set_sort_text_raw(self, option_to_js(value))
}

///|
/// A string that should be used when comparing this item
/// with other items. When `falsy` the {@link TestItem.label label}
/// is used.
pub fn TestItem::clear_sort_text(self : TestItem) -> Unit {
  test_item_set_sort_text_raw(self, @v.JsValue::make(()))
}

///|
/// Location of the test item in its {@link TestItem.uri uri}.
///
/// This is only meaningful if the `uri` points to a file.
pub fn TestItem::range(self : TestItem) -> Range? {
  js_to_option(test_item_range_raw(self))
}

///|
/// Location of the test item in its {@link TestItem.uri uri}.
///
/// This is only meaningful if the `uri` points to a file.
pub fn TestItem::set_range(self : TestItem, value : Range?) -> Unit {
  test_item_set_range_raw(self, option_to_js(value))
}

///|
/// Location of the test item in its {@link TestItem.uri uri}.
///
/// This is only meaningful if the `uri` points to a file.
pub fn TestItem::clear_range(self : TestItem) -> Unit {
  test_item_set_range_raw(self, @v.JsValue::make(()))
}

///|
/// Optional error encountered while loading the test.
///
/// Note that this is not a test result and should only be used to represent errors in
/// test discovery, such as syntax errors.
pub fn TestItem::error(self : TestItem) -> MarkdownStringValue? {
  js_to_option(test_item_error_raw(self))
}

///|
/// Optional error encountered while loading the test.
///
/// Note that this is not a test result and should only be used to represent errors in
/// test discovery, such as syntax errors.
pub fn TestItem::set_error(
  self : TestItem,
  value : MarkdownStringValue?,
) -> Unit {
  test_item_set_error_raw(self, option_to_js(value))
}

///|
/// Optional error encountered while loading the test.
///
/// Note that this is not a test result and should only be used to represent errors in
/// test discovery, such as syntax errors.
pub fn TestItem::clear_error(self : TestItem) -> Unit {
  test_item_set_error_raw(self, @v.JsValue::make(()))
}

///|
/// @param label The name of the stack frame
/// @param file The file URI of the stack frame
/// @param position The position of the stack frame within the file
pub fn TestMessageStackFrame::new(
  label : String,
  uri? : Uri,
  position? : Position,
) -> Self {
  test_message_stack_frame_ffi(label, option_to_js(uri), option_to_js(position))
}

///|
/// The name of the stack frame, typically a method or function name.

///|
/// The name of the stack frame, typically a method or function name.

///|
/// The location of this stack frame. This should be provided as a URI if the
/// location of the call frame can be accessed by the editor.

///|
/// The location of this stack frame. This should be provided as a URI if the
/// location of the call frame can be accessed by the editor.

///|
/// The location of this stack frame. This should be provided as a URI if the
/// location of the call frame can be accessed by the editor.

///|
/// Position of the stack frame within the file.

///|
/// Position of the stack frame within the file.

///|
/// Position of the stack frame within the file.

///|
/// Creates a new TestMessage instance.
/// @param message The message to show to the user.
pub fn TestMessage::new(message : MarkdownStringValue) -> Self {
  test_message_ffi(message)
}

///|
/// Creates a new TestMessage that will present as a diff in the editor.
/// @param message Message to display to the user.
/// @param expected Expected output.
/// @param actual Actual output.
pub fn TestMessage::diff(
  message : MarkdownStringValue,
  expected : String,
  actual : String,
) -> Self {
  test_message_diff_ffi(message, expected, actual)
}

///|
pub fn TestMessage::stack_trace(self : Self) -> Array[TestMessageStackFrame]? {
  js_to_option(test_message_stack_trace_raw(self))
}

///|
pub fn TestMessage::set_stack_trace(
  self : Self,
  value : Array[TestMessageStackFrame]?,
) -> Unit {
  test_message_set_stack_trace_raw(self, option_to_js(value))
}

///|
pub fn TestMessage::clear_stack_trace(self : Self) -> Unit {
  test_message_set_stack_trace_raw(self, @v.JsValue::make(()))
}

///|
/// Human-readable message text to display.

///|
/// Human-readable message text to display.

///|
/// Expected test output. If given with {@link TestMessage.actualOutput actualOutput }, a diff view will be shown.

///|
/// Expected test output. If given with {@link TestMessage.actualOutput actualOutput }, a diff view will be shown.

///|
/// Expected test output. If given with {@link TestMessage.actualOutput actualOutput }, a diff view will be shown.

///|
/// Actual test output. If given with {@link TestMessage.expectedOutput expectedOutput }, a diff view will be shown.

///|
/// Actual test output. If given with {@link TestMessage.expectedOutput expectedOutput }, a diff view will be shown.

///|
/// Actual test output. If given with {@link TestMessage.expectedOutput expectedOutput }, a diff view will be shown.

///|
/// Associated file location.

///|
/// Associated file location.

///|
/// Associated file location.

///|
/// Context value of the test item. This can be used to contribute message-
/// specific actions to the test peek view. The value set here can be found
/// in the `testMessage` property of the following `menus` contribution points:
///
/// - `testing/message/context` - context menu for the message in the results tree
/// - `testing/message/content` - a prominent button overlaying editor content where
///    the message is displayed.
///
/// For example:
///
/// ```json
/// "contributes": {
///   "menus": {
///     "testing/message/content": [
///       {
///         "command": "extension.deleteCommentThread",
///         "when": "testMessage == canApplyRichDiff"
///       }
///     ]
///   }
/// }
/// ```
///
/// The command will be called with an object containing:
/// - `test`: the {@link TestItem} the message is associated with, *if* it
///    is still present in the {@link TestController.items} collection.
/// - `message`: the {@link TestMessage} instance.

///|
/// Context value of the test item. This can be used to contribute message-
/// specific actions to the test peek view. The value set here can be found
/// in the `testMessage` property of the following `menus` contribution points:
///
/// - `testing/message/context` - context menu for the message in the results tree
/// - `testing/message/content` - a prominent button overlaying editor content where
///    the message is displayed.
///
/// For example:
///
/// ```json
/// "contributes": {
///   "menus": {
///     "testing/message/content": [
///       {
///         "command": "extension.deleteCommentThread",
///         "when": "testMessage == canApplyRichDiff"
///       }
///     ]
///   }
/// }
/// ```
///
/// The command will be called with an object containing:
/// - `test`: the {@link TestItem} the message is associated with, *if* it
///    is still present in the {@link TestController.items} collection.
/// - `message`: the {@link TestMessage} instance.

///|
/// Context value of the test item. This can be used to contribute message-
/// specific actions to the test peek view. The value set here can be found
/// in the `testMessage` property of the following `menus` contribution points:
///
/// - `testing/message/context` - context menu for the message in the results tree
/// - `testing/message/content` - a prominent button overlaying editor content where
///    the message is displayed.
///
/// For example:
///
/// ```json
/// "contributes": {
///   "menus": {
///     "testing/message/content": [
///       {
///         "command": "extension.deleteCommentThread",
///         "when": "testMessage == canApplyRichDiff"
///       }
///     ]
///   }
/// }
/// ```
///
/// The command will be called with an object containing:
/// - `test`: the {@link TestItem} the message is associated with, *if* it
///    is still present in the {@link TestController.items} collection.
/// - `message`: the {@link TestMessage} instance.

///|
/// The stack trace associated with the message or failure.

///|
/// The stack trace associated with the message or failure.

///|
/// The stack trace associated with the message or failure.

///|
/// @param covered Value for {@link TestCoverageCount.covered}
/// @param total Value for {@link TestCoverageCount.total}
pub fn TestCoverageCount::new(covered : Int, total : Int) -> Self {
  test_coverage_count_ffi(covered, total)
}

///|
pub extern "js" fn TestCoverageCount::covered(self : Self) -> Int =
  #| (value) => value.covered

///|
pub extern "js" fn TestCoverageCount::total(self : Self) -> Int =
  #| (value) => value.total

///|
/// Number of items covered in the file.

///|
/// Number of items covered in the file.

///|
/// Total number of covered items in the file.

///|
/// Total number of covered items in the file.

///|
/// @param uri Covered file URI
/// @param statementCoverage Statement coverage information. If the reporter
/// does not provide statement coverage information, this can instead be
/// used to represent line coverage.
/// @param branchCoverage Branch coverage information
/// @param declarationCoverage Declaration coverage information
/// @param includesTests Test cases included in this coverage report, see {@link FileCoverage.includesTests}
pub fn FileCoverage::new(
  uri : Uri,
  statement_coverage : TestCoverageCount,
  branch_coverage? : TestCoverageCount,
  declaration_coverage? : TestCoverageCount,
  includes_tests? : Array[TestItem],
) -> Self {
  file_coverage_ffi(
    uri,
    statement_coverage,
    option_to_js(branch_coverage),
    option_to_js(declaration_coverage),
    option_to_js(includes_tests),
  )
}

///|
/// Creates a {@link FileCoverage} instance with counts filled in from
/// the coverage details.
/// @param uri Covered file URI
/// @param details Detailed coverage information
pub fn FileCoverage::from_details(
  uri : Uri,
  details : Array[FileCoverageDetail],
) -> Self {
  file_coverage_from_details_ffi(uri, details)
}

///|
pub extern "js" fn FileCoverage::statement_coverage(
  self : Self,
) -> TestCoverageCount =
  #| (value) => value.statementCoverage

///|
/// File URI.

///|
/// Statement coverage information. If the reporter does not provide statement
/// coverage information, this can instead be used to represent line coverage.

///|
/// Statement coverage information. If the reporter does not provide statement
/// coverage information, this can instead be used to represent line coverage.

///|
/// Branch coverage information.

///|
/// Branch coverage information.

///|
/// Branch coverage information.

///|
/// Declaration coverage information. Depending on the reporter and
/// language, this may be types such as functions, methods, or namespaces.

///|
/// Declaration coverage information. Depending on the reporter and
/// language, this may be types such as functions, methods, or namespaces.

///|
/// Declaration coverage information. Depending on the reporter and
/// language, this may be types such as functions, methods, or namespaces.

///|
/// A list of {@link TestItem test cases} that generated coverage in this
/// file. If set, then {@link TestRunProfile.loadDetailedCoverageForTest}
/// should also be defined in order to retrieve detailed coverage information.

///|
/// A list of {@link TestItem test cases} that generated coverage in this
/// file. If set, then {@link TestRunProfile.loadDetailedCoverageForTest}
/// should also be defined in order to retrieve detailed coverage information.

///|
/// A list of {@link TestItem test cases} that generated coverage in this
/// file. If set, then {@link TestRunProfile.loadDetailedCoverageForTest}
/// should also be defined in order to retrieve detailed coverage information.

///|
/// @param location The statement position.
/// @param executed The number of times this statement was executed, or a
/// boolean indicating  whether it was executed if the exact count is
/// unknown. If zero or false, the statement will be marked as un-covered.
/// @param branches Coverage from branches of this line.  If it's not a
/// conditional, this should be omitted.
pub fn StatementCoverage::new(
  executed : IntOrBool,
  location : PositionOrRange,
  branches? : Array[BranchCoverage],
) -> Self {
  statement_coverage_ffi(
    executed.to_js(),
    location.to_js(),
    option_to_js(branches),
  )
}

///|
/// The number of times this statement was executed, or a boolean indicating
/// whether it was executed if the exact count is unknown. If zero or false,
/// the statement will be marked as un-covered.

///|
/// The number of times this statement was executed, or a boolean indicating
/// whether it was executed if the exact count is unknown. If zero or false,
/// the statement will be marked as un-covered.

///|
/// Statement location.

///|
/// Statement location.

///|
/// Coverage from branches of this line or statement. If it's not a
/// conditional, this will be empty.

///|
/// Coverage from branches of this line or statement. If it's not a
/// conditional, this will be empty.

///|
/// @param executed The number of times this branch was executed, or a
/// boolean indicating  whether it was executed if the exact count is
/// unknown. If zero or false, the branch will be marked as un-covered.
/// @param location The branch position.
pub fn BranchCoverage::new(
  executed : IntOrBool,
  location? : PositionOrRange,
  label? : String,
) -> Self {
  branch_coverage_ffi(
    executed.to_js(),
    option_position_or_range_to_js(location),
    option_to_js(label),
  )
}

///|
/// The number of times this branch was executed, or a boolean indicating
/// whether it was executed if the exact count is unknown. If zero or false,
/// the branch will be marked as un-covered.

///|
/// The number of times this branch was executed, or a boolean indicating
/// whether it was executed if the exact count is unknown. If zero or false,
/// the branch will be marked as un-covered.

///|
/// Branch location.

///|
/// Branch location.

///|
/// Branch location.

///|
/// Label for the branch, used in the context of "the ${label} branch was
/// not taken," for example.

///|
/// Label for the branch, used in the context of "the ${label} branch was
/// not taken," for example.

///|
/// Label for the branch, used in the context of "the ${label} branch was
/// not taken," for example.

///|
/// @param executed The number of times this declaration was executed, or a
/// boolean indicating  whether it was executed if the exact count is
/// unknown. If zero or false, the declaration will be marked as un-covered.
/// @param location The declaration position.
pub fn DeclarationCoverage::new(
  name : String,
  executed : IntOrBool,
  location : PositionOrRange,
) -> Self {
  declaration_coverage_ffi(name, executed.to_js(), location.to_js())
}

///|
/// Name of the declaration.

///|
/// Name of the declaration.

///|
/// The number of times this declaration was executed, or a boolean
/// indicating whether it was executed if the exact count is unknown. If
/// zero or false, the declaration will be marked as un-covered.

///|
/// The number of times this declaration was executed, or a boolean
/// indicating whether it was executed if the exact count is unknown. If
/// zero or false, the declaration will be marked as un-covered.

///|
/// Declaration location.

///|
/// Declaration location.

///|
extern "js" fn tests_controller_create_run_profile_ffi(
  controller : TestController,
  label : String,
  kind : TestRunProfileKind,
  run_handler : (TestRunRequest, CancellationToken) -> Unit,
  is_default : @v.JsValue,
  tag : @v.JsValue,
  supports_continuous_run : @v.JsValue,
) -> TestRunProfile =
  #| (controller, label, kind, runHandler, isDefault, tag, supportsContinuousRun) => {
  #|   const actualDefault = isDefault === undefined || isDefault === null ? undefined : isDefault;
  #|   const actualTag = tag === undefined || tag === null ? undefined : tag;
  #|   const actualContinuous =
  #|     supportsContinuousRun === undefined || supportsContinuousRun === null
  #|       ? undefined
  #|       : supportsContinuousRun;
  #|   return controller.createRunProfile(
  #|     label,
  #|     kind,
  #|     (request, token) => runHandler(request, token),
  #|     actualDefault,
  #|     actualTag,
  #|     actualContinuous,
  #|   );
  #| }

///|
extern "js" fn tests_controller_create_test_run_ffi(
  controller : TestController,
  request : TestRunRequest,
  name : @v.JsValue,
  persist : @v.JsValue,
) -> TestRun =
  #| (controller, request, name, persist) => {
  #|   const actualName = name === undefined || name === null ? undefined : name;
  #|   const actualPersist = persist === undefined || persist === null ? undefined : persist;
  #|   return controller.createTestRun(request, actualName, actualPersist);
  #| }

///|
extern "js" fn tests_controller_set_resolve_handler_ffi(
  controller : TestController,
  handler : (@v.JsValue) -> Unit,
) -> Unit =
  #| (controller, handler) => {
  #|   controller.resolveHandler = (item) => handler(item);
  #| }

///|
extern "js" fn tests_controller_set_resolve_handler_raw(
  controller : TestController,
  handler : @v.JsValue,
) -> Unit =
  #| (controller, handler) => {
  #|   controller.resolveHandler =
  #|     handler === undefined || handler === null ? undefined : handler;
  #| }

///|
extern "js" fn tests_controller_set_refresh_handler_ffi(
  controller : TestController,
  handler : (CancellationToken) -> Unit,
) -> Unit =
  #| (controller, handler) => {
  #|   controller.refreshHandler = (token) => handler(token);
  #| }

///|
extern "js" fn tests_controller_set_refresh_handler_raw(
  controller : TestController,
  handler : @v.JsValue,
) -> Unit =
  #| (controller, handler) => {
  #|   controller.refreshHandler =
  #|     handler === undefined || handler === null ? undefined : handler;
  #| }

///|
extern "js" fn tests_controller_invalidate_test_results_ffi(
  controller : TestController,
  items : @v.JsValue,
) -> Unit =
  #| (controller, items) => {
  #|   if (items === undefined || items === null) {
  #|     controller.invalidateTestResults();
  #|   } else {
  #|     controller.invalidateTestResults(items);
  #|   }
  #| }

///|
extern "js" fn TestRunProfile::tag_raw(self : TestRunProfile) -> @v.JsValue =
  #| (profile) => profile.tag

///|
extern "js" fn test_run_profile_set_configure_handler_raw(
  profile : TestRunProfile,
  value : @v.JsValue,
) -> Unit =
  #| (profile, value) => {
  #|   profile.configureHandler =
  #|     value === undefined || value === null ? undefined : value;
  #| }

///|
extern "js" fn test_run_request_ffi(
  included_items : @v.JsValue,
  exclude : @v.JsValue,
  profile : @v.JsValue,
  continuous : @v.JsValue,
  preserve_focus : @v.JsValue,
) -> TestRunRequest =
  #| (includedItems, exclude, profile, continuous, preserveFocus) => {
  #|   const actualInclude =
  #|     includedItems === undefined || includedItems === null ? undefined : includedItems;
  #|   const actualExclude = exclude === undefined || exclude === null ? undefined : exclude;
  #|   const actualProfile = profile === undefined || profile === null ? undefined : profile;
  #|   const actualContinuous =
  #|     continuous === undefined || continuous === null ? undefined : continuous;
  #|   const actualPreserveFocus =
  #|     preserveFocus === undefined || preserveFocus === null ? undefined : preserveFocus;
  #|   return new (require("vscode").TestRunRequest)(
  #|     actualInclude,
  #|     actualExclude,
  #|     actualProfile,
  #|     actualContinuous,
  #|     actualPreserveFocus,
  #|   );
  #| }

///|
extern "js" fn test_run_request_include_raw(
  request : TestRunRequest,
) -> @v.JsValue =
  #| (request) => request.include

///|
extern "js" fn test_run_request_exclude_raw(
  request : TestRunRequest,
) -> @v.JsValue =
  #| (request) => request.exclude

///|
extern "js" fn test_run_request_profile_raw(
  request : TestRunRequest,
) -> @v.JsValue =
  #| (request) => request.profile

///|
extern "js" fn test_run_request_continuous_raw(
  request : TestRunRequest,
) -> @v.JsValue =
  #| (request) => request.continuous

///|
extern "js" fn test_run_failed_ffi(
  run : TestRun,
  item : TestItem,
  message : @v.JsValue,
  duration : @v.JsValue,
) -> Unit =
  #| (run, item, message, duration) => {
  #|   const actualDuration = duration === undefined || duration === null ? undefined : duration;
  #|   run.failed(item, message, actualDuration);
  #| }

///|
extern "js" fn test_run_errored_ffi(
  run : TestRun,
  item : TestItem,
  message : @v.JsValue,
  duration : @v.JsValue,
) -> Unit =
  #| (run, item, message, duration) => {
  #|   const actualDuration = duration === undefined || duration === null ? undefined : duration;
  #|   run.errored(item, message, actualDuration);
  #| }

///|
extern "js" fn test_run_passed_ffi(
  run : TestRun,
  item : TestItem,
  duration : @v.JsValue,
) -> Unit =
  #| (run, item, duration) => {
  #|   const actualDuration = duration === undefined || duration === null ? undefined : duration;
  #|   run.passed(item, actualDuration);
  #| }

///|
extern "js" fn test_run_append_output_ffi(
  run : TestRun,
  output : String,
  location : @v.JsValue,
  test_item : @v.JsValue,
) -> Unit =
  #| (run, output, location, testItem) => {
  #|   const actualLocation = location === undefined || location === null ? undefined : location;
  #|   const actualTest = testItem === undefined || testItem === null ? undefined : testItem;
  #|   run.appendOutput(output, actualLocation, actualTest);
  #| }

///|
extern "js" fn test_item_collection_get_raw(
  items : TestItemCollection,
  item_id : String,
) -> @v.JsValue =
  #| (items, itemId) => items.get(itemId)

///|
extern "js" fn test_run_name_raw(run : TestRun) -> @v.JsValue =
  #| (run) => run.name

///|
extern "js" fn test_item_uri_raw(item : TestItem) -> @v.JsValue =
  #| (item) => item.uri

///|
extern "js" fn test_item_parent_raw(item : TestItem) -> @v.JsValue =
  #| (item) => item.parent

///|
extern "js" fn test_item_description_raw(item : TestItem) -> @v.JsValue =
  #| (item) => item.description

///|
extern "js" fn test_item_set_description_raw(
  item : TestItem,
  value : @v.JsValue,
) -> Unit =
  #| (item, value) => { item.description = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn test_item_sort_text_raw(item : TestItem) -> @v.JsValue =
  #| (item) => item.sortText

///|
extern "js" fn test_item_set_sort_text_raw(
  item : TestItem,
  value : @v.JsValue,
) -> Unit =
  #| (item, value) => { item.sortText = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn test_item_range_raw(item : TestItem) -> @v.JsValue =
  #| (item) => item.range

///|
extern "js" fn test_item_set_range_raw(
  item : TestItem,
  value : @v.JsValue,
) -> Unit =
  #| (item, value) => { item.range = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn test_item_error_raw(item : TestItem) -> @v.JsValue =
  #| (item) => item.error

///|
extern "js" fn test_item_set_error_raw(
  item : TestItem,
  value : @v.JsValue,
) -> Unit =
  #| (item, value) => { item.error = value === undefined || value === null ? undefined : value; }

///|
extern "js" fn test_message_stack_frame_ffi(
  label : String,
  uri : @v.JsValue,
  position : @v.JsValue,
) -> TestMessageStackFrame =
  #| (label, uri, position) => {
  #|   const actualUri = uri === undefined || uri === null ? undefined : uri;
  #|   const actualPosition =
  #|     position === undefined || position === null ? undefined : position;
  #|   return new (require("vscode").TestMessageStackFrame)(
  #|     label,
  #|     actualUri,
  #|     actualPosition,
  #|   );
  #| }

///|
extern "js" fn test_message_ffi(message : MarkdownStringValue) -> TestMessage =
  #| (message) => new (require("vscode").TestMessage)(message)

///|
extern "js" fn test_message_diff_ffi(
  message : MarkdownStringValue,
  expected : String,
  actual : String,
) -> TestMessage =
  #| (message, expected, actual) =>
  #|   require("vscode").TestMessage.diff(message, expected, actual)

///|
extern "js" fn test_message_stack_trace_raw(value : TestMessage) -> @v.JsValue =
  #| (value) => value.stackTrace

///|
extern "js" fn test_message_set_stack_trace_raw(
  value : TestMessage,
  stack_trace : @v.JsValue,
) -> Unit =
  #| (value, stackTrace) => {
  #|   value.stackTrace =
  #|     stackTrace === undefined || stackTrace === null ? undefined : stackTrace;
  #| }

///|
extern "js" fn test_coverage_count_ffi(
  covered : Int,
  total : Int,
) -> TestCoverageCount =
  #| (covered, total) => new (require("vscode").TestCoverageCount)(covered, total)

///|
extern "js" fn file_coverage_ffi(
  uri : Uri,
  statement_coverage : TestCoverageCount,
  branch_coverage : @v.JsValue,
  declaration_coverage : @v.JsValue,
  includes_tests : @v.JsValue,
) -> FileCoverage =
  #| (uri, statementCoverage, branchCoverage, declarationCoverage, includesTests) => {
  #|   const actualBranchCoverage =
  #|     branchCoverage === undefined || branchCoverage === null
  #|       ? undefined
  #|       : branchCoverage;
  #|   const actualDeclarationCoverage =
  #|     declarationCoverage === undefined || declarationCoverage === null
  #|       ? undefined
  #|       : declarationCoverage;
  #|   const actualIncludesTests =
  #|     includesTests === undefined || includesTests === null ? undefined : includesTests;
  #|   return new (require("vscode").FileCoverage)(
  #|     uri,
  #|     statementCoverage,
  #|     actualBranchCoverage,
  #|     actualDeclarationCoverage,
  #|     actualIncludesTests,
  #|   );
  #| }

///|
extern "js" fn file_coverage_from_details_ffi(
  uri : Uri,
  details : Array[FileCoverageDetail],
) -> FileCoverage =
  #| (uri, details) => require("vscode").FileCoverage.fromDetails(uri, details)

///|
extern "js" fn statement_coverage_ffi(
  executed : @v.JsValue,
  location : @v.JsValue,
  branches : @v.JsValue,
) -> StatementCoverage =
  #| (executed, location, branches) => {
  #|   const actualBranches = branches === undefined || branches === null ? undefined : branches;
  #|   return new (require("vscode").StatementCoverage)(
  #|     executed,
  #|     location,
  #|     actualBranches,
  #|   );
  #| }

///|
extern "js" fn branch_coverage_ffi(
  executed : @v.JsValue,
  location : @v.JsValue,
  label : @v.JsValue,
) -> BranchCoverage =
  #| (executed, location, label) => {
  #|   const actualLocation = location === undefined || location === null ? undefined : location;
  #|   const actualLabel = label === undefined || label === null ? undefined : label;
  #|   return new (require("vscode").BranchCoverage)(executed, actualLocation, actualLabel);
  #| }

///|
extern "js" fn declaration_coverage_ffi(
  name : String,
  executed : @v.JsValue,
  location : @v.JsValue,
) -> DeclarationCoverage =
  #| (name, executed, location) =>
  #|   new (require("vscode").DeclarationCoverage)(name, executed, location)
