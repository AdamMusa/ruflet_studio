# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "Container"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: container(
        width: 260,
        height: 120,
        padding: 16,
        bgcolor: "#172033",
        border_radius: 8,
        content: text(value: "Container with padding, color, radius, width, and height.")
      )
    )
  )
end
