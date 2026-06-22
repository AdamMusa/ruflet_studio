# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "GridView"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: container(
        height: 260,
        content: grid_view(
          runs_count: 3,
          max_extent: 120,
          spacing: 8,
          run_spacing: 8,
          child_aspect_ratio: 1.15,
          children: (1..12).map do |index|
            container(
              padding: 10,
              bgcolor: index.even? ? "#172033" : "#1f2937",
              border_radius: 8,
              content: column(
                spacing: 6,
                horizontal_alignment: "center",
                children: [
                  icon(icon: "widgets", color: "#9dccff"),
                  text(value: "Item #{index}", style: { size: 13, color: "#111827" })
                ]
              )
            )
          end
        )
      )
    )
  )
end
