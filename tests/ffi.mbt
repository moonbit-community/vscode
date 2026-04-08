///|
/// JS FFI bindings for VS Code tests namespace.

///|
extern "js" fn tests_create_test_controller_ffi(
  id : String,
  label : String,
) -> TestController =
  #| (id, label) => require("vscode").tests.createTestController(id, label)

///|
extern "js" fn tests_controller_create_test_item_ffi(
  controller : TestController,
  id : String,
  label : String,
  uri : @v.JsValue,
) -> TestItem =
  #| (controller, id, label, uri) =>
  #|   controller.createTestItem(
  #|     id,
  #|     label,
  #|     uri === undefined || uri === null ? undefined : uri
  #|   )

///|
extern "js" fn tests_controller_add_root_item_ffi(
  controller : TestController,
  item : TestItem,
) -> Unit =
  #| (controller, item) => controller.items.add(item)

///|
extern "js" fn tests_controller_remove_root_item_ffi(
  controller : TestController,
  item_id : String,
) -> Unit =
  #| (controller, itemId) => controller.items.delete(itemId)

///|
extern "js" fn tests_controller_root_items_size_ffi(
  controller : TestController,
) -> Int =
  #| (controller) => controller.items.size
