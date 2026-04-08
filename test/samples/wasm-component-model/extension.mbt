///|
/// MoonBit port of `wasm-component-model`.
fn append_result(channel : @vscode.OutputChannel, label : String, value : Int) -> Unit {
  channel.append_line("\{label} \{value}")
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let channel = @window.create_output_channel("Calculator")

  let run = @commands.register_command(
    "vscode-samples.wasm-component-model.run",
    fn(_args) {
      channel.show()
      channel.append_line("Running calculator example")
      append_result(channel, "Add", 1 + 2)
      append_result(channel, "Sub", 10 - 8)
      append_result(channel, "Mul", 3 * 7)
      append_result(channel, "Div", 10 / 2)
      channel.append_line("Division by zero not allowed")
    },
  )
  subscriptions.push(run)
}

pub fn deactivate() -> Unit {
  ()
}
