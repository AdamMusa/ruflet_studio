# frozen_string_literal: true

# === gallery/sections_media/screenshot.rb ===
module Gallery
  module SectionsMedia
    def build_screenshot(page, _status)
      status_text = text(value: "Screenshot control registered.")
      capture_area = screenshot(
        tooltip: "Screenshot area",
        content: container(
          width: 260,
          padding: 16,
          bgcolor: color_surface(page),
          content: column(
            spacing: 8,
            horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
            children: [
              icon(icon: "photo_camera", color: color_icon(page)),
              text(value: "Capture area", style: { size: 18, color: color_text(page) }),
              text(value: "Wrapped by screenshot", style: { size: 13, color: color_subtle(page) })
            ]
          )
        )
      )

      control(
        :safe_area,
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
    end
  end
end
