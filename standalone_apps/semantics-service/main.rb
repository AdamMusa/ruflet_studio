# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.title = "Semantics Service"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status_text = text(value: "Semantics service registered.")
  page.semantics_service(
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
            button(
              content: "Refresh data",
              on_click: lambda { |_e|
                page.semantics_service(
                  key: "studio_semantics_service",
                  data: { "message" => "Updated from Showcase" }
                )
                page.update(status_text, value: "Semantics service data refreshed.")
              }
            )
          ]
        )
      )
    )
  )
end
