# frozen_string_literal: true

# === gallery/sections_controls/code_editor.rb ===
module Gallery
  module SectionsControls
    SAMPLE_CODE = <<~RUBY
      # A tiny Ruflet app
      class App < Ruflet::App
        def view(page)
          page.add(text(value: "Hello from Ruflet!"))
        end
      end
    RUBY

    def build_code_editor(page, status)
      editor = code_editor(
        SAMPLE_CODE,
        language: "ruby",
        code_theme: theme_mode == "dark" ? "atom-one-dark" : "atom-one-light",
        read_only: false,
        height: preview_content_height(page, max: 520, min: 320),
        on_change: ->(e) { page.update(status, value: "#{e.data.to_s.length} characters") },
        on_focus: ->(_e) { page.update(status, value: "Editor focused") },
        on_blur: ->(_e) { page.update(status, value: "Editor blurred") }
      )

      read_only = false

      column(
        spacing: 12,
        children: [
          status,
          row(
            spacing: 8,
            children: [
              elevated_button(
                content: text(value: "Toggle read-only"),
                on_click: ->(_e) {
                  read_only = !read_only
                  page.update(editor, read_only: read_only)
                  page.update(status, value: read_only ? "Read-only" : "Editable")
                }
              ),
              elevated_button(
                content: text(value: "Focus"),
                on_click: ->(_e) { editor.focus }
              )
            ]
          ),
          container(
            height: preview_content_height(page, max: 520, min: 320),
            border_radius: 12,
            bgcolor: color_panel(page),
            content: editor
          )
        ]
      )
    end
  end
end
