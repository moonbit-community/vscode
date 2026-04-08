///|
/// MoonBit port of `quickinput-sample`.
async fn run_show_quick_pick() -> Unit {
  let selected = @window.show_quick_pick_strings(
    ["Great", "Good", "Fair", "Poor"],
    options=@vscode.QuickPickOptions::new(
      place_holder="How was your day?",
      ignore_focus_out=true,
    ),
  )
  match selected {
    None => ()
    Some(value) =>
      ignore(@window.show_information_message("QuickPick selected: \{value}"))
  }
}

async fn run_show_input_box() -> Unit {
  let value = @window.show_input_box(
    options=@vscode.InputBoxOptions::new(
      prompt="Tell me something interesting",
      place_holder="Type here",
      ignore_focus_out=true,
    ),
  )
  match value {
    None => ()
    Some(text) => ignore(@window.show_information_message("Input: \{text}"))
  }
}

async fn run_multi_step_input() -> Unit {
  let first = @window.show_input_box(
    options=@vscode.InputBoxOptions::new(prompt="Name your project"),
  )
  match first {
    None => ()
    Some(project) => {
      let second = @window.show_quick_pick_strings(
        ["TypeScript", "MoonBit", "Rust"],
        options=@vscode.QuickPickOptions::new(
          place_holder="Choose a language",
        ),
      )
      match second {
        None => ()
        Some(language) =>
          ignore(
            @window.show_information_message(
              "Multi-step result: \{project} (\{language})",
            ),
          )
      }
    }
  }
}

async fn run_quick_open() -> Unit {
  let _ : @vscode.Any = @commands.execute_command(
    "workbench.action.quickOpen",
    args=@commands.command_args(),
  )
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let picker_command = @commands.register_command_async(
    "samples.quickInput",
    async fn(_args) {
      let selected = @window.show_quick_pick_strings(
        ["showQuickPick", "showInputBox", "multiStepInput", "quickOpen"],
        options=@vscode.QuickPickOptions::new(place_holder="QuickInput Sample"),
      )
      match selected {
        None => ()
        Some("showQuickPick") => run_show_quick_pick()
        Some("showInputBox") => run_show_input_box()
        Some("multiStepInput") => run_multi_step_input()
        Some("quickOpen") => run_quick_open()
        Some(_) => ()
      }
    },
  )
  ctx.subscriptions().push(picker_command)
}

pub fn deactivate() -> Unit {
  ()
}
