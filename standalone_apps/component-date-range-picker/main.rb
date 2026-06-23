# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "DateRangePicker"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  result = text(value: "Range: 2026-05-01 - 2026-05-21", style: { size: 14, color: "#6b7280" })
  dialog = date_range_picker(
    start_value: "2026-05-01",
    end_value: "2026-05-21",
    first_date: "2026-01-01",
    last_date: "2026-12-31",
    help_text: "Pick a date range",
    on_change: lambda do |event|
      start_value = event.control.props["start_value"]
      end_value = event.control.props["end_value"]
      page.update(result, value: "Range: #{start_value} - #{end_value}")
    end
  )
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: column(
        spacing: 10,
        children: [
          result,
          filled_button(content: text(value: "Open range picker"), on_click: ->(_e) { page.show_dialog(dialog) })
        ]
      )
    )
  )
end
