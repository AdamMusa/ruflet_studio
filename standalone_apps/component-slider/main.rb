# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Slider"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: slider(min: 0, max: 100, divisions: 10, value: 35, label: "Value = {value}")
    )
  )
end
