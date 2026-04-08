///|
/// Workspace edit metadata helpers.

///|
pub fn WorkspaceEditMetadata::new(
  is_refactoring? : Bool,
) -> WorkspaceEditMetadata {
  WorkspaceEditMetadata::{ is_refactoring, }
}

///|
/// Signal to the editor that this edit is a refactoring.
