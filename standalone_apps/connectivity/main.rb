# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "Connectivity"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  current_text = text(value: "")
  page.connectivity(
    on_change: lambda { |event|
      values = Array(event&.data).map(&:to_s)
      label = values.empty? ? "none" : values.join(", ")
      page.update(current_text, value: label)
    }
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
          row(
            children: [
              button(
                content: "Get connectivity",
                icon: 'wifi',
                on_click: ->(_e) do
                  page.get_connectivity(
                    on_result: lambda { |result, error|
                      if error && !error.to_s.empty?
                        page.update(current_text, value: "Connectivity error: #{error}")
                        next
                      end
      
                      values = Array(result).map(&:to_s)
                      label = values.empty? ? "none" : values.join(", ")
                      page.update(current_text, value: label)
                    }
                  )
                end
              ),
              container(expand: true, content: current_text)
            ]
          )
        ]
      )
    )
  )
end
