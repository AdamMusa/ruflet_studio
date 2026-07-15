# frozen_string_literal: true

def editor_view(page, item, back_route:)
  actions =
    if page.width.to_f >= 760
      [
        text_button(content: row(spacing: 6, children: [icon(icon: "fork_right", color: TEXT), text("Fork", style: { color: TEXT })])),
        text_button(content: row(spacing: 6, children: [icon(icon: "ios_share", color: TEXT), text("Share", style: { color: TEXT })])),
        icon_button(icon: "open_in_new"),
        icon_button(icon: "download")
      ]
    else
      # Compact icon-only actions on phones so the app bar doesn't overflow.
      [
        icon_button(icon: "fork_right"),
        icon_button(icon: "download")
      ]
    end

  # The 3-pane (files + code + preview) layout; on phones fall back to the
  # compact tabbed workspace.
  workspace =
    if page.width.to_f >= 760
      desktop_editor_workspace(page, item)
    else
      mobile_editor_workspace(page, item)
    end

  control(:view, route: route_path(page), bgcolor: BG, padding: 0,
    appbar: top_bar(page, item[:title], back: back_route, actions: actions),
    children: [workspace])
end

def desktop_editor_workspace(page, item)
  row(expand: true, spacing: 0, children: [
    file_pane(page, item),
    container(width: 1, bgcolor: BORDER),
    code_pane(page, item),
    container(width: 1, bgcolor: BORDER),
    preview_pane(page, item)
  ])
end

# Compact editor for narrow screens: the Files / Code / Preview tabs switch the
# visible pane via a ?tab= param (instead of cramming all three side by side).
def mobile_editor_workspace(page, item)
  tab = page.query["tab"].to_s
  tab = "preview" unless %w[files code preview].include?(tab)

  body =
    case tab
    when "files" then mobile_file_list(page, item)
    when "code"  then code_pane(page, item)
    else mobile_preview_pane(page, item)
    end

  column(expand: true, horizontal_alignment: "stretch", spacing: 0, children: [
    container(height: 48, bgcolor: BAR, content: row(spacing: 0, children: [
      mobile_workspace_tab(page, "Files", "folder", "files", tab == "files"),
      mobile_workspace_tab(page, "Code", "code", "code", tab == "code"),
      mobile_workspace_tab(page, "Preview", "play_circle_outline", "preview", tab == "preview")
    ])),
    container(expand: true, content: body),
    console_bar
  ])
end

def mobile_preview_pane(page, item)
  host, fill = preview_host(page, item)
  if fill
    # Platform views need a BOUNDED height. A scroll view hands them unbounded
    # height, which makes the native view's layer infinite/NaN and crashes the
    # app (CALayerInvalidGeometry). Give them the full pane, no scroll.
    container(expand: true, bgcolor: PREVIEW_SURFACE, content: host)
  else
    container(expand: true, bgcolor: PREVIEW_SURFACE, padding: 14, clip_behavior: "hardEdge",
      content: column(expand: true, scroll: "auto", horizontal_alignment: "stretch",
        children: [host]))
  end
end

def mobile_workspace_tab(page, label, icon_value, tab_key, selected)
  container(expand: true, alignment: "center", bgcolor: selected ? BG : BAR,
    on_click: ->(_e) { studio_go(page, tab_route(page, tab_key)) },
    content: row(alignment: "center", spacing: 6, children: [
      icon(icon: icon_value, color: selected ? BLUE : MUTED, size: 18),
      text(label, style: { color: selected ? BLUE : MUTED, size: 14, weight: selected ? "w700" : "w600" })
    ]))
end

def mobile_file_list(page, item)
  current = selected_file(page, item)
  container(expand: true, bgcolor: BG, padding: 12, content: column(expand: true, scroll: "auto", spacing: 6, children:
    item_files(item).keys.map do |file|
      sel = file == current
      container(border_radius: 8, bgcolor: sel ? SURFACE_2 : BG, padding: 12,
        on_click: ->(_e) { studio_go(page, tab_route(page, "code", file: file)) },
        content: row(spacing: 10, children: [
          icon(icon: "insert_drive_file", color: sel ? BLUE : MUTED),
          text(file, style: { color: TEXT, size: 16, weight: sel ? "w700" : "w500" })
        ]))
    end))
end

# Route to a workspace tab, preserving the selected file and the back origin.
def tab_route(page, tab, file: nil)
  base = route_path(page)
  selected = file || page.query["file"]
  origin = page.query["from"]
  params = { "tab" => tab }
  params["file"] = selected unless selected.to_s.empty?
  params["from"] = origin unless origin.to_s.empty?
  "#{base}?" + params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
end

def file_pane(page, item)
  current_file = selected_file(page, item)
  files = item_files(item)
  container(width: 250, bgcolor: BG, padding: 12, content: column(expand: true, spacing: 8, children: [
    row(children: [
      text("Files", style: { color: TEXT, size: 14, weight: "w700" }),
      container(expand: true, content: text("")),
      icon(icon: "unfold_less", color: TEXT, size: 18)
    ]),
    *files.keys.map do |file|
      selected = file == current_file
      container(border_radius: 8, bgcolor: selected ? "#1c2630" : BG, padding: { top: 8, bottom: 8, left: 8, right: 8 },
        on_click: ->(_e) { studio_go(page, file_route(page, file)) },
        content: row(spacing: 8, children: [
          icon(icon: "insert_drive_file", color: MUTED),
          text(file, style: { color: TEXT, size: 15, weight: selected ? "w700" : "w500" })
        ]))
    end
  ]))
end

def code_pane(page, item)
  compact = mobile?(page)
  file = selected_file(page, item)
  state = editor_session(page, item, file)
  status = text(state[:editable] ? "Editing preview" : "Read-only preview",
    style: { color: MUTED, size: compact ? 12 : 14 }, max_lines: 1)
  lock_icon = icon(icon: state[:editable] ? "edit" : "lock", color: MUTED, size: 20)
  run_button = nil
  editor = code_editor(
    state[:code],
    language: "ruby",
    code_theme: "atom-one-dark",
    read_only: !state[:editable],
    expand: true,
    on_change: ->(event) { state[:code].replace(editor_change_source(event)) }
  )
  unlock = lambda do |_event|
    next if state[:editable]

    state[:editable] = true
    page.update(editor, read_only: false, autofocus: true)
    page.update(run_button, disabled: false)
    page.update(lock_icon, icon: "edit", color: BLUE)
    page.update(status, value: "Editing preview", style: { color: BLUE, size: compact ? 12 : 14 })
  end
  run_button = filled_button(
    height: 36,
    disabled: !state[:editable],
    content: row(tight: true, spacing: 6, children: [
      icon(icon: "play_arrow", size: 18),
      text("Run")
    ]),
    on_click: ->(_event) { run_editor_preview(page, item, status) }
  )
  container(expand: true, bgcolor: EDITOR_BG, content: column(expand: true, spacing: 0, children: [
    container(height: compact ? 52 : 66, bgcolor: "#2a2d33", padding: { left: compact ? 12 : 20, right: compact ? 12 : 18 },
      content: row(spacing: 10, children: [
        run_button,
        lock_icon,
        status,
        container(expand: true, content: text("")),
        *(compact ? [] : [outlined_button(content: row(spacing: 8, children: [icon(icon: "fork_right"), text("Fork")]), disabled: true)])
      ])),
    gesture_detector(expand: true, on_double_tap: unlock, content: editor)
  ]))
end

# Examples whose preview is a native platform view. These must NOT be clipped
# OR placed inside a scroll view: a platform view composited under a scroll/clip
# transform paints with an invalid matrix and renders blank (the WebView "blank
# preview" bug). They get the full pane, no padding, no scroll.
FILL_PREVIEW_SLUGS = %w[webview video map camera].freeze

def preview_pane(page, item)
  host, fill = preview_host(page, item)
  inner =
    if fill
      # Platform views must NOT be clipped (a clip ancestor blanks them).
      container(expand: true, bgcolor: PREVIEW_SURFACE, content: host)
    else
      # Everything else is clipped to the pane so overflow-heavy previews (e.g.
      # the animation's scattered, absolutely-positioned shapes) can't bleed
      # into the code pane.
      container(expand: true, bgcolor: PREVIEW_SURFACE, padding: 24, clip_behavior: "hardEdge",
        content: column(expand: true, scroll: "auto", horizontal_alignment: "stretch",
          children: [host]))
    end
  container(expand: true, bgcolor: "#12161a", content: column(expand: true, spacing: 0, children: [
    inner,
    console_bar
  ]))
end

def preview_host(page, item)
  state = editor_session(page, item, "main.rb")
  unless state[:preview]
    state[:preview] = render_example_code(page, state[:code], session: state)
    state[:last_successful_preview] = state[:preview]
  end
  fill = preview_requires_bounded_host?(item, state[:preview])
  host = preview_host_container(fill, state[:preview])
  state[:preview_host] = host
  state[:preview_fill] = fill
  [host, fill]
rescue Exception # User-authored source can raise SyntaxError or SystemExit.
  fallback = state[:last_successful_preview] || preview_for(page, item[:slug], large: true)
  state[:preview] = fallback
  state[:last_successful_preview] = fallback
  fill = preview_requires_bounded_host?(item, fallback)
  host = preview_host_container(fill, fallback)
  state[:preview_host] = host
  state[:preview_fill] = fill
  [host, fill]
end

# A self-contained app that uses flex expansion needs the same finite viewport
# constraints it receives when run directly. Detect that from the rendered
# control tree instead of maintaining per-example exceptions.
def preview_requires_bounded_host?(item, content)
  FILL_PREVIEW_SLUGS.include?(item[:slug]) || control_tree_expands?(content)
end

def control_tree_expands?(value)
  case value
  when Ruflet::Control
    return true if value.props["expand"] && value.props["expand"] != false

    value.children.any? { |child| control_tree_expands?(child) } ||
      value.props.values.any? { |prop| control_tree_expands?(prop) }
  when Array
    value.any? { |entry| control_tree_expands?(entry) }
  when Hash
    value.values.any? { |entry| control_tree_expands?(entry) }
  else
    false
  end
end

# Platform-view previews fill the pane; everything else hugs the top-left so
# scrollable content lays out naturally.
def preview_host_container(fill, content)
  if fill
    container(expand: true, content: fill_preview_body(content))
  else
    container(alignment: { x: -1, y: -1 }, content: content)
  end
end

# A platform-view example's root uses expand:true, which only takes effect
# inside a flex parent. Host it in an expanding column (like a real app page)
# so the native view fills the pane instead of collapsing to zero height.
def fill_preview_body(content)
  column(expand: true, horizontal_alignment: "stretch", children: [content])
end

# "Run" evaluates the current source string and replaces the preview host.
# Failed edits leave the last successful preview mounted.
def run_editor_preview(page, item, status)
  state = editor_session(page, item, "main.rb")
  rendered = render_example_code(page, state[:code], session: state)
  state[:preview] = rendered
  state[:last_successful_preview] = rendered
  state[:last_successful_code].replace(state[:code])
  page.update(status, value: "Preview updated", style: { color: "#4ade80", size: mobile?(page) ? 12 : 14 })

  if mobile?(page)
    studio_go(page, tab_route(page, "preview"))
  elsif state[:preview_host]
    fill = preview_requires_bounded_host?(item, rendered)
    state[:preview_fill] = fill
    body = fill ? fill_preview_body(rendered) : rendered
    page.update(state[:preview_host], content: body)
  end
rescue Exception => error # User-authored source can raise SyntaxError or SystemExit.
  state[:preview] = state[:last_successful_preview] if state
  if state && state[:preview_host] && state[:last_successful_preview]
    page.update(state[:preview_host], content: state[:last_successful_preview])
  end
  message = "Run failed: #{error.message}"
  page.update(status, value: message, style: { color: "#f87171", size: mobile?(page) ? 12 : 14 })
end

def console_bar
  container(height: 48, bgcolor: "#090c0f", padding: { left: 14, right: 10 }, content: row(spacing: 12, children: [
    icon(icon: "chevron_right", color: TEXT),
    text("Console", style: { color: TEXT, size: 14, weight: "w700" }),
    container(expand: true, content: text("")),
    icon(icon: "delete_outline", color: "#60656d")
  ]))
end

# Category slug -> icon, for the lightweight gallery card thumbnails.
