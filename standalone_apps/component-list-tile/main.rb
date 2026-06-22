# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "ListTile"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: list_tile(
        leading: icon(icon: Ruflet::MaterialIcons::INFO),
        title: text(value: "ListTile title"),
        subtitle: text(value: "Subtitle"),
        trailing: icon(icon: Ruflet::MaterialIcons::CHEVRON_RIGHT)
      )
    )
  )
end
