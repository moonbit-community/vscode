///|
/// Workspace folder input helpers.

///|
pub fn WorkspaceFolderInput::new(
  uri : Uri,
  name? : String,
) -> WorkspaceFolderInput {
  WorkspaceFolderInput::{ uri, name }
}

///|

///|
