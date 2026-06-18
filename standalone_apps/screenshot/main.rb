# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.title = "Screenshot"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status_text = text(value: "Screenshot control registered.")
  capture_area = page.screenshot(
    tooltip: "Screenshot area",
    content: container(
      width: 260,
      padding: 16,
      bgcolor: "#ffffff",
      content: column(
        spacing: 8,
        horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
        children: [
          icon(icon: Ruflet::MaterialIcons::PHOTO_CAMERA, color: "#374151"),
          text(value: "Capture area", style: { size: 18, color: "#111827" }),
          text(value: "Wrapped by page.screenshot", style: { size: 13, color: "#6b7280" })
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
            button(
              content: "Refresh",
              on_click: ->(_e) { page.update(status_text, value: "Screenshot control refreshed.") }
            )
          ]
        )
      )
    )
  )
end
