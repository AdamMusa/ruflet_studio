# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "File Picker"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  page.file_picker
  selected_files = text(value: "")
  save_file_path = text(value: "")
  directory_path = text(value: "")
  picker_in_flight = false
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: column(
        spacing: 10,
        children: [
          status,
          row(
            children: [
              button(
                content: "Pick files",
                icon: "upload_file",
                on_click: ->(_e) do
                  next if picker_in_flight
                  picker_in_flight = true
                  page.update(selected_files, value: "Opening file picker...")
                  page.pick_files(
                    allow_multiple: true,
                    with_data: false,
                    on_result: lambda { |result, error|
                      picker_in_flight = false
                      if error && !error.to_s.empty?
                        page.update(selected_files, value: "File picker error: #{error}")
                        next
                      end
                      files = Array(result)
                      names = files.map { |f| f["name"] || f[:name] }.compact.join(", ")
                      page.update(selected_files, value: names.empty? ? "Cancelled!" : names)
                    }
                  )
                end
              ),
              container(expand: true, content: selected_files)
            ]
          ),
          row(
            children: [
              button(
                content: "Save file",
                icon: "save",
                on_click: ->(_e) do
                  next if picker_in_flight
                  picker_in_flight = true
                  page.update(save_file_path, value: "Opening save dialog...")
                  page.save_file(
                    file_name: "ruflet_sample.txt",
                    src_bytes: "Saved from Showcase\n".b,
                    on_result: lambda { |result, error|
                      picker_in_flight = false
                      if error && !error.to_s.empty?
                        page.update(save_file_path, value: "File picker error: #{error}")
                        next
                      end
                      page.update(save_file_path, value: result.to_s.empty? ? "Cancelled!" : result.to_s)
                    }
                  )
                end
              ),
              container(expand: true, content: save_file_path)
            ]
          ),
          # Pick/save use the browser's file APIs on web, but a directory
          # picker has no web equivalent — guard that one control so it shows
          # a clean notice instead of a "not supported on web" exception.
          if true
            row(
              children: [
                button(
                  content: "Open directory",
                  icon: "folder_open",
                  on_click: ->(_e) do
                    next if picker_in_flight
                    picker_in_flight = true
                    page.update(directory_path, value: "Opening directory picker...")
                    page.get_directory_path(
                      on_result: lambda { |result, error|
                        picker_in_flight = false
                        if error && !error.to_s.empty?
                          page.update(directory_path, value: "File picker error: #{error}")
                          next
                        end
                        page.update(directory_path, value: result.to_s.empty? ? "Cancelled!" : result.to_s)
                      }
                    )
                  end
                ),
                container(expand: true, content: directory_path)
              ]
            )
          else
            text(value: "Open directory")
          end
        ]
      )
    )
  )
end
