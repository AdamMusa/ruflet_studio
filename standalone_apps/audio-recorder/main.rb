# frozen_string_literal: true

require "fileutils"
require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Audio Recorder"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"

  recorder = page.audio_recorder(key: "studio_audio_recorder")
  recording_path = nil

  spinner = container(visible: false, height: 64, alignment: "center",
                      content: spinkit(pulse: { color: "#ef4444", size: 56 }))
  status = text(value: "Tap Record to start.", style: { size: 14, color: "#374151" })
  record_button = nil
  stop_button = nil

  set_recording = lambda do |recording|
    page.update(spinner, visible: recording)
    page.update(record_button, disabled: recording)
    page.update(stop_button, disabled: !recording)
  end

  record_button = filled_button(content: row(tight: true, spacing: 8, children: [
    icon(icon: "mic"), text("Record")
  ]), on_click: ->(_e) {
    page.update(status, value: "Preparing recording…")
    page.get_application_documents_directory(on_result: ->(documents_dir, path_error) {
      if path_error || documents_dir.to_s.empty?
        page.update(status, value: "Recording path error: #{path_error || "documents directory unavailable"}")
        next
      end

      recording_path = File.join(documents_dir.to_s, "showcase_recording.wav")
      begin
        FileUtils.mkdir_p(File.dirname(recording_path))
      rescue StandardError
        # best effort; the recorder creates the file on most platforms
      end

      recorder.has_permission(on_result: ->(allowed, recorder_error) {
        if recorder_error
          page.update(status, value: "Permission error: #{recorder_error}")
        elsif !allowed
          page.update(status, value: "Microphone permission was not granted.")
        else
          set_recording.call(true)
          page.update(status, value: "Recording → #{recording_path}")
          recorder.start_recording(output_path: recording_path, configuration: { encoder: "wav" }, on_result: ->(_r, error) {
            if error
              set_recording.call(false)
              page.update(status, value: "Start error: #{error}")
            end
          })
        end
      })
    })
  })
  stop_button = outlined_button(disabled: true, content: row(tight: true, spacing: 8, children: [
    icon(icon: "stop"), text("Stop")
  ]), on_click: ->(_e) {
    recorder.stop_recording(on_result: ->(result, error) {
      set_recording.call(false)
      page.update(status, value: error ? "Stop error: #{error}" : "Saved: #{result.inspect || recording_path || "unknown path"}")
    })
  })

  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: column(
        horizontal_alignment: "center",
        spacing: 20,
        children: [spinner, status, row(alignment: "center", spacing: 12, children: [record_button, stop_button])]
      )
    )
  )
end
