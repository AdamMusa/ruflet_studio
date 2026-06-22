# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Secure Storage"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  storage = page.secure_storage(key: "studio_secure_storage")
  key = "showcase_sample"
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
            wrap: true,
            children: [
              text_button(content: text(value: "Set"), on_click: ->(_e) {
                storage.set(key, "hello", on_result: ->(_result, error) {
                  page.update(status, value: error ? "Set error: #{error}" : "Saved secure value")
                })
              }),
              text_button(content: text(value: "Get"), on_click: ->(_e) {
                storage.get(key, on_result: ->(result, error) {
                  page.update(status, value: error ? "Get error: #{error}" : "Value: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Clear"), on_click: ->(_e) {
                storage.clear(on_result: ->(_result, error) {
                  page.update(status, value: error ? "Clear error: #{error}" : "Secure storage cleared")
                })
              })
            ]
          )
        ]
      )
    )
  )
end
