# frozen_string_literal: true

require "ruflet"
require "cgi"

require_relative "lib/studio/config"
require_relative "lib/gallery"
require_relative "lib/studio/builtin_examples"
require_relative "lib/studio/gallery_catalog"
require_relative "lib/studio/preview_runtime"
require_relative "lib/studio/routing"
require_relative "lib/studio/shell"
require_relative "lib/studio/gallery_views"
require_relative "lib/studio/editor_views"
require_relative "lib/studio/thumbnails"
require_relative "lib/studio/preview_builders"
require_relative "lib/studio/settings"

Ruflet.run do |page|
  page.on_route_change = ->(_e) { render(page) }

  # Embedded clients can receive their real size after the initial handshake.
  # Re-render only when crossing a responsive layout breakpoint.
  layout_signature = nil
  page.on_resize = ->(_e) do
    next_signature = [page.width.to_f >= 700, page.width.to_f >= 760]
    next if next_signature == layout_signature

    layout_signature = next_signature
    render(page)
  end

  render(page)
end
