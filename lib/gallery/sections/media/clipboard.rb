# frozen_string_literal: true

# === gallery/sections_media/clipboard.rb ===
module Gallery
  module SectionsMedia
    def build_clipboard(page, _status)
      clipboard = page.clipboard

      state_text = text(value: "")
      clipboard_in_flight = false

      set_text_btn = button(
        content: "Copy sample text",
        on_click: ->(_e) do
          next if clipboard_in_flight

          clipboard_in_flight = true
          page.update(state_text, value: "Writing clipboard text...")
          clipboard.set(
            "Hello from Ruflet",
            timeout: 6,
            on_result: lambda { |result, error|
              clipboard_in_flight = false
              if error && !error.to_s.empty?
                page.update(state_text, value: "Clipboard error: #{error}")
                next
              end
              page.update(state_text, value: "Copied text to clipboard (result: #{result.inspect}).")
            }
          )
        end
      )

      get_text_btn = button(
        content: "Read clipboard text",
        on_click: ->(_e) do
          next if clipboard_in_flight

          clipboard_in_flight = true
          page.update(state_text, value: "Reading clipboard text...")
          clipboard.get(
            timeout: 6,
            on_result: lambda { |result, error|
              clipboard_in_flight = false
              if error && !error.to_s.empty?
                page.update(state_text, value: "Clipboard error: #{error}")
                next
              end
              page.update(state_text, value: "Clipboard: #{result.inspect}")
            }
          )
        end
      )

      get_image_btn = button(
        content: "Get image from clipboard",
        on_click: ->(_e) do
          next if clipboard_in_flight

          clipboard_in_flight = true
          page.update(state_text, value: "Reading clipboard image...")
          page.get_clipboard_image(
            timeout: 6,
            on_result: lambda { |result, error|
              clipboard_in_flight = false
              if error && !error.to_s.empty?
                page.update(state_text, value: "Clipboard image error: #{error}")
                next
              end
              size = result.respond_to?(:bytesize) ? result.bytesize : result.to_s.bytesize
              if result.nil? || size.zero?
                page.update(state_text, value: "No image in clipboard.")
              else
                page.update(state_text, value: "Clipboard image available (#{size} bytes).")
              end
            }
          )
        end
      )

      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          children: [
            set_text_btn,
            get_text_btn,
            get_image_btn,
            state_text
          ]
        )
      )
    end
  end
end
