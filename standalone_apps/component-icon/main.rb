# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
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
          icon(icon: Ruflet::MaterialIcons::HOME, color: "#74c0fc"),
          icon(icon: Ruflet::MaterialIcons::SETTINGS, color: "#adb5bd"),
          icon(icon: Ruflet::MaterialIcons::CHECK_CIRCLE, color: "#69db7c")
        ]
      )
    )
  )
end
