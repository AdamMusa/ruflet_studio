# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.title = "Radio"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: radio_group(
        column(
          spacing: 6,
          children: [
            radio(label: "Ruby", value: "ruby"),
            radio(label: "Flutter", value: "flutter"),
            radio(label: "Ruflet", value: "ruflet")
          ]
        ),
        value: "ruflet",
        on_change: ->(event) { page.update(status, value: "Radio: #{event.value}") }
      )
    )
  )
end
