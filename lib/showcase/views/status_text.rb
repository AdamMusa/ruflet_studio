# frozen_string_literal: true

# === showcase/views/status_text.rb ===
module Showcase
  module Views
    def status_text(page)
      text(value: "", style: { size: 12, color: color_subtle(page) })
    end
  end
end
