# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Text"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: column(
        spacing: 8,
        children: [
          text(value: "Text"),
          text(value: "Large bold text", style: { size: 22, weight: "w700", color: "#9dccff" }),
          text(value: "Muted secondary text", style: { size: 14, color: "#6b7280" })
        ]
      )
    )
  )
end
