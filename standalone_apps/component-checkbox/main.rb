# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Checkbox"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: checkbox(label: "I like Ruflet", value: true, on_change: ->(event) { page.update(status, value: "Checked: #{event.value}") })
    )
  )
end
