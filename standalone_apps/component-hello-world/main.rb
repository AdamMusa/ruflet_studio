# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.title = "Hello World"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: text(value: "Hello world", style: { size: 28, weight: "w700", color: "#111827" })
    )
  )
end
