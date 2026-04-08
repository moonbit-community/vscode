///|
/// MoonBit port of `call-hierarchy-sample`.
priv struct FoodRelation {
  subject : String
  verb : String
  object : String
  range : @vscode.Range
  subject_range : @vscode.Range
  verb_range : @vscode.Range
  object_range : @vscode.Range
}

fn FoodRelation::get_range_of(
  self : FoodRelation,
  word : String,
) -> @vscode.Range {
  let needle = word.to_lower()
  if needle == self.subject {
    self.subject_range
  } else if needle == self.verb {
    self.verb_range
  } else if needle == self.object {
    self.object_range
  } else {
    self.range
  }
}

priv struct FoodPyramid {
  relations : Array[FoodRelation]
}

fn FoodPyramid::new() -> FoodPyramid {
  { relations: [], }
}

fn FoodPyramid::add_relation(
  self : FoodPyramid,
  relation : FoodRelation,
) -> Unit {
  self.relations.push(relation)
}

fn FoodPyramid::get_relation_at(
  self : FoodPyramid,
  word_range : @vscode.Range,
) -> FoodRelation? {
  for relation in self.relations {
    if relation.range.contains_range(word_range) {
      return Some(relation)
    }
  }
  None
}

fn FoodPyramid::is_verb(self : FoodPyramid, name : String) -> Bool {
  let needle = name.to_lower()
  for relation in self.relations {
    if relation.verb == needle {
      return true
    }
  }
  false
}

fn FoodPyramid::is_noun(self : FoodPyramid, name : String) -> Bool {
  let needle = name.to_lower()
  for relation in self.relations {
    if relation.subject == needle || relation.object == needle {
      return true
    }
  }
  false
}

fn FoodPyramid::get_verb_relations(
  self : FoodPyramid,
  verb : String,
) -> Array[FoodRelation] {
  let needle = verb.to_lower()
  let relations : Array[FoodRelation] = []
  for relation in self.relations {
    if relation.verb == needle {
      relations.push(relation)
    }
  }
  relations
}

fn FoodPyramid::get_subject_relations(
  self : FoodPyramid,
  subject : String,
) -> Array[FoodRelation] {
  let needle = subject.to_lower()
  let relations : Array[FoodRelation] = []
  for relation in self.relations {
    if relation.subject == needle {
      relations.push(relation)
    }
  }
  relations
}

fn FoodPyramid::get_object_relations(
  self : FoodPyramid,
  object : String,
) -> Array[FoodRelation] {
  let needle = object.to_lower()
  let relations : Array[FoodRelation] = []
  for relation in self.relations {
    if relation.object == needle {
      relations.push(relation)
    }
  }
  relations
}

priv struct WordSpan {
  text : String
  start : Int
  end_ : Int
}

fn is_word_char(char : Char) -> Bool {
  char == '_' || char.is_ascii_alphabetic() || char.is_ascii_digit()
}

fn collect_word_spans(text : String) -> Array[WordSpan] {
  let words : Array[WordSpan] = []
  let mut in_word = false
  let mut word_start = 0
  let mut offset = 0

  for char in text.iter() {
    if is_word_char(char) {
      if !in_word {
        in_word = true
        word_start = offset
      }
    } else if in_word {
      words.push({
        text: text.view(start_offset=word_start, end_offset=offset).to_string(),
        start: word_start,
        end_: offset,
      })
      in_word = false
    }
    offset = offset + char.utf16_len()
  }

  if in_word {
    words.push({
      text: text.view(start_offset=word_start, end_offset=offset).to_string(),
      start: word_start,
      end_: offset,
    })
  }

  words
}

fn is_whitespace_gap(text : String, start : Int, end_ : Int) -> Bool {
  if end_ <= start {
    return false
  }
  for char in text.view(start_offset=start, end_offset=end_).iter() {
    if !char.is_whitespace() {
      return false
    }
  }
  true
}

fn has_single_tail_char(text : String, start : Int) -> Bool {
  text.view(start_offset=start).iter().count() == 1
}

fn parse_line_relation(
  line : @vscode.TextLine,
) -> FoodRelation? {
  let text = line.text
  let words = collect_word_spans(text)

  if words.length() != 3 {
    return None
  }

  let subject = words[0]
  let verb = words[1]
  let object = words[2]

  if subject.start != 0 {
    return None
  }
  if !is_whitespace_gap(text, subject.end_, verb.start) {
    return None
  }
  if !is_whitespace_gap(text, verb.end_, object.start) {
    return None
  }
  if !has_single_tail_char(text, object.end_) {
    return None
  }

  let line_number = line.lineNumber
  Some({
    subject: subject.text.to_lower(),
    verb: verb.text.to_lower(),
    object: object.text.to_lower(),
    range: line.range,
    subject_range: @vscode.Range::new(
      @vscode.Position::new(line_number, subject.start),
      @vscode.Position::new(line_number, subject.end_),
    ),
    verb_range: @vscode.Range::new(
      @vscode.Position::new(line_number, verb.start),
      @vscode.Position::new(line_number, verb.end_),
    ),
    object_range: @vscode.Range::new(
      @vscode.Position::new(line_number, object.start),
      @vscode.Position::new(line_number, object.end_),
    ),
  })
}

fn parse_food_pyramid(document : @vscode.TextDocument) -> FoodPyramid {
  let model = FoodPyramid::new()
  for line_number in 0..<document.line_count() {
    match parse_line_relation(document.line_at_line(line_number)) {
      None => ()
      Some(relation) => model.add_relation(relation)
    }
  }
  model
}

fn create_call_hierarchy_item(
  word : String,
  type_ : String,
  document : @vscode.TextDocument,
  range : @vscode.Range,
) -> @vscode.CallHierarchyItem {
  @vscode.CallHierarchyItem::new(
    @vscode.SymbolKind::Object,
    word,
    "(\{type_})",
    document.uri(),
    range,
    range,
  )
}

fn has_string(values : Array[String], value : String) -> Bool {
  for item in values {
    if item == value {
      return true
    }
  }
  false
}

priv struct FoodPyramidHierarchyProvider {}

impl @vscode.CallHierarchyProvider for FoodPyramidHierarchyProvider with prepare_call_hierarchy(
  _self,
  document,
  position,
  _token,
) {
  match document.get_word_range_at_position(position) {
    None => None
    Some(range) =>
      Some([
        create_call_hierarchy_item(
          document.get_text_range(range),
          "",
          document,
          range,
        ),
      ])
  }
}

impl @vscode.CallHierarchyProvider for FoodPyramidHierarchyProvider with provide_call_hierarchy_outgoing_calls(
  _self,
  item,
  _token,
) {
  let document = @workspace.open_text_document_uri(item.uri())
  let model = parse_food_pyramid(document)
  let origin_relation = model.get_relation_at(item.range())

  let outgoing_call_items : Array[@vscode.CallHierarchyOutgoingCall] = []

  if model.is_verb(item.name()) {
    match origin_relation {
      None => ()
      Some(origin_relation) => {
        for relation in model.get_verb_relations(item.name()) {
          if relation.subject == origin_relation.subject {
            let outgoing_call_range = relation.get_range_of(relation.object)
            let noun_item = create_call_hierarchy_item(
              relation.object,
              "noun",
              document,
              outgoing_call_range,
            )
            outgoing_call_items.push(
              @vscode.CallHierarchyOutgoingCall::new(
                noun_item,
                [outgoing_call_range],
              ),
            )
          }
        }
      }
    }
  } else if model.is_noun(item.name()) {
    let subject_relations = model.get_subject_relations(item.name())
    let verbs : Array[String] = []
    for relation in subject_relations {
      if !has_string(verbs, relation.verb) {
        verbs.push(relation.verb)
      }
    }

    for verb in verbs {
      let outgoing_call_ranges : Array[@vscode.Range] = []
      for relation in subject_relations {
        if relation.verb == verb {
          outgoing_call_ranges.push(relation.get_range_of(verb))
        }
      }
      if outgoing_call_ranges.length() > 0 {
        let verb_item = create_call_hierarchy_item(
          verb,
          "verb",
          document,
          outgoing_call_ranges[0],
        )
        outgoing_call_items.push(
          @vscode.CallHierarchyOutgoingCall::new(
            verb_item,
            outgoing_call_ranges,
          ),
        )
      }
    }
  }

  Some(outgoing_call_items)
}

impl @vscode.CallHierarchyProvider for FoodPyramidHierarchyProvider with provide_call_hierarchy_incoming_calls(
  _self,
  item,
  _token,
) {
  let document = @workspace.open_text_document_uri(item.uri())
  let model = parse_food_pyramid(document)
  let origin_relation = model.get_relation_at(item.range())

  let incoming_call_items : Array[@vscode.CallHierarchyIncomingCall] = []

  if model.is_verb(item.name()) {
    match origin_relation {
      None => ()
      Some(origin_relation) => {
        for relation in model.get_verb_relations(item.name()) {
          if relation.object == origin_relation.object {
            let incoming_call_range = relation.get_range_of(relation.subject)
            let noun_item = create_call_hierarchy_item(
              relation.subject,
              "noun",
              document,
              incoming_call_range,
            )
            incoming_call_items.push(
              @vscode.CallHierarchyIncomingCall::new(
                noun_item,
                [incoming_call_range],
              ),
            )
          }
        }
      }
    }
  } else if model.is_noun(item.name()) {
    let object_relations = model.get_object_relations(item.name())
    let verbs : Array[String] = []
    for relation in object_relations {
      if !has_string(verbs, relation.verb) {
        verbs.push(relation.verb)
      }
    }

    for verb in verbs {
      let incoming_call_ranges : Array[@vscode.Range] = []
      for relation in object_relations {
        if relation.verb == verb {
          incoming_call_ranges.push(relation.get_range_of(verb))
        }
      }
      if incoming_call_ranges.length() > 0 {
        let verb_item = create_call_hierarchy_item(
          verb,
          "verb-inverted",
          document,
          incoming_call_ranges[0],
        )
        incoming_call_items.push(
          @vscode.CallHierarchyIncomingCall::new(
            verb_item,
            incoming_call_ranges,
          ),
        )
      }
    }
  }

  Some(incoming_call_items)
}

async fn show_sample_text(ctx : @vscode.ExtensionContext) -> Unit {
  let sample_text_encoded = @workspace.fs().read_file(
    @vscode.Uri::file(ctx.as_absolute_path("sample.txt")),
  )
  let sample_text = @workspace.decode(sample_text_encoded)
  let doc = @workspace.open_text_document_untitled(
    language="plaintext",
    content=sample_text,
  )
  ignore(@window.show_text_document(doc))
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let subscriptions = ctx.subscriptions()
  subscriptions.push(
    @languages.register_call_hierarchy_provider(
      @vscode.DocumentSelector::Language("plaintext"),
      FoodPyramidHierarchyProvider::{},
    ),
  )

  @vscode.activate_async(ctx, show_sample_text)
}

pub fn deactivate() -> Unit {
  ()
}
