# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Icon"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: row(
        spacing: 12,
        children: [
          icon(icon: "home", color: "#74c0fc"),
          icon(icon: "settings", color: "#adb5bd"),
          icon(icon: "check_circle", color: "#69db7c")
        ]
      )
    )
  )
end
