# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "InteractiveViewer"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: interactive_viewer(
        container(
          width: 360,
          height: 220,
          padding: 18,
          bgcolor: "#172033",
          border_radius: 8,
          content: column(
            spacing: 12,
            horizontal_alignment: "center",
            children: [
              icon(icon: Ruflet::MaterialIcons[:open_with], color: "#74c0fc", size: 48),
              text(value: "Pinch, scroll, or drag", style: { size: 16, weight: "w700", color: "#111827" }),
              text(value: "InteractiveViewer content", style: { size: 13, color: "#6b7280" })
            ]
          )
        ),
        min_scale: 0.5,
        max_scale: 4,
        pan_enabled: true,
        scale_enabled: true,
        boundary_margin: { left: 80, top: 80, right: 80, bottom: 80 },
        on_interaction_update: ->(_event) { page.update(status, value: "InteractiveViewer updated") }
      )
    )
  )
end
