# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.title = "ProgressRing"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: progress_ring(stroke_width: 5, color: "#69db7c", bgcolor: "#172033")
    )
  )
end
