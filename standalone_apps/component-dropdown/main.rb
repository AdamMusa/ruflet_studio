# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.title = "Dropdown"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: dropdown(
        [
          dropdown_option("ruby", text: "Ruby"),
          dropdown_option("flutter", text: "Flutter"),
          dropdown_option("ruflet", text: "Ruflet")
        ],
        label: "Pick one",
        value: "ruflet",
        on_select: ->(event) { page.update(status, value: "Selected: #{event.value}") }
      )
    )
  )
end
