///|
/// MoonBit port of `codelens-sample`.
priv struct CodelensState {
  mut disposables : Array[&@vscode.Disposable]
}

let codelens_state : CodelensState = { disposables: [] }

fn code_lens_enabled() -> Bool {
  @workspace.get_configuration(
    section="codelens-sample",
  ).get_bool_or("enableCodeLens", true)
}

priv struct CodelensProvider {
  mut code_lenses : Array[@vscode.CodeLens]
  regex_pattern : String
  on_did_change_code_lenses_emitter : @vscode.EventEmitter[Unit]
  on_did_change_code_lenses_event : @vscode.Event[Unit]
}

fn CodelensProvider::new() -> CodelensProvider {
  let emitter : @vscode.EventEmitter[Unit] = @vscode.EventEmitter::new()
  let provider = CodelensProvider::{
    code_lenses: [],
    regex_pattern: "(.+)",
    on_did_change_code_lenses_emitter: emitter,
    on_did_change_code_lenses_event: emitter.event(),
  }
  let _ = @workspace.on_did_change_configuration().subscribe(_ =>
    provider.on_did_change_code_lenses_emitter.fire(()))
  provider
}

///|
impl @vscode.CodeLensProvider for CodelensProvider with on_did_change_code_lenses(
  self,
) {
  Some(self.on_did_change_code_lenses_event)
}

///|
impl @vscode.CodeLensProvider for CodelensProvider with provide_code_lenses(
  self,
  document,
  _token,
) {
  if !code_lens_enabled() {
    return Some([])
  }

  self.code_lenses = []

  for line_number in 0..<document.line_count() {
    let line = document.line_at_line(line_number)
    if line.text.length() == 0 {
      continue
    }

    let position = @vscode.Position::new(line.lineNumber, 0)
    match document.get_word_range_at_position(
      position,
      regex=@vscode.RegExp::new(self.regex_pattern, flags="g"),
    ) {
      Some(range) => self.code_lenses.push(@vscode.CodeLens::new(range))
      None => ()
    }
  }

  Some(self.code_lenses)
}

///|
impl @vscode.CodeLensProvider for CodelensProvider with resolve_code_lens(
  _self,
  code_lens,
  _token,
) {
  if code_lens_enabled() {
    code_lens.set_command(@vscode.Command::new(
        "Codelens provided by sample extension",
        "codelens-sample.codelensAction",
        tooltip="Tooltip provided by sample extension",
        arguments=[
          @vscode.Any::from("Argument 1"),
          @vscode.Any::from(false),
        ],
      ))
    Some(code_lens)
  } else {
    None
  }
}

pub fn activate(_context : @vscode.ExtensionContext) -> Unit {
  let codelens_provider = CodelensProvider::new()

  let _ = @languages.register_code_lens_provider(
    @vscode.DocumentSelector::Language("*"),
    codelens_provider,
  )

  let _ = @commands.register_command_async(
    "codelens-sample.enableCodeLens",
    async fn(_args) {
      @workspace.get_configuration(section="codelens-sample").update(
        "enableCodeLens",
        value=@vscode.Any::from(true),
        target=@vscode.ConfigurationTargetValue::BoolValue(true),
      )
    },
  )

  let _ = @commands.register_command_async(
    "codelens-sample.disableCodeLens",
    async fn(_args) {
      @workspace.get_configuration(section="codelens-sample").update(
        "enableCodeLens",
        value=@vscode.Any::from(false),
        target=@vscode.ConfigurationTargetValue::BoolValue(true),
      )
    },
  )

  let _ = @commands.register_command_async(
    "codelens-sample.codelensAction",
    async fn(args) {
      let value : String = match args.get(0) {
        Some(actual) => actual
        None => "undefined"
      }
      let _ = @window.show_information_message(
        "CodeLens action clicked with args=\{value}",
      )
    },
  )
}

pub fn deactivate() -> Unit {
  for disposable in codelens_state.disposables {
    disposable.dispose()
  }
  codelens_state.disposables = []
}
