# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "Tabs"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: tabs(
        length: 2,
        selected_index: 0,
        content: column(
          spacing: 8,
          children: [
            tab_bar([
              tab(label: "Controls", icon: "widgets"),
              tab(label: "Services", icon: "settings")
            ]),
            container(
              height: 140,
              content: tab_bar_view([
                container(
                  alignment: "center",
                  content: text(value: "Controls tab body")
                ),
                container(
                  alignment: "center",
                  content: text(value: "Services tab body")
                )
              ])
            )
          ]
        ),
        on_change: ->(event) { page.update(status, value: "Tab index: #{event.value}") }
      )
    )
  )
end
