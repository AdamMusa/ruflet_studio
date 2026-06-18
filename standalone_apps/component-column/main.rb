# frozen_string_literal: true

require "ruflet"

def component_chip(label)
  container(
    padding: { left: 12, right: 12, top: 8, bottom: 8 },
    bgcolor: "#172033",
    border_radius: 8,
    content: text(value: label)
  )
end

Ruflet.run do |page|
  page.title = "Column"
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
          component_chip("Top"),
          component_chip("Middle"),
          component_chip("Bottom")
        ]
      )
    )
  )
end
