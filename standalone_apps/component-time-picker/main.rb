# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.title = "TimePicker"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  result = text(value: "Time: 09:30", style: { size: 14, color: "#6b7280" })
  dialog = time_picker(
    value: "09:30",
    help_text: "Pick a time",
    on_change: ->(event) { page.update(result, value: "Time: #{event.control.props["value"]}") }
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
          filled_button(content: text(value: "Open time picker"), on_click: ->(_e) { page.show_dialog(dialog) })
        ]
      )
    )
  )
end
