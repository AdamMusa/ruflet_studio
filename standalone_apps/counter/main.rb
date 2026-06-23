# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "Counter"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  count = 0
  value = text(value: count.to_s, style: { size: 28 })
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: container(
        width: 320,
        padding: 12,
        border_radius: 12,
        bgcolor: "#f3f4f6",
        content: column(
          spacing: 12,
          children: [
            status,
            row(alignment: "center", children: [value]),
            row(
              alignment: "center",
              spacing: 10,
              children: [
                elevated_button(
                  width: 120,
                  content: text(value: "-1"),
                  on_click: ->(_e) {
                    count -= 1
                    page.update(value, value: count.to_s)
                    page.update(status, value: "Counter: #{count}")
                  }
                ),
                elevated_button(
                  width: 120,
                  content: text(value: "+1"),
                  on_click: ->(_e) {
                    count += 1
                    page.update(value, value: count.to_s)
                    page.update(status, value: "Counter: #{count}")
                  }
                )
              ]
            ),
          ]
        )
      )
    )
  )
end
