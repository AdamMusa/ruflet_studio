# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "Shake Detector"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  shake_count = 0
  state_text = text(value: "Waiting for shake...")
  page.shake_detector(
    minimum_shake_count: 1,
    shake_count_reset_time_ms: 1_500,
    shake_slop_time_ms: 250,
    shake_threshold_gravity: 1.5,
    on_shake: lambda { |_event|
      shake_count += 1
      page.update(state_text, value: "Shake count: #{shake_count}")
    }
  )
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: safe_area(
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 8,
          children: [
            state_text,
            row(
              alignment: Ruflet::MainAxisAlignment::CENTER,
              spacing: 8,
              children: [
                button(
                  content: "Reset",
                  on_click: lambda { |_e|
                    shake_count = 0
                    page.update(state_text, value: "Waiting for shake...")
                  }
                )
              ]
            )
          ]
        )
      )
    )
  )
end
