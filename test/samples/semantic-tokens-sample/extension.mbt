///|
/// MoonBit port of `semantic-tokens-sample`.
priv struct ParsedToken {
  line : Int
  start_character : Int
  length : Int
  token_type : String
  token_modifiers : Array[String]
}

fn semantic_legend() -> @vscode.SemanticTokensLegend {
  @vscode.SemanticTokensLegend::new(
    [
      "comment",
      "string",
      "keyword",
      "number",
      "regexp",
      "operator",
      "namespace",
      "type",
      "struct",
      "class",
      "interface",
      "enum",
      "typeParameter",
      "function",
      "method",
      "decorator",
      "macro",
      "variable",
      "parameter",
      "property",
      "label",
    ],
    token_modifiers=[
      "declaration",
      "documentation",
      "readonly",
      "static",
      "abstract",
      "deprecated",
      "modification",
      "async",
    ],
  )
}

fn trim_trailing_cr(value : String) -> String {
  if value.has_suffix("\r") {
    value.unsafe_substring(start=0, end=value.length() - 1)
  } else {
    value
  }
}

fn parse_tokens(text : String) -> Array[ParsedToken] {
  let parsed : Array[ParsedToken] = []
  let mut line_no = 0
  for line_part in text.split("\n") {
    let line = trim_trailing_cr(line_part.to_string())
    let mut current_offset = 0
    let mut done = false
    while !done {
      if current_offset >= line.length() {
        done = true
      } else {
        let rest = line.unsafe_substring(start=current_offset, end=line.length())
        match rest.find("[") {
          None => done = true
          Some(open_rel) => {
            let open_abs = current_offset + open_rel
            let after_open_start = open_abs + 1
            if after_open_start >= line.length() {
              done = true
            } else {
              let after_open = line.unsafe_substring(
                start=after_open_start,
                end=line.length(),
              )
              match after_open.find("]") {
                None => done = true
                Some(close_rel) => {
                  let token_text = after_open.unsafe_substring(
                    start=0,
                    end=close_rel,
                  )
                  let mut token_type = ""
                  let token_modifiers : Array[String] = []
                  let mut first = true
                  for part in token_text.split(".") {
                    if first {
                      token_type = part.to_string()
                      first = false
                    } else {
                      token_modifiers.push(part.to_string())
                    }
                  }
                  parsed.push({
                    line: line_no,
                    start_character: open_abs + 1,
                    length: close_rel,
                    token_type,
                    token_modifiers,
                  })
                  current_offset = after_open_start + close_rel + 1
                }
              }
            }
          }
        }
      }
    }
    line_no = line_no + 1
  }
  parsed
}

fn encode_token_type(token_type : String) -> Int {
  match token_type {
    "comment" => 0
    "string" => 1
    "keyword" => 2
    "number" => 3
    "regexp" => 4
    "operator" => 5
    "namespace" => 6
    "type" => 7
    "struct" => 8
    "class" => 9
    "interface" => 10
    "enum" => 11
    "typeParameter" => 12
    "function" => 13
    "method" => 14
    "decorator" => 15
    "macro" => 16
    "variable" => 17
    "parameter" => 18
    "property" => 19
    "label" => 20
    "notInLegend" => 23
    _ => 0
  }
}

fn encode_token_modifier_bit(token_modifier : String) -> Int? {
  match token_modifier {
    "declaration" => Some(0)
    "documentation" => Some(1)
    "readonly" => Some(2)
    "static" => Some(3)
    "abstract" => Some(4)
    "deprecated" => Some(5)
    "modification" => Some(6)
    "async" => Some(7)
    _ => None
  }
}

fn encode_token_modifiers(token_modifiers : Array[String]) -> Int {
  let mut result = 0
  for token_modifier in token_modifiers {
    match encode_token_modifier_bit(token_modifier) {
      Some(bit) => result = result | (1 << bit)
      None =>
        if token_modifier == "notInLegend" {
          result = result | (1 << 10)
        }
    }
  }
  result
}

priv struct DocumentSemanticTokensProvider {
  legend : @vscode.SemanticTokensLegend
}

impl @vscode.DocumentSemanticTokensProvider for DocumentSemanticTokensProvider with provide_document_semantic_tokens(
  self,
  document,
  _token,
) {
  let builder = @vscode.SemanticTokensBuilder::new(legend=self.legend)
  let tokens = parse_tokens(document.get_text())
  for token in tokens {
    builder.push_raw(
      token.line,
      token.start_character,
      token.length,
      encode_token_type(token.token_type),
      token_modifiers=encode_token_modifiers(token.token_modifiers),
    )
  }
  builder.build()
}

impl @vscode.DocumentSemanticTokensProvider for DocumentSemanticTokensProvider with provide_document_semantic_tokens_edits(
  _self,
) {
  None
}

impl @vscode.DocumentSemanticTokensProvider for DocumentSemanticTokensProvider with on_did_change_semantic_tokens(
  _self,
) {
  None
}

pub fn activate(context : @vscode.ExtensionContext) -> Unit {
  let subscriptions = context.subscriptions()
  let legend = semantic_legend()
  let provider : DocumentSemanticTokensProvider = { legend, }
  subscriptions.push(
    @languages.register_document_semantic_tokens_provider(
      @vscode.DocumentSelector::Language("semanticLanguage"),
      provider,
      legend,
    ),
  )
}

pub fn deactivate() -> Unit {
  ()
}
