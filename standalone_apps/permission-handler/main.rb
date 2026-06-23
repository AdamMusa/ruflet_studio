# frozen_string_literal: true

require "ruflet"

def permission_handler_platform_notice(page)
  safe_area(
    content: column(
      horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
      spacing: 8,
      children: [
        text(value: "PermissionHandler is available on iOS, Android, Windows, and Web."),
        text(value: "Current platform: #{(page.client_details && page.client_details["platform"]).to_s.empty? ? "unknown" : (page.client_details && page.client_details["platform"]).to_s}", style: { size: 12 })
      ]
    )
  )
end

Ruflet.run do |page|
  page.padding = 0
  page.title = "Permission Handler"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  return permission_handler_platform_notice(page) unless true
  permissions = page.permission_handler(key: "studio_permission_handler")
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
              text_button(content: text(value: "Microphone status"), on_click: ->(_e) {
                permissions.get_status("microphone", on_result: ->(result, error) {
                  page.update(status, value: error ? "Status error: #{error}" : "Microphone: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Request mic"), on_click: ->(_e) {
                permissions.request("microphone", on_result: ->(result, error) {
                  page.update(status, value: error ? "Microphone request error: #{error}" : "Microphone request: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Request camera"), on_click: ->(_e) {
                permissions.request("camera", on_result: ->(result, error) {
                  page.update(status, value: error ? "Camera request error: #{error}" : "Camera request: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Open settings"), on_click: ->(_e) {
                permissions.open_app_settings(on_result: ->(result, error) {
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
