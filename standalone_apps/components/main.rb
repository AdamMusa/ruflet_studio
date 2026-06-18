# frozen_string_literal: true

require "ruflet"

SUPPORTED_COMPONENTS = [
  { label: "Hello World", slug: "hello-world", icon: Ruflet::MaterialIcons::WAVING_HAND },
  { label: "Text", slug: "text", icon: Ruflet::MaterialIcons::TEXT_FIELDS },
  { label: "Button", slug: "button", icon: Ruflet::MaterialIcons::TOUCH_APP },
  { label: "Container", slug: "container", icon: Ruflet::MaterialIcons::CROP_SQUARE },
  { label: "Row", slug: "row", icon: Ruflet::MaterialIcons::VIEW_COLUMN },
  { label: "Column", slug: "column", icon: Ruflet::MaterialIcons::VIEW_STREAM },
  { label: "TextField", slug: "text-field", icon: Ruflet::MaterialIcons::EDIT },
  { label: "Icon", slug: "icon", icon: Ruflet::MaterialIcons::STAR },
  { label: "Image", slug: "image", icon: Ruflet::MaterialIcons::IMAGE },
  { label: "Dialog", slug: "dialog", icon: Ruflet::MaterialIcons::OPEN_IN_NEW },
  { label: "DatePicker", slug: "date-picker", icon: Ruflet::MaterialIcons[:calendar_today] },
  { label: "DateRangePicker", slug: "date-range-picker", icon: Ruflet::MaterialIcons[:date_range] },
  { label: "TimePicker", slug: "time-picker", icon: Ruflet::MaterialIcons[:schedule] },
  { label: "DataTable", slug: "data-table", icon: Ruflet::MaterialIcons::TABLE_CHART },
  { label: "Dropdown", slug: "dropdown", icon: Ruflet::MaterialIcons[:arrow_drop_down_circle] },
  { label: "Checkbox", slug: "checkbox", icon: Ruflet::MaterialIcons[:check_box] },
  { label: "Radio", slug: "radio", icon: Ruflet::MaterialIcons[:radio_button_checked] },
  { label: "Tabs", slug: "tabs", icon: Ruflet::MaterialIcons[:tab] },
  { label: "ProgressBar", slug: "progress-bar", icon: Ruflet::MaterialIcons[:linear_scale] },
  { label: "ProgressRing", slug: "progress-ring", icon: Ruflet::MaterialIcons[:donut_large] },
  { label: "GridView", slug: "grid-view", icon: Ruflet::MaterialIcons[:grid_view] },
  { label: "InteractiveViewer", slug: "interactive-viewer", icon: Ruflet::MaterialIcons[:open_with] },
  { label: "ListTile", slug: "list-tile", icon: Ruflet::MaterialIcons::LIST },
  { label: "Switch", slug: "switch", icon: Ruflet::MaterialIcons::TOGGLE_ON },
  { label: "Slider", slug: "slider", icon: Ruflet::MaterialIcons::TUNE }
].freeze

Ruflet.run do |page|
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
              trailing: icon(icon: Ruflet::MaterialIcons::CHEVRON_RIGHT, color: "#6b7280"),
              on_click: ->(_e) { page.go("/components/#{slug}") }
            )
          end
        ]
      )
    )
  )
end
