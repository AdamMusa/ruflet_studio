# frozen_string_literal: true

CATEGORY_ICON = CATEGORIES.each_with_object({}) do |(_label, _desc, icon_value, slug), acc|
  acc[slug] = icon_value
end.freeze

# A static, lightweight thumbnail for a gallery card. The grid renders ~40 of
# these at once; embedding the *live* preview here (video/webview/map/sensors)
# overwhelms iOS and blanks the grid. The live preview lives in the detail view,
# one at a time, where it works fine.
def gallery_card_thumb(item)
  container(expand: true, alignment: "center", clip_behavior: "hardEdge",
    content: gallery_thumbnail(item))
end

def gallery_thumbnail(item)
  slug = item[:slug]
  return compact_counter_thumbnail if slug == "counter"
  return static_todo_thumbnail if slug == "todo"
  return static_calculator_thumbnail if slug == "calculator"
  return compact_code_thumbnail if slug == "code-editor"
  return compact_layout_thumbnail if %w[responsive-row components].include?(slug)
  return compact_drawing_thumbnail if slug == "drawing"
  return compact_buttons_thumbnail if %w[material cupertino].include?(slug)
  return compact_chart_thumbnail if slug == "charts"
  return compact_game_thumbnail if slug == "minesweeper"
  return static_icons_thumbnail if slug == "icon-search"
  return static_flet_logo_thumbnail if slug == "animation"
  return compact_rive_thumbnail if slug == "rive"
  return compact_spinkit_thumbnail if slug == "spinkit"
  return compact_services_thumbnail(item) if item[:category] == "services"
  return static_control_thumbnail(item[:slug]) if item[:component_slug]

  compact_feature_thumbnail(item)
end

def compact_spinkit_thumbnail
  column(tight: true, horizontal_alignment: "center", spacing: 12, children: [
    row(tight: true, alignment: "center", spacing: 14, children: [
      spinkit(rotating_circle: { color: "#2563eb", size: 30 }),
      spinkit(wave: { color: "#7c3aed", size: 30 }),
      spinkit(cube_grid: { color: "#db2777", size: 30 })
    ]),
    row(tight: true, alignment: "center", spacing: 14, children: [
      spinkit(pumping_heart: { color: "#ef4444", size: 30 }),
      spinkit(dual_ring: { color: "#0ea5e9", size: 30 }),
      spinkit(folding_cube: { color: "#16a34a", size: 30 })
    ])
  ])
end

def compact_counter_thumbnail
  column(tight: true, horizontal_alignment: "center", spacing: 8, children: [
    text("0", style: { color: "#111827", size: 28, weight: "w700" }),
    row(tight: true, spacing: 8, children: [
      mini_pill("-1", "#dbeafe", "#1d4ed8"),
      mini_pill("+1", "#2563eb", "#ffffff")
    ])
  ])
end

def mini_pill(label, bgcolor, color)
  container(width: 58, height: 24, border_radius: 12, bgcolor: bgcolor,
    alignment: "center", content: text(label, style: { color: color, size: 10 }))
end

def compact_code_thumbnail
  container(width: 250, height: 116, padding: 10, border_radius: 6, bgcolor: "#20242b",
    content: column(spacing: 5, children: [
      text("1  require \"ruflet\"", style: { color: "#c678dd", size: 8 }),
      text("2  Ruflet.run do |page|", style: { color: "#61afef", size: 8 }),
      text("3    page.add(text(\"Hello\"))", style: { color: "#98c379", size: 8 }),
      text("4  end", style: { color: "#61afef", size: 8 })
    ]))
end

def compact_layout_thumbnail
  column(tight: true, spacing: 6, children: [
    row(tight: true, spacing: 6, children: [
      mini_layout_block(76, "#bfdbfe"), mini_layout_block(152, "#bbf7d0")
    ]),
    row(tight: true, spacing: 6, children: [
      mini_layout_block(134, "#fecdd3"), mini_layout_block(94, "#fde68a")
    ])
  ])
end

def mini_layout_block(width, color)
  container(width: width, height: 38, border_radius: 5, bgcolor: color)
end

def compact_drawing_thumbnail
  stack(width: 240, height: 112, children: [
    container(width: 240, height: 112, border_radius: 8, bgcolor: "#ffffff"),
    container(left: 18, top: 20, width: 76, height: 54, border_radius: 10, bgcolor: "#60a5fa"),
    container(left: 82, top: 46, width: 92, height: 10, border_radius: 5, bgcolor: "#f43f5e", rotate: 0.35),
    container(left: 170, top: 22, width: 42, height: 42, border_radius: 21, bgcolor: "#fbbf24")
  ])
end

def compact_buttons_thumbnail
  column(tight: true, horizontal_alignment: "center", spacing: 10, children: [
    mini_button("Primary", "#2563eb", "#ffffff"),
    mini_button("Secondary", "#e2e8f0", "#334155")
  ])
end

def mini_button(label, bgcolor, color)
  container(width: 150, height: 30, border_radius: 15, bgcolor: bgcolor,
    alignment: "center", content: text(label, style: { color: color, size: 10 }))
end

def compact_chart_thumbnail
  row(alignment: "end", spacing: 12, children: [36, 72, 52, 94, 64].map.with_index do |height, index|
    container(width: 26, height: height, border_radius: 4,
      bgcolor: ["#60a5fa", "#4ade80", "#fb7185", "#fbbf24", "#a78bfa"][index])
  end)
end

def compact_game_thumbnail
  cells = Array.new(16) do |index|
    marked = (index % 5).zero?
    container(width: 24, height: 24, border_radius: 3,
      bgcolor: marked ? "#ef4444" : "#cbd5e1", alignment: "center",
      content: marked ? icon(icon: "flag", color: "#ffffff", size: 11) : nil)
  end
  column(tight: true, spacing: 4, children: cells.each_slice(4).map do |slice|
    row(tight: true, spacing: 4, children: slice)
  end)
end

def compact_rive_thumbnail
  column(tight: true, horizontal_alignment: "center", spacing: 8, children: [
    icon(icon: "directions_car", color: "#2563eb", size: 52),
    row(tight: true, spacing: 5,
      children: Array.new(5) { container(width: 24, height: 4, border_radius: 2, bgcolor: "#94a3b8") })
  ])
end

def compact_services_thumbnail(item)
  icons = {
    "audio" => :audiotrack, "audio-recorder" => :mic, "video" => :play_circle,
    "camera" => :photo_camera, "map" => :map, "geolocator" => :location_on,
    "file-picker" => :folder_open, "share" => :share, "webview" => :language,
    "battery" => :battery_full, "flashlight" => :flashlight_on
  }
  icon_value = Ruflet::MaterialIcons[icons[item[:slug]] || :sensors]
  column(tight: true, horizontal_alignment: "center", spacing: 10, children: [
    container(width: 72, height: 72, border_radius: 36, bgcolor: "#dbeafe",
      alignment: "center", content: icon(icon: icon_value, color: "#2563eb", size: 34)),
    text(item[:title], style: { color: "#334155", size: 11, weight: "w600" })
  ])
end

def compact_feature_thumbnail(item)
  icon_value = CATEGORY_ICON[item[:category]] || "code"
  column(tight: true, horizontal_alignment: "center", spacing: 10, children: [
    icon(icon: icon_value, color: "#2563eb", size: 40),
    container(width: 150, height: 8, border_radius: 4, bgcolor: "#cbd5e1"),
    container(width: 100, height: 8, border_radius: 4, bgcolor: "#e2e8f0")
  ])
end

def thumbnail_for(page, slug)
  item = example(slug)
  return gallery_card_thumb(item) if item[:gallery]

  case slug
  when "calculator"
    static_calculator_thumbnail
  when "todo"
    static_todo_thumbnail
  when "animation"
    static_flet_logo_thumbnail
  when "icons-browser"
    static_icons_thumbnail
  when "router"
    static_router_thumbnail
  else
    static_control_thumbnail(slug)
  end
end
