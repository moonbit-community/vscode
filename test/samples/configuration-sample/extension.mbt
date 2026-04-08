///|
/// MoonBit port of `configuration-sample`.
priv struct ConfigurationSampleState {
  mut status_size_disposable : &@vscode.Disposable?
}

let configuration_state : ConfigurationSampleState = {
  status_size_disposable: None,
}

fn has_workspace_folders() -> Bool {
  match @workspace.workspace_folders() {
    Some(_) => true
    None => false
  }
}

fn active_document() -> @vscode.TextDocument? {
  match @window.active_text_editor() {
    Some(editor) => Some(editor.document())
    None => None
  }
}

fn resource_setting_value(
  scope : @vscode.ConfigurationScope,
) -> @vscode.Any {
  @workspace.get_configuration(
    scope=scope,
  ).get_or(
    "conf.resource.insertEmptyLastLine",
    @vscode.Any::empty_object(),
  )
}

fn resource_setting_matches_document(document : @vscode.TextDocument) -> Bool {
  resource_setting_value(
    @vscode.ConfigurationScope::TextDocumentScope(document),
  ).object_get_bool_or(document.file_name(), false)
}

fn clear_status_size_disposable() -> Unit {
  match configuration_state.status_size_disposable {
    Some(disposable) => {
      disposable.dispose()
      configuration_state.status_size_disposable = None
    }
    None => ()
  }
}

fn update_status_size(document : @vscode.TextDocument) -> Unit {
  clear_status_size_disposable()
  let show_size = @workspace.get_configuration(
    scope=@vscode.ConfigurationScope::TextDocumentScope(document),
  ).get_bool_or("conf.language.showSize", false)
  if show_size {
    configuration_state.status_size_disposable = Some(
      @window.set_status_bar_message("\{document.get_text().length()}"),
    )
  }
}

fn to_json_string(value : String?) -> @vscode.Any? {
  match value {
    None => None
    Some(value) => Some(@vscode.Any::from(value))
  }
}

fn configured_view_to_command(view : String) -> String? {
  match view {
    "explorer" => Some("workbench.view.explorer")
    "search" => Some("workbench.view.search")
    "scm" => Some("workbench.view.scm")
    "debug" => Some("workbench.view.debug")
    "extensions" => Some("workbench.view.extensions")
    _ => None
  }
}

fn window_target_items() -> Array[@vscode.QuickPickItem] {
  [
    @vscode.QuickPickItem::new("User", description="User Settings"),
    @vscode.QuickPickItem::new("Workspace", description="Workspace Settings"),
  ]
}

fn window_target_from_item(
  item : @vscode.QuickPickItem,
) -> @vscode.ConfigurationTarget? {
  match item.label {
    "User" => Some(@vscode.ConfigurationTarget::Global)
    "Workspace" => Some(@vscode.ConfigurationTarget::Workspace)
    _ => None
  }
}

fn resource_target_items() -> Array[@vscode.QuickPickItem] {
  [
    @vscode.QuickPickItem::new("Application", description="User Settings"),
    @vscode.QuickPickItem::new("Workspace", description="Workspace Settings"),
    @vscode.QuickPickItem::new(
      "Workspace Folder",
      description="Workspace Folder Settings",
    ),
  ]
}

fn resource_target_from_item(
  item : @vscode.QuickPickItem,
) -> @vscode.ConfigurationTarget? {
  match item.label {
    "Application" => Some(@vscode.ConfigurationTarget::Global)
    "Workspace" => Some(@vscode.ConfigurationTarget::Workspace)
    "Workspace Folder" => Some(@vscode.ConfigurationTarget::WorkspaceFolder)
    _ => None
  }
}

async fn show_configured_view_on_window_open(
  _ctx : @vscode.ExtensionContext,
) -> Unit {
  match @workspace.get_configuration().get_string_option("conf.view.showOnWindowOpen") {
    None => ()
    Some(configured_view) =>
      match configured_view_to_command(configured_view) {
        None => ()
        Some(command_id) => {
          let _ : @vscode.Any = @commands.execute_command(command_id)
        }
      }
  }
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  subscriptions.push(
    @commands.register_command_async(
      "config.commands.configureViewOnWindowOpen",
      async fn(_args) {
        let value = @window.show_quick_pick_strings(
          ["explorer", "search", "scm", "debug", "extensions"],
          options=@vscode.QuickPickOptions::new(
            place_holder="Select the view to show when opening a window.",
          ),
        )

        if has_workspace_folders() {
          match value {
            None => ()
            Some(value) =>
              match @window.show_quick_pick(
                window_target_items(),
                options=@vscode.QuickPickOptions::new(
                  place_holder="Select the view to show when opening a window.",
                ),
              ) {
                None => ()
                Some(item) =>
                  match window_target_from_item(item) {
                    None => ()
                    Some(target) =>
                      @workspace.get_configuration().update(
                        "conf.view.showOnWindowOpen",
                        value=@vscode.Any::from(value),
                        target=@vscode.ConfigurationTargetValue::Target(
                          target,
                        ),
                      )
                  }
              }
          }
        } else {
          match to_json_string(value) {
            Some(value) =>
              @workspace.get_configuration().update(
                "conf.view.showOnWindowOpen",
                value=value,
                target=@vscode.ConfigurationTargetValue::Target(
                  @vscode.ConfigurationTarget::Global,
                ),
              )
            None =>
              @workspace.get_configuration().update(
                "conf.view.showOnWindowOpen",
                target=@vscode.ConfigurationTargetValue::Target(
                  @vscode.ConfigurationTarget::Global,
                ),
              )
          }
        }
      },
    ),
  )

  subscriptions.push(
    @workspace.on_did_open_text_document().subscribe_async(async fn(document) {
      if resource_setting_matches_document(document) {
        let _ = @window.show_information_message(
          "An empty line will be added to the document \{document.file_name()}",
        )
      }
    }),
  )

  subscriptions.push(
    @commands.register_command_async(
      "config.commands.configureEmptyLastLineCurrentFile",
      async fn(_args) {
        match active_document() {
          None => ()
          Some(current_document) => {
            let configuration = @workspace.get_configuration(
              scope=@vscode.ConfigurationScope::TextDocumentScope(current_document),
            )
            let current_value = configuration.get_or(
              "conf.resource.insertEmptyLastLine",
              @vscode.Any::empty_object(),
            )
            let target = if has_workspace_folders() {
              @vscode.ConfigurationTarget::WorkspaceFolder
            } else {
              @vscode.ConfigurationTarget::Global
            }
            let new_value = current_value.object_with_bool(
              current_document.file_name(),
              true,
            )
            configuration.update(
              "conf.resource.insertEmptyLastLine",
              value=new_value,
              target=@vscode.ConfigurationTargetValue::Target(target),
            )
          }
        }
      },
    ),
  )

  subscriptions.push(
    @commands.register_command_async(
      "config.commands.configureEmptyLastLineFiles",
      async fn(_args) {
        let value = @window.show_input_box(
          options=@vscode.InputBoxOptions::new(
            prompt="Provide glob pattern of files to have empty last line.",
          ),
        )

        if has_workspace_folders() {
          match value {
            None => ()
            Some(value) =>
              match @window.show_quick_pick(
                resource_target_items(),
                options=@vscode.QuickPickOptions::new(
                  place_holder=
                    "Select the target to which this setting should be applied",
                ),
              ) {
                None => ()
                Some(item) =>
                  match resource_target_from_item(item) {
                    None => ()
                    Some(target) =>
                      if target == @vscode.ConfigurationTarget::WorkspaceFolder {
                        match @window.show_workspace_folder_pick(
                          options=@vscode.WorkspaceFolderPickOptions::new(
                            place_holder=
                              "Pick Workspace Folder to which this setting should be applied",
                          ),
                        ) {
                          None => ()
                          Some(workspace_folder) => {
                            let configuration = @workspace.get_configuration(
                              scope=@vscode.ConfigurationScope::Uri(
                                workspace_folder.uri(),
                              ),
                            )
                            let current_value = configuration.get_or(
                              "conf.resource.insertEmptyLastLine",
                              @vscode.Any::empty_object(),
                            )
                            let new_value = current_value.object_with_bool(
                              value,
                              true,
                            )
                            configuration.update(
                              "conf.resource.insertEmptyLastLine",
                              value=new_value,
                              target=@vscode.ConfigurationTargetValue::Target(
                                target,
                              ),
                            )
                          }
                        }
                      } else {
                        let configuration = @workspace.get_configuration()
                        let current_value = configuration.get_or(
                          "conf.resource.insertEmptyLastLine",
                          @vscode.Any::empty_object(),
                        )
                        let new_value = current_value.object_with_bool(
                          value,
                          true,
                        )
                        configuration.update(
                          "conf.resource.insertEmptyLastLine",
                          value=new_value,
                          target=@vscode.ConfigurationTargetValue::Target(
                            target,
                          ),
                        )
                      }
                  }
              }
          }
        } else {
          let configuration = @workspace.get_configuration()
          let current_value = configuration.get_or(
            "conf.resource.insertEmptyLastLine",
            @vscode.Any::empty_object(),
          )
          let new_value = match value {
            None => current_value
            Some(value) => current_value.object_with_bool(value, true)
          }
          configuration.update(
            "conf.resource.insertEmptyLastLine",
            value=new_value,
            target=@vscode.ConfigurationTargetValue::Target(
              @vscode.ConfigurationTarget::Global,
            ),
          )
        }
      },
    ),
  )

  subscriptions.push(
    @workspace.on_did_open_text_document().subscribe(fn(document) {
      update_status_size(document)
    }),
  )

  subscriptions.push(
    @commands.register_command_async(
      "config.commands.overrideLanguageValue",
      async fn(_args) {
        let language_id = @window.show_input_box(
          options=@vscode.InputBoxOptions::new(
            place_holder="Enter the language id",
          ),
        )
        match language_id {
          None => ()
          Some(language_id) =>
            @workspace.get_configuration(
              scope=@vscode.ConfigurationScope::LanguageId(language_id),
            ).update(
              "conf.language.showSize",
              value=@vscode.Any::from(true),
              target=@vscode.ConfigurationTargetValue::BoolValue(false),
              override_in_language=true,
            )
        }
      },
    ),
  )

  subscriptions.push(
    @workspace.on_did_change_configuration().subscribe_async(async fn(event) {
      if event.affects_configuration("conf.resource.insertEmptyLastLine") {
        match active_document() {
          None => ()
          Some(current_document) =>
            if resource_setting_matches_document(current_document) {
              let _ = @window.show_information_message(
                "An empty line will be added to the document \{current_document.file_name()}",
              )
            }
        }
      }

      match active_document() {
        None => ()
        Some(current_document) => {
          let _ = event.affects_configuration(
            "conf.language.showSize",
            scope=@vscode.ConfigurationScope::TextDocumentScope(current_document),
          )
        }
      }

      let _ = event.affects_configuration(
        "conf.language.showSize",
        scope=@vscode.ConfigurationScope::LanguageId("typescript"),
      )
    }),
  )

  @vscode.activate_async(ctx, show_configured_view_on_window_open)
}

pub fn deactivate() -> Unit {
  clear_status_size_disposable()
}
