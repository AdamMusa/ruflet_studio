# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "Screenshot"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status_text = text(value: "Screenshot control registered.")
  capture_area = screenshot(
    tooltip: "Screenshot area",
    content: container(
      width: 260,
      padding: 16,
      bgcolor: "#ffffff",
      content: column(
        spacing: 8,
        horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
        children: [
          icon(icon: "photo_camera", color: "#374151"),
          text(value: "Capture area", style: { size: 18, color: "#111827" }),
          text(value: "Wrapped by screenshot", style: { size: 13, color: "#6b7280" })
        ]
      )
    )
  )
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: safe_area(
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 10,
          children: [
            capture_area,
            status_text,
            button(content: "Capture", on_click: lambda { |_e|
              page.update(status_text, value: "Capturing…")
              capture_area.capture(on_result: lambda { |result, error|
                size = result.respond_to?(:bytesize) ? result.bytesize : result.to_s.bytesize
                page.update(status_text, value: error ? "Capture error: #{error}" : "Captured #{size} PNG bytes.")
              })
            })
          ]
        )
      )
    )
  )
end
