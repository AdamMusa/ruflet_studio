# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "DatePicker"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  result = text(value: "Date: 2026-05-21", style: { size: 14, color: "#6b7280" })
  dialog = date_picker(
    value: "2026-05-21",
    first_date: "2026-01-01",
    last_date: "2026-12-31",
    help_text: "Pick a date",
    on_change: ->(event) { page.update(result, value: "Date: #{event.control.props["value"]}") }
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
          filled_button(content: text(value: "Open date picker"), on_click: ->(_e) { page.show_dialog(dialog) })
        ]
      )
    )
  )
end
