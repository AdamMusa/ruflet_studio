# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Dialog"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  dialog = alert_dialog(
    open: false,
    modal: true,
    title: text(value: "Dialog"),
    content: text(value: "Hello world from a Ruflet dialog."),
    actions: [
      text_button(content: text(value: "Close"), on_click: ->(_e) { page.update(dialog, open: false) })
    ]
  )
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: filled_button(content: text(value: "Open dialog"), on_click: ->(_e) { page.show_dialog(dialog) })
    )
  )
end
