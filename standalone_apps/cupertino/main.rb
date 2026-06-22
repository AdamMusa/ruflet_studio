# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Cupertino controls"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  cupertino_dialog = nil
  cupertino_dialog = cupertino_alert_dialog(
    open: false,
    modal: true,
    title: text(value: "Cupertino"),
    content: text(value: "Hello from Cupertino"),
    actions: [
      cupertino_dialog_action(
        content: text(value: "OK"),
        on_click: ->(_e) { page.update(cupertino_dialog, open: false) }
      )
    ]
  )
  cupertino_picker = cupertino_picker(
    magnification: 1.2,
    use_magnifier: true,
    item_extent: 32,
    children: [
      text(value: "One"),
      text(value: "Two"),
      text(value: "Three")
    ]
  )
  radio_group_control = radio_group(
    value: "r1",
    content: row(
      spacing: 8,
      children: [
        cupertino_radio(label: "Radio 1", value: "r1"),
        cupertino_radio(label: "Radio 2", value: "r2")
      ]
    )
  )
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: column(
        spacing: 12,
        children: [
          status,
          cupertino_text_field(label: "Text Field"),
          cupertino_checkbox(label: "Checkbox"),
          cupertino_switch(label: "Switch"),
          cupertino_slider(min: 0, max: 100, divisions: 10, value: 50),
          radio_group_control,
          column(
            spacing: 8,
            children: [
              cupertino_button(
                content: text(value: "Show Dialog"),
                on_click: ->(_e) { page.show_dialog(cupertino_dialog) }
              ),
              cupertino_button(
                content: text(value: "Show Picker"),
                on_click: ->(_e) {
                  page.show_dialog(cupertino_bottom_sheet(content: cupertino_picker, height: 216, padding: { top: 6 }))
                }
              )
            ]
          ),
          column(
            spacing: 8,
            children: [
              cupertino_button(
                content: text(value: "Show DatePicker"),
                on_click: ->(_e) {
                  page.show_dialog(cupertino_bottom_sheet(content: cupertino_date_picker(), height: 216, padding: { top: 6 }))
                }
              ),
              cupertino_button(
                content: text(value: "Show TimerPicker"),
                on_click: ->(_e) {
                  page.show_dialog(cupertino_bottom_sheet(content: cupertino_timer_picker(), height: 216, padding: { top: 6 }))
                }
              )
            ]
          )
        ]
      )
    )
  )
end
