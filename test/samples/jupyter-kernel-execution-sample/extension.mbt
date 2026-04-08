///|
/// MoonBit port of `jupyter-kernel-execution-sample`.
let code_snippets : Array[String] = [
  "Print Hello World",
  "Stream Output",
  "Display Markdown",
  "Display HTML",
  "Print to StdErr",
  "Throw an Error",
]

async fn ensure_jupyter_extension() -> Bool {
  let extension : @vscode.Extension[@vscode.Any]? = @extensions.get_extension(
    "ms-toolsai.jupyter",
  )
  match extension {
    None => {
      @window.show_error_message("Jupyter extension not installed")
      false
    }
    Some(extension) => {
      if !extension.is_active() {
        ignore(extension.activate())
      }
      true
    }
  }
}

async fn run_kernel_sample() -> Unit {
  if !ensure_jupyter_extension() {
    return
  }

  let selection = @window.show_quick_pick_strings(
    code_snippets,
    options=@vscode.QuickPickOptions::new(
      place_holder="Select code to execute against the kernel",
    ),
  )

  match selection {
    None => ()
    Some(label) => {
      let _ : Unit = @commands.execute_command("notebook.selectKernel")
      @window.show_information_message(
        "Selected \{label}. Choose a kernel and run a cell in your notebook.",
      )
    }
  }
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  subscriptions.push(
    @commands.register_command_async(
      "jupyterKernelExecution.listKernels",
      async fn(_args) {
        run_kernel_sample()
      },
    ),
  )
}

pub fn deactivate() -> Unit {
  ()
}
