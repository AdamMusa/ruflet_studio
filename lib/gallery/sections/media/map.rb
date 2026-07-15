# frozen_string_literal: true

# === gallery/sections_media/map.rb ===
module Gallery
  module SectionsMedia
    def build_map(page, status)
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
        initial_center: center,
        initial_zoom: 13,
        min_zoom: 2,
        max_zoom: 18,
        on_tap: ->(e) { page.update(status, value: "Map tap: #{e.data}") },
        on_position_change: ->(e) { page.update(status, value: "Map position: #{e.data}") }
      )

      column(
        spacing: 8,
        children: [
          status,
          row(
            spacing: 8,
            children: [
              text_button(content: text(value: "Center"), on_click: ->(_e) {
                map_control.center_on(center, zoom: 13)
              }),
              text_button(content: text(value: "Zoom in"), on_click: ->(_e) {
                map_control.zoom_in
              }),
              text_button(content: text(value: "Zoom out"), on_click: ->(_e) {
                map_control.zoom_out
              })
            ]
          ),
          container(
            height: preview_content_height(page, max: 520, min: 320),
            content: map_control
          )
        ]
      )
    end
  end
end
