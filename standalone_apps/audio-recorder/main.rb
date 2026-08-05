# frozen_string_literal: true

require "fileutils"
require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "Audio Recorder"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"

  recorder = page.audio_recorder(key: "studio_audio_recorder")
  recording_path = nil
  playback = nil

  spinner = container(visible: false, width: 42, height: 42, alignment: "center",
                      content: spinkit(pulse: { color: "#ef4444", size: 34 }))
  status = text(value: "Tap Record to start.", style: { size: 14, color: "#374151" })
  helper = text(value: "Plays automatically after Stop.", style: { size: 12, color: "#64748b" })
  record_button = nil
  stop_button = nil

  set_recording = lambda do |recording|
    page.update(spinner, visible: recording)
    page.update(record_button, disabled: recording)
    page.update(stop_button, disabled: !recording)
  end

  autoplay_recording = lambda do |path|
    page.remove_service(playback) if playback
    playback = page.audio(
      src: path,
      autoplay: true,
      release_mode: "stop",
      on_state_change: lambda do |event|
        data = event.respond_to?(:data) ? event.data : event
        state = data.is_a?(Hash) ? (data["state"] || data[:state]) : data
        message = case state.to_s
                  when "playing" then "Playing your recording…"
                  when "completed", "stopped" then "Recording saved and playback finished."
                  end
        page.update(status, value: message) if message
      end,
      on_error: lambda do |event|
        data = event.respond_to?(:data) ? event.data : event
        page.update(status, value: "Playback error: #{data}")
      end
    )
    page.update(status, value: "Saved. Playing your recording…")
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
          page.update(status, value: "Recording… Speak now.")
          recorder.start_recording(output_path: recording_path, configuration: { encoder: "wav" }, on_result: ->(result, error) {
            if error || result == false
              set_recording.call(false)
              page.update(status, value: error ? "Start error: #{error}" : "The recorder could not start.")
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
      if error
        page.update(status, value: "Stop error: #{error}")
      else
        path = result.to_s.empty? ? recording_path.to_s : result.to_s
        if path.empty?
          page.update(status, value: "Recording stopped, but no audio file was returned.")
        else
          autoplay_recording.call(path)
        end
      end
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
        children: [
          row(spacing: 12, vertical_alignment: "center", children: [
            spinner,
            container(expand: true, content: column(spacing: 4, children: [status, helper]))
          ]),
          row(alignment: "center", spacing: 12, wrap: true, children: [record_button, stop_button])
        ]
      )
    )
  )
end
