///|
/// MoonBit port of `contentprovider-sample`.
let references_scheme = "references"

priv struct ReferencesDocumentState {
  key : String
  uri : @vscode.Uri
  lines : Array[String]
  links : Array[@vscode.DocumentLink]
}

priv struct ContentProviderState {
  mut docs : Array[ReferencesDocumentState]
  mut seq : Int
  mut emitter : @vscode.EventEmitter[@vscode.Uri]?
  mut close_listener : &@vscode.Disposable?
  mut editor_decoration : @vscode.TextEditorDecorationType?
}

let content_provider_state : ContentProviderState = {
  docs: [],
  seq: 0,
  emitter: None,
  close_listener: None,
  editor_decoration: None,
}

fn copy_lines(values : Array[String]) -> Array[String] {
  let result : Array[String] = []
  for value in values {
    result.push(value)
  }
  result
}

fn copy_links(values : Array[@vscode.DocumentLink]) -> Array[@vscode.DocumentLink] {
  let result : Array[@vscode.DocumentLink] = []
  for value in values {
    result.push(value)
  }
  result
}

fn get_doc(key : String) -> ReferencesDocumentState? {
  for doc in content_provider_state.docs {
    if doc.key == key {
      return Some(doc)
    }
  }
  None
}

fn put_doc(doc : ReferencesDocumentState) -> Unit {
  let next : Array[ReferencesDocumentState] = []
  let mut replaced = false
  for existing in content_provider_state.docs {
    if existing.key == doc.key {
      next.push(doc)
      replaced = true
    } else {
      next.push(existing)
    }
  }
  if !replaced {
    next.push(doc)
  }
  content_provider_state.docs = next
}

fn update_doc(
  key : String,
  updater : (ReferencesDocumentState) -> ReferencesDocumentState,
) -> Unit {
  match get_doc(key) {
    None => ()
    Some(doc) => put_doc(updater(doc))
  }
}

fn remove_doc(key : String) -> Unit {
  let next : Array[ReferencesDocumentState] = []
  for existing in content_provider_state.docs {
    if existing.key != key {
      next.push(existing)
    }
  }
  content_provider_state.docs = next
}

fn doc_value(uri : @vscode.Uri) -> String {
  match get_doc(uri.to_string()) {
    None => ""
    Some(doc) => doc.lines.join("\n")
  }
}

fn doc_links(uri : @vscode.Uri) -> Array[@vscode.DocumentLink]? {
  match get_doc(uri.to_string()) {
    None => None
    Some(doc) => Some(doc.links)
  }
}

fn doc_line_count(key : String) -> Int {
  match get_doc(key) {
    None => 0
    Some(doc) => doc.lines.length()
  }
}

fn append_doc_line(key : String, line : String) -> Unit {
  update_doc(
    key,
    fn(doc) {
      let lines = copy_lines(doc.lines)
      lines.push(line)
      {
        key: doc.key,
        uri: doc.uri,
        lines,
        links: doc.links,
      }
    },
  )
}

fn append_doc_link(key : String, link : @vscode.DocumentLink) -> Unit {
  update_doc(
    key,
    fn(doc) {
      let links = copy_links(doc.links)
      links.push(link)
      {
        key: doc.key,
        uri: doc.uri,
        lines: doc.lines,
        links,
      }
    },
  )
}

fn fire_doc_change(uri : @vscode.Uri) -> Unit {
  match content_provider_state.emitter {
    None => ()
    Some(emitter) => emitter.fire(uri)
  }
}

fn compare_locations(a : @vscode.Location, b : @vscode.Location) -> Int {
  let a_uri = a.uri().to_string()
  let b_uri = b.uri().to_string()
  if a_uri < b_uri {
    -1
  } else if a_uri > b_uri {
    1
  } else {
    a.range().start().compare_to(b.range().start())
  }
}

fn sort_locations(
  locations : Array[@vscode.Location],
) -> Array[@vscode.Location] {
  let mut sorted : Array[@vscode.Location] = []
  for location in locations {
    let mut inserted = false
    let next : Array[@vscode.Location] = []
    for existing in sorted {
      if !inserted && compare_locations(location, existing) < 0 {
        next.push(location)
        inserted = true
      }
      next.push(existing)
    }
    if !inserted {
      next.push(location)
    }
    sorted = next
  }
  sorted
}

fn rotate_to_target_resource(
  locations : Array[@vscode.Location],
  target : @vscode.Uri,
) -> Array[@vscode.Location] {
  let target_key = target.to_string()
  let mut target_index = 0
  let mut found = false

  for index in 0..<locations.length() {
    if !found && locations[index].uri().to_string() == target_key {
      target_index = index
      found = true
    }
  }

  if !found || target_index == 0 {
    locations
  } else {
    let rotated : Array[@vscode.Location] = []
    for index in target_index..<locations.length() {
      rotated.push(locations[index])
    }
    for index in 0..<target_index {
      rotated.push(locations[index])
    }
    rotated
  }
}

async fn find_references(
  target : @vscode.Uri,
  position : @vscode.Position,
) -> Array[@vscode.Location] {
  let raw : Array[@vscode.Location]? = @commands.execute_command(
    "vscode.executeReferenceProvider",
    args=@commands.command_args2(target, position),
  )
  match raw {
    None => []
    Some(locations) => locations
  }
}

fn context_line(line_number : Int, text : String) -> String {
  if text.length() == 0 {
    "  \{line_number + 1}"
  } else {
    "  \{line_number + 1}  \{text}"
  }
}

fn append_leading(
  doc_key : String,
  document : @vscode.TextDocument,
  line_number : Int,
  previous : @vscode.Range?,
) -> Unit {
  let mut from = 0
  let nearby = line_number - 3
  if nearby > from {
    from = nearby
  }
  match previous {
    None => ()
    Some(previous_range) => {
      let previous_end = previous_range.end().line()
      if previous_end > from {
        from = previous_end
      }
    }
  }

  let start_line = from + 1
  for index in start_line..<line_number {
    append_doc_line(doc_key, context_line(index, document.line_at_line(index).text))
  }
}

fn append_match(
  doc_key : String,
  document : @vscode.TextDocument,
  line_number : Int,
  match_range : @vscode.Range,
  target : @vscode.Uri,
) -> Unit {
  let text = document.line_at_line(line_number).text
  let preamble = "  \{line_number + 1}: "
  let link_line = doc_line_count(doc_key)
  append_doc_line(doc_key, "\{preamble}\{text}")

  let start_character = preamble.length() + match_range.start().character()
  let end_character = preamble.length() + match_range.end().character()
  let link_range = @vscode.Range::new(
    @vscode.Position::new(link_line, start_character),
    @vscode.Position::new(link_line, end_character),
  )
  let link_target = target.with_parts(
    fragment="\{match_range.start().line() + 1}",
  )
  append_doc_link(doc_key, @vscode.DocumentLink::new(link_range, target=link_target))
}

fn append_trailing(
  doc_key : String,
  document : @vscode.TextDocument,
  line_number : Int,
  next : @vscode.Range?,
) -> Unit {
  let mut to_line = document.line_count()
  let nearby = line_number + 3
  if nearby < to_line {
    to_line = nearby
  }

  match next {
    Some(next_range) =>
      if next_range.start().line() - to_line <= 2 {
        return
      }
    None => ()
  }

  let start_line = line_number + 1
  for index in start_line..<to_line {
    append_doc_line(doc_key, context_line(index, document.line_at_line(index).text))
  }

  match next {
    Some(_) => append_doc_line(doc_key, "  ...")
    None => ()
  }
}

async fn fetch_and_format_locations(
  doc_key : String,
  uri : @vscode.Uri,
  ranges : Array[@vscode.Range],
) -> Unit {
  try {
    let document = @workspace.open_text_document_uri(uri)
    append_doc_line(doc_key, "")
    append_doc_line(doc_key, uri.to_string())
    for index in 0..<ranges.length() {
      let range = ranges[index]
      let previous = if index > 0 { Some(ranges[index - 1]) } else { None }
      let next = if index + 1 < ranges.length() {
        Some(ranges[index + 1])
      } else {
        None
      }
      let line_number = range.start().line()
      append_leading(doc_key, document, line_number, previous)
      append_match(doc_key, document, line_number, range, uri)
      append_trailing(doc_key, document, line_number, next)
    }
  } catch {
    _ => {
      append_doc_line(doc_key, "")
      append_doc_line(doc_key, "Failed to load '\{uri.to_string()}'")
      append_doc_line(doc_key, "")
    }
  }
}

async fn populate_document(
  document_uri : @vscode.Uri,
  locations : Array[@vscode.Location],
) -> Unit {
  let doc_key = document_uri.to_string()
  let mut current_uri : @vscode.Uri? = None
  let mut current_ranges : Array[@vscode.Range] = []

  for location in locations {
    let uri = location.uri()
    let range = location.range()
    match current_uri {
      None => {
        current_uri = Some(uri)
        current_ranges = [range]
      }
      Some(previous_uri) => {
        if previous_uri.to_string() == uri.to_string() {
          current_ranges.push(range)
        } else {
          fetch_and_format_locations(doc_key, previous_uri, current_ranges)
          fire_doc_change(document_uri)
          current_uri = Some(uri)
          current_ranges = [range]
        }
      }
    }
  }

  match current_uri {
    None => ()
    Some(uri) => {
      fetch_and_format_locations(doc_key, uri, current_ranges)
      fire_doc_change(document_uri)
    }
  }
}

fn start_populating(
  document_uri : @vscode.Uri,
  locations : Array[@vscode.Location],
) -> Unit {
  let _ = @js_async.Promise::from_async(async fn() {
    populate_document(document_uri, locations)
  })
}

fn encode_location(uri : @vscode.Uri, position : @vscode.Position) -> @vscode.Uri {
  let seq = content_provider_state.seq
  content_provider_state.seq = seq + 1
  let payload : (String, Int, Int) = (
    uri.to_string(),
    position.line(),
    position.character(),
  )
  let query = payload.to_json().stringify()
  @vscode.Uri::parse("references:References.locations").with_parts(
    query=query,
    fragment="\{seq}",
  )
}

fn decode_location_payload(query : String) -> (String, Int, Int)? {
  try {
    Some(@json.from_json(@json.parse(query)))
  } catch {
    _ => None
  }
}

fn decode_location(uri : @vscode.Uri) -> (@vscode.Uri, @vscode.Position) {
  match decode_location_payload(uri.query()) {
    Some((target, line, character)) => (
      @vscode.Uri::parse(target),
      @vscode.Position::new(line, character),
    )
    None => (uri, @vscode.Position::new(0, 0))
  }
}

fn reset_provider_state() -> Unit {
  content_provider_state.docs = []

  match content_provider_state.close_listener {
    None => ()
    Some(listener) => {
      listener.dispose()
      content_provider_state.close_listener = None
    }
  }

  match content_provider_state.editor_decoration {
    None => ()
    Some(decoration) => {
      decoration.dispose()
      content_provider_state.editor_decoration = None
    }
  }

  match content_provider_state.emitter {
    None => ()
    Some(emitter) => {
      emitter.dispose()
      content_provider_state.emitter = None
    }
  }
}

priv struct ReferencesContentProvider {}

impl @vscode.TextDocumentContentProvider for ReferencesContentProvider with on_did_change(
  _self,
) {
  match content_provider_state.emitter {
    Some(emitter) => Some(emitter.event())
    None => None
  }
}

impl @vscode.TextDocumentContentProvider for ReferencesContentProvider with provide_text_document_content(
  _self,
  uri,
  _token,
) {
  match get_doc(uri.to_string()) {
    Some(doc) => doc.lines.join("\n")
    None => {
      let (target, position) = decode_location(uri)
      let locations = rotate_to_target_resource(
        sort_locations(find_references(target, position)),
        target,
      )
      put_doc({
        key: uri.to_string(),
        uri,
        lines: ["Found \{locations.length()} references"],
        links: [],
      })
      start_populating(uri, locations)
      doc_value(uri)
    }
  }
}

priv struct ReferencesDocumentLinkProvider {}

impl @vscode.DocumentLinkProvider for ReferencesDocumentLinkProvider with provide_document_links(
  _self,
  document,
  _token,
) {
  doc_links(document.uri())
}

impl @vscode.DocumentLinkProvider for ReferencesDocumentLinkProvider with resolve_document_link(
  _self,
  _link,
  _token,
) {
  None
}

pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  reset_provider_state()
  let subscriptions = ctx.subscriptions()

  let emitter : @vscode.EventEmitter[@vscode.Uri] = @vscode.EventEmitter::new()
  content_provider_state.emitter = Some(emitter)

  let decoration = @window.create_text_editor_decoration_type(
    @vscode.DecorationRenderOptions::new(text_decoration="underline"),
  )
  content_provider_state.editor_decoration = Some(decoration)

  let close_listener = @workspace.on_did_close_text_document().subscribe(fn(document) {
    remove_doc(document.uri().to_string())
  })
  content_provider_state.close_listener = Some(close_listener)
  subscriptions.push(close_listener)

  subscriptions.push(
    @workspace.register_text_document_content_provider(
      references_scheme,
      ReferencesContentProvider::{},
    ),
  )
  subscriptions.push(
    @languages.register_document_link_provider(
      @vscode.DocumentSelector::Filter(
        @vscode.DocumentFilter::new(scheme=references_scheme),
      ),
      ReferencesDocumentLinkProvider::{},
    ),
  )

  subscriptions.push(
    @commands.register_text_editor_command_async(
      "editor.printReferences",
      async fn(editor, _edit, _args) {
        let uri = encode_location(editor.document().uri(), editor.selection().active())
        let document = @workspace.open_text_document_uri(uri)
        ignore(
          @window.show_text_document(
            document,
            options=@vscode.TextDocumentShowOptions::new(
              view_column=@vscode.ViewColumn::Beside,
            ),
          ),
        )
      },
    ),
  )
}

pub fn deactivate() -> Unit {
  reset_provider_state()
}
