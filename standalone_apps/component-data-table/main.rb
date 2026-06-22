# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "DataTable"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: data_table(
        [
          data_column("Widget"),
          data_column("Status")
        ],
        rows: [
          data_row([data_cell("Text"), data_cell("Supported")]),
          data_row([data_cell("Button"), data_cell("Supported")]),
          data_row([data_cell("Dialog"), data_cell("Supported")])
        ],
        column_spacing: 24,
        heading_row_height: 42,
        data_row_min_height: 38,
        data_row_max_height: 44
      )
    )
  )
end
