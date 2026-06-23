# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "Material controls"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  material_dialog = nil
  material_dialog = alert_dialog(
    open: false,
    modal: true,
    title: text(value: "Hello"),
    content: text(value: "Hello from Ruflet"),
    actions: [
      text_button(content: text(value: "OK"), on_click: ->(_e) { page.update(material_dialog, open: false) })
    ]
  )
  build_banner = lambda do
    banner(
      open: true,
      leading: icon(icon: "info"),
      content: text(value: "Backup completed successfully."),
      actions: [
        text_button(content: text(value: "Dismiss"), on_click: ->(_e) { page.pop_dialog })
      ]
    )
  end
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: column(
        spacing: 12,
        children: [
          status,
          card(
            content: container(
              padding: 12,
              content: column(
                spacing: 8,
                children: [
                  text(value: "TextField", style: { size: 14, weight: "w600" }),
                  text_field(label: "Name", value: "Ruflet")
                ]
              )
            )
          ),
          card(
            content: container(
              padding: 12,
              content: column(
                spacing: 8,
                children: [
                  text(value: "Buttons", style: { size: 14, weight: "w600" }),
                  row(
                    spacing: 8,
                    children: [
                      filled_button(content: text(value: "Filled"), on_click: ->(_e) { page.update(status, value: "Filled pressed") }),
                      filled_tonal_button(content: text(value: "Tonal"), on_click: ->(_e) { page.update(status, value: "Tonal pressed") }),
                      outlined_button(content: text(value: "Outlined"), on_click: ->(_e) { page.update(status, value: "Outlined pressed") })
                    ]
                  )
                ]
              )
            )
          ),
          card(
            content: container(
              padding: 12,
              content: column(
                spacing: 8,
                children: [
                  text(value: "Selection", style: { size: 14, weight: "w600" }),
                  switch(label: "Wi-Fi", value: true),
                  slider(min: 0, max: 100, divisions: 10, value: 35, label: "Value = {value}")
                ]
              )
            )
          ),
          card(
            content: container(
              padding: 12,
              content: column(
                spacing: 8,
                children: [
                  text(value: "Dialogs", style: { size: 14, weight: "w600" }),
                  text_button(content: text(value: "Show dialog"), on_click: ->(_e) { page.show_dialog(material_dialog) })
                ]
              )
            )
          ),
          card(
            content: container(
              padding: 12,
              content: column(
                spacing: 8,
                children: [
                  text(value: "Banners", style: { size: 14, weight: "w600" }),
                  text_button(content: text(value: "Show banner"), on_click: ->(_e) {
                    page.show_dialog(build_banner.call)
                  })
                ]
              )
            )
          ),
          list_tile(leading: icon(icon: "info"), title: text(value: "ListTile"))
        ]
      )
    )
  )
end
