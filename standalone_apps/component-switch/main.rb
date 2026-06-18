# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.title = "Switch"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: switch(label: "Enabled", value: true, on_change: ->(_e) { page.update(status, value: "Switch changed") })
    )
  )
end
