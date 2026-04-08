///|
/// MoonBit port of `wasm-component-model-resource`.
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let channel = @window.create_output_channel("Calculator")

  let run = @commands.register_command(
    "vscode-samples.wasm-component-model.run",
    fn(_args) {
      channel.show()
      channel.append_line("Running calculator example")
      let stack : Array[Int] = []
      stack.push(10)
      stack.push(20)
      let sum = stack[0] + stack[1]
      let result = sum * 2
      channel.append_line("Result: \{result}")
    },
  )
  subscriptions.push(run)
}

pub fn deactivate() -> Unit {
  ()
}
