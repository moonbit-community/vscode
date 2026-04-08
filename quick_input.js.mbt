///|
/// Quick input base helpers.

///|
/// An optional title for the input UI.

///|
/// An optional title for the input UI.

///|
/// An optional title for the input UI.

///|
/// An optional current step count for multi-step input flows.

///|
/// An optional current step count for multi-step input flows.

///|
/// An optional current step count for multi-step input flows.

///|
/// An optional total step count for multi-step input flows.

///|
/// An optional total step count for multi-step input flows.

///|
/// An optional total step count for multi-step input flows.

///|
/// Determines if the UI should allow for user input. Defaults to `true`.
///
/// Change this to `false`, for example, while validating user input or loading data for the next
/// step in user input.

///|
/// Determines if the UI should allow for user input. Defaults to `true`.
///
/// Change this to `false`, for example, while validating user input or loading data for the next
/// step in user input.

///|
/// Determines if the UI should show a progress indicator. Defaults to `false`.
///
/// Change this to `true`, for example, while loading more data or validating user input.

///|
/// Determines if the UI should show a progress indicator. Defaults to `false`.
///
/// Change this to `true`, for example, while loading more data or validating user input.

///|
/// Determines if the UI should stay open even when losing UI focus. Defaults to `false`.
/// This setting is ignored on iPad and is always `false`.

///|
/// Determines if the UI should stay open even when losing UI focus. Defaults to `false`.
/// This setting is ignored on iPad and is always `false`.

///|
/// Makes the input UI visible in its current configuration.
///
/// Any other input UI will first fire an {@link QuickInput.onDidHide onDidHide} event.
pub extern "js" fn QuickInput::show(self : QuickInput) -> Unit =
  #| (input) => input.show()

///|
/// Hides this input UI.
///
/// This will also fire an {@link QuickInput.onDidHide onDidHide} event.
pub extern "js" fn QuickInput::hide(self : QuickInput) -> Unit =
  #| (input) => input.hide()

///|
/// An event signaling when this input UI is hidden.
///
/// There are several reasons why this UI might have to be hidden and the extension will be notified
/// through {@link QuickInput.onDidHide onDidHide}. Examples include: an explicit call to
/// {@link QuickInput.hide hide}, the user pressing Esc, some other input UI opening, etc.

///|
/// Dispose of this input UI and any associated resources.
///
/// If it is still visible, it is first hidden. After this call the input UI is no longer functional
/// and no additional methods or properties on it should be accessed. Instead a new input UI should
/// be created.
extern "js" fn quick_input_dispose_raw(input : QuickInput) -> Unit =
  #| (input) => input.dispose()

///|
pub impl Disposable for QuickInput with dispose(self) {
  quick_input_dispose_raw(self)
}
