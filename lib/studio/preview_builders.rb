# frozen_string_literal: true

def preview_for(page, slug, large:)
  item = example(slug)
  return gallery_preview(page, item, large: large) if item[:gallery]

  case slug
  when "calculator"
    calculator_preview(page, large)
  when "todo"
    todo_preview
  when "animation"
    flet_logo_preview
  when "icons-browser"
    icons_preview
  when "router"
    router_preview
  when "routing-two-pages"
    routing_preview
  else
    control_example_preview(slug, large)
  end
end

def gallery_status
  text(value: "", style: { color: MUTED, size: 12 })
end

def gallery_preview(page, item, large:)
  content =
    if item[:component_slug]
      GALLERY_PREVIEW.build_component_detail(page, gallery_status, item[:component_slug])
    else
      GALLERY_PREVIEW.public_send(item[:builder], page, gallery_status)
    end

  container(
    width: large ? nil : 320,
    height: large ? nil : 132,
    padding: large ? 0 : 8,
    clip_behavior: "hardEdge",
    content: large ? content : column(height: 116, scroll: "hidden", children: [content])
  )
rescue StandardError => e
  container(width: large ? 420 : 260, padding: 16, border_radius: 8, bgcolor: "#ffffff",
    content: column(spacing: 8, children: [
      text("Preview unavailable", style: { color: "#111827", weight: "w700" }),
      text(e.message, style: { color: "#4b5563", size: 12, max_lines: 3 })
    ]))
end

def calculator_preview(page, large)
  state = { current: "0", left: nil, operator: nil, reset: false }
  display = text("0", style: { color: "#ffffff", size: large ? 28 : 16 })

  apply = lambda do |value|
    case value
    when "AC"
      state[:current] = "0"
      state[:left] = nil
      state[:operator] = nil
      state[:reset] = false
    when "+/-"
      state[:current] = state[:current].start_with?("-") ? state[:current][1..] : "-#{state[:current]}"
    when "%"
      state[:current] = format_calc_number(state[:current].to_f / 100.0)
    when "/", "*", "-", "+"
      state[:left] = state[:current].to_f
      state[:operator] = value
      state[:reset] = true
    when "="
      if state[:left] && state[:operator]
        right = state[:current].to_f
        result =
          case state[:operator]
          when "/" then right.zero? ? 0 : state[:left] / right
          when "*" then state[:left] * right
          when "-" then state[:left] - right
          else state[:left] + right
          end
        state[:current] = format_calc_number(result)
        state[:left] = nil
        state[:operator] = nil
        state[:reset] = true
      end
    when "."
      state[:current] = "0" if state[:reset]
      state[:reset] = false
      state[:current] += "." unless state[:current].include?(".")
    else
      state[:current] = state[:reset] || state[:current] == "0" ? value : "#{state[:current]}#{value}"
      state[:reset] = false
    end

    page&.update(display, value: state[:current])
  end

  container(width: large ? 340 : 270, padding: large ? 16 : 18, border_radius: 20, bgcolor: "#000000",
    content: column(spacing: 12, children: [
      row(alignment: "end", children: [display]),
      calc_row(%w[AC +/- % /], large, apply),
      calc_row(%w[7 8 9 *], large, apply),
      calc_row(%w[4 5 6 -], large, apply),
      calc_row(%w[1 2 3 +], large, apply),
      calc_row(%w[0 . =], large, apply)
    ]))
end

def format_calc_number(value)
  return "0" if value.nan? || value.infinite?

  formatted = value.round(8).to_s
  formatted.sub(/\.0\z/, "")
end

def calc_row(values, large, apply)
  row(spacing: large ? 8 : 6, children: values.map { |value| calc_button(value, large, apply) })
end

def calc_button(value, large, apply)
  orange = %w[/ * - + =].include?(value)
  button(expand: value == "0", width: value == "0" ? nil : (large ? 62 : 54), height: large ? 42 : 26,
    bgcolor: orange ? ORANGE : (value =~ /\d|\./ ? "#3f3f3f" : "#dce3e5"),
    color: orange || value =~ /\d|\./ ? "#ffffff" : "#111111",
    on_click: ->(_e) { apply.call(value) },
    content: text(value, style: { color: orange || value =~ /\d|\./ ? "#ffffff" : "#111111", size: large ? 18 : 10, weight: "w700" }))
end

def static_calculator_thumbnail
  container(width: 224, padding: 8, border_radius: 14, bgcolor: "#000000",
    content: column(spacing: 4, children: [
      row(alignment: "end", children: [text("0", style: { color: "#ffffff", size: 13 })]),
      static_calc_row([false, false, false, true]),
      static_calc_row([false, false, false, true]),
      static_calc_row([false, false, false, true]),
      static_calc_row([false, false, false, true])
    ]))
end

def static_calc_row(actions)
  row(spacing: 5, children: actions.map { |action| static_calc_button(action) })
end

def static_calc_button(action)
  container(width: 40, height: 18, border_radius: 12, bgcolor: action ? ORANGE : "#3f3f3f")
end

def static_todo_thumbnail
  container(padding: 10, bgcolor: PREVIEW_BG, content: column(spacing: 6, children: [
    text("Todos", style: { color: "#111827", weight: "w700", size: 13 }),
    container(height: 22, border: { width: 1, color: "#9ca3af" }, content: text(" What needs to be done?", style: { size: 9, color: "#374151" })),
    static_todo_line(true, "Release new Ruflet"),
    static_todo_line(true, "Update docs"),
    static_todo_line(false, "Write a blog post")
  ]))
end

def static_todo_line(done, label)
  row(spacing: 8, children: [
    container(width: 10, height: 10, border: { width: 1, color: "#64748b" }, bgcolor: done ? "#5b7da9" : PREVIEW_BG),
    text(label, style: { color: "#111827", size: 9 })
  ])
end

def static_flet_logo_thumbnail
  row(tight: true, alignment: "center", spacing: 8, children: [
    compact_logo_column("#df3266", [3, 2, 3]),
    compact_logo_column("#ffc13d", [1, 1, 4]),
    compact_logo_column("#88c557", [4, 2, 4]),
    compact_logo_column("#5d3dbb", [4, 1, 1])
  ])
end

def compact_logo_column(color, rows)
  column(tight: true, spacing: 3, children: rows.map do |count|
    row(tight: true, spacing: 3, children: Array.new(count) do
      container(width: 9, height: 9, bgcolor: color, border_radius: 2)
    end)
  end)
end

def static_icons_thumbnail
  column(spacing: 8, children: [
    container(height: 26, border: { width: 1, color: "#9ca3af" }, content: text("  add", style: { color: "#111827", size: 10 })),
    row(spacing: 16, children: ["add", "photo_camera", "alarm", "accessibility"].map { |i| icon(icon: i, color: "#446b9e", size: 20) })
  ])
end

def static_router_thumbnail
  column(spacing: 8, children: [
    text("Router Demo", style: { color: "#111827", weight: "w700", size: 12 }),
    row(spacing: 12, children: %w[Home Projects Settings].map { |label| text(label, style: { color: label == "Home" ? "#2563eb" : "#111827", size: 9 }) }),
    text("Welcome to the Router Demo!", style: { color: "#111827", size: 10 })
  ])
end

def static_routing_thumbnail
  column(spacing: 8, children: [
    row(spacing: 20, children: [
      text("Flet app", style: { color: "#111827", size: 14, weight: "w700" }),
      container(width: 34, height: 18, border_radius: 12, bgcolor: "#d1d5db")
    ]),
    container(width: 92, height: 22, border_radius: 14, bgcolor: "#e8edf5", alignment: "center",
      content: text("Visit Store", style: { color: "#46658d", size: 9 }))
  ])
end

def static_control_thumbnail(slug)
  control_example_preview(slug, false)
end

def control_example_preview(slug, large)
  title = example(slug)[:title]
  case title
  when "Card"
    container(width: large ? 340 : 220, padding: 18, border_radius: 8, bgcolor: "#ffffff",
      content: column(spacing: 10, children: [
        text("Card title", style: { color: "#111827", size: large ? 22 : 13, weight: "w700" }),
        text("Cards group related content and actions.", style: { color: "#4b5563", size: large ? 14 : 9 }),
        row(spacing: 8, children: [outlined_button(content: text("Cancel")), filled_button(content: text("Open"))])
      ]))
  when "Column"
    column(spacing: large ? 14 : 7, children: %w[First Second Third].map.with_index do |label, i|
      container(width: large ? 260 : 170, height: large ? 44 : 24, border_radius: 6, bgcolor: ["#dbeafe", "#dcfce7", "#fee2e2"][i], alignment: "center",
        content: text("#{label} item", style: { color: "#111827", size: large ? 14 : 9 }))
    end)
  when "Container"
    container(width: large ? 280 : 190, height: large ? 150 : 90, border_radius: 14, bgcolor: "#dbeafe", alignment: "center",
      content: text("Container", style: { color: "#1e3a8a", size: large ? 22 : 13, weight: "w700" }))
  when "DataTable"
    container(width: large ? 360 : 230, padding: 12, bgcolor: "#ffffff", border_radius: 6,
      content: column(spacing: 8, children: [
        row(spacing: large ? 78 : 36, children: [text("Name", style: { color: "#111827", weight: "w700" }), text("Role", style: { color: "#111827", weight: "w700" })]),
        container(height: 1, bgcolor: "#d1d5db"),
        row(spacing: large ? 92 : 50, children: [text("Ada", style: { color: "#111827" }), text("Engineer", style: { color: "#111827" })]),
        row(spacing: large ? 98 : 55, children: [text("Lin", style: { color: "#111827" }), text("Designer", style: { color: "#111827" })])
      ]))
  when "Divider"
    column(width: large ? 320 : 220, spacing: 14, children: [
      text("Above", style: { color: "#111827", size: large ? 18 : 12 }),
      container(height: 1, bgcolor: "#9ca3af"),
      text("Below", style: { color: "#111827", size: large ? 18 : 12 })
    ])
  when "GridView"
    grid_view(width: large ? 340 : 230, height: large ? 240 : 130, max_extent: large ? 76 : 48, spacing: 10, run_spacing: 10,
      children: Array.new(8) { |i| container(height: large ? 58 : 32, border_radius: 8, bgcolor: i.even? ? "#bfdbfe" : "#fecdd3", alignment: "center", content: text((i + 1).to_s, style: { color: "#111827" })) })
  else
    container(width: large ? 340 : 230, padding: 18, border_radius: 8, bgcolor: "#ffffff",
      content: column(spacing: 14, children: [
        text(title, style: { color: "#111827", size: large ? 24 : 15, weight: "w700" }),
        text("Live Ruflet preview", style: { color: "#4b5563", size: large ? 14 : 10 }),
        filled_button(content: text("Action"))
      ]))
  end
end

def todo_preview
  container(padding: 12, bgcolor: PREVIEW_BG, content: column(spacing: 8, children: [
    text("Todos", style: { color: "#111827", weight: "w700" }),
    row(spacing: 8, children: [container(expand: true, height: 28, border: { width: 1, color: "#9ca3af" }, content: text(" What needs to be done?", style: { size: 10, color: "#374151" })), container(width: 32, height: 32, bgcolor: "#dbeafe", border_radius: 8, content: text("+", style: { color: "#2563eb" }))]),
    checkbox(label: "Release new Ruflet", value: true),
    checkbox(label: "Update docs", value: true),
    checkbox(label: "Write a blog post", value: false)
  ]))
end

def flet_logo_preview
  row(alignment: "center", spacing: 22, children: [
    logo_column("#df3266", [3, 2, 3]),
    logo_column("#ffc13d", [1, 1, 4]),
    logo_column("#88c557", [4, 2, 4]),
    logo_column("#5d3dbb", [4, 1, 1])
  ])
end

def logo_column(color, rows)
  column(spacing: 6, children: rows.map { |count| row(spacing: 6, children: Array.new(count) { container(width: 18, height: 18, bgcolor: color, border_radius: 3) }) })
end

def icons_preview
  column(spacing: 10, children: [
    container(height: 30, border: { width: 1, color: "#9ca3af" }, content: text("  add", style: { color: "#111827" })),
    row(spacing: 16, children: ["add", "photo_camera", "alarm", "accessibility"].map { |i| icon(icon: i, color: "#446b9e") })
  ])
end

def router_preview
  column(spacing: 10, children: [
    text("Router Demo", style: { color: "#111827", weight: "w700" }),
    row(spacing: 12, children: %w[Home Projects Settings].map { |label| text(label, style: { color: label == "Home" ? "#2563eb" : "#111827", size: 12 }) }),
    text("Welcome to the Router Demo!", style: { color: "#111827" }),
    filled_button(content: text("Browse projects"))
  ])
end

def routing_preview
  column(spacing: 12, children: [
    row(spacing: 20, children: [text("Flet app", style: { color: "#111827", size: 20, weight: "w700" }), switch(value: false, label: "Dark mode")]),
    outlined_button(content: text("Visit Store")),
    outlined_button(content: text("Do something"))
  ])
end
