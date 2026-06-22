# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Audio Recorder"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"

  spinner = container(visible: false, height: 64, alignment: "center",
                      content: spinkit(pulse: { color: "#ef4444", size: 56 }))
  status = text(value: "Tap Record to start.", style: { size: 14, color: "#374151" })
  record_button = nil
  stop_button = nil

  apply_state = lambda do |state|
    recording = state == "recording"
    page.update(spinner, visible: recording)
    page.update(record_button, disabled: recording)
    page.update(stop_button, disabled: !recording)
    page.update(status, value: (
      case state
      when "recording" then "Recording…"
      when "paused" then "Paused"
      when "stopped" then "Stopped — recording saved."
      else state.to_s
      end
    ))
  end

  # Use state_change events for feedback (no invoke-result dependency) and let
  # the recorder default its output path on the device.
  recorder = page.audio_recorder(
    key: "studio_audio_recorder",
    on_state_change: ->(event) { apply_state.call(event.data.to_s) }
  )

  record_button = filled_button(content: row(tight: true, spacing: 8, children: [
    icon(icon: "mic"), text("Record")
  ]), on_click: ->(_e) {
    page.update(status, value: "Starting… allow microphone access if prompted.")
    recorder.start_recording(configuration: { encoder: "aacLc" })
  })
  stop_button = outlined_button(disabled: true, content: row(tight: true, spacing: 8, children: [
    icon(icon: "stop"), text("Stop")
  ]), on_click: ->(_e) {
    page.update(status, value: "Stopping…")
    recorder.stop_recording
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
