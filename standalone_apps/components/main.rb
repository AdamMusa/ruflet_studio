# frozen_string_literal: true

require "ruflet"

SUPPORTED_COMPONENTS = [
  { label: "Hello World", slug: "hello-world", icon: "waving_hand" },
  { label: "Text", slug: "text", icon: "text_fields" },
  { label: "Button", slug: "button", icon: "touch_app" },
  { label: "Container", slug: "container", icon: "crop_square" },
  { label: "Row", slug: "row", icon: "view_column" },
  { label: "Column", slug: "column", icon: "view_stream" },
  { label: "TextField", slug: "text-field", icon: "edit" },
  { label: "Icon", slug: "icon", icon: "star" },
  { label: "Image", slug: "image", icon: "image" },
  { label: "Dialog", slug: "dialog", icon: "open_in_new" },
  { label: "DatePicker", slug: "date-picker", icon: "calendar_today" },
  { label: "DateRangePicker", slug: "date-range-picker", icon: "date_range" },
  { label: "TimePicker", slug: "time-picker", icon: "schedule" },
  { label: "DataTable", slug: "data-table", icon: "table_chart" },
  { label: "Dropdown", slug: "dropdown", icon: "arrow_drop_down_circle" },
  { label: "Checkbox", slug: "checkbox", icon: "check_box" },
  { label: "Radio", slug: "radio", icon: "radio_button_checked" },
  { label: "Tabs", slug: "tabs", icon: "tab" },
  { label: "ProgressBar", slug: "progress-bar", icon: "linear_scale" },
  { label: "ProgressRing", slug: "progress-ring", icon: "donut_large" },
  { label: "GridView", slug: "grid-view", icon: "grid_view" },
  { label: "InteractiveViewer", slug: "interactive-viewer", icon: "open_with" },
  { label: "ListTile", slug: "list-tile", icon: "list" },
  { label: "Switch", slug: "switch", icon: "toggle_on" },
  { label: "Slider", slug: "slider", icon: "tune" }
].freeze

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Components"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: column(
        spacing: 8,
        horizontal_alignment: "stretch",
        children: [
          status,
          text(value: "Supported widgets", style: { size: 18, weight: "w700", color: "#111827" }),
          *SUPPORTED_COMPONENTS.map do |component|
            slug = component.fetch(:slug)
            list_tile(
              bgcolor: "#ffffff",
              content_padding: { left: 12, right: 12, top: 8, bottom: 8 },
              leading: icon(icon: component.fetch(:icon), color: "#374151"),
              title: text(value: component.fetch(:label), style: { size: 16, color: "#111827" }),
              trailing: icon(icon: "chevron_right", color: "#6b7280"),
              on_click: ->(_e) { page.go("/components/#{slug}") }
            )
          end
        ]
      )
    )
  )
end
