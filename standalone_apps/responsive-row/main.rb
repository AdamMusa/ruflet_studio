# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "Responsive Row"
  page.theme_mode = "system"

  colors = ["#2563eb", "#7c3aed", "#db2777", "#0f766e", "#ea580c", "#0891b2"]

  # Each cell takes the full 12 columns on phones (1 per row), 6 on tablets
  # (2 per row) and 4 on desktops (3 per row), via a per-breakpoint `col` map.
  cell = lambda do |index, color|
    container(
      col: { "xs" => 12, "sm" => 6, "md" => 4 },
      height: 96,
      padding: 16,
      border_radius: 10,
      bgcolor: color,
      alignment: "center",
      content: text(value: "Cell #{index}", style: { size: 16, weight: "w700", color: "#ffffff" })
    )
  end

  page.add(
    column(
      expand: true,
      scroll: "auto",
      spacing: 12,
      children: [
        container(
          padding: { left: 20, right: 20, top: 20 },
          content: column(
            spacing: 4,
            children: [
              text(value: "Responsive Row", style: { size: 22, weight: "w700" }),
              text(
                value: "Resize the window: cells reflow — 1 per row on phones, 2 on tablets, 3 on desktop.",
                style: { size: 13, color: "#6b7280" }
              )
            ]
          )
        ),
        container(
          padding: { left: 20, right: 20, bottom: 20 },
          content: responsive_row(
            spacing: 12,
            run_spacing: 12,
            children: colors.each_with_index.map { |color, i| cell.call(i + 1, color) }
          )
        )
      ]
    )
  )
end
