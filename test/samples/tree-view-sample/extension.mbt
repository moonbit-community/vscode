///|
/// MoonBit port of `tree-view-sample`.
fn node_dependency_tree_item(element : String) -> @vscode.TreeItem {
  let item = @vscode.TreeItem::from_label(
    @vscode.TreeItemLabelValue::Text(element),
    collapsible_state=@vscode.TreeItemCollapsibleState::None,
  )
  item.set_command(@vscode.Command::new(
      "extension.openPackageOnNpm",
      "Open package on npm",
      arguments=[@vscode.Any::from(element)],
    ))
  item
}

fn node_dependency_children(element : String?) -> Array[String]? {
  match element {
    None => Some(["moonbitlang/core", "moonbitlang/async"])
    Some(_) => Some([])
  }
}

fn json_outline_tree_item(element : String) -> @vscode.TreeItem {
  @vscode.TreeItem::from_label(
    @vscode.TreeItemLabelValue::Text(element),
    collapsible_state=@vscode.TreeItemCollapsibleState::None,
  )
}

fn json_outline_children(element : String?) -> Array[String]? {
  match element {
    None => Some(["root", "settings", "items"])
    Some(_) => Some([])
  }
}

fn first_string_arg(args : @commands.CommandArgs) -> String? {
  args.get(0)
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()

  let node_change : @vscode.EventEmitter[String?] = @vscode.EventEmitter::new()
  let json_change : @vscode.EventEmitter[String?] = @vscode.EventEmitter::new()

  let node_get_item : async (String) -> @vscode.TreeItem = fn(element) {
    node_dependency_tree_item(element)
  }
  let node_get_children : async (String?) -> Array[String]? = fn(element) {
    node_dependency_children(element)
  }
  subscriptions.push(
    @window.register_tree_data_provider(
      "nodeDependencies",
      node_get_item,
      node_get_children,
      on_did_change_tree_data=node_change.event(),
    ),
  )

  let json_get_item : async (String) -> @vscode.TreeItem = fn(element) {
    json_outline_tree_item(element)
  }
  let json_get_children : async (String?) -> Array[String]? = fn(element) {
    json_outline_children(element)
  }
  subscriptions.push(
    @window.register_tree_data_provider(
      "jsonOutline",
      json_get_item,
      json_get_children,
      on_did_change_tree_data=json_change.event(),
    ),
  )

  subscriptions.push(
    @commands.register_command(
      "nodeDependencies.refreshEntry",
      fn(_args) {
        node_change.fire(None)
      },
    ),
  )

  subscriptions.push(
    @commands.register_command(
      "jsonOutline.refresh",
      fn(_args) {
        json_change.fire(None)
      },
    ),
  )

  subscriptions.push(
    @commands.register_command(
      "jsonOutline.refreshNode",
      fn(_args) {
        json_change.fire(None)
      },
    ),
  )

  subscriptions.push(
    @commands.register_command_async(
      "extension.openPackageOnNpm",
      async fn(args) {
        let package_name = match first_string_arg(args) {
          None => "moonbitlang/core"
          Some(value) => value
        }
        ignore(
          @env.open_external(
            @vscode.Uri::parse("https://www.npmjs.com/package/\{package_name}"),
          ),
        )
      },
    ),
  )

  let info_commands : Array[String] = [
    "nodeDependencies.addEntry",
    "nodeDependencies.editEntry",
    "nodeDependencies.deleteEntry",
    "ftpExplorer.refresh",
    "ftpExplorer.openFtpResource",
    "ftpExplorer.revealResource",
    "jsonOutline.renameNode",
    "fileExplorer.refreshFile",
    "fileExplorer.openFile",
    "testView.reveal",
    "testView.changeTitle",
  ]

  for command_id in info_commands {
    let disposable = @commands.register_command_async(
      command_id,
      async fn(_args) {
        ignore(@window.show_information_message("\{command_id} executed."))
      },
    )
    subscriptions.push(disposable)
  }
}

pub fn deactivate() -> Unit {
  ()
}
