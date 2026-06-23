# frozen_string_literal: true

require "ruflet"

def sensor_axis_value(data, key)
  value = data[key] || data[key.to_sym]
  value.is_a?(Numeric) ? format("%.3f", value) : value.to_s
end

def sensor_reading_label(data)
  x = sensor_axis_value(data, "x")
  y = sensor_axis_value(data, "y")
  z = sensor_axis_value(data, "z")
  "x: #{x}\ny: #{y}\nz: #{z}"
end

Ruflet.run do |page|
  page.padding = 0
  page.title = "Accelerometer"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  reading_text = text(value: "Waiting for accelerometer reading...")
  error_text = text(value: "")
  accelerometer = page.accelerometer(
    interval: 200,
    cancel_on_error: false,
    on_reading: lambda { |event|
      data = event&.data || {}
      page.update(reading_text, value: sensor_reading_label(data))
      page.update(error_text, value: "")
    },
    on_error: lambda { |event|
      message = event&.data&.dig("message") || event&.data.to_s
      page.update(error_text, value: "Accelerometer error: #{message}")
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
                button(content: "Start", on_click: ->(_e) { page.update(accelerometer, enabled: true) }),
                button(content: "Stop", on_click: ->(_e) { page.update(accelerometer, enabled: false) })
              ]
            )
          ]
        )
      )
    )
  )
end
