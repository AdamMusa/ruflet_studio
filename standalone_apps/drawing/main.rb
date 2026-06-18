# frozen_string_literal: true

require "ruflet"
require "json"

def extract_pos(event)
  return nil unless event&.data

  data = event.data
  if data.is_a?(String)
    begin
      data = JSON.parse(data)
    rescue StandardError
      return nil
    end
  end

  return nil unless data.is_a?(Hash)

  # Flutter/Flet's GestureDetector emits flat local coords as lx/ly
  # (and global as gx/gy) on tap/tap_down/pan events. Prefer those.
  lx = data["lx"] || data[:lx]
  ly = data["ly"] || data[:ly]
  return { x: lx.to_f, y: ly.to_f } if lx && ly

  gx = data["gx"] || data[:gx]
  gy = data["gy"] || data[:gy]
  return { x: gx.to_f, y: gy.to_f } if gx && gy

  # Fallback for nested {localPosition: {x, y}} style payloads.
  pos = data["localPosition"] || data["local_position"] || data[:localPosition] || data[:local_position] ||
    data["l"] || data[:l] || data["g"] || data[:g] || data
  return nil unless pos.is_a?(Hash)

  x = pos["x"] || pos[:x]
  y = pos["y"] || pos[:y]
  return nil unless x && y

  { x: x.to_f, y: y.to_f }
end

Ruflet.run do |page|
  page.title = "Drawing Tool"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  strokes = []
  last_point = nil
  drawing_paint = paint(color: "#ff6b6b", stroke_width: 3, style: "stroke", stroke_cap: "round", stroke_join: "round")
  demo_shapes = [
    rect(x: 18, y: 18, width: 72, height: 44, border_radius: 8, paint: paint(color: "#4dabf7", stroke_width: 3, style: "stroke")),
    circle(x: 170, y: 40, radius: 22, paint: paint(color: "#ffd43b", style: "fill")),
    path(
      elements: [
        path_move_to(42, 156),
        path_line_to(92, 112),
        path_line_to(142, 156),
        path_close
      ],
      paint: paint(color: "#69db7c", stroke_width: 4, style: "stroke", stroke_join: "round")
    )
  ]
  drawing_canvas = canvas(
    demo_shapes,
    width: 420,
    height: 260,
    content: gesture_detector(
      on_pan_start: ->(e) {
        pos = extract_pos(e)
        last_point = pos
      },
      on_pan_update: ->(e) {
        pos = extract_pos(e)
        if last_point && pos
          strokes << line(x1: last_point[:x], y1: last_point[:y], x2: pos[:x], y2: pos[:y], paint: drawing_paint)
          page.update(drawing_canvas, shapes: demo_shapes + strokes)
        end
        last_point = pos
      },
      on_pan_end: ->(_e) { last_point = nil },
      drag_interval: 10
    )
  )
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: column(spacing: 8, tight: true, children: [status, drawing_canvas])
    )
  )
end
