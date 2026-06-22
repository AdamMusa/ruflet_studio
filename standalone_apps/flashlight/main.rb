# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Flashlight"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  flashlight = page.service(
    :flashlight,
    on_error: ->(e) { page.update(status, value: "Flashlight error: #{e.data}") }
  )
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: column(
        spacing: 8,
        children: [
          status,
          row(
            spacing: 8,
            children: [
              text_button(content: text(value: "On"), on_click: ->(_e) {
                page.invoke(flashlight, "on")
                page.update(status, value: "Flashlight on")
              }),
              text_button(content: text(value: "Off"), on_click: ->(_e) {
                page.invoke(flashlight, "off")
                page.update(status, value: "Flashlight off")
              })
            ]
          )
        ]
      )
    )
  )
end
