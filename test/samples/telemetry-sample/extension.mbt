///|
/// MoonBit port of `telemetry-sample`.
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  let logger = @window.create_log_output_channel("Telemetry Sample")

  let event_command = @commands.register_command_async(
    "extension.logEvent",
    async fn(_args) {
      let telemetry_state = if @env.is_telemetry_enabled() {
        "enabled"
      } else {
        "disabled"
      }
      logger.info("Event: testEvent")
      logger.info("Data: {\"testProp\":\"testValue\",\"telemetry\":\"\{telemetry_state}\"}")
      ignore(@window.show_information_message("Logged telemetry event!"))
    },
  )
  subscriptions.push(event_command)

  let exception_command = @commands.register_command_async(
    "extension.logException",
    async fn(_args) {
      logger.error("Exception: Test")
      logger.error("Data: {\"testProp\":\"testValue\"}")
      ignore(@window.show_information_message("Logged telemetry exception!"))
    },
  )
  subscriptions.push(exception_command)
}

pub fn deactivate() -> Unit {
  ()
}
