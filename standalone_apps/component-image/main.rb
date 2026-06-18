# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.title = "Image"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: container(
        width: 260,
        height: 140,
        clip_behavior: "antiAlias",
        border_radius: 8,
        content: image(src: "https://picsum.photos/520/280", fit: "cover")
      )
    )
  )
end
