# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "WebView"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"

  status = text(value: "Loading…", style: { size: 12, color: "#6b7280" })

  # Give the WebView the full area (no surrounding padding that would collapse
  # its height), enable JavaScript, and surface load/error state so a blank page
  # is diagnosable instead of silent.
  webview_control = web_view(
    url: "https://flet.dev",
    enable_javascript: true,
    expand: true,
    on_page_started: ->(_e) { page.update(status, value: "Loading…") },
    on_page_ended: ->(_e) { page.update(status, value: "Loaded") },
    on_web_resource_error: ->(e) { page.update(status, value: "Load error: #{e.data}") }
  )

  page.add(
    column(
      expand: true,
      spacing: 0,
      children: [
        container(padding: { left: 12, right: 12, top: 8, bottom: 8 }, content: status),
        container(expand: true, content: webview_control)
      ]
    )
  )
end
