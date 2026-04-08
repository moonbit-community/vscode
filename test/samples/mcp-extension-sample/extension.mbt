///|
/// MoonBit port of `mcp-extension-sample`.
priv struct GistState {
  mut gists : Array[String]
}

let gist_state : GistState = { gists: [] }

fn remove_gist(value : String) -> Unit {
  let filtered : Array[String] = []
  for gist in gist_state.gists {
    if gist != value {
      filtered.push(gist)
    }
  }
  gist_state.gists = filtered
}

fn definitions_from_gists() -> Array[@lm.McpServerDefinition] {
  let definitions : Array[@lm.McpServerDefinition] = []
  for gist in gist_state.gists {
    let server = @lm.McpStdioServerDefinition::new(
      "Gist \{gist}",
      "node",
      args=["-e", "console.log('mcp gist sample')"],
      env_entries=[("GIST_URL", Some(@vscode.Any::from(gist)))],
    )
    definitions.push(@lm.McpServerDefinition::from_stdio(server))
  }
  definitions
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let global_state = ctx.global_state()
  gist_state.gists = global_state.get_or("gists", [])

  let did_change : @vscode.EventEmitter[Unit] = @vscode.EventEmitter::new()

  let add = @commands.register_command_async(
    "mcp-extension-sample.addGist",
    async fn(_args) {
      let gist = @window.show_input_box(
        options=@vscode.InputBoxOptions::new(prompt="Enter Gist URL"),
      )
      match gist {
        None => ()
        Some(gist) => {
          gist_state.gists.push(gist)
          global_state.update("gists", gist_state.gists)
          ignore(@window.show_information_message("Gist added: \{gist}"))
          did_change.fire(())
        }
      }
    },
  )
  subscriptions.push(add)

  let remove = @commands.register_command_async(
    "mcp-extension-sample.removeGist",
    async fn(_args) {
      let gist = @window.show_quick_pick_strings(
        gist_state.gists,
        options=@vscode.QuickPickOptions::new(place_holder="Select Gist to remove"),
      )
      match gist {
        None => ()
        Some(gist) => {
          remove_gist(gist)
          global_state.update("gists", gist_state.gists)
          ignore(@window.show_information_message("Gist removed: \{gist}"))
          did_change.fire(())
        }
      }
    },
  )
  subscriptions.push(remove)

  let provide_definitions : async (@vscode.CancellationToken) -> Array[
    @lm.McpServerDefinition,
  ]? = fn(_token) {
    Some(definitions_from_gists())
  }

  let provider = @lm.McpServerDefinitionProvider::new(
    provide_definitions,
    on_did_change_mcp_server_definitions=did_change.event(),
  )
  subscriptions.push(
    @lm.register_mcp_server_definition_provider("exampleGist", provider),
  )
}

pub fn deactivate() -> Unit {
  ()
}
