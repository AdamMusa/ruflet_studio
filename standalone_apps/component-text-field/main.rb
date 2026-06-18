# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.title = "TextField"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: text_field(label: "Name", value: "Ruflet")
    )
  )
end
