# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "Semantics Service"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status_text = text(value: "Semantics service registered.")
  semantics = page.semantics_service(
    key: "studio_semantics_service",
    data: { "message" => "Showcase semantics service sample" }
  )
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: safe_area(
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 8,
          children: [
            text(value: "Semantics Service"),
            status_text,
            button(content: "Announce message", on_click: lambda { |_e|
              semantics.announce_message("Ruflet semantics service is working", on_result: lambda { |_result, error|
                page.update(status_text, value: error ? "Announcement error: #{error}" : "Accessibility message announced.")
              })
            }),
            button(content: "Accessibility features", on_click: lambda { |_e|
              semantics.get_accessibility_features(on_result: lambda { |result, error|
                page.update(status_text, value: error ? "Features error: #{error}" : "Features: #{result.inspect}")
              })
            })
          ]
        )
      )
    )
  )
end
