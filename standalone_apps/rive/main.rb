# frozen_string_literal: true

require "ruflet"

RIVE_SAMPLE_SRC = "https://cdn.rive.app/animations/vehicles.riv"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Rive"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"

  # The web client has no Rive renderer; show a notice there instead of a
  # broken "Unknown control: Rive" box. RUFLET_TARGET is set by `ruflet run --web`.
  if ENV["RUFLET_TARGET"] == "web" || page.web
    page.add(
      container(
        expand: true,
        alignment: "center",
        padding: 24,
        content: column(tight: true, horizontal_alignment: "center", spacing: 8, children: [
          text(value: "Rive", style: { size: 18, weight: "w700" }),
          text(value: "Rive animations run in the desktop and mobile clients.\nThe web client can't render them yet.",
               text_align: "center", style: { size: 13, color: "#6b7280" })
        ])
      )
    )
    next
  end

  status = text(value: "", style: { size: 12, color: "#6b7280" })
  animation = rive(
    RIVE_SAMPLE_SRC,
    width: 300,
    height: 300,
    fit: "contain",
    speed_multiplier: 1.0
  )
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: column(
        spacing: 12,
        children: [
          status,
          safe_area(content: column(
            spacing: 12,
            children: [
              container(
                width: 300,
                height: 300,
                border_radius: 12,
                bgcolor: "#f3f4f6",
                content: animation
              ),
              text(value: "Rive animation from #{RIVE_SAMPLE_SRC}", style: { size: 12, color: "#6b7280" }),
              slider(
                min: 0,
                max: 3,
                value: 1,
                divisions: 6,
                label: "Speed = {value}x",
                on_change: ->(e) {
                  page.update(animation, speed_multiplier: (e.data.is_a?(Hash) ? e.data["value"] : e.data).to_f || 1)
                  page.update(status, value: "Speed #{(e.data.is_a?(Hash) ? e.data['value'] : e.data).to_f || 1}x")
                }
              ),
              row(
                spacing: 8,
                wrap: true,
                run_spacing: 8,
                children: %w[contain cover fill fit_width fit_height none].map do |fit_value|
                  button(
                    content: text(value: fit_value),
                    on_click: ->(_e) {
                      page.update(animation, fit: fit_value)
                      page.update(status, value: "Fit: #{fit_value}")
                    }
                  )
                end
              )
            ]
          ))
        ]
      )
    )
  )
end
