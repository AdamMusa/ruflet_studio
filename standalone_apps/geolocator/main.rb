# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.title = "Geolocator"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  geo = page.geolocator(key: "studio_geolocator")
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
              text_button(content: text(value: "Permission"), on_click: ->(_e) {
                geo.get_permission_status(on_result: ->(result, error) {
                  page.update(status, value: error ? "Permission error: #{error}" : "Permission: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Request permission"), on_click: ->(_e) {
                geo.request_permission(on_result: ->(result, error) {
                  page.update(status, value: error ? "Request error: #{error}" : "Permission request: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Current position"), on_click: ->(_e) {
                page.update(status, value: "Getting current position...")
                geo.get_current_position(on_result: ->(result, error) {
                  page.update(status, value: error ? "Position error: #{error}" : "Current position: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Location enabled"), on_click: ->(_e) {
                geo.is_location_service_enabled(on_result: ->(result, error) {
                  page.update(status, value: error ? "Location error: #{error}" : "Enabled: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Location settings"), on_click: ->(_e) {
                geo.open_location_settings(on_result: ->(result, error) {
                  page.update(status, value: error ? "Settings error: #{error}" : "Opened: #{result.inspect}")
                })
              })
            ]
          )
        ]
      )
    )
  )
end
