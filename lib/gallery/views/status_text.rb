# frozen_string_literal: true

# === gallery/views/status_text.rb ===
module Gallery
  module Views
    def status_text(page)
      text(value: "", style: { size: 12, color: color_subtle(page) })
    end
  end
end
