///|
/// MoonBit port of `comment-sample`.
priv struct NoteCommentRecord {
  id : Int
  comment : @vscode.Comment
  parent : @vscode.CommentThread
  saved_body : @vscode.MarkdownStringValue
}

priv struct CommentSampleState {
  mut comment_id : Int
  mut controller : @vscode.CommentController?
  mut records : Array[NoteCommentRecord]
}

let comment_state : CommentSampleState = {
  comment_id: 1,
  controller: None,
  records: [],
}

priv struct WikiCommentingRangeProvider {}

impl @vscode.CommentingRangeProvider for WikiCommentingRangeProvider with provide_commenting_ranges(
  _self,
  document,
  _token,
) {
  let line_count = document.line_count()
  Some(
    @vscode.CommentingRanges::new(
      false,
      ranges=[
        @vscode.Range::new(
          @vscode.Position::new(0, 0),
          @vscode.Position::new(line_count - 1, 0),
        ),
      ],
    ),
  )
}

fn command_reply(args : @commands.CommandArgs) -> @vscode.CommentReply? {
  args.get(0)
}

fn command_comment(args : @commands.CommandArgs) -> @vscode.Comment? {
  args.get(0)
}

fn command_thread(args : @commands.CommandArgs) -> @vscode.CommentThread? {
  args.get(0)
}

extern "js" fn comment_is_equal(
  left : @vscode.Comment,
  right : @vscode.Comment,
) -> Bool =
  #| (left, right) => left === right

fn next_comment_id() -> Int {
  comment_state.comment_id = comment_state.comment_id + 1
  comment_state.comment_id
}

fn add_record(comment : @vscode.Comment, parent : @vscode.CommentThread) -> Int {
  let id = next_comment_id()
  comment_state.records.push({
    id,
    comment,
    parent,
    saved_body: comment.body,
  })
  id
}

fn find_record(comment : @vscode.Comment) -> NoteCommentRecord? {
  for record in comment_state.records {
    if comment_is_equal(record.comment, comment) {
      return Some(record)
    }
  }
  None
}

fn remove_record_by_id(target_id : Int) -> Unit {
  let remaining : Array[NoteCommentRecord] = []
  for record in comment_state.records {
    if record.id != target_id {
      remaining.push(record)
    }
  }
  comment_state.records = remaining
}

fn remove_records_for_thread(target : @vscode.CommentThread) -> Unit {
  let remaining : Array[NoteCommentRecord] = []
  for record in comment_state.records {
    if !record.parent.is_equal(target) {
      remaining.push(record)
    }
  }
  comment_state.records = remaining
}

fn set_record_saved_body(
  target_id : Int,
  body : @vscode.MarkdownStringValue,
) -> Unit {
  let updated : Array[NoteCommentRecord] = []
  for record in comment_state.records {
    if record.id == target_id {
      updated.push({
        id: record.id,
        comment: record.comment,
        parent: record.parent,
        saved_body: body,
      })
    } else {
      updated.push(record)
    }
  }
  comment_state.records = updated
}

fn author() -> @vscode.CommentAuthorInformation {
  @vscode.CommentAuthorInformation::new("vscode")
}

fn append_comment(thread : @vscode.CommentThread, comment : @vscode.Comment) -> Unit {
  let updated : Array[@vscode.Comment] = []
  for item in thread.comments() {
    updated.push(item)
  }
  updated.push(comment)
  thread.set_comments(updated)
}

fn create_note_comment(
  body : String,
  mode : @vscode.CommentMode,
  parent : @vscode.CommentThread,
  context_value? : String,
) -> @vscode.Comment {
  let comment = @vscode.Comment::new(
    @vscode.MarkdownStringValue::Text(body),
    mode,
    author(),
  )
  match context_value {
    Some(value) => comment.context_value = Some(value)
    None => ()
  }
  let _ = add_record(comment, parent)
  comment
}

fn reply_note(reply : @vscode.CommentReply) -> Unit {
  let thread = reply.thread
  let new_comment = if thread.comments().length() > 0 {
    create_note_comment(
      reply.text,
      @vscode.CommentMode::Preview,
      thread,
      context_value="canDelete",
    )
  } else {
    create_note_comment(
      reply.text,
      @vscode.CommentMode::Preview,
      thread,
    )
  }
  match thread.context_value() {
    Some(value) =>
      if value == "draft" {
        new_comment.label = Some("pending")
      }
    None => ()
  }
  append_comment(thread, new_comment)
}

fn clear_all_labels(thread : @vscode.CommentThread) -> Unit {
  let updated : Array[@vscode.Comment] = []
  for comment in thread.comments() {
    comment.label = None
    updated.push(comment)
  }
  thread.set_comments(updated)
}

pub fn activate(context : @vscode.ExtensionContext) -> Unit {
  let comment_controller = @comments.create_comment_controller(
    "comment-sample",
    "Comment API Sample",
  )
  comment_state.controller = Some(comment_controller)
  comment_controller.set_commenting_range_provider(WikiCommentingRangeProvider::{})

  let subscriptions = context.subscriptions()

  subscriptions.push(
    @commands.register_command(
      "mywiki.createNote",
      fn(args) {
        match command_reply(args) {
          Some(reply) => reply_note(reply)
          None => ()
        }
      },
    ),
  )

  subscriptions.push(
    @commands.register_command(
      "mywiki.replyNote",
      fn(args) {
        match command_reply(args) {
          Some(reply) => reply_note(reply)
          None => ()
        }
      },
    ),
  )

  subscriptions.push(
    @commands.register_command(
      "mywiki.startDraft",
      fn(args) {
        match command_reply(args) {
          None => ()
          Some(reply) => {
            let thread = reply.thread
            thread.set_context_value("draft")
            let new_comment = create_note_comment(
              reply.text,
              @vscode.CommentMode::Preview,
              thread,
            )
            new_comment.label = Some("pending")
            append_comment(thread, new_comment)
          }
        }
      },
    ),
  )

  subscriptions.push(
    @commands.register_command(
      "mywiki.finishDraft",
      fn(args) {
        match command_reply(args) {
          None => ()
          Some(reply) => {
            let thread = reply.thread
            thread.clear_context_value()
            thread.set_collapsible_state(@vscode.CommentThreadCollapsibleState::Collapsed)
            if reply.text != "" {
              let new_comment = create_note_comment(
                reply.text,
                @vscode.CommentMode::Preview,
                thread,
              )
              append_comment(thread, new_comment)
            }
            clear_all_labels(thread)
          }
        }
      },
    ),
  )

  subscriptions.push(
    @commands.register_command(
      "mywiki.deleteNoteComment",
      fn(args) {
        match command_comment(args) {
          None => ()
          Some(comment) =>
            match find_record(comment) {
              None => ()
              Some(target) => {
                let thread = target.parent
                let remaining_comments : Array[@vscode.Comment] = []
                for item in thread.comments() {
                  match find_record(item) {
                    Some(record) => {
                      if record.id != target.id {
                        remaining_comments.push(item)
                      }
                    }
                    None => remaining_comments.push(item)
                  }
                }
                thread.set_comments(remaining_comments)
                remove_record_by_id(target.id)
                if remaining_comments.length() == 0 {
                  thread.dispose()
                  remove_records_for_thread(thread)
                }
              }
            }
        }
      },
    ),
  )

  subscriptions.push(
    @commands.register_command(
      "mywiki.deleteNote",
      fn(args) {
        match command_thread(args) {
          None => ()
          Some(thread) => {
            thread.dispose()
            remove_records_for_thread(thread)
          }
        }
      },
    ),
  )

  subscriptions.push(
    @commands.register_command(
      "mywiki.cancelsaveNote",
      fn(args) {
        match command_comment(args) {
          None => ()
          Some(comment) =>
            match find_record(comment) {
              None => ()
              Some(record) => {
                let thread = record.parent
                let updated : Array[@vscode.Comment] = []
                for item in thread.comments() {
                  if comment_is_equal(item, comment) {
                    item.body = record.saved_body
                    item.mode = @vscode.CommentMode::Preview
                  }
                  updated.push(item)
                }
                thread.set_comments(updated)
              }
            }
        }
      },
    ),
  )

  subscriptions.push(
    @commands.register_command(
      "mywiki.saveNote",
      fn(args) {
        match command_comment(args) {
          None => ()
          Some(comment) =>
            match find_record(comment) {
              None => ()
              Some(record) => {
                let thread = record.parent
                let mut saved_body : @vscode.MarkdownStringValue? = None
                let updated : Array[@vscode.Comment] = []
                for item in thread.comments() {
                  if comment_is_equal(item, comment) {
                    saved_body = Some(item.body)
                    item.mode = @vscode.CommentMode::Preview
                  }
                  updated.push(item)
                }
                thread.set_comments(updated)
                match saved_body {
                  Some(body) => set_record_saved_body(record.id, body)
                  None => ()
                }
              }
            }
        }
      },
    ),
  )

  subscriptions.push(
    @commands.register_command(
      "mywiki.editNote",
      fn(args) {
        match command_comment(args) {
          None => ()
          Some(comment) =>
            match find_record(comment) {
              None => ()
              Some(record) => {
                let thread = record.parent
                let updated : Array[@vscode.Comment] = []
                for item in thread.comments() {
                  if comment_is_equal(item, comment) {
                    item.mode = @vscode.CommentMode::Editing
                  }
                  updated.push(item)
                }
                thread.set_comments(updated)
              }
            }
        }
      },
    ),
  )

  subscriptions.push(
    @commands.register_command(
      "mywiki.dispose",
      fn(_args) {
        comment_controller.dispose()
        comment_state.controller = None
        comment_state.records = []
      },
    ),
  )
}

pub fn deactivate() -> Unit {
  match comment_state.controller {
    Some(controller) => {
      controller.dispose()
      comment_state.controller = None
    }
    None => ()
  }
  comment_state.records = []
}
