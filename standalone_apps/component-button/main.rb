# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "Button"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: row(
        spacing: 8,
        wrap: true,
        children: [
          filled_button(content: text(value: "Filled"), on_click: ->(_e) { page.update(status, value: "Filled button clicked") }),
          button(content: text(value: "Button"), on_click: ->(_e) { page.update(status, value: "Button clicked") }),
          text_button(content: text(value: "Text"), on_click: ->(_e) { page.update(status, value: "Text button clicked") })
        ]
      )
    )
  )
end
