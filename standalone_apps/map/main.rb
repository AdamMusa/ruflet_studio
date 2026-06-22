# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Map"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  center = [51.505, -0.09]
  map_control = map(
    [
      tile_layer(
        url_template: "https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
        user_agent_package_name: "com.izeesoft.rufletexplorer"
      ),
      simple_attribution(
        text: "OpenStreetMap contributors, CARTO"
      ),
      marker_layer(
        [
          marker(
            coordinates: center,
            width: 44,
            height: 44,
            content: icon(icon: "location_on", color: "#ff5a5f")
          )
        ]
      ),
      circle_layer(
        [
          circle_marker(
            coordinates: center,
            radius: 400,
            color: "#4f8cff33",
            border_color: "#4f8cff",
            border_stroke_width: 2
          )
        ]
      )
    ],
    expand: true,
    initial_center: center,
    initial_zoom: 13,
    min_zoom: 2,
    max_zoom: 18,
    on_tap: ->(e) { page.update(status, value: "Map tap: #{e.data}") },
    on_position_change: ->(e) { page.update(status, value: "Map position: #{e.data}") }
  )
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: column(
        spacing: 8,
        expand: true,
        children: [
          status,
          row(
            spacing: 8,
            children: [
              text_button(content: text(value: "Center"), on_click: ->(_e) {
                map_control.center_on(center, zoom: 13)
              }),
              text_button(content: text(value: "Zoom in"), on_click: ->(_e) {
                map_control.zoom_in(delta: 1)
              }),
              text_button(content: text(value: "Zoom out"), on_click: ->(_e) {
                map_control.zoom_out(delta: 1)
              })
            ]
          ),
          container(
            expand: true,
            height: 520,
            content: map_control
          )
        ]
      )
    )
  )
end
