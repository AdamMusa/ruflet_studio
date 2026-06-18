# frozen_string_literal: true

require "ruflet"

def barometer_reading_label(data)
  pressure = data["pressure"] || data[:pressure]
  value = pressure.is_a?(Numeric) ? format("%.3f", pressure) : pressure.to_s
  "pressure: #{value}"
end

Ruflet.run do |page|
  page.title = "Barometer"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  reading_text = text(value: "Waiting for barometer reading...")
  error_text = text(value: "")
  barometer = page.barometer(
    interval: 200,
    enabled: false,
    cancel_on_error: false,
    on_reading: lambda { |event|
      data = event&.data || {}
      page.update(reading_text, value: barometer_reading_label(data))
      page.update(error_text, value: "")
    },
    on_error: lambda { |event|
      message = event&.data&.dig("message") || event&.data.to_s
      page.update(error_text, value: "Barometer error: #{message}")
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
            reading_text,
            error_text,
            row(
              alignment: Ruflet::MainAxisAlignment::CENTER,
              spacing: 8,
              children: [
                button(content: "Start", on_click: ->(_e) { page.update(barometer, enabled: true) }),
                button(content: "Stop", on_click: ->(_e) { page.update(barometer, enabled: false) })
              ]
            )
          ]
        )
      )
    )
  )
end
