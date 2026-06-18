# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.title = "Browser Context Menu"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  page.browser_context_menu(key: "studio_browser_context_menu")
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: column(
        spacing: 8,
        children: [
          status,
          row(
            spacing: 8,
            children: [
              text_button(content: text(value: "Disable menu"), on_click: ->(_e) {
                page.disable_browser_context_menu(on_result: ->(_result, error) {
                  page.update(status, value: error ? "Disable failed: #{error}" : "Browser context menu disabled")
                })
              }),
              text_button(content: text(value: "Enable menu"), on_click: ->(_e) {
                page.enable_browser_context_menu(on_result: ->(_result, error) {
                  page.update(status, value: error ? "Enable failed: #{error}" : "Browser context menu enabled")
                })
              })
            ]
          )
        ]
      )
    )
  )
end
