///|
/// JS entrypoint for chat namespace binding checks.

///|
fn fixture_root() -> @vscode.Uri {
  match @workspace.workspace_folders() {
    Some([folder, ..]) => folder.uri()
    _ => @vscode.Uri::file("/tmp/moonbit-chat-fixture")
  }
}

///|
fn fixture_uri(root : @vscode.Uri, name : String) -> @vscode.Uri {
  @vscode.Uri::join_path(root, [name])
}

///|
async fn write_result(
  root : @vscode.Uri,
  name : String,
  content : String,
) -> Unit {
  let fs = @workspace.fs()
  fs.write_file(fixture_uri(root, name), @workspace.encode(content))
}

///|
fn bool_to_string(value : Bool) -> String {
  if value {
    "true"
  } else {
    "false"
  }
}

///|
async fn run_check_chat(root : @vscode.Uri) -> Unit {
  let is_available = @chat.available()
  if !is_available {
    write_result(root, "chat-result.txt", "chat ok available=false")
  } else {
    let error_details = @chat.ChatErrorDetails::new(
      "MoonBit Chat Error",
      response_is_filtered=true,
    )
    let result = @chat.ChatResult::new(
      error_details=error_details,
      metadata=@vscode.Any::from("chat-metadata"),
    )
    let metadata_state = match result.metadata {
      None => "none"
      Some(_) => "some"
    }

    let followup = @chat.ChatFollowup::new(
      "moonbit followup prompt",
      label="MoonBit Followup",
      participant="moonbit.chat.participant",
      command="moonbit.chat.command",
    )
    let followup_provider = @chat.ChatFollowupProvider::new(
      fn(_result, _context, _token) {
        Some([followup])
      },
    )

    let tree = @chat.ChatResponseFileTree::new(
      "src",
      children=[@chat.ChatResponseFileTree::new("main.mbt")],
    )
    let tree_children = match tree.children {
      None => "none"
      Some(value) => "\{value.length()}"
    }

    let markdown_part = @chat.ChatResponseMarkdownPart::new(
      @chat.ChatMarkdownValue::text("moonbit markdown"),
    )
    let anchor_part = @chat.ChatResponseAnchorPart::new(
      @chat.ChatAnchorValue::uri(root),
      title="Fixture Root",
    )
    let progress_part = @chat.ChatResponseProgressPart::new("in-progress")
    let reference_part = @chat.ChatResponseReferencePart::new(
      @chat.ChatAnchorValue::uri(root),
    )
    let command_button_part = @chat.ChatResponseCommandButtonPart::new(
      @vscode.Command::new(
        "MoonBit Chat Command",
        "moonbit.chat.checkBindings",
      ),
    )

    let parts : Array[@chat.ChatResponsePart] = [
      @chat.ChatResponsePart::from_markdown_part(markdown_part),
      @chat.ChatResponsePart::from_anchor_part(anchor_part),
      @chat.ChatResponsePart::from_progress_part(progress_part),
      @chat.ChatResponsePart::from_reference_part(reference_part),
      @chat.ChatResponsePart::from_command_button_part(command_button_part),
    ]

    let handler = @chat.ChatRequestHandler::new(
      fn(_request, _context, _response, _token) {
        Some(result)
      },
    )
    let participant_from_handler = @chat.create_chat_participant_with_handler(
      "moonbit.chat.participant.handler",
      handler,
    )
    let participant_handler_state =
      if participant_from_handler.id == "moonbit.chat.participant.handler" {
        "some"
      } else {
        "none"
      }
    participant_from_handler.dispose()

    let direct_participant = @chat.create_chat_participant(
      "moonbit.chat.participant.direct",
      fn(_request, _context, _response, _token) {
        Some(result)
      },
    )
    let direct_participant_state = "some:\{direct_participant.id}"
    direct_participant.dispose()

    let try_handler_state = match @chat.try_create_chat_participant_with_handler(
      "moonbit.chat.participant.try-handler",
      handler,
    ) {
      Some(participant) => {
        let id = participant.id
        participant.dispose()
        "some:\{id}"
      }
      None => "none"
    }

    let participant_state = match @chat.try_create_chat_participant(
      "moonbit.chat.participant",
      fn(_request, _context, _response, _token) {
        Some(result)
      },
    ) {
      Some(participant) => {
        participant.icon_path = Some(@vscode.IconPath::ThemeIconValue(@vscode.ThemeIcon::new("comment-discussion")))
        participant.followup_provider = Some(followup_provider)
        let has_icon = participant.icon_path is Some(_)
        let has_followup_provider = participant.followup_provider is Some(_)
        let feedback_event = participant.on_did_receive_feedback.subscribe(_ => ())
        feedback_event.dispose()
        participant.followup_provider = None
        let participant_id = participant.id
        participant.dispose()
        "some:\{participant_id}:\{bool_to_string(has_icon)}:\{bool_to_string(has_followup_provider)}"
      }
      None => "none"
    }

    write_result(
      root,
      "chat-result.txt",
      "chat ok available=true metadata=\{metadata_state} tree_children=\{tree_children} parts=\{parts.length()} markdown=\{markdown_part.value().value()} participant=\{participant_state} handler_participant=\{participant_handler_state} direct_participant=\{direct_participant_state} try_handler=\{try_handler_state}",
    )
  }
}

///|
pub fn activate(ctx : @vscode.ExtensionContext) -> Unit {
  let root = fixture_root()
  let subscriptions = ctx.subscriptions()

  let disposable = @commands.register_command_async(
    "moonbit.chat.checkBindings",
    async fn(_args) {
      run_check_chat(root)
    },
  )
  subscriptions.push(disposable)
}

///|
pub fn deactivate() -> Unit {
  ()
}
