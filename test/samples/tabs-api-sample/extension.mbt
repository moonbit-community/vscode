///|
/// MoonBit port of `tabs-api-sample`.
priv struct TabActivityEntry {
  key : String
  mut last_active_ms : Int
}

priv struct TabsState {
  mut activities : Array[TabActivityEntry]
  mut loop_running : Bool
}

let tabs_state : TabsState = {
  activities: [],
  loop_running: false,
}

fn now_ms() -> Int {
  @vscode.Date::now().to_millis().to_int()
}

fn view_column_value(column : @vscode.ViewColumn) -> Int {
  match column {
    @vscode.ViewColumn::Active => -1
    @vscode.ViewColumn::Beside => -2
    @vscode.ViewColumn::One => 1
    @vscode.ViewColumn::Two => 2
    @vscode.ViewColumn::Three => 3
    @vscode.ViewColumn::Four => 4
    @vscode.ViewColumn::Five => 5
    @vscode.ViewColumn::Six => 6
    @vscode.ViewColumn::Seven => 7
    @vscode.ViewColumn::Eight => 8
    @vscode.ViewColumn::Nine => 9
    @vscode.ViewColumn::Custom(value) => value
  }
}

fn tab_key(tab : @vscode.Tab) -> String {
  let column = view_column_value(tab.group().view_column())
  let input = tab.input()
  match input.as_text() {
    Some(value) => "text:\{value.uri().to_string()}@\{column}"
    None =>
      match input.as_text_diff() {
        Some(value) =>
          "text-diff:\{value.original().to_string()}::\{value.modified().to_string()}@\{column}"
        None =>
          match input.as_custom() {
            Some(value) =>
              "custom:\{value.view_type()}:\{value.uri().to_string()}@\{column}"
            None =>
              match input.as_webview() {
                Some(value) => "webview:\{value.view_type()}@\{column}"
                None =>
                  match input.as_notebook() {
                    Some(value) =>
                      "notebook:\{value.notebook_type()}:\{value.uri().to_string()}@\{column}"
                    None =>
                      match input.as_notebook_diff() {
                          Some(value) =>
                          "notebook-diff:\{value.notebook_type()}:\{value.original().to_string()}::\{value.modified().to_string()}@\{column}"
                        None =>
                          match input.as_terminal() {
                            Some(_) => "terminal:\{tab.label()}@\{column}"
                            None => "tab:\{tab.label()}@\{column}"
                          }
                      }
                  }
              }
          }
      }
  }
}

fn find_activity_index(key : String) -> Int? {
  for i in 0..<tabs_state.activities.length() {
    if tabs_state.activities[i].key == key {
      return Some(i)
    }
  }
  None
}

fn mark_tab_active(tab : @vscode.Tab, timestamp : Int) -> Unit {
  let key = tab_key(tab)
  match find_activity_index(key) {
    None => tabs_state.activities.push({ key, last_active_ms: timestamp, })
    Some(index) => tabs_state.activities[index].last_active_ms = timestamp
  }
}

fn remove_activity_key(key : String) -> Unit {
  let remaining : Array[TabActivityEntry] = []
  for entry in tabs_state.activities {
    if entry.key != key {
      remaining.push(entry)
    }
  }
  tabs_state.activities = remaining
}

fn remove_tab_activity(tab : @vscode.Tab) -> Unit {
  remove_activity_key(tab_key(tab))
}

fn mark_all_tabs_active(groups : @vscode.TabGroups) -> Unit {
  tabs_state.activities = []
  let timestamp = now_ms()
  for group in groups.all() {
    for tab in group.tabs() {
      mark_tab_active(tab, timestamp)
    }
  }
}

fn find_tab_by_key(groups : @vscode.TabGroups, key : String) -> @vscode.Tab? {
  for group in groups.all() {
    for tab in group.tabs() {
      if tab_key(tab) == key {
        return Some(tab)
      }
    }
  }
  None
}

async fn close_inactive_tabs(
  groups : @vscode.TabGroups,
  inactive_time_ms : Int,
) -> Unit {
  let now = now_ms()
  match groups.active_tab_group().active_tab() {
    None => ()
    Some(tab) => mark_tab_active(tab, now)
  }

  let keys_to_remove : Array[String] = []
  for entry in tabs_state.activities {
    if now - entry.last_active_ms > inactive_time_ms {
      match find_tab_by_key(groups, entry.key) {
        None => keys_to_remove.push(entry.key)
        Some(tab) => {
          if tab.is_active() || tab.is_dirty() {
            mark_tab_active(tab, now)
          } else {
            let did_close = groups.close_tab(tab, preserve_focus=true)
            if did_close {
              keys_to_remove.push(entry.key)
            }
          }
        }
      }
    }
  }

  for key in keys_to_remove {
    remove_activity_key(key)
  }
}

fn start_polling(groups : @vscode.TabGroups) -> Unit {
  tabs_state.loop_running = true
  let _ = @js_async.Promise::from_async(async fn() {
    while tabs_state.loop_running {
      let max_inactive_seconds = @workspace.get_configuration().get_or(
        "tabs.maxInactiveTime",
        30,
      )
      close_inactive_tabs(groups, max_inactive_seconds * 1000)
      @async.sleep(1000)
    }
  })
}

priv struct PollingDisposable {}

impl @vscode.Disposable for PollingDisposable with dispose(_self) {
  tabs_state.loop_running = false
}

pub fn activate(context : @vscode.ExtensionContext) -> Unit {
  let subscriptions = context.subscriptions()
  let groups = @window.tab_groups()

  mark_all_tabs_active(groups)

  subscriptions.push(groups.on_did_change_tab_groups().subscribe(fn(_event) {
    mark_all_tabs_active(groups)
  }))

  subscriptions.push(groups.on_did_change_tabs().subscribe(fn(event) {
    for removed_tab in event.closed {
      remove_tab_activity(removed_tab)
    }
    let timestamp = now_ms()
    for tab in event.opened {
      mark_tab_active(tab, timestamp)
    }
    for tab in event.changed {
      mark_tab_active(tab, timestamp)
    }
  }))

  start_polling(groups)
  subscriptions.push(PollingDisposable::{})
}

pub fn deactivate() -> Unit {
  tabs_state.loop_running = false
}
