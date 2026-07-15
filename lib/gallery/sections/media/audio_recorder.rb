# frozen_string_literal: true

# === gallery/sections_media/audio_recorder.rb ===
require "fileutils"

module Gallery
  module SectionsMedia
    def build_audio_recorder(page, status)
      recorder = page.audio_recorder(key: "studio_audio_recorder")
      recording_path = nil

      spinner = container(visible: false, height: 60, alignment: "center",
                          content: spinkit(pulse: { color: "#ef4444", size: 52 }))
      record_button = nil
      stop_button = nil

      set_recording = lambda do |recording|
        page.update(spinner, visible: recording)
        page.update(record_button, disabled: recording)
        page.update(stop_button, disabled: !recording)
      end

      # Pure Ruby: resolve a writable path, then record to it (same flow as the
      # gallery reference). No client/Dart changes.
      start = lambda do |_e|
        page.update(status, value: "Preparing recording…")
        page.get_application_documents_directory(on_result: ->(documents_dir, path_error) {
          if path_error || documents_dir.to_s.empty?
            page.update(status, value: "Recording path error: #{path_error || "documents directory unavailable"}")
            next
          end

          recording_path = File.join(documents_dir.to_s, "gallery_recording.wav")
          next unless prepare_recorder_output_path(page, recording_path, status)

          recorder.has_permission(on_result: ->(allowed, recorder_error) {
            if recorder_error
              page.update(status, value: "Recorder permission error: #{recorder_error}")
            elsif !allowed
              page.update(status, value: "Microphone permission was not granted.")
            else
              set_recording.call(true)
              page.update(status, value: "Recording → #{recording_path}")
              recorder.start_recording(output_path: recording_path, configuration: { encoder: "wav" }, on_result: ->(_result, error) {
                if error
                  set_recording.call(false)
                  page.update(status, value: "Start error: #{error}")
                end
              })
            end
          })
        })
      end

      stop = lambda do |_e|
        recorder.stop_recording(on_result: ->(result, error) {
          set_recording.call(false)
          page.update(status, value: error ? "Stop error: #{error}" : "Saved: #{result.inspect || recording_path || "unknown path"}")
        })
      end

      record_button = filled_button(content: row(tight: true, spacing: 8, children: [
        icon(icon: "mic"), text(value: "Record")
      ]), on_click: start)
      stop_button = outlined_button(disabled: true, content: row(tight: true, spacing: 8, children: [
        icon(icon: "stop"), text(value: "Stop")
      ]), on_click: stop)

      column(
        spacing: 16,
        horizontal_alignment: "center",
        children: [
          spinner,
          status,
          row(alignment: "center", spacing: 12, children: [record_button, stop_button])
        ]
      )
    end

    def prepare_recorder_output_path(page, recording_path, status)
      return true unless %w[macos linux windows].include?(client_platform(page))

      FileUtils.mkdir_p(File.dirname(recording_path))
      FileUtils.touch(recording_path)
      true
    rescue StandardError => e
      page.update(status, value: "Recording file prepare error: #{e.class}: #{e.message}")
      false
    end
  end
end
