# frozen_string_literal: true

require "tmpdir"
require "fileutils"

module RufletStudio
  module SectionsMedia
    def build_share(page, _status)
      status_text = text(value: "")
      raw_text = text(value: "")

      update_result = lambda do |result, error|
        if error && !error.to_s.empty?
          page.update(status_text, value: "Share error: #{error}")
          page.update(raw_text, value: "")
          next
        end

        payload = result.is_a?(Hash) ? result : {}
        state = payload["status"] || payload[:status]
        raw = payload["raw"] || payload[:raw]
        state_value = state.to_s.empty? ? "UNKNOWN" : state.to_s.upcase
        raw_value = raw.to_s.empty? ? "(empty)" : raw.to_s
        page.update(status_text, value: "Share status: ShareResultStatus.#{state_value}")
        page.update(raw_text, value: "Raw: #{raw_value}")
      end

      share_text_btn = button(
        content: "Share text",
        on_click: ->(_e) do
          page.update(status_text, value: "Opening share sheet...")
          page.update(raw_text, value: "")
          page.share_text(
            "Hello from Ruflet!",
            title: "Share greeting",
            subject: "Greeting",
            download_fallback_enabled: true,
            mail_to_fallback_enabled: true,
            on_result: update_result
          )
        end
      )

      share_link_btn = button(
        content: "Share link",
        on_click: ->(_e) do
          page.update(status_text, value: "Opening share sheet...")
          page.update(raw_text, value: "")
          page.share_uri(
            "https://ruflet.dev",
            on_result: update_result
          )
        end
      )

      share_bytes_btn = button(
        content: "Share file from bytes",
        on_click: ->(_e) do
          page.update(status_text, value: "Opening share sheet...")
          page.update(raw_text, value: "")
          page.share_files(
            [
              {
                "data" => "Sample content from memory".b,
                "mime_type" => "text/plain",
                "name" => "sample.txt"
              }
            ],
            text: "Sharing a file from memory",
            download_fallback_enabled: true,
            mail_to_fallback_enabled: true,
            on_result: update_result
          )
        end
      )

      share_path_btn = button(
        content: "Share file from path",
        on_click: ->(_e) do
          page.update(status_text, value: "Preparing file for share...")
          page.update(raw_text, value: "")
          page.get_temporary_directory(
            on_result: lambda { |temp_dir, temp_error|
              if temp_error && !temp_error.to_s.empty?
                page.update(status_text, value: "Storage paths error: #{temp_error}")
                page.update(raw_text, value: "")
                next
              end

              base_dir = temp_dir.to_s
              if base_dir.empty?
                page.update(status_text, value: "Storage paths error: empty temporary directory")
                page.update(raw_text, value: "")
                next
              end

              FileUtils.mkdir_p(base_dir)
              sample_path = File.join(base_dir, "sample_from_path.txt")
              File.write(sample_path, "Sample content from file path\n")

              page.update(status_text, value: "Opening share sheet...")
              page.share_files(
                [{ "path" => sample_path }],
                text: "Sharing a file from path",
                download_fallback_enabled: true,
                mail_to_fallback_enabled: true,
                on_result: update_result
              )
            }
          )
        end
      )

      control(
        :safe_area,
        content: column(
          children: [
            row(
              wrap: true,
              children: [
                share_text_btn,
                share_link_btn,
                share_bytes_btn,
                share_path_btn
              ]
            ),
            status_text,
            raw_text
          ]
        )
      )
    end
  end
end
