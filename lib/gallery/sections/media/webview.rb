# frozen_string_literal: true

# === gallery/sections_media/webview.rb ===
module Gallery
  module SectionsMedia
    def build_webview(page, status)
      # On the web the native webview becomes an <iframe>, which most sites
      # refuse to be embedded in (X-Frame-Options), so it's only shown natively.
      return unsupported_feature_panel(page, "WebView", "webview") unless feature_supported?(page, "webview")

      webview_height = preview_content_height(page, max: 640, min: 360)
      # Same call the working gallery uses; surface load/error state too.
      webview_control = web_view(
        url: "https://rubyonrails.org",
        method: "get",
        height: webview_height,
        on_page_started: ->(_e) { page.update(status, value: "Loading…") },
        on_page_ended: ->(_e) { page.update(status, value: "Loaded") },
        on_web_resource_error: ->(e) { page.update(status, value: "Load error: #{e.data}") }
      )
      column(spacing: 8, children: [status, container(height: webview_height, content: webview_control)])
    end
  end
end
