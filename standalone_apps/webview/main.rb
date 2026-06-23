# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "WebView"

  # Exact same code as the showcase webview section.
  webview_control = web_view(
    url: "https://rubyonrails.org",
    method: "get",
    expand: true
  )

  page.add(
    container(
      expand: true,
      content: webview_control
    )
  )
end
