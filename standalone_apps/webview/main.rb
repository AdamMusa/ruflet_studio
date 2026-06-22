# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "WebView"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  webview_control = web_view(
    url: "https://ruflet.dev/",
    method: "get",
    expand: true
  )
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: container(
        expand: true,
        content: webview_control
      )
    )
  )
end
