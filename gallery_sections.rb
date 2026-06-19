# frozen_string_literal: true

# Auto-bundled showcase gallery sections for Ruflet Studio.
# Self-contained: defines the Showcase::Helpers / Views / SectionsControls /
# SectionsMedia / SectionsMisc modules the studio mixes in to render live
# previews. Generated from the section sources; no external showcase/ needed.

require "json"

# === showcase/helpers.rb ===
module Showcase
  module Helpers
    # Platforms each native capability actually works on. A feature absent
    # here is assumed available everywhere. Used to guard demos so the user
    # never triggers a "not supported on web" exception — the section shows a
    # clean notice instead.
    FEATURE_PLATFORMS = {
      "directory_picker" => %w[macos windows linux android ios], # not web
      "battery" => %w[android ios],                              # not web/desktop
      "accelerometer" => %w[android ios],
      "gyroscope" => %w[android ios],
      "magnetometer" => %w[android ios],
      "barometer" => %w[android ios],
      "user_accelerometer" => %w[android ios],
      "shake_detector" => %w[android ios],
      "flashlight" => %w[android ios],
      "screen_brightness" => %w[android ios],
      "camera" => %w[android ios],
      "webview" => %w[macos windows linux android ios]           # not web (iframe)
    }.freeze

    def web_platform?(page)
      client_platform(page).downcase == "web"
    end

    def feature_supported?(page, feature)
      platforms = FEATURE_PLATFORMS[feature.to_s]
      return true unless platforms

      platform = client_platform(page).downcase
      return true if platform.empty? # unknown host: don't hide anything

      platforms.include?(platform)
    end

    # Clean placeholder shown in place of a control/section the current
    # platform cannot run, instead of a raw service exception.
    def unsupported_feature_panel(page, title, feature = nil)
      supported = feature ? FEATURE_PLATFORMS[feature.to_s] : nil
      platform = client_platform(page)
      where = platform.to_s.strip.empty? ? "this platform" : platform
      detail =
        if supported
          "Available on #{supported.join(', ')}. Current platform: #{where}."
        else
          "Not available on #{where}."
        end
      container(
        padding: 16,
        border_radius: 12,
        bgcolor: color_panel(page),
        content: column(
          spacing: 6,
          children: [
            row(
              spacing: 8,
              children: [
                icon(Ruflet::MaterialIcons[:info_outline], size: 18, color: color_subtle(page)),
                text(value: title, style: { size: 15, weight: "w600" })
              ]
            ),
            text(value: detail, style: { size: 13, color: color_subtle(page) })
          ]
        )
      )
    end

    # Renders the section body only when the feature is supported here;
    # otherwise a clean notice. Pass a block that builds the real content.
    def with_feature_guard(page, feature, title)
      return unsupported_feature_panel(page, title, feature) unless feature_supported?(page, feature)

      yield
    end

    def github_repo_base
      "https://github.com/AdamMusa/ruflet/blob/main/"
    end

    def github_url_for(path)
      return nil unless path

      source_path = path.to_s.sub(%r{^/}, "")
      source_path = source_path.sub(%r{\Ashowcase/}, "")
      source_path = File.join("ruflet_studio", source_path)
      github_repo_base + source_path
    end

    def github_icon_image(page)
      image(
        src: "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png",
        width: 18,
        height: 18
      )
    end

    def open_github(page, path)
      url = github_url_for(path)
      return unless url

      page.launch_url(
        url,
        mode: "external_application",
        on_result: lambda { |_result, error|
          Kernel.warn("GitHub URL launch failed: #{error}") if error && !error.to_s.empty?
        }
      )
    end

    def github_action(page, path)
      text_button(
        content: github_icon_image(page),
        on_click: ->(_e) { open_github(page, path) }
      )
    end

    def theme_mode
      @theme_mode ||= "system"
    end

    def effective_theme(page)
      return theme_mode unless theme_mode == "system"

      brightness = page.client_details&.dig("platform_brightness") || page.client_details&.dig(:platform_brightness)
      brightness == "dark" ? "dark" : "light"
    end

    def client_platform(page)
      (page.client_details&.dig("platform") || page.client_details&.dig(:platform)).to_s
    end

    def mobile_platform?(page)
      %w[ios android].include?(client_platform(page))
    end

    def permission_handler_platform?(page)
      %w[ios android windows web].include?(client_platform(page))
    end

    def mobile_only_notice(page, feature)
      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 8,
          children: [
            text(value: "#{feature} is available on iOS and Android devices."),
            text(value: "Current platform: #{client_platform(page).empty? ? "unknown" : client_platform(page)}", style: { size: 12 })
          ]
        )
      )
    end

    def set_theme(page, mode)
      normalized = mode.to_s.strip.downcase
      return unless %w[system light dark].include?(normalized)

      @theme_mode = normalized
      page.theme_mode = normalized
      page.go(page.route || "/settings")
    end

    def theme_colors(page)
      if effective_theme(page) == "light"
        {
          bg: "#edf3fb",
          surface: "#ffffff",
          text: "#1f2328",
          subtle: "#475467",
          icon: "#475467",
          divider: "#cad5e5",
          panel: "#dce6f5",
          nav_indicator: "#bfd3ff",
          accent: "#2563eb"
        }
      else
        {
          bg: "#0b1220",
          surface: "#111827",
          text: "#e5edf7",
          subtle: "#94a3b8",
          icon: "#cbd5e1",
          divider: "#233044",
          panel: "#172033",
          nav_indicator: "#1d4ed8",
          accent: "#60a5fa"
        }
      end
    end


    def color_bg(page) = theme_colors(page)[:bg]
    def color_surface(page) = theme_colors(page)[:surface]
    def color_text(page) = theme_colors(page)[:text]
    def color_subtle(page) = theme_colors(page)[:subtle]
    def color_icon(page) = theme_colors(page)[:icon]
    def color_divider(page) = theme_colors(page)[:divider]
    def color_panel(page) = theme_colors(page)[:panel]
    def color_nav_indicator(page) = theme_colors(page)[:nav_indicator]
    def color_accent(page) = theme_colors(page)[:accent]

    def preview_content_width(page, max:, margin: 56, min: 240)
      viewport = page.width.to_f
      return max if viewport <= 0

      [[viewport - margin, min].max, max].min
    end

    def preview_content_height(page, max:, chrome: 210, min: 280)
      viewport = page.height.to_f
      return max if viewport <= 0

      [[viewport - chrome, min].max, max].min
    end

    def read_number(data, key)
      return nil unless data
      return data if data.is_a?(Numeric)
      return data.to_f if data.is_a?(String) && data.match?(/\A-?\d+(\.\d+)?\z/)
      if data.is_a?(Hash)
        raw = data[key] || data[key.to_s] || data[key.to_sym]
        return raw if raw.is_a?(Numeric)
        return raw.to_f if raw
      end
      nil
    end

    def read_string(data, key)
      return nil unless data
      return data if data.is_a?(String)
      if data.is_a?(Hash)
        raw = data[key] || data[key.to_s] || data[key.to_sym]
        return raw if raw.is_a?(String)
      end
      nil
    end

    def compute(op1, op2, op)
      v2 = op2.to_f
      case op
      when "+"
        op1 + v2
      when "-"
        op1 - v2
      when "*"
        op1 * v2
      when "/"
        return "Error" if v2.zero?

        op1 / v2
      else
        "Error"
      end
    rescue StandardError
      "Error"
    end

    def fmt_pos(event)
      return "?" unless event&.data

      data = event.data
      if data.is_a?(String)
        begin
          data = JSON.parse(data)
        rescue StandardError
          return event.data.to_s
        end
      end

      return event.data.to_s unless data.is_a?(Hash)

      pos = data["localPosition"] || data["local_position"] || data[:localPosition] || data[:local_position] ||
        data["l"] || data[:l] || data["g"] || data[:g] || data
      if pos.is_a?(Hash)
        x = pos["x"] || pos[:x]
        y = pos["y"] || pos[:y]
        return "#{x}, #{y}" if x && y
      end
      event.data.to_s
    end

    def extract_pos(event)
      return nil unless event&.data

      data = event.data
      if data.is_a?(String)
        begin
          data = JSON.parse(data)
        rescue StandardError
          return nil
        end
      end

      return nil unless data.is_a?(Hash)

      # Flutter/Flet's GestureDetector emits flat local coords as lx/ly
      # (and global as gx/gy) on tap/tap_down/pan events. Prefer those.
      lx = data["lx"] || data[:lx]
      ly = data["ly"] || data[:ly]
      return { x: lx.to_f, y: ly.to_f } if lx && ly

      gx = data["gx"] || data[:gx]
      gy = data["gy"] || data[:gy]
      return { x: gx.to_f, y: gy.to_f } if gx && gy

      # Fallback for nested {localPosition: {x, y}} style payloads.
      pos = data["localPosition"] || data["local_position"] || data[:localPosition] || data[:local_position] ||
        data["l"] || data[:l] || data["g"] || data[:g] || data
      return nil unless pos.is_a?(Hash)

      x = pos["x"] || pos[:x]
      y = pos["y"] || pos[:y]
      return nil unless x && y

      { x: x.to_f, y: y.to_f }
    end
  end
end

# === showcase/views/status_text.rb ===
module Showcase
  module Views
    def status_text(page)
      text(value: "", style: { size: 12, color: color_subtle(page) })
    end
  end
end

# === showcase/sections_controls/calculator.rb ===
module Showcase
  module SectionsControls
    DIGITS = %w[0 1 2 3 4 5 6 7 8 9].freeze

    def build_calculator(page, status)
      display = calculator_display(page)
      calculator_width = preview_content_width(page, max: 420, min: 300)
      key_width = [[(calculator_width - 42) / 4.0, 56].max, 78].min
      container(
        width: calculator_width,
        padding: 12,
        border_radius: 12,
        bgcolor: color_panel(page),
        content: column(
          spacing: 12,
          children: [
            status,
            container(height: 24),
            row(alignment: "end", children: [display]),
            container(height: 20),
            calculator_keypad_row(page, display, status, key_width, "BS", "AC", "%", "/"),
            calculator_keypad_row(page, display, status, key_width, "7", "8", "9", "x"),
            calculator_keypad_row(page, display, status, key_width, "4", "5", "6", "-"),
            calculator_keypad_row(page, display, status, key_width, "1", "2", "3", "+"),
            calculator_keypad_row(page, display, status, key_width, "+/-", "0", ".", "=")
          ]
        )
      )
    end

    def calculator_state
      @calculator_state ||= { display: "0", operand: nil, operator: nil, start_new_value: false }
    end

    def calculator_display(page)
      @calculator_display = text(
        value: calculator_state[:display],
        text_align: "right",
        style: { size: 84, color: color_text(page) }
      )
    end

    def calculator_keypad_row(page, display, status, key_width, *labels)
      row(
        alignment: "center",
        spacing: 6,
        children: labels.map do |label|
          elevated_button(
            content: text(value: label),
            width: key_width,
            height: 65,
            color: calculator_key_text_color(page, label),
            bgcolor: calculator_key_bg(page, label),
            on_click: ->(e) { calculator_handle_input(label, e, page, display, status) }
          )
        end
      )
    end

    def calculator_key_bg(page, label)
      %w[/ x - + =].include?(label) ? color_accent(page) : color_surface(page)
    end

    def calculator_key_text_color(page, label)
      %w[/ x - + =].include?(label) ? "#FFFFFF" : color_text(page)
    end

    def calculator_handle_input(label, event, page, display, status)
      if DIGITS.include?(label)
        calculator_on_digit(label)
      elsif label == "."
        calculator_on_decimal
      elsif %w[x / - +].include?(label)
        calculator_on_operator(label)
      elsif label == "="
        calculator_on_equals
      elsif label == "AC"
        calculator_reset
      elsif label == "+/-"
        calculator_on_toggle_sign
      elsif label == "%"
        calculator_on_percent
      elsif label == "BS"
        calculator_on_backspace
      end

      page.update(display, value: calculator_state[:display])
      page.update(status, value: "Calculator result: #{calculator_state[:display]}") if label == "="
      event
    end

    def calculator_on_digit(digit)
      if calculator_state[:start_new_value] || calculator_state[:display] == "Error"
        calculator_state[:display] = digit
        calculator_state[:start_new_value] = false
        return
      end

      calculator_state[:display] = (calculator_state[:display] == "0" ? digit : "#{calculator_state[:display]}#{digit}")
    end

    def calculator_on_decimal
      if calculator_state[:start_new_value] || calculator_state[:display] == "Error"
        calculator_state[:display] = "0."
        calculator_state[:start_new_value] = false
        return
      end

      calculator_state[:display] += "." unless calculator_state[:display].include?(".")
    end

    def calculator_on_operator(next_operator)
      if calculator_state[:operator] && !calculator_state[:start_new_value]
        calculator_apply_calculation
        return if calculator_state[:display] == "Error"
      else
        calculator_state[:operand] = calculator_to_number(calculator_state[:display])
      end

      calculator_state[:operator] = next_operator
      calculator_state[:start_new_value] = true
    end

    def calculator_on_equals
      return unless calculator_state[:operator]

      calculator_apply_calculation
      calculator_state[:operator] = nil if calculator_state[:display] != "Error"
    end

    def calculator_on_toggle_sign
      return if calculator_state[:display] == "0" || calculator_state[:display] == "Error"

      calculator_state[:display] = if calculator_state[:display].start_with?("-")
                                     calculator_state[:display][1..]
                                   else
                                     "-#{calculator_state[:display]}"
                                   end
    end

    def calculator_on_percent
      return if calculator_state[:display] == "Error"

      calculator_state[:display] = calculator_format_number(calculator_to_number(calculator_state[:display]) / 100.0)
      calculator_state[:start_new_value] = true
    end

    def calculator_on_backspace
      return if calculator_state[:display] == "Error"

      if calculator_state[:display].length <= 1 || (calculator_state[:display].length == 2 && calculator_state[:display].start_with?("-"))
        calculator_state[:display] = "0"
        return
      end

      calculator_state[:display] = calculator_state[:display][0...-1]
    end

    def calculator_apply_calculation
      right = calculator_to_number(calculator_state[:display])
      result = case calculator_state[:operator]
               when "+"
                 calculator_state[:operand] + right
               when "-"
                 calculator_state[:operand] - right
               when "x"
                 calculator_state[:operand] * right
               when "/"
                 return calculator_show_error if right.zero?

                 calculator_state[:operand] / right
               end

      calculator_state[:display] = calculator_format_number(result)
      calculator_state[:operand] = calculator_to_number(calculator_state[:display])
      calculator_state[:start_new_value] = true
    end

    def calculator_to_number(value)
      Float(value)
    rescue StandardError
      0.0
    end

    def calculator_format_number(value)
      number = value.to_f
      return number.to_i.to_s if number == number.to_i

      number.to_s.sub(/\.?0+\z/, "")
    end

    def calculator_show_error
      calculator_state[:display] = "Error"
      calculator_state[:operator] = nil
      calculator_state[:operand] = nil
      calculator_state[:start_new_value] = true
    end

    def calculator_reset
      calculator_state[:display] = "0"
      calculator_state[:operand] = nil
      calculator_state[:operator] = nil
      calculator_state[:start_new_value] = false
    end
  end
end

# === showcase/sections_controls/code_editor.rb ===
module Showcase
  module SectionsControls
    SAMPLE_CODE = <<~RUBY
      # A tiny Ruflet app
      class App < Ruflet::App
        def view(page)
          page.add(text(value: "Hello from Ruflet!"))
        end
      end
    RUBY

    def build_code_editor(page, status)
      editor = code_editor(
        SAMPLE_CODE,
        language: "ruby",
        code_theme: theme_mode == "dark" ? "atom-one-dark" : "atom-one-light",
        read_only: false,
        height: preview_content_height(page, max: 520, min: 320),
        on_change: ->(e) { page.update(status, value: "#{e.data.to_s.length} characters") },
        on_focus: ->(_e) { page.update(status, value: "Editor focused") },
        on_blur: ->(_e) { page.update(status, value: "Editor blurred") }
      )

      read_only = false

      column(
        spacing: 12,
        children: [
          status,
          row(
            spacing: 8,
            children: [
              elevated_button(
                content: text(value: "Toggle read-only"),
                on_click: ->(_e) {
                  read_only = !read_only
                  page.update(editor, read_only: read_only)
                  page.update(status, value: read_only ? "Read-only" : "Editable")
                }
              ),
              elevated_button(
                content: text(value: "Focus"),
                on_click: ->(_e) { editor.focus }
              )
            ]
          ),
          container(
            height: preview_content_height(page, max: 520, min: 320),
            border_radius: 12,
            bgcolor: color_panel(page),
            content: editor
          )
        ]
      )
    end
  end
end

# === showcase/sections_controls/components.rb ===
module Showcase
  module SectionsControls
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

    def build_components(page, status)
      column(
        spacing: 8,
        horizontal_alignment: "stretch",
        children: [
          status,
          text(value: "Supported widgets", style: { size: 18, weight: "w700", color: color_text(page) }),
          *SUPPORTED_COMPONENTS.map do |component|
            slug = component.fetch(:slug)
            control(
              :list_tile,
              bgcolor: color_surface(page),
              content_padding: { left: 12, right: 12, top: 8, bottom: 8 },
              leading: icon(icon: component.fetch(:icon), color: color_icon(page)),
              title: text(value: component.fetch(:label), style: { size: 16, color: color_text(page) }),
              trailing: icon(icon: Ruflet::MaterialIcons::CHEVRON_RIGHT, color: color_subtle(page)),
              on_click: ->(_e) { page.go("/components/#{slug}") }
            )
          end
        ]
      )
    end

    def build_component_detail(page, status, slug)
      column(
        spacing: 12,
        horizontal_alignment: "stretch",
        children: [
          status,
          component_panel(component_title(slug), component_demo(page, status, slug))
        ]
      )
    end

    def component_title(slug)
      SUPPORTED_COMPONENTS.find { |component| component.fetch(:slug) == slug }&.fetch(:label) || "Components"
    end

    def component_demo(page, status, slug)
      case slug
      when "hello-world"
        text(value: "Hello world", style: { size: 28, weight: "w700", color: color_text(page) })
      when "text"
        column(
          spacing: 8,
          children: [
            text(value: "Text"),
            text(value: "Large bold text", style: { size: 22, weight: "w700", color: "#9dccff" }),
            text(value: "Muted secondary text", style: { size: 14, color: color_subtle(page) })
          ]
        )
      when "button"
        row(
          spacing: 8,
          wrap: true,
          children: [
            filled_button(content: text(value: "Filled"), on_click: ->(_e) { page.update(status, value: "Filled button clicked") }),
            button(content: text(value: "Button"), on_click: ->(_e) { page.update(status, value: "Button clicked") }),
            text_button(content: text(value: "Text"), on_click: ->(_e) { page.update(status, value: "Text button clicked") })
          ]
        )
      when "container"
        container(
          width: 260,
          height: 120,
          padding: 16,
          bgcolor: "#172033",
          border_radius: 8,
          content: text(value: "Container with padding, color, radius, width, and height.")
        )
      when "row"
        row(
          spacing: 8,
          children: [
            component_chip("First"),
            component_chip("Second"),
            component_chip("Third")
          ]
        )
      when "column"
        column(
          spacing: 8,
          children: [
            component_chip("Top"),
            component_chip("Middle"),
            component_chip("Bottom")
          ]
        )
      when "text-field"
        text_field(label: "Name", value: "Ruflet")
      when "icon"
        row(
          spacing: 12,
          children: [
            icon(icon: Ruflet::MaterialIcons::HOME, color: "#74c0fc"),
            icon(icon: Ruflet::MaterialIcons::SETTINGS, color: "#adb5bd"),
            icon(icon: Ruflet::MaterialIcons::CHECK_CIRCLE, color: "#69db7c")
          ]
        )
      when "image"
        container(
          width: 260,
          height: 140,
          clip_behavior: "antiAlias",
          border_radius: 8,
          content: image(src: "https://picsum.photos/520/280", fit: "cover")
        )
      when "dialog"
        dialog = alert_dialog(
          open: false,
          modal: true,
          title: text(value: "Dialog"),
          content: text(value: "Hello world from a Ruflet dialog."),
          actions: [
            text_button(content: text(value: "Close"), on_click: ->(_e) { page.update(dialog, open: false) })
          ]
        )
        filled_button(content: text(value: "Open dialog"), on_click: ->(_e) { page.show_dialog(dialog) })
      when "date-picker"
        result = text(value: "Date: 2026-05-21", style: { size: 14, color: color_subtle(page) })
        dialog = date_picker(
          value: "2026-05-21",
          first_date: "2026-01-01",
          last_date: "2026-12-31",
          help_text: "Pick a date",
          on_change: ->(event) { page.update(result, value: "Date: #{event.control.props["value"]}") }
        )
        column(
          spacing: 10,
          children: [
            result,
            filled_button(content: text(value: "Open date picker"), on_click: ->(_e) { page.show_dialog(dialog) })
          ]
        )
      when "date-range-picker"
        result = text(value: "Range: 2026-05-01 - 2026-05-21", style: { size: 14, color: color_subtle(page) })
        dialog = date_range_picker(
          start_value: "2026-05-01",
          end_value: "2026-05-21",
          first_date: "2026-01-01",
          last_date: "2026-12-31",
          help_text: "Pick a date range",
          on_change: lambda do |event|
            start_value = event.control.props["start_value"]
            end_value = event.control.props["end_value"]
            page.update(result, value: "Range: #{start_value} - #{end_value}")
          end
        )
        column(
          spacing: 10,
          children: [
            result,
            filled_button(content: text(value: "Open range picker"), on_click: ->(_e) { page.show_dialog(dialog) })
          ]
        )
      when "time-picker"
        result = text(value: "Time: 09:30", style: { size: 14, color: color_subtle(page) })
        dialog = time_picker(
          value: "09:30",
          help_text: "Pick a time",
          on_change: ->(event) { page.update(result, value: "Time: #{event.control.props["value"]}") }
        )
        column(
          spacing: 10,
          children: [
            result,
            filled_button(content: text(value: "Open time picker"), on_click: ->(_e) { page.show_dialog(dialog) })
          ]
        )
      when "data-table"
        data_table(
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
      when "dropdown"
        dropdown(
          [
            dropdown_option("ruby", text: "Ruby"),
            dropdown_option("flutter", text: "Flutter"),
            dropdown_option("ruflet", text: "Ruflet")
          ],
          label: "Pick one",
          value: "ruflet",
          on_select: ->(event) { page.update(status, value: "Selected: #{event.value}") }
        )
      when "checkbox"
        checkbox(label: "I like Ruflet", value: true, on_change: ->(event) { page.update(status, value: "Checked: #{event.value}") })
      when "radio"
        radio_group(
          column(
            spacing: 6,
            children: [
              radio(label: "Ruby", value: "ruby"),
              radio(label: "Flutter", value: "flutter"),
              radio(label: "Ruflet", value: "ruflet")
            ]
          ),
          value: "ruflet",
          on_change: ->(event) { page.update(status, value: "Radio: #{event.value}") }
        )
      when "tabs"
        tabs(
          length: 2,
          selected_index: 0,
          content: column(
            spacing: 8,
            children: [
              tab_bar([
                tab(label: "Controls", icon: "widgets"),
                tab(label: "Services", icon: "settings")
              ]),
              container(
                height: 140,
                content: tab_bar_view([
                  container(
                    alignment: "center",
                    content: text(value: "Controls tab body")
                  ),
                  container(
                    alignment: "center",
                    content: text(value: "Services tab body")
                  )
                ])
              )
            ]
          ),
          on_change: ->(event) { page.update(status, value: "Tab index: #{event.value}") }
        )
      when "progress-bar"
        progress_bar(bar_height: 8, color: "#74c0fc", bgcolor: "#172033")
      when "progress-ring"
        progress_ring(stroke_width: 5, color: "#69db7c", bgcolor: "#172033")
      when "grid-view"
        container(
          height: 260,
          content: grid_view(
            runs_count: 3,
            max_extent: 120,
            spacing: 8,
            run_spacing: 8,
            child_aspect_ratio: 1.15,
            children: (1..12).map do |index|
              container(
                padding: 10,
                bgcolor: index.even? ? "#172033" : "#1f2937",
                border_radius: 8,
                content: column(
                  spacing: 6,
                  horizontal_alignment: "center",
                  children: [
                    icon(icon: Ruflet::MaterialIcons[:widgets], color: "#9dccff"),
                    text(value: "Item #{index}", style: { size: 13, color: color_text(page) })
                  ]
                )
              )
            end
          )
        )
      when "interactive-viewer"
        interactive_viewer(
          container(
            width: preview_content_width(page, max: 360),
            height: 220,
            padding: 18,
            bgcolor: "#172033",
            border_radius: 8,
            content: column(
              spacing: 12,
              horizontal_alignment: "center",
              children: [
                icon(icon: Ruflet::MaterialIcons[:open_with], color: "#74c0fc", size: 48),
                text(value: "Pinch, scroll, or drag", style: { size: 16, weight: "w700", color: color_text(page) }),
                text(value: "InteractiveViewer content", style: { size: 13, color: color_subtle(page) })
              ]
            )
          ),
          min_scale: 0.5,
          max_scale: 4,
          pan_enabled: true,
          scale_enabled: true,
          boundary_margin: { left: 80, top: 80, right: 80, bottom: 80 },
          on_interaction_update: ->(_event) { page.update(status, value: "InteractiveViewer updated") }
        )
      when "list-tile"
        control(
          :list_tile,
          leading: icon(icon: Ruflet::MaterialIcons::INFO),
          title: text(value: "ListTile title"),
          subtitle: text(value: "Subtitle"),
          trailing: icon(icon: Ruflet::MaterialIcons::CHEVRON_RIGHT)
        )
      when "switch"
        control(:switch, label: "Enabled", value: true, on_change: ->(_e) { page.update(status, value: "Switch changed") })
      when "slider"
        control(:slider, min: 0, max: 100, divisions: 10, value: 35, label: "Value = {value}")
      else
        text(value: "Component not found.")
      end
    end

    def component_panel(title, content)
      container(
        padding: 12,
        bgcolor: "#111827",
        border_radius: 8,
        content: column(
          spacing: 8,
          children: [
            text(value: title, style: { size: 14, weight: "w600" }),
            content
          ]
        )
      )
    end

    def component_chip(label)
      container(
        padding: { left: 12, right: 12, top: 8, bottom: 8 },
        bgcolor: "#172033",
        border_radius: 8,
        content: text(value: label)
      )
    end
  end
end

# === showcase/sections_controls/counter.rb ===
module Showcase
  module SectionsControls
    def build_counter(page, status)
      count = 0
      value = text(value: count.to_s, style: { size: 28 })

      container(
        width: 320,
        padding: 12,
        border_radius: 12,
        bgcolor: color_panel(page),
        content: column(
          spacing: 12,
          children: [
            status,
            row(alignment: "center", children: [value]),
            row(
              alignment: "center",
              spacing: 10,
              children: [
                elevated_button(
                  width: 120,
                  content: text(value: "-1"),
                  on_click: ->(_e) {
                    count -= 1
                    page.update(value, value: count.to_s)
                    page.update(status, value: "Counter: #{count}")
                  }
                ),
                elevated_button(
                  width: 120,
                  content: text(value: "+1"),
                  on_click: ->(_e) {
                    count += 1
                    page.update(value, value: count.to_s)
                    page.update(status, value: "Counter: #{count}")
                  }
                )
              ]
            ),
          ]
        )
      )
    end
  end
end

# === showcase/sections_controls/cupertino_controls.rb ===
module Showcase
  module SectionsControls
    def build_cupertino_controls(page, status)
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

      cupertino_picker = control(
        :cupertino_picker,
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
            control(:cupertino_radio, label: "Radio 1", value: "r1"),
            control(:cupertino_radio, label: "Radio 2", value: "r2")
          ]
        )
      )

      column(
        spacing: 12,
        children: [
          status,
          control(:cupertino_text_field, label: "Text Field"),
          control(:cupertino_checkbox, label: "Checkbox"),
          control(:cupertino_switch, label: "Switch"),
          control(:cupertino_slider, min: 0, max: 100, divisions: 10, value: 50),
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
                  page.show_dialog(control(:cupertino_bottom_sheet, content: cupertino_picker, height: 216, padding: { top: 6 }))
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
                  page.show_dialog(control(:cupertino_bottom_sheet, content: control(:cupertino_date_picker), height: 216, padding: { top: 6 }))
                }
              ),
              cupertino_button(
                content: text(value: "Show TimerPicker"),
                on_click: ->(_e) {
                  page.show_dialog(control(:cupertino_bottom_sheet, content: control(:cupertino_timer_picker), height: 216, padding: { top: 6 }))
                }
              )
            ]
          )
        ]
      )
    end
  end
end

# === showcase/sections_controls/material_controls.rb ===
module Showcase
  module SectionsControls
    def build_material_controls(page, status)
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
        control(
          :banner,
          open: true,
          leading: icon(icon: Ruflet::MaterialIcons::INFO),
          content: text(value: "Backup completed successfully."),
          actions: [
            text_button(content: text(value: "Dismiss"), on_click: ->(_e) { page.pop_dialog })
          ]
        )
      end

      column(
        spacing: 12,
        children: [
          status,
          control(
            :card,
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
          control(
            :card,
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
                      control(:filled_tonal_button, content: text(value: "Tonal"), on_click: ->(_e) { page.update(status, value: "Tonal pressed") }),
                      control(:outlined_button, content: text(value: "Outlined"), on_click: ->(_e) { page.update(status, value: "Outlined pressed") })
                    ]
                  )
                ]
              )
            )
          ),
          control(
            :card,
            content: container(
              padding: 12,
              content: column(
                spacing: 8,
                children: [
                  text(value: "Selection", style: { size: 14, weight: "w600" }),
                  control(:switch, label: "Wi-Fi", value: true),
                  control(:slider, min: 0, max: 100, divisions: 10, value: 35, label: "Value = {value}")
                ]
              )
            )
          ),
          control(
            :card,
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
          control(
            :card,
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
          control(:list_tile, leading: icon(icon: Ruflet::MaterialIcons::INFO), title: text(value: "ListTile"))
        ]
      )
    end
  end
end

# === showcase/sections_controls/responsive_row.rb ===
module Showcase
  module SectionsControls
    def build_responsive_row(page, status)
      cell = lambda do |label, bg, col|
        container(
          col: col,
          padding: 16,
          border_radius: 8,
          bgcolor: bg,
          content: text(value: label, style: { size: 14, weight: "w600", color: "#ffffff" })
        )
      end

      column(
        spacing: 16,
        children: [
          status,
          text(value: "Resize the window — columns reflow at each breakpoint.",
               style: { size: 13, color: color_subtle(page) }),

          # Each child spans the full 12 columns on phones, half on tablets,
          # and a third on desktops via a per-breakpoint `col` map.
          text(value: "Per-breakpoint col", style: { size: 14, weight: "w600" }),
          responsive_row(
            spacing: 10,
            run_spacing: 10,
            columns: 12,
            children: [
              cell.call("xs:12 / sm:6 / md:4", "#2563eb", { "xs" => 12, "sm" => 6, "md" => 4 }),
              cell.call("xs:12 / sm:6 / md:4", "#7c3aed", { "xs" => 12, "sm" => 6, "md" => 4 }),
              cell.call("xs:12 / sm:12 / md:4", "#db2777", { "xs" => 12, "sm" => 12, "md" => 4 })
            ]
          ),

          # A fixed split: a 4/8 sidebar + content layout.
          text(value: "Fixed 4 / 8 split", style: { size: 14, weight: "w600" }),
          responsive_row(
            spacing: 10,
            children: [
              container(col: 4, padding: 16, border_radius: 8, bgcolor: "#0f766e",
                        content: text(value: "Sidebar (col 4)", style: { color: "#ffffff" })),
              container(col: 8, padding: 16, border_radius: 8, bgcolor: "#334155",
                        content: text(value: "Content (col 8)", style: { color: "#ffffff" }))
            ]
          )
        ]
      )
    end
  end
end

# === showcase/sections_controls/todo.rb ===
module Showcase
  module SectionsControls
    def build_todo(page, _status)
      todos = [
        { text: "Buy milk", done: false },
        { text: "Write docs", done: true }
      ]

      input_text = ""
      input = text_field(
        hint_text: "What needs to be done?",
        on_change: ->(e) { input_text = e.data.to_s }
      )
      list = column(spacing: 6, children: [])

      render_list = lambda do
        new_controls = todos.each_with_index.map do |item, idx|
          checkbox_control = checkbox(
            label: item[:text],
            value: item[:done],
            on_change: ->(e) {
              val = read_number(e.data, "value")
              if val.nil?
                payload = e.data.to_s
                val = payload == "true" || payload == "1"
              end
              todos[idx][:done] = val == 1 || val == true
              render_list.call
            }
          )

          row(
            alignment: "spaceBetween",
            children: [
              checkbox_control,
              icon_button(
                icon: Ruflet::MaterialIcons::DELETE,
                tooltip: "Delete",
                on_click: ->(_e) {
                  todos.delete_at(idx)
                  render_list.call
                }
              )
            ]
          )
        end

        list.children.replace(new_controls)
        page.update
      end

      add_todo = lambda do
        text = input_text.to_s.strip
        return if text.empty?

        todos << { text: text, done: false }
        page.update(input, value: "")
        render_list.call
      end

      render_list.call

      column(
        spacing: 8,
        children: [
          text(value: "Todos", style: { size: 20, weight: "w600" }),
          input,
          button(content: text(value: "Add"), on_click: ->(_e) { add_todo.call }),
          list,
          control(
            :outlined_button,
            content: text(value: "Clear completed"),
            on_click: ->(_e) {
              todos.reject! { |item| item[:done] }
              render_list.call
            }
          )
        ]
      )
    end
  end
end

# === showcase/sections_media/accelerometer.rb ===
module Showcase
  module SectionsMedia
    def build_accelerometer(page, _status)
      return mobile_only_notice(page, "Accelerometer") unless mobile_platform?(page)

      reading_text = text(value: "Waiting for accelerometer reading...")
      error_text = text(value: "")

      accelerometer = page.accelerometer(
        interval: 200,
        cancel_on_error: false,
        on_reading: lambda { |event|
          data = event&.data || {}
          page.update(reading_text, value: sensor_reading_label(data))
          page.update(error_text, value: "")
        },
        on_error: lambda { |event|
          message = event&.data&.dig("message") || event&.data.to_s
          page.update(error_text, value: "Accelerometer error: #{message}")
        }
      )

      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 8,
          children: [
            reading_text,
            error_text,
            row(
              alignment: Ruflet::MainAxisAlignment::CENTER,
              spacing: 8,
              children: [
                button(content: "Start", on_click: ->(_e) { page.update(accelerometer, enabled: true) }),
                button(content: "Stop", on_click: ->(_e) { page.update(accelerometer, enabled: false) })
              ]
            )
          ]
        )
      )
    end

    def sensor_reading_label(data)
      x = sensor_axis_value(data, "x")
      y = sensor_axis_value(data, "y")
      z = sensor_axis_value(data, "z")
      "x: #{x}\ny: #{y}\nz: #{z}"
    end

    def sensor_axis_value(data, key)
      value = data[key] || data[key.to_sym]
      value.is_a?(Numeric) ? format("%.3f", value) : value.to_s
    end
  end
end

# === showcase/sections_media/animation.rb ===
module Showcase
  module SectionsMedia
    def build_animation(page, status)
      random = Random.new
      scattered = true
      size = 14
      gap = 4
      duration = 2_000
      letter_gap = 2
      colors = ["#ec5f94", "#ffa000", "#5bd46f", "#7c4dff", "#42a5f5", "#ffd43b"]
      scatter_colors = [
        "#ffd54f", "#40c4ff", "#ff7043", "#66bb6a", "#ab47bc",
        "#26a69a", "#5c7cfa", "#f06292", "#ffca28", "#4dd0e1"
      ]
      letter_grids = {
        "R" => ["1110", "1001", "1110", "1010", "1001"],
        "u" => ["1001", "1001", "1001", "1001", "1111"],
        "f" => ["1111", "1000", "1110", "1000", "1000"],
        "l" => ["1000", "1000", "1000", "1000", "1111"],
        "e" => ["1111", "1000", "1110", "1000", "1111"],
        "t" => ["1111", "0100", "0100", "0100", "0100"]
      }
      letters = ["R", "u", "f", "l", "e", "t"]

      parts = []
      cursor = 0
      letters.each_with_index do |letter, letter_index|
        rows = letter_grids.fetch(letter)
        rows.each_with_index do |row, y|
          row.chars.each_with_index do |cell, x|
            next unless cell == "1"

            parts << {
              left: (cursor + x) * (size + gap),
              top: y * (size + gap),
              color: colors[letter_index]
            }
          end
        end
        cursor += rows.first.length + letter_gap
      end

      width = cursor * (size + gap)
      height = 5 * (size + gap)
      scatter_props = lambda do
        {
          left: random.rand(0..width),
          top: random.rand(0..(height * 3)),
          width: random.rand((size / 2)..(size * 3)),
          height: random.rand((size / 2)..(size * 3)),
          bgcolor: scatter_colors.sample(random: random),
          border_radius: random.rand(0..(size / 2)),
          rotate: random.rand(0..90) * Math::PI / 180.0
        }
      end
      settle_props = lambda do |part|
        {
          left: part.fetch(:left),
          top: part.fetch(:top),
          width: size,
          height: size,
          bgcolor: part.fetch(:color),
          border_radius: 4,
          rotate: 0
        }
      end

      cells = parts.map do |part|
        container(
          **scatter_props.call,
          animate: duration,
          animate_position: duration,
          animate_rotation: duration
        )
      end

      canvas = stack(
        width: width,
        height: height * 3,
        animate_scale: duration,
        animate_opacity: duration,
        scale: 3.4,
        opacity: 0.32,
        children: cells
      )

      btn = button(content: text(value: "Go!"))
      btn.on(:click) do |_e|
        scattered = !scattered
        cells.each_with_index do |cell, index|
          page.update(cell, **(scattered ? scatter_props.call : settle_props.call(parts[index])))
        end
        page.update(canvas, scale: scattered ? 3.4 : 1, opacity: scattered ? 0.32 : 1)
        page.update(btn, content: text(value: scattered ? "Go!" : "Again!"))
        page.update(status, value: scattered ? "Ruflet scattered." : "Ruflet assembled.")
      end

      container(
        alignment: "center",
        content: column(
          alignment: "center",
          horizontal_alignment: "center",
          tight: true,
          spacing: 16,
          children: [canvas, btn]
        )
      )
    end
  end
end

# === showcase/sections_media/audio.rb ===
module Showcase
  module SectionsMedia
    def build_audio(page, status)
      duration_ms = 0.0
      position_ms = 0.0

      progress = control(:progress_bar, value: 0.0)

      audio = page.instance_variable_get(:@audio_service)
      unless audio
        audio = page.audio(
          src: "https://github.com/flet-dev/media/raw/refs/heads/main/sounds/sweet-life-luxury-chill-438146.mp3",
          autoplay: false,
          volume: 1.0,
          balance: 0.0,
          release_mode: "stop",
          on_loaded: ->(_e) {
            page.update(status, value: "Audio loaded")
            audio.get_duration
          },
          on_duration_change: ->(e) {
            payload = e.data.is_a?(Hash) ? e.data : {}
            duration_ms = payload["duration"].to_f
            duration_ms = duration_ms.positive? ? duration_ms : payload["duration"].to_f
            if duration_ms.positive?
              page.update(play_btn, disabled: false)
              page.update(pause_btn, disabled: false)
              page.update(resume_btn, disabled: false)
              page.update(release_btn, disabled: false)
            end
            page.update(status, value: "Duration: #{duration_ms.to_i}ms")
          },
          on_position_change: ->(e) {
            payload = e.data.is_a?(Hash) ? e.data : {}
            position_ms = payload["position"].to_f
            position_ms = position_ms.positive? ? position_ms : payload["position"].to_f
            if duration_ms.positive?
              page.update(progress, value: (position_ms / duration_ms).clamp(0.0, 1.0))
            end
            page.update(status, value: "Position: #{position_ms.to_i}ms")
          },
          on_state_change: ->(e) { page.update(status, value: "State: #{e.data}") },
          on_seek_complete: ->(_e) { page.update(status, value: "Seek complete") },
          on_error: ->(e) { page.update(status, value: "Audio error: #{e.data}") }
        )
        page.instance_variable_set(:@audio_service, audio)
      end

      send_audio = lambda do |label, method_name, args: nil|
        page.update(status, value: "Audio: #{label}")
        callback = lambda { |result, error|
          if error && !error.to_s.empty?
            page.update(status, value: "Audio error: #{error}")
          elsif result
            page.update(status, value: "Audio #{label}: #{result}")
          else
            page.update(status, value: "Audio #{label} complete")
          end
        }
        case method_name
        when "play"
          audio.play(on_result: callback)
        when "pause"
          audio.pause(on_result: callback)
        when "resume"
          audio.resume(on_result: callback)
        when "release"
          audio.release(on_result: callback)
        when "seek"
          audio.seek(args && args[:position], on_result: callback)
        when "get_duration"
          audio.get_duration(on_result: callback)
        when "get_current_position"
          audio.get_current_position(on_result: callback)
        end
      end

      play_btn = button(content: text(value: "Play"), on_click: ->(_e) { send_audio.call("Play", "play") })
      pause_btn = button(content: text(value: "Pause"), on_click: ->(_e) { send_audio.call("Pause", "pause") })
      resume_btn = button(content: text(value: "Resume"), on_click: ->(_e) { send_audio.call("Resume", "resume") })
      release_btn = button(content: text(value: "Release"), on_click: ->(_e) { send_audio.call("Release", "release") })

      adjust_volume = lambda do |delta|
        next_volume = (audio.props["volume"].to_f + delta).clamp(0.0, 1.0)
        page.update(audio, volume: next_volume)
        page.update(status, value: "Volume: #{next_volume.round(2)}")
      end

      adjust_balance = lambda do |delta|
        next_balance = (audio.props["balance"].to_f + delta).clamp(-1.0, 1.0)
        page.update(audio, balance: next_balance)
        page.update(status, value: "Balance: #{next_balance.round(2)}")
      end

      column(
        spacing: 8,
        children: [
          status,
          progress,
          column(
            spacing: 8,
            children: [
              play_btn,
              pause_btn,
              resume_btn,
              release_btn
            ]
          ),
          column(
            spacing: 8,
            children: [
              button(content: text(value: "Seek 2s"), on_click: ->(_e) { send_audio.call("Seek 2s", "seek", args: { position: 2000 }) }),
              button(content: text(value: "Get duration"), on_click: ->(_e) { send_audio.call("Get duration", "get_duration") }),
              button(content: text(value: "Get position"), on_click: ->(_e) { send_audio.call("Get position", "get_current_position") })
            ]
          ),
          column(
            spacing: 8,
            children: [
              button(content: text(value: "Volume -"), on_click: ->(_e) { adjust_volume.call(-0.1) }),
              button(content: text(value: "Volume +"), on_click: ->(_e) { adjust_volume.call(0.1) })
            ]
          ),
          column(
            spacing: 8,
            children: [
              button(content: text(value: "Balance L"), on_click: ->(_e) { adjust_balance.call(-0.1) }),
              button(content: text(value: "Balance R"), on_click: ->(_e) { adjust_balance.call(0.1) })
            ]
          ),
        ]
      )
    end
  end
end

# === showcase/sections_media/audio_recorder.rb ===
require "fileutils"

module Showcase
  module SectionsMedia
    def build_audio_recorder(page, status)
      recorder = page.audio_recorder(key: "studio_audio_recorder")
      recording_path = nil

      column(
        spacing: 8,
        children: [
          status,
          row(
            spacing: 8,
            wrap: true,
            children: [
              text_button(content: text(value: "Permission"), on_click: ->(_e) {
                recorder.has_permission(on_result: ->(result, error) {
                  page.update(status, value: error ? "Recorder permission error: #{error}" : "Recorder microphone permission: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Input devices"), on_click: ->(_e) {
                recorder.get_input_devices(on_result: ->(result, error) {
                  page.update(status, value: error ? "Devices error: #{error}" : "Devices: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Start"), on_click: ->(_e) {
                page.update(status, value: "Preparing recording path...")
                page.get_application_documents_directory(on_result: ->(documents_dir, path_error) {
                  if path_error || documents_dir.to_s.empty?
                    page.update(status, value: "Recording path error: #{path_error || "documents directory unavailable"}")
                    next
                  end

                  recording_path = File.join(documents_dir.to_s, "showcase_recording.wav")
                  next unless prepare_recorder_output_path(page, recording_path, status)

                  recorder.has_permission(on_result: ->(allowed, recorder_error) {
                    if recorder_error
                      page.update(status, value: "Recorder permission error: #{recorder_error}")
                    elsif !allowed
                      page.update(status, value: "Recorder microphone permission was not granted.")
                    else
                      page.update(status, value: "Recording to #{recording_path}")
                      recorder.start_recording(output_path: recording_path, configuration: { encoder: "wav" }, on_result: ->(result, error) {
                        page.update(status, value: error ? "Start error: #{error}" : "Recording started: #{result.inspect}")
                      })
                    end
                  })
                })
              }),
              text_button(content: text(value: "Stop"), on_click: ->(_e) {
                recorder.stop_recording(on_result: ->(result, error) {
                  page.update(status, value: error ? "Stop error: #{error}" : "Recording saved: #{result.inspect || recording_path || "unknown path"}")
                })
              }),
              text_button(content: text(value: "Cancel"), on_click: ->(_e) {
                recorder.cancel_recording(on_result: ->(result, error) {
                  page.update(status, value: error ? "Cancel error: #{error}" : "Recording cancelled: #{result.inspect}")
                })
              })
            ]
          )
        ]
      )
    end

    def prepare_recorder_output_path(page, recording_path, status)
      return true unless %w[macos linux windows].include?(client_platform(page))

      FileUtils.mkdir_p(File.dirname(recording_path))
      FileUtils.touch(recording_path)
      true
    rescue StandardError => e
      page.update(status, value: "Recording file prepare error: #{e.class}: #{e.message}")
      false
    end
  end
end

# === showcase/sections_media/barometer.rb ===
module Showcase
  module SectionsMedia
    def build_barometer(page, _status)
      return mobile_only_notice(page, "Barometer") unless mobile_platform?(page)

      reading_text = text(value: "Waiting for barometer reading...")
      error_text = text(value: "")

      barometer = page.barometer(
        interval: 200,
        enabled: false,
        cancel_on_error: false,
        on_reading: lambda { |event|
          data = event&.data || {}
          page.update(reading_text, value: barometer_reading_label(data))
          page.update(error_text, value: "")
        },
        on_error: lambda { |event|
          message = event&.data&.dig("message") || event&.data.to_s
          page.update(error_text, value: "Barometer error: #{message}")
        }
      )

      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 8,
          children: [
            reading_text,
            error_text,
            row(
              alignment: Ruflet::MainAxisAlignment::CENTER,
              spacing: 8,
              children: [
                button(content: "Start", on_click: ->(_e) { page.update(barometer, enabled: true) }),
                button(content: "Stop", on_click: ->(_e) { page.update(barometer, enabled: false) })
              ]
            )
          ]
        )
      )
    end

    def barometer_reading_label(data)
      pressure = data["pressure"] || data[:pressure]
      value = pressure.is_a?(Numeric) ? format("%.3f", pressure) : pressure.to_s
      "pressure: #{value}"
    end
  end
end

# === showcase/sections_media/battery.rb ===
module Showcase
  module SectionsMedia
    def build_battery(page, _status)
      return unsupported_feature_panel(page, "Battery", "battery") unless feature_supported?(page, "battery")

      info_text = text(value: "Battery level: -\nBattery state: -\nBattery saver: -")

      refresh_info = lambda do
        page.get_battery_level(
          on_result: lambda { |level, level_error|
            if level_error && !level_error.to_s.empty?
              page.update(info_text, value: "Battery error: #{level_error}")
              next
            end

            page.get_battery_state(
              on_result: lambda { |state, state_error|
                if state_error && !state_error.to_s.empty?
                  page.update(info_text, value: "Battery error: #{state_error}")
                  next
                end

                page.is_in_battery_save_mode(
                  on_result: lambda { |save_mode, save_error|
                    if save_error && !save_error.to_s.empty?
                      page.update(info_text, value: "Battery error: #{save_error}")
                      next
                    end

                    level_label = level.nil? ? "Unknown" : "#{level}%"
                    state_label = state.to_s.empty? ? "unknown" : state.to_s.upcase
                    saver_label = save_mode ? "ON" : "OFF"
                    page.update(
                      info_text,
                      value: "Battery level: #{level_label}\nBattery state: #{state_label}\nBattery saver: #{saver_label}"
                    )
                  }
                )
              }
            )
          }
        )
      end

      page.battery(on_state_change: ->(_e) { refresh_info.call })
      refresh_info.call

      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          children: [
            info_text,
            button(
              content: "Refresh battery info",
              on_click: ->(_e) { refresh_info.call }
            )
          ]
        )
      )
    end
  end
end

# === showcase/sections_media/browser_context_menu.rb ===
module Showcase
  module SectionsMedia
    def build_browser_context_menu(page, status)
      page.browser_context_menu(key: "studio_browser_context_menu")

      column(
        spacing: 8,
        children: [
          status,
          row(
            spacing: 8,
            children: [
              text_button(content: text(value: "Disable menu"), on_click: ->(_e) {
                page.disable_browser_context_menu(on_result: ->(_result, error) {
                  page.update(status, value: error ? "Disable failed: #{error}" : "Browser context menu disabled")
                })
              }),
              text_button(content: text(value: "Enable menu"), on_click: ->(_e) {
                page.enable_browser_context_menu(on_result: ->(_result, error) {
                  page.update(status, value: error ? "Enable failed: #{error}" : "Browser context menu enabled")
                })
              })
            ]
          )
        ]
      )
    end
  end
end

# === showcase/sections_media/camera.rb ===
module Showcase
  module SectionsMedia
    def build_camera(page, status)
      return mobile_only_notice(page, "Camera") unless mobile_platform?(page)

      camera = page.camera(
        preview_enabled: true,
        on_error: ->(e) { page.update(status, value: "Camera error: #{e.data}") }
      )
      camera_busy = false
      open_button = nil
      take_picture_button = nil
      initialized = false
      last_picture = text(value: "")

      preview = container(
        height: 1,
        border_radius: 10,
        bgcolor: color_panel(page),
        border: { width: 1, color: color_divider(page) },
        content: camera
      )

      open_button = button(
        content: text(value: "Open camera"),
        on_click: ->(_e) do
          next if camera_busy
          camera_busy = true
          page.update(open_button, disabled: true)
          page.update(status, value: "Checking available cameras...")
          Thread.new do
            sleep(2)
            if camera_busy
              page.update(status, value: "Still waiting for the platform camera list...")
            end
          end
          page.invoke(
            camera,
            "get_available_cameras",
            timeout: 5,
            on_result: lambda { |result, error|
              if error && !error.to_s.empty?
                camera_busy = false
                page.update(open_button, disabled: false)
                page.update(status, value: "Camera error: #{error}")
                next
              end

              cameras = Array(result)
              if cameras.empty?
                camera_busy = false
                page.update(open_button, disabled: false)
                page.update(status, value: "No camera available on this device.")
                next
              end

              page.update(status, value: "Initializing camera...")
              page.invoke(
                camera,
                "initialize",
                args: {
                  "description" => cameras.first,
                  "resolution_preset" => "medium",
                  "enable_audio" => false,
                  "image_format_group" => "jpeg"
                },
                timeout: 180,
                on_result: lambda { |_init_result, init_error|
                  camera_busy = false
                  page.update(open_button, disabled: false)
                  if init_error && !init_error.to_s.empty?
                    page.update(status, value: "Camera error: #{init_error}")
                  else
                    initialized = true
                    page.update(preview, height: 320)
                    page.update(take_picture_button, disabled: false)
                    page.update(status, value: "Camera initialized.")
                  end
                }
              )
            }
          )
        end
      )

      take_picture_button = button(
        content: text(value: "Take picture"),
        disabled: true,
        on_click: ->(_e) do
          unless initialized
            page.update(status, value: "Initialize camera first.")
            next
          end

          page.update(status, value: "Taking picture...")
          page.invoke(
            camera,
            "take_picture",
            timeout: 45,
            on_result: lambda { |result, error|
              if error && !error.to_s.empty?
                page.update(status, value: "Camera error: #{error}")
                next
              end

              bytes = result.respond_to?(:bytesize) ? result.bytesize : Array(result).length
              page.update(last_picture, value: "Last picture: #{bytes} bytes")
              page.update(status, value: "Picture captured.")
            }
          )
        end
      )

      column(
        spacing: 10,
        children: [
          status,
          row(spacing: 8, wrap: true, children: [open_button, take_picture_button]),
          text(value: "Tap Open camera to initialize and show preview.", style: { size: 12 }),
          last_picture,
          preview
        ]
      )
    end
  end
end

# === showcase/sections_media/clipboard.rb ===
require "tmpdir"
require "fileutils"

module Showcase
  module SectionsMedia
    def build_clipboard(page, _status)
      page.clipboard

      state_text = text(value: "")
      files_column = column(horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER, spacing: 0, children: [])
      clipboard_in_flight = false

      temp_dir = File.join(Dir.tmpdir, "ruflet_clipboard_files_example")
      FileUtils.mkdir_p(temp_dir)
      sample_files = [
        File.join(temp_dir, "sample_1.txt"),
        File.join(temp_dir, "sample_2.txt")
      ]
      File.write(sample_files[0], "Clipboard sample file 1\n")
      File.write(sample_files[1], "Clipboard sample file 2\n")

      set_files_btn = button(
        content: "Set example files to clipboard",
        on_click: ->(_e) do
          next if clipboard_in_flight

          clipboard_in_flight = true
          page.update(state_text, value: "Setting clipboard files...")
          page.set_clipboard_files(
            sample_files,
            timeout: 6,
            on_result: lambda { |result, error|
              clipboard_in_flight = false
              if error && !error.to_s.empty?
                page.update(state_text, value: "Clipboard error: #{error}")
                next
              end
              page.update(files_column, children: [])
              page.update(state_text, value: "Set #{sample_files.length} file references to clipboard (result: #{result}).")
            }
          )
        end
      )

      get_files_btn = button(
        content: "Get files from clipboard",
        on_click: ->(_e) do
          next if clipboard_in_flight

          clipboard_in_flight = true
          page.update(state_text, value: "Reading clipboard files...")
          page.get_clipboard_files(
            timeout: 6,
            on_result: lambda { |result, error|
              clipboard_in_flight = false
              if error && !error.to_s.empty?
                page.update(state_text, value: "Clipboard error: #{error}")
                page.update(files_column, children: [])
                next
              end

              paths = Array(result).map(&:to_s).reject(&:empty?)
              rows = paths.map do |path|
                row(
                  alignment: Ruflet::MainAxisAlignment::CENTER,
                  children: [text(value: path, selectable: true)]
                )
              end

              page.update(state_text, value: "Read #{paths.length} file reference(s) from clipboard.")
              page.update(files_column, children: rows)
            }
          )
        end
      )

      get_image_btn = button(
        content: "Get image from clipboard",
        on_click: ->(_e) do
          next if clipboard_in_flight

          clipboard_in_flight = true
          page.update(state_text, value: "Reading clipboard image...")
          page.get_clipboard_image(
            timeout: 6,
            on_result: lambda { |result, error|
              clipboard_in_flight = false
              if error && !error.to_s.empty?
                page.update(state_text, value: "Clipboard image error: #{error}")
                next
              end
              size = result.respond_to?(:bytesize) ? result.bytesize : result.to_s.bytesize
              if result.nil? || size.zero?
                page.update(state_text, value: "No image in clipboard.")
              else
                page.update(state_text, value: "Clipboard image available (#{size} bytes).")
              end
            }
          )
        end
      )

      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          children: [
            set_files_btn,
            get_files_btn,
            get_image_btn,
            state_text,
            files_column
          ]
        )
      )
    end
  end
end

# === showcase/sections_media/connectivity.rb ===
module Showcase
  module SectionsMedia
    def build_connectivity(page, status)
      current_text = text(value: "")
      page.connectivity(
        on_change: lambda { |event|
          values = Array(event&.data).map(&:to_s)
          label = values.empty? ? "none" : values.join(", ")
          page.update(current_text, value: label)
        }
      )

      column(
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
    end
  end
end

# === showcase/sections_media/file_picker.rb ===
module Showcase
  module SectionsMedia
    def build_file_picker(page, status)
      page.file_picker

      selected_files = text(value: "")
      save_file_path = text(value: "")
      directory_path = text(value: "")
      picker_in_flight = false

      column(
        spacing: 10,
        children: [
          status,
          row(
            children: [
              button(
                content: "Pick files",
                icon: Ruflet::MaterialIcons::UPLOAD_FILE,
                on_click: ->(_e) do
                  next if picker_in_flight
                  picker_in_flight = true
                  page.update(selected_files, value: "Opening file picker...")
                  page.pick_files(
                    allow_multiple: true,
                    with_data: false,
                    on_result: lambda { |result, error|
                      picker_in_flight = false
                      if error && !error.to_s.empty?
                        page.update(selected_files, value: "File picker error: #{error}")
                        next
                      end
                      files = Array(result)
                      names = files.map { |f| f["name"] || f[:name] }.compact.join(", ")
                      page.update(selected_files, value: names.empty? ? "Cancelled!" : names)
                    }
                  )
                end
              ),
              container(expand: true, content: selected_files)
            ]
          ),
          row(
            children: [
              button(
                content: "Save file",
                icon: Ruflet::MaterialIcons::SAVE,
                on_click: ->(_e) do
                  next if picker_in_flight
                  picker_in_flight = true
                  page.update(save_file_path, value: "Opening save dialog...")
                  page.save_file(
                    file_name: "ruflet_sample.txt",
                    src_bytes: "Saved from Showcase\n".b,
                    on_result: lambda { |result, error|
                      picker_in_flight = false
                      if error && !error.to_s.empty?
                        page.update(save_file_path, value: "File picker error: #{error}")
                        next
                      end
                      page.update(save_file_path, value: result.to_s.empty? ? "Cancelled!" : result.to_s)
                    }
                  )
                end
              ),
              container(expand: true, content: save_file_path)
            ]
          ),
          # Pick/save use the browser's file APIs on web, but a directory
          # picker has no web equivalent — guard that one control so it shows
          # a clean notice instead of a "not supported on web" exception.
          if feature_supported?(page, "directory_picker")
            row(
              children: [
                button(
                  content: "Open directory",
                  icon: Ruflet::MaterialIcons::FOLDER_OPEN,
                  on_click: ->(_e) do
                    next if picker_in_flight
                    picker_in_flight = true
                    page.update(directory_path, value: "Opening directory picker...")
                    page.get_directory_path(
                      on_result: lambda { |result, error|
                        picker_in_flight = false
                        if error && !error.to_s.empty?
                          page.update(directory_path, value: "File picker error: #{error}")
                          next
                        end
                        page.update(directory_path, value: result.to_s.empty? ? "Cancelled!" : result.to_s)
                      }
                    )
                  end
                ),
                container(expand: true, content: directory_path)
              ]
            )
          else
            unsupported_feature_panel(page, "Open directory", "directory_picker")
          end
        ]
      )
    end
  end
end

# === showcase/sections_media/flashlight.rb ===
module Showcase
  module SectionsMedia
    def build_flashlight(page, status)
      return mobile_only_notice(page, "Flashlight") unless mobile_platform?(page)

      flashlight = page.service(
        :flashlight,
        on_error: ->(e) { page.update(status, value: "Flashlight error: #{e.data}") }
      )

      column(
        spacing: 8,
        children: [
          status,
          row(
            spacing: 8,
            children: [
              text_button(content: text(value: "On"), on_click: ->(_e) {
                page.invoke(flashlight, "on")
                page.update(status, value: "Flashlight on")
              }),
              text_button(content: text(value: "Off"), on_click: ->(_e) {
                page.invoke(flashlight, "off")
                page.update(status, value: "Flashlight off")
              })
            ]
          )
        ]
      )
    end
  end
end

# === showcase/sections_media/geolocator.rb ===
module Showcase
  module SectionsMedia
    def build_geolocator(page, status)
      geo = page.geolocator(key: "studio_geolocator")

      column(
        spacing: 8,
        children: [
          status,
          row(
            spacing: 8,
            wrap: true,
            children: [
              text_button(content: text(value: "Permission"), on_click: ->(_e) {
                geo.get_permission_status(on_result: ->(result, error) {
                  page.update(status, value: error ? "Permission error: #{error}" : "Permission: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Request permission"), on_click: ->(_e) {
                geo.request_permission(on_result: ->(result, error) {
                  page.update(status, value: error ? "Request error: #{error}" : "Permission request: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Current position"), on_click: ->(_e) {
                page.update(status, value: "Getting current position...")
                geo.get_current_position(on_result: ->(result, error) {
                  page.update(status, value: error ? "Position error: #{error}" : "Current position: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Location enabled"), on_click: ->(_e) {
                geo.is_location_service_enabled(on_result: ->(result, error) {
                  page.update(status, value: error ? "Location error: #{error}" : "Enabled: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Location settings"), on_click: ->(_e) {
                geo.open_location_settings(on_result: ->(result, error) {
                  page.update(status, value: error ? "Settings error: #{error}" : "Opened: #{result.inspect}")
                })
              })
            ]
          )
        ]
      )
    end
  end
end

# === showcase/sections_media/gyroscope.rb ===
module Showcase
  module SectionsMedia
    def build_gyroscope(page, _status)
      return mobile_only_notice(page, "Gyroscope") unless mobile_platform?(page)

      reading_text = text(value: "Waiting for gyroscope reading...")
      error_text = text(value: "")

      gyroscope = page.gyroscope(
        interval: 200,
        cancel_on_error: false,
        on_reading: lambda { |event|
          data = event&.data || {}
          page.update(reading_text, value: sensor_reading_label(data))
          page.update(error_text, value: "")
        },
        on_error: lambda { |event|
          message = event&.data&.dig("message") || event&.data.to_s
          page.update(error_text, value: "Gyroscope error: #{message}")
        }
      )

      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 8,
          children: [
            reading_text,
            error_text,
            row(
              alignment: Ruflet::MainAxisAlignment::CENTER,
              spacing: 8,
              children: [
                button(content: "Start", on_click: ->(_e) { page.update(gyroscope, enabled: true) }),
                button(content: "Stop", on_click: ->(_e) { page.update(gyroscope, enabled: false) })
              ]
            )
          ]
        )
      )
    end
  end
end

# === showcase/sections_media/magnetometer.rb ===
module Showcase
  module SectionsMedia
    def build_magnetometer(page, _status)
      return mobile_only_notice(page, "Magnetometer") unless mobile_platform?(page)

      reading_text = text(value: "Waiting for magnetometer reading...")
      error_text = text(value: "")

      magnetometer = page.magnetometer(
        interval: 200,
        cancel_on_error: false,
        on_reading: lambda { |event|
          data = event&.data || {}
          page.update(reading_text, value: sensor_reading_label(data))
          page.update(error_text, value: "")
        },
        on_error: lambda { |event|
          message = event&.data&.dig("message") || event&.data.to_s
          page.update(error_text, value: "Magnetometer error: #{message}")
        }
      )

      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 8,
          children: [
            reading_text,
            error_text,
            row(
              alignment: Ruflet::MainAxisAlignment::CENTER,
              spacing: 8,
              children: [
                button(content: "Start", on_click: ->(_e) { page.update(magnetometer, enabled: true) }),
                button(content: "Stop", on_click: ->(_e) { page.update(magnetometer, enabled: false) })
              ]
            )
          ]
        )
      )
    end
  end
end

# === showcase/sections_media/map.rb ===
module Showcase
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
                content: icon(icon: Ruflet::MaterialIcons::LOCATION_ON, color: "#ff5a5f")
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
                map_control.zoom_in(delta: 1)
              }),
              text_button(content: text(value: "Zoom out"), on_click: ->(_e) {
                map_control.zoom_out(delta: 1)
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

# === showcase/sections_media/permission_handler.rb ===
module Showcase
  module SectionsMedia
    def build_permission_handler(page, status)
      return permission_handler_platform_notice(page) unless permission_handler_platform?(page)

      permissions = page.permission_handler(key: "studio_permission_handler")

      column(
        spacing: 8,
        children: [
          status,
          row(
            spacing: 8,
            wrap: true,
            children: [
              text_button(content: text(value: "Microphone status"), on_click: ->(_e) {
                permissions.get_status("microphone", on_result: ->(result, error) {
                  page.update(status, value: error ? "Status error: #{error}" : "Microphone: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Request mic"), on_click: ->(_e) {
                permissions.request("microphone", on_result: ->(result, error) {
                  page.update(status, value: error ? "Microphone request error: #{error}" : "Microphone request: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Request camera"), on_click: ->(_e) {
                permissions.request("camera", on_result: ->(result, error) {
                  page.update(status, value: error ? "Camera request error: #{error}" : "Camera request: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Open settings"), on_click: ->(_e) {
                permissions.open_app_settings(on_result: ->(result, error) {
                  page.update(status, value: error ? "Settings error: #{error}" : "Opened: #{result.inspect}")
                })
              })
            ]
          )
        ]
      )
    end

    def permission_handler_platform_notice(page)
      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 8,
          children: [
            text(value: "PermissionHandler is available on iOS, Android, Windows, and Web."),
            text(value: "Current platform: #{client_platform(page).empty? ? "unknown" : client_platform(page)}", style: { size: 12 })
          ]
        )
      )
    end
  end
end

# === showcase/sections_media/rive.rb ===
module Showcase
  module SectionsMedia
    # Public sample animation hosted by Rive.
    RIVE_SAMPLE_SRC = "https://cdn.rive.app/animations/vehicles.riv"

    def build_rive(page, status)
      # The flet_rive extension has no web renderer, so the web client reports
      # "Unknown control: Rive". Show a clean notice there instead. RUFLET_TARGET
      # (set by `ruflet run --web`) is the reliable signal; page.web is a fallback.
      if ENV["RUFLET_TARGET"] == "web" || page.web
        return container(
          padding: 16,
          border_radius: 12,
          bgcolor: color_panel(page),
          content: column(spacing: 6, children: [
            text(value: "Rive", style: { size: 15, weight: "w600" }),
            text(value: "Rive animations run in the desktop and mobile clients — the web client can't render them yet.",
                 style: { size: 13, color: color_subtle(page) })
          ])
        )
      end
      return unsupported_feature_panel(page, "Rive", "rive") unless feature_supported?(page, "rive")

      animation = rive(
        RIVE_SAMPLE_SRC,
        width: 300,
        height: 300,
        fit: "contain",
        speed_multiplier: 1.0,
        placeholder: progress_ring()
      )

      column(
        spacing: 12,
        children: [
          status,
          control(:safe_area, content: column(
            spacing: 12,
            children: [
              container(
                width: 300,
                height: 300,
                border_radius: 12,
                bgcolor: color_panel(page),
                content: animation
              ),
              text(value: "Rive animation from #{RIVE_SAMPLE_SRC}", style: { size: 12, color: color_subtle(page) }),
              control(
                :slider,
                min: 0,
                max: 3,
                value: 1,
                divisions: 6,
                label: "Speed = {value}x",
                on_change: ->(e) {
                  page.update(animation, speed_multiplier: read_number(e.data, "value") || 1)
                  page.update(status, value: "Speed #{read_number(e.data, 'value') || 1}x")
                }
              ),
              row(
                spacing: 8,
                wrap: true,
                run_spacing: 8,
                children: %w[contain cover fill fit_width fit_height none].map do |fit_value|
                  button(
                    content: text(value: fit_value),
                    on_click: ->(_e) {
                      page.update(animation, fit: fit_value)
                      page.update(status, value: "Fit: #{fit_value}")
                    }
                  )
                end
              )
            ]
          ))
        ]
      )
    end
  end
end

# === showcase/sections_media/screen_brightness.rb ===
module Showcase
  module SectionsMedia
    def build_screen_brightness(page, _status)
      unless feature_supported?(page, "screen_brightness")
        return unsupported_feature_panel(page, "Screen brightness", "screen_brightness")
      end

      page.screen_brightness(key: "studio_screen_brightness")
      screen_brightness = page.screen_brightness
      info_text = text(value: "Application brightness: -\nSystem brightness: -\nSystem change: -\nAnimate: -\nAuto reset: -")

      fail_info = lambda do |label, error|
        page.update(info_text, value: "#{label} error: #{error}")
      end

      refresh_info = lambda do
        screen_brightness.get_application_screen_brightness(
          on_result: lambda { |application_brightness, application_error|
            if application_error && !application_error.to_s.empty?
              fail_info.call("Application brightness", application_error)
              next
            end

            screen_brightness.get_system_screen_brightness(
              on_result: lambda { |system_brightness, system_error|
                if system_error && !system_error.to_s.empty?
                  fail_info.call("System brightness", system_error)
                  next
                end

                screen_brightness.can_change_system_screen_brightness(
                  on_result: lambda { |can_change, can_change_error|
                    if can_change_error && !can_change_error.to_s.empty?
                      fail_info.call("System change", can_change_error)
                      next
                    end

                    screen_brightness.is_animate(
                      on_result: lambda { |animate, animate_error|
                        if animate_error && !animate_error.to_s.empty?
                          fail_info.call("Animate", animate_error)
                          next
                        end

                        screen_brightness.is_auto_reset(
                          on_result: lambda { |auto_reset, auto_reset_error|
                            if auto_reset_error && !auto_reset_error.to_s.empty?
                              fail_info.call("Auto reset", auto_reset_error)
                              next
                            end

                            page.update(
                              info_text,
                              value: [
                                "Application brightness: #{format_brightness(application_brightness)}",
                                "System brightness: #{format_brightness(system_brightness)}",
                                "System change: #{format_boolean(can_change)}",
                                "Animate: #{format_boolean(animate)}",
                                "Auto reset: #{format_boolean(auto_reset)}"
                              ].join("\n")
                            )
                          }
                        )
                      }
                    )
                  }
                )
              }
            )
          }
        )
      end

      refresh_info.call

      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 8,
          children: [
            info_text,
            row(
              wrap: true,
              alignment: "center",
              spacing: 8,
              children: [
                button(content: "Refresh", on_click: ->(_e) { refresh_info.call }),
                button(content: "App 50%", on_click: ->(_e) {
                  screen_brightness.set_application_screen_brightness(
                    0.5,
                    on_result: lambda { |_result, error|
                      error && !error.to_s.empty? ? fail_info.call("Application brightness", error) : refresh_info.call
                    }
                  )
                }),
                button(content: "System 50%", on_click: ->(_e) {
                  screen_brightness.set_system_screen_brightness(
                    0.5,
                    on_result: lambda { |_result, error|
                      error && !error.to_s.empty? ? fail_info.call("System brightness", error) : refresh_info.call
                    }
                  )
                }),
                button(content: "Reset app", on_click: ->(_e) {
                  screen_brightness.reset_application_screen_brightness(
                    on_result: lambda { |_result, error|
                      error && !error.to_s.empty? ? fail_info.call("Reset brightness", error) : refresh_info.call
                    }
                  )
                }),
                button(content: "Animate on", on_click: ->(_e) {
                  screen_brightness.set_animate(
                    true,
                    on_result: lambda { |_result, error|
                      error && !error.to_s.empty? ? fail_info.call("Animate", error) : refresh_info.call
                    }
                  )
                }),
                button(content: "Auto reset on", on_click: ->(_e) {
                  screen_brightness.set_auto_reset(
                    true,
                    on_result: lambda { |_result, error|
                      error && !error.to_s.empty? ? fail_info.call("Auto reset", error) : refresh_info.call
                    }
                  )
                })
              ]
            )
          ]
        )
      )
    end

    def format_brightness(value)
      return "Unknown" if value.nil?
      return format("%.2f", value) if value.is_a?(Numeric)

      value.to_s.empty? ? "Unknown" : value.to_s
    end

    def format_boolean(value)
      case value
      when true then "YES"
      when false then "NO"
      else value.to_s.empty? ? "Unknown" : value.to_s.upcase
      end
    end
  end
end

# === showcase/sections_media/screenshot.rb ===
module Showcase
  module SectionsMedia
    def build_screenshot(page, _status)
      status_text = text(value: "Screenshot control registered.")
      capture_area = page.screenshot(
        tooltip: "Screenshot area",
        content: container(
          width: 260,
          padding: 16,
          bgcolor: color_surface(page),
          content: column(
            spacing: 8,
            horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
            children: [
              icon(icon: Ruflet::MaterialIcons::PHOTO_CAMERA, color: color_icon(page)),
              text(value: "Capture area", style: { size: 18, color: color_text(page) }),
              text(value: "Wrapped by page.screenshot", style: { size: 13, color: color_subtle(page) })
            ]
          )
        )
      )

      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 10,
          children: [
            capture_area,
            status_text,
            button(
              content: "Refresh",
              on_click: ->(_e) { page.update(status_text, value: "Screenshot control refreshed.") }
            )
          ]
        )
      )
    end
  end
end

# === showcase/sections_media/secure_storage.rb ===
module Showcase
  module SectionsMedia
    def build_secure_storage(page, status)
      storage = page.secure_storage(key: "studio_secure_storage")
      key = "showcase_sample"

      column(
        spacing: 8,
        children: [
          status,
          row(
            spacing: 8,
            wrap: true,
            children: [
              text_button(content: text(value: "Set"), on_click: ->(_e) {
                storage.set(key, "hello", on_result: ->(_result, error) {
                  page.update(status, value: error ? "Set error: #{error}" : "Saved secure value")
                })
              }),
              text_button(content: text(value: "Get"), on_click: ->(_e) {
                storage.get(key, on_result: ->(result, error) {
                  page.update(status, value: error ? "Get error: #{error}" : "Value: #{result.inspect}")
                })
              }),
              text_button(content: text(value: "Clear"), on_click: ->(_e) {
                storage.clear(on_result: ->(_result, error) {
                  page.update(status, value: error ? "Clear error: #{error}" : "Secure storage cleared")
                })
              })
            ]
          )
        ]
      )
    end
  end
end

# === showcase/sections_media/semantics_service.rb ===
module Showcase
  module SectionsMedia
    def build_semantics_service(page, _status)
      status_text = text(value: "Semantics service registered.")

      page.semantics_service(
        key: "studio_semantics_service",
        data: { "message" => "Showcase semantics service sample" }
      )

      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 8,
          children: [
            text(value: "Semantics Service"),
            status_text,
            button(
              content: "Refresh data",
              on_click: lambda { |_e|
                page.semantics_service(
                  key: "studio_semantics_service",
                  data: { "message" => "Updated from Showcase" }
                )
                page.update(status_text, value: "Semantics service data refreshed.")
              }
            )
          ]
        )
      )
    end
  end
end

# === showcase/sections_media/shake_detector.rb ===
module Showcase
  module SectionsMedia
    def build_shake_detector(page, _status)
      return mobile_only_notice(page, "Shake detector") unless mobile_platform?(page)

      shake_count = 0
      state_text = text(value: "Waiting for shake...")

      page.shake_detector(
        minimum_shake_count: 1,
        shake_count_reset_time_ms: 1_500,
        shake_slop_time_ms: 250,
        shake_threshold_gravity: 1.5,
        on_shake: lambda { |_event|
          shake_count += 1
          page.update(state_text, value: "Shake count: #{shake_count}")
        }
      )

      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 8,
          children: [
            state_text,
            row(
              alignment: Ruflet::MainAxisAlignment::CENTER,
              spacing: 8,
              children: [
                button(
                  content: "Reset",
                  on_click: lambda { |_e|
                    shake_count = 0
                    page.update(state_text, value: "Waiting for shake...")
                  }
                )
              ]
            )
          ]
        )
      )
    end
  end
end

# === showcase/sections_media/share.rb ===
require "tmpdir"
require "fileutils"

module Showcase
  module SectionsMedia
    def build_share(page, _status)
      page.share

      status_text = text(value: "")
      raw_text = text(value: "")
      share_in_flight = false

      update_result = lambda do |result, error|
        share_in_flight = false
        if error && !error.to_s.empty?
          page.update(status_text, value: "Share error: #{error}")
          page.update(raw_text, value: "")
          next
        end

        payload = result.is_a?(Hash) ? result : {}
        state = payload["status"] || payload[:status]
        raw = payload["raw"] || payload[:raw]
        state_value = state.to_s.empty? ? "UNKNOWN" : state.to_s.upcase
        raw_value = raw.to_s.empty? ? "(empty)" : raw.to_s
        page.update(status_text, value: "Share status: ShareResultStatus.#{state_value}")
        page.update(raw_text, value: "Raw: #{raw_value}")
      end

      share_sample_file_from_bytes = lambda do |text_value|
        page.share_files(
          [
            {
              "data" => "Sample content from file path\n".b,
              "mime_type" => "text/plain",
              "name" => "sample_from_path.txt"
            }
          ],
          text: text_value,
          download_fallback_enabled: true,
          mail_to_fallback_enabled: true,
          timeout: 30,
          on_result: update_result
        )
      end

      share_text_btn = button(
        content: "Share text",
        on_click: ->(_e) do
          next if share_in_flight

          share_in_flight = true
          page.update(status_text, value: "Opening share sheet...")
          page.update(raw_text, value: "")
          page.share_text(
            "Hello from Ruflet!",
            title: "Share greeting",
            subject: "Greeting",
            download_fallback_enabled: true,
            mail_to_fallback_enabled: true,
            timeout: 30,
            on_result: update_result
          )
        end
      )

      share_link_btn = button(
        content: "Share link",
        on_click: ->(_e) do
          next if share_in_flight

          share_in_flight = true
          page.update(status_text, value: "Opening share sheet...")
          page.update(raw_text, value: "")
          page.share_uri(
            "https://ruflet.dev",
            timeout: 30,
            on_result: update_result
          )
        end
      )

      share_bytes_btn = button(
        content: "Share file from bytes",
        on_click: ->(_e) do
          next if share_in_flight

          share_in_flight = true
          page.update(status_text, value: "Opening share sheet...")
          page.update(raw_text, value: "")
          page.share_files(
            [
              {
                "data" => "Sample content from memory".b,
                "mime_type" => "text/plain",
                "name" => "sample.txt"
              }
            ],
            text: "Sharing a file from memory",
            download_fallback_enabled: true,
            mail_to_fallback_enabled: true,
            timeout: 30,
            on_result: update_result
          )
        end
      )

      share_path_btn = button(
        content: "Share file from path",
        on_click: ->(_e) do
          next if share_in_flight

          share_in_flight = true
          page.update(status_text, value: "Preparing file for share...")
          page.update(raw_text, value: "")

          sample_content = "Sample content from file path\n"
          begin
            base_dir = File.join(Dir.tmpdir, "ruflet_share_example")
            FileUtils.mkdir_p(base_dir)
            sample_path = File.join(base_dir, "sample_from_path.txt")
            File.write(sample_path, sample_content)
          rescue StandardError => e
            page.update(status_text, value: "Path share fallback: #{e.class}: #{e.message}")
            share_sample_file_from_bytes.call("Sharing a file from path fallback")
            next
          end

          page.update(status_text, value: "Opening share sheet...")
          page.share_files(
            [sample_path],
            text: "Sharing a file from path",
            download_fallback_enabled: true,
            mail_to_fallback_enabled: true,
            timeout: 30,
            on_result: update_result
          )
        end
      )

      control(
        :safe_area,
        content: column(
          children: [
            row(
              wrap: true,
              children: [
                share_text_btn,
                share_link_btn,
                share_bytes_btn,
                share_path_btn
              ]
            ),
            status_text,
            raw_text
          ]
        )
      )
    end
  end
end

# === showcase/sections_media/storage_paths.rb ===
require "fileutils"
require "tmpdir"

module Showcase
  module SectionsMedia
    def build_storage_paths(page, _status)
      page.storage_paths

      status_text = text(value: "Loading temporary path...")
      path_text = text(value: "", selectable: true)
      local_text = text(value: "", selectable: true)

      write_local_sample = lambda do
        local_dir = File.join(Dir.tmpdir, "ruflet_storage_paths_example")
        FileUtils.mkdir_p(local_dir)
        local_path = File.join(local_dir, "sample.txt")
        File.write(local_path, "Hello from Showcase storage paths\n")
        local_path
      end

      page.get_temporary_directory(
        timeout: 10,
        on_result: lambda { |result, error|
          if error && !error.to_s.empty?
            page.update(status_text, value: "Storage paths error: #{error}")
            next
          end

          temporary_directory = result.to_s
          if temporary_directory.empty?
            page.update(status_text, value: "Temporary directory is not available on this platform.")
            next
          end

          page.update(status_text, value: "Temporary directory")
          page.update(path_text, value: File.join(temporary_directory, "sample.txt"))

          begin
            page.update(local_text, value: "Local Ruby sample: #{write_local_sample.call}")
          rescue StandardError => e
            page.update(local_text, value: "Local Ruby sample error: #{e.class}: #{e.message}")
          end
        }
      )

      refresh_btn = button(
        content: "Refresh",
        on_click: ->(_e) do
          page.update(status_text, value: "Loading temporary path...")
          page.update(path_text, value: "")
          page.get_temporary_directory(
            timeout: 10,
            on_result: lambda { |result, error|
              if error && !error.to_s.empty?
                page.update(status_text, value: "Storage paths error: #{error}")
                next
              end

              temporary_directory = result.to_s
              page.update(status_text, value: temporary_directory.empty? ? "Temporary directory is not available." : "Temporary directory")
              page.update(path_text, value: temporary_directory.empty? ? "" : File.join(temporary_directory, "sample.txt"))
            }
          )
        end
      )

      column(
        spacing: 8,
        children: [
          status_text,
          path_text,
          local_text,
          refresh_btn
        ]
      )
    end
  end
end

# === showcase/sections_media/user_accelerometer.rb ===
module Showcase
  module SectionsMedia
    def build_user_accelerometer(page, _status)
      return mobile_only_notice(page, "User accelerometer") unless mobile_platform?(page)

      reading_text = text(value: "Waiting for user accelerometer reading...")
      error_text = text(value: "")

      user_accelerometer = page.user_accelerometer(
        interval: 200,
        cancel_on_error: false,
        on_reading: lambda { |event|
          data = event&.data || {}
          page.update(reading_text, value: sensor_reading_label(data))
          page.update(error_text, value: "")
        },
        on_error: lambda { |event|
          message = event&.data&.dig("message") || event&.data.to_s
          page.update(error_text, value: "User accelerometer error: #{message}")
        }
      )

      control(
        :safe_area,
        content: column(
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          spacing: 8,
          children: [
            reading_text,
            error_text,
            row(
              alignment: Ruflet::MainAxisAlignment::CENTER,
              spacing: 8,
              children: [
                button(content: "Start", on_click: ->(_e) { page.update(user_accelerometer, enabled: true) }),
                button(content: "Stop", on_click: ->(_e) { page.update(user_accelerometer, enabled: false) })
              ]
            )
          ]
        )
      )
    end
  end
end

# === showcase/sections_media/video.rb ===
module Showcase
  module SectionsMedia
    def build_video(page, status)
      video = video(
        width: 320,
        height: 180,
        aspect_ratio: 16 / 9.0,
        playlist: [
          { "resource" => "https://user-images.githubusercontent.com/28951144/229373720-14d69157-1a56-4a78-a2f4-d7a134d7c3e9.mp4" },
          { "resource" => "https://user-images.githubusercontent.com/28951144/229373718-86ce5e1d-d195-45d5-baa6-ef94041d0b90.mp4" }
        ],
        playlist_mode: "loop",
        autoplay: false,
        volume: 100,
        playback_rate: 1.0,
        on_loaded: ->(_e) { page.update(status, value: "Video loaded") },
        on_enter_fullscreen: ->(_e) { page.update(status, value: "Video fullscreen") },
        on_exit_fullscreen: ->(_e) { page.update(status, value: "Video exit fullscreen") },
        on_completed: ->(_e) { page.update(status, value: "Video completed") },
        on_error: ->(e) { page.update(status, value: "Video error: #{e.data}") }
      )

      send_video = lambda do |label, method_name, args: nil|
        page.update(status, value: "Video: #{label}")
        case method_name
        when "play"
          video.play
        when "pause"
          video.pause
        when "play_or_pause"
          video.play_or_pause
        when "stop"
          video.stop
        when "next"
          video.next
        when "previous"
          video.previous
        when "seek"
          video.seek(args && args[:position])
        end
      end

      column(
        spacing: 8,
        children: [
          status,
          control(:safe_area, content: column(
            spacing: 12,
            children: [
              video,
              column(
                spacing: 8,
                children: [
                  button(content: text(value: "Play"), on_click: ->(_e) { send_video.call("Play", "play") }),
                  button(content: text(value: "Pause"), on_click: ->(_e) { send_video.call("Pause", "pause") }),
                  button(content: text(value: "Play/Pause"), on_click: ->(_e) { send_video.call("Play/Pause", "play_or_pause") }),
                  button(content: text(value: "Stop"), on_click: ->(_e) { send_video.call("Stop", "stop") }),
                  button(content: text(value: "Next"), on_click: ->(_e) { send_video.call("Next", "next") }),
                  button(content: text(value: "Prev"), on_click: ->(_e) { send_video.call("Prev", "previous") })
                ]
              ),
              column(
                spacing: 8,
                children: [
                  button(content: text(value: "Seek 10s"), on_click: ->(_e) { send_video.call("Seek 10s", "seek", args: { position: 10_000 }) }),
                  button(content: text(value: "Fullscreen"), on_click: ->(_e) { page.update(video, fullscreen: true) })
                ]
              ),
              control(
                :slider,
                min: 0,
                max: 100,
                value: 100,
                divisions: 10,
                label: "Volume = {value}%",
                on_change: ->(e) {
                  page.update(video, volume: read_number(e.data, "value") || 100)
                }
              ),
              control(
                :slider,
                min: 1,
                max: 3,
                value: 1,
                divisions: 6,
                label: "Playback rate = {value}x",
                on_change: ->(e) {
                  page.update(video, playback_rate: read_number(e.data, "value") || 1)
                }
              )
            ]
          ))
        ]
      )
    end
  end
end

# === showcase/sections_media/webview.rb ===
module Showcase
  module SectionsMedia
    def build_webview(page, _status)
      # On the web the native webview becomes an <iframe>, which most sites
      # (including ruflet.dev via X-Frame-Options) refuse to be embedded in.
      return unsupported_feature_panel(page, "WebView", "webview") unless feature_supported?(page, "webview")

      webview_height = preview_content_height(page, max: 640, min: 360)
      webview_control = web_view(
        url: "https://ruflet.dev/",
        method: "get",
        height: webview_height
      )
      container(height: webview_height, content: webview_control)
    end
  end
end

# === showcase/sections_media/window.rb ===
module Showcase
  module SectionsMedia
    def build_window(page, status)
      window = page.window(key: "studio_window", width: 900, height: 700, resizable: true, visible: true)

      column(
        spacing: 8,
        children: [
          status,
          row(
            spacing: 8,
            wrap: true,
            children: [
              text_button(content: text(value: "Ready"), on_click: ->(_e) {
                invoke_studio_window(window, page, status, :wait_until_ready_to_show, "Window ready")
              }),
              text_button(content: text(value: "Center"), on_click: ->(_e) {
                invoke_studio_window(window, page, status, :center, "Window centered")
              }),
              text_button(content: text(value: "To front"), on_click: ->(_e) {
                page.update(window, focused: true, visible: true)
                invoke_studio_window(window, page, status, :to_front, "Window moved to front")
              })
            ]
          )
        ]
      )
    end

    def invoke_studio_window(window, page, status, method_name, success_message)
      window.public_send(method_name, on_result: ->(_result, error) {
        page.update(status, value: error ? "Window error: #{error}" : success_message)
      })
    end
  end
end

# === showcase/sections_misc/icon_search.rb ===
module Showcase
  module SectionsMisc
    ICON_SEARCH_MAX_RESULTS = 80
    ICON_SEARCH_RESULTS_HEIGHT = 420

    def build_icon_search(page, status)
      query = ""
      summary = text(value: icon_search_summary_text(query, []), style: { size: 12 })
      copy_status = text(value: "Tap an item to copy icon name", style: { size: 12 })
      results_grid = grid_view(
        runs_count: 3,
        max_extent: 220,
        child_aspect_ratio: 2.0,
        spacing: 10,
        run_spacing: 10,
        controls: []
      )

      on_query_change = lambda do |new_query|
        query = new_query.to_s
        names = icon_search_filtered_names(query)
        page.update(summary, value: icon_search_summary_text(query, names))
        page.update(results_grid, controls: names.map { |name| icon_search_tile(page, name, copy_status) })
        page.update(copy_status, value: "Tap an item to copy icon name")
      end

      container(
        width: preview_content_width(page, max: 760),
        content: column(
          spacing: 10,
          alignment: Ruflet::MainAxisAlignment::CENTER,
          horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
          children: [
            status,
            text_field(
              label: "Search Material icons",
              autofocus: true,
              value: query,
              on_change: ->(e) {
                data = e.data
                value = data.is_a?(Hash) ? (data["value"] || data[:value]) : data
                on_query_change.call(value.to_s)
              }
            ),
            summary,
            copy_status,
            container(
              height: ICON_SEARCH_RESULTS_HEIGHT,
              content: results_grid
            )
          ]
        )
      )
    end

    def icon_search_tile(page, name, copy_status)
      container(
        padding: 10,
        border_radius: 8,
        on_click: ->(_e) {
          call_id = page.set_clipboard(name)
          if call_id
            page.update(copy_status, value: "Copied: #{name}")
          else
            page.update(copy_status, value: "Copy failed: clipboard service unavailable")
          end
        },
        content: row(
          spacing: 8,
          children: [
            icon(icon: Ruflet::MaterialIcons.const_get(name)),
            container(
              expand: true,
              content: text(value: name, max_lines: 1, ellipsis: true)
            )
          ]
        )
      )
    rescue NameError
      container(
        padding: 10,
        border_radius: 8,
        content: text(value: name)
      )
    end

    def icon_search_summary_text(query, names)
      total = icon_search_icon_names.size
      shown = names.size
      q = query.to_s.strip
      return "Type to search icons (#{total} available)" if q.empty?

      "Showing #{shown} results for \"#{q}\""
    end

    def icon_search_icon_names
      @icon_search_icon_names ||= Ruflet::MaterialIcons.constants(false).map(&:to_s).sort
    end

    def icon_search_filtered_names(query)
      q = query.to_s.strip.upcase
      return [] if q.empty?

      icon_search_icon_names.select { |name| name.include?(q) }.first(ICON_SEARCH_MAX_RESULTS)
    end
  end
end

# === showcase/sections_charts.rb ===
module Showcase
  module SectionsMisc
    def build_charts(page, status)
      bar_chart = bar_chart(
        width: 320,
        height: 180,
        max_y: 110,
        border: { width: 1, color: color_divider(page) },
        horizontal_grid_lines: { color: color_divider(page), width: 1, dash_pattern: [3, 3] },
        tooltip: nil,
        left_axis: chart_axis(label_size: 40, title: text(value: "Fruit supply"), title_size: 40),
        right_axis: chart_axis(show_labels: false),
        bottom_axis: chart_axis(
          label_size: 40,
          labels: [
            chart_axis_label(value: 0, label: container(content: text(value: "Apple"), padding: 10)),
            chart_axis_label(value: 1, label: container(content: text(value: "Blueberry"), padding: 10)),
            chart_axis_label(value: 2, label: container(content: text(value: "Cherry"), padding: 10)),
            chart_axis_label(value: 3, label: container(content: text(value: "Orange"), padding: 10))
          ]
        ),
        groups: [
          bar_chart_group(x: 0, rods: [bar_chart_rod(from_y: 0, to_y: 40, width: 40, color: "#69db7c", border_radius: 0)]),
          bar_chart_group(x: 1, rods: [bar_chart_rod(from_y: 0, to_y: 100, width: 40, color: "#4dabf7", border_radius: 0)]),
          bar_chart_group(x: 2, rods: [bar_chart_rod(from_y: 0, to_y: 30, width: 40, color: "#ff6b6b", border_radius: 0)]),
          bar_chart_group(x: 3, rods: [bar_chart_rod(from_y: 0, to_y: 60, width: 40, color: "#ffa94d", border_radius: 0)])
        ]
      )

      line_chart = line_chart(
        data_series: [
          line_chart_data(points: [
            line_chart_data_point(x: 1, y: 1),
            line_chart_data_point(x: 3, y: 1.5),
            line_chart_data_point(x: 5, y: 1.4),
            line_chart_data_point(x: 7, y: 3.4)
          ], stroke_width: 4, color: "#51cf66", curved: true, rounded_stroke_cap: true),
          line_chart_data(points: [
            line_chart_data_point(x: 1, y: 1),
            line_chart_data_point(x: 3, y: 2.8),
            line_chart_data_point(x: 7, y: 1.2),
            line_chart_data_point(x: 10, y: 2.8)
          ], stroke_width: 4, color: "#f06595", curved: true, rounded_stroke_cap: true)
        ],
        min_y: 0,
        max_y: 4,
        min_x: 0,
        max_x: 14,
        interactive: true,
        width: 320,
        height: 180,
        tooltip: nil,
        on_event: ->(e) { page.update(status, value: "Line chart event: #{e.data}") }
      )

      pie_chart = pie_chart(
        width: 220,
        height: 220,
        sections_space: 0,
        center_space_radius: 0,
        sections: [
          pie_chart_section(value: 40, title: "40%", color: "#4dabf7", radius: 100),
          pie_chart_section(value: 30, title: "30%", color: "#ffd43b", radius: 100),
          pie_chart_section(value: 15, title: "15%", color: "#845ef7", radius: 100),
          pie_chart_section(value: 15, title: "15%", color: "#51cf66", radius: 100)
        ],
        on_event: ->(e) { page.update(status, value: "Pie chart event: #{e.data}") }
      )

      candlestick_chart = candlestick_chart(
        width: 320,
        height: 180,
        min_x: -0.5,
        max_x: 6.5,
        min_y: 22,
        max_y: 36,
        spots: [
          candlestick_chart_spot(x: 0, open: 24.8, high: 28.6, low: 23.9, close: 27.2, selected: true),
          candlestick_chart_spot(x: 1, open: 27.2, high: 30.1, low: 25.8, close: 28.4)
        ],
        tooltip: nil,
        on_event: ->(e) { page.update(status, value: "Candlestick event: #{e.data}") }
      )

      radar_chart = radar_chart(
        width: 300,
        height: 180,
        titles: [
          radar_chart_title(text: "macOS"),
          radar_chart_title(text: "Linux"),
          radar_chart_title(text: "Windows")
        ],
        data_sets: [
          radar_data_set(entries: [
            radar_data_set_entry(value: 300),
            radar_data_set_entry(value: 50),
            radar_data_set_entry(value: 250)
          ])
        ],
        on_event: ->(e) { page.update(status, value: "Radar event: #{e.data}") }
      )

      scatter_chart = scatter_chart(
        width: 300,
        height: 180,
        min_x: 0,
        max_x: 50,
        min_y: 0,
        max_y: 50,
        left_axis: chart_axis(show_labels: false),
        right_axis: chart_axis(show_labels: false),
        top_axis: chart_axis(show_labels: false),
        bottom_axis: chart_axis(show_labels: false),
        on_event: ->(e) { page.update(status, value: "Scatter event: #{e.data}") },
        spots: [
          scatter_chart_spot(x: 10, y: 10, radius: 6, color: "#339af0"),
          scatter_chart_spot(x: 20, y: 25, radius: 10, color: "#ff922b"),
          scatter_chart_spot(x: 35, y: 40, radius: 8, color: "#51cf66")
        ]
      )

      column(
        spacing: 12,
        tight: true,
        children: [
          text(value: "BarChart", style: { size: 14, weight: "w600" }),
          bar_chart,
          text(value: "LineChart", style: { size: 14, weight: "w600" }),
          line_chart,
          text(value: "PieChart", style: { size: 14, weight: "w600" }),
          pie_chart,
          text(value: "CandlestickChart", style: { size: 14, weight: "w600" }),
          candlestick_chart,
          text(value: "RadarChart", style: { size: 14, weight: "w600" }),
          radar_chart,
          text(value: "ScatterChart", style: { size: 14, weight: "w600" }),
          scatter_chart
        ]
      )
    end
  end
end

# === showcase/sections_drawing.rb ===
module Showcase
  module SectionsMisc
    def build_drawing(page, status)
      strokes = []
      last_point = nil
      drawing_paint = paint(color: "#ff6b6b", stroke_width: 3, style: "stroke", stroke_cap: "round", stroke_join: "round")
      demo_shapes = [
        rect(x: 18, y: 18, width: 72, height: 44, border_radius: 8, paint: paint(color: "#4dabf7", stroke_width: 3, style: "stroke")),
        circle(x: 170, y: 40, radius: 22, paint: paint(color: "#ffd43b", style: "fill")),
        path(
          elements: [
            path_move_to(42, 156),
            path_line_to(92, 112),
            path_line_to(142, 156),
            path_close
          ],
          paint: paint(color: "#69db7c", stroke_width: 4, style: "stroke", stroke_join: "round")
        )
      ]

      drawing_canvas = canvas(
        demo_shapes,
        width: preview_content_width(page, max: 420),
        height: 260,
        content: gesture_detector(
          on_pan_start: ->(e) {
            pos = extract_pos(e)
            last_point = pos
          },
          on_pan_update: ->(e) {
            pos = extract_pos(e)
            if last_point && pos
              strokes << line(x1: last_point[:x], y1: last_point[:y], x2: pos[:x], y2: pos[:y], paint: drawing_paint)
              page.update(drawing_canvas, shapes: demo_shapes + strokes)
            end
            last_point = pos
          },
          on_pan_end: ->(_e) { last_point = nil },
          drag_interval: 10
        )
      )

      column(spacing: 8, tight: true, children: [status, drawing_canvas])
    end
  end
end

# === showcase/sections_minesweeper.rb ===
module Showcase
  module SectionsMisc
    def build_minesweeper(page, status)
      rows = 9
      cols = 9
      size = 24
      board_width = cols * size
      board_height = rows * size
      mine_count = 10
      mines_left = mine_count
      game_over = false
      won = false
      first_click_done = false
      last_tap_pos = nil

      squares = Array.new(rows * cols) do |idx|
        r = idx / cols
        c = idx % cols
        {
          row: r,
          col: c,
          mine: false,
          revealed: false,
          flagged: false,
          exploded: false,
          adjacent: 0
        }
      end

      number_color = lambda do |value|
        case value
        when 1 then "#2f6df6"
        when 2 then "#2f9e44"
        when 3 then "#f03e3e"
        when 4 then "#5f3dc4"
        when 5 then "#9c36b5"
        when 6 then "#12b886"
        when 7 then "#343a40"
        when 8 then "#212529"
        else "#1f2328"
        end
      end

      setup_board = lambda do
        squares.each do |sq|
          sq[:mine] = false
          sq[:revealed] = false
          sq[:flagged] = false
          sq[:exploded] = false
          sq[:adjacent] = 0
        end

        mines = (0...(rows * cols)).to_a.sample(mine_count)
        mines.each { |idx| squares[idx][:mine] = true }

        squares.each do |sq|
          next if sq[:mine]

          count = 0
          (-1..1).each do |dr|
            (-1..1).each do |dc|
              next if dr.zero? && dc.zero?

              nr = sq[:row] + dr
              nc = sq[:col] + dc
              next unless nr.between?(0, rows - 1) && nc.between?(0, cols - 1)

              nidx = nr * cols + nc
              count += 1 if squares[nidx][:mine]
            end
          end
          sq[:adjacent] = count
        end

        mines_left = mine_count
        game_over = false
        won = false
        first_click_done = false
      end
      setup_board.call

      mines_text = text(value: format("%03d", mines_left), style: { size: 16, weight: "w600" })
      face_text = text(value: "🙂", style: { size: 18 })
      timer_text = text(value: "000", style: { size: 16, weight: "w600" })

      cell_texts = []
      cell_containers = []
      squares.each_with_index do |sq, idx|
        label_text = text(value: sq[:flagged] ? "🚩" : "", style: { size: 14, weight: "w600" })
        cell_texts[idx] = label_text

        cell_containers[idx] = container(
          width: size,
          height: size,
          left: sq[:col] * size,
          top: sq[:row] * size,
          bgcolor: "#c0c0c0",
          border: {
            top: { width: 2, color: "#ffffff" },
            left: { width: 2, color: "#ffffff" },
            bottom: { width: 2, color: "#7b7b7b" },
            right: { width: 2, color: "#7b7b7b" }
          },
          alignment: "center",
          content: label_text
        )
      end

      board = stack(width: board_width, height: board_height, children: cell_containers)

      safe_update = lambda do |control, props|
        return unless control

        if props.key?(:controls) || props.key?("controls")
          list = props[:controls] || props["controls"]
          control.children.replace(list)
          page.update if control.wire_id
          return
        end

        if control.wire_id
          page.update(control, **props)
        else
          props.each { |k, v| control.props[k.to_s] = v }
        end
      end

      rebuild = lambda do
        squares.each_with_index do |sq, idx|
          label =
            if !sq[:revealed] && sq[:flagged]
              "🚩"
            elsif !sq[:revealed]
              ""
            elsif sq[:exploded]
              "💥"
            elsif sq[:mine]
              "💣"
            elsif sq[:adjacent].positive?
              sq[:adjacent].to_s
            else
              ""
            end

          container = cell_containers[idx]
          text = cell_texts[idx]
          safe_update.call(container, {
            bgcolor: if sq[:exploded]
              "#8b0000"
            elsif sq[:revealed]
              "#d0d0d0"
            else
              "#c0c0c0"
            end,
            border: if sq[:revealed]
              { width: 1, color: "#8d8d8d" }
            else
              {
                top: { width: 2, color: "#ffffff" },
                left: { width: 2, color: "#ffffff" },
                bottom: { width: 2, color: "#7b7b7b" },
                right: { width: 2, color: "#7b7b7b" }
              }
            end
          })
          safe_update.call(text, {
            value: label,
            color: if sq[:exploded]
              "#ffffff"
            elsif sq[:mine]
              "#212529"
            else
              number_color.call(sq[:adjacent])
            end,
            weight: "w600"
          })
        end

        safe_update.call(mines_text, { value: format("%03d", mines_left) })
        safe_update.call(face_text, { value: won ? "😎" : game_over ? "😵" : "🙂" })
      end

      reveal = lambda do |row, col|
        stack = [[row, col]]
        while (cell = stack.pop)
          r, c = cell
          idx = r * cols + c
          sq = squares[idx]
          next if sq[:revealed] || sq[:flagged]

          sq[:revealed] = true
          next if sq[:adjacent].positive?

          (-1..1).each do |dr|
            (-1..1).each do |dc|
              next if dr.zero? && dc.zero?

              nr = r + dr
              nc = c + dc
              next unless nr.between?(0, rows - 1) && nc.between?(0, cols - 1)

              stack << [nr, nc]
            end
          end
        end
      end

      check_win = lambda do
        return if game_over
        return unless squares.all? { |s| s[:revealed] || s[:mine] }

        game_over = true
        won = true
        mines_left = 0
        squares.each { |sq| sq[:flagged] = true if sq[:mine] }
        stop_timer.call if stop_timer
        safe_update.call(status, { value: "You win!" })
        rebuild.call
      end

      timer_state = page.instance_variable_get(:@minesweeper_timer_state)
      unless timer_state
        timer_state = {
          running: false,
          value: 0,
          thread: nil,
          token: 0,
          start_time: nil
        }
        page.instance_variable_set(:@minesweeper_timer_state, timer_state)
      end
      timer_state[:token] += 1
      timer_token = timer_state[:token]
      timer_state[:running] = false
      timer_state[:thread]&.kill
      timer_state[:thread] = nil
      timer_state[:value] = 0
      timer_state[:start_time] = nil
      safe_update.call(timer_text, { value: format("%03d", timer_state[:value]) })

      start_timer = lambda do
        return if timer_state[:running]

        timer_state[:running] = true
        timer_state[:start_time] = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        timer_state[:thread] = Thread.new do
          last_shown = -1
          loop do
            sleep 0.2
            break unless timer_state[:running]
            break unless timer_state[:token] == timer_token

            elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - timer_state[:start_time]
            seconds = elapsed.floor
            next if seconds == last_shown

            last_shown = seconds
            timer_state[:value] = seconds
            safe_update.call(timer_text, { value: format("%03d", seconds) })
          end
        end
      end

      stop_timer = lambda do
        timer_state[:running] = false
        timer_state[:thread]&.kill
        timer_state[:thread] = nil
      end

      reset_timer = lambda do
        stop_timer.call
        timer_state[:value] = 0
        timer_state[:start_time] = nil
        safe_update.call(timer_text, { value: "000" })
      end

      start_game = lambda do
        unless first_click_done
          first_click_done = true
          start_timer.call
        end
      end

      cell_from_event = lambda do |event|
        pos = extract_pos(event) || last_tap_pos
        return nil unless pos

        r = (pos[:y] / size).floor
        c = (pos[:x] / size).floor
        return nil unless r.between?(0, rows - 1) && c.between?(0, cols - 1)

        [r, c]
      end

      reset_game = lambda do
        setup_board.call
        reset_timer.call
        safe_update.call(status, { value: "New game" })
        rebuild.call
      end

      on_tap = lambda do |e|
        return if game_over

        cell = cell_from_event.call(e)
        return unless cell

        start_game.call
        r, c = cell
        sq = squares[r * cols + c]
        return if sq[:flagged] || sq[:revealed]

        if sq[:mine]
          sq[:exploded] = true
          squares.each { |s| s[:revealed] = true if s[:mine] }
          game_over = true
          won = false
          safe_update.call(status, { value: "Game over" })
          stop_timer.call
        else
          reveal.call(r, c)
          check_win.call
        end
        rebuild.call
      end

      on_flag = lambda do |e|
        return if game_over

        cell = cell_from_event.call(e)
        return unless cell

        start_game.call
        r, c = cell
        sq = squares[r * cols + c]
        return if sq[:revealed]

        sq[:flagged] = !sq[:flagged]
        mines_left += sq[:flagged] ? -1 : 1
        rebuild.call
      end

      board_gesture = gesture_detector(
        on_tap_down: ->(e) {
          last_tap_pos = extract_pos(e)
        },
        on_tap: ->(e) {
          on_tap.call(e)
        },
        on_right_pan_start: ->(e) {
          on_flag.call(e)
        },
        on_long_press_start: ->(e) {
          on_flag.call(e)
        },
        drag_interval: 5,
        width: board_width,
        height: board_height,
        content: board
      )

      rebuild.call

      bevel = lambda do |content, padding: 6|
        container(
          padding: padding,
          bgcolor: "#bcbcbc",
          border: {
            top: { width: 2, color: "#ffffff" },
            left: { width: 2, color: "#ffffff" },
            bottom: { width: 2, color: "#8d8d8d" },
            right: { width: 2, color: "#8d8d8d" }
          },
          content: content
        )
      end

      counter_box = lambda do |content|
        container(
          width: 70,
          height: 36,
          alignment: "center",
          bgcolor: "#d0d0d0",
          border: {
            top: { width: 2, color: "#8d8d8d" },
            left: { width: 2, color: "#8d8d8d" },
            bottom: { width: 2, color: "#ffffff" },
            right: { width: 2, color: "#ffffff" }
          },
          content: content
        )
      end

      column(
        spacing: 8,
        horizontal_alignment: "center",
        tight: true,
        children: [
          container(
            padding: 8,
            width: board_width + 16,
            bgcolor: "#c0c0c0",
            border: {
              top: { width: 2, color: "#ffffff" },
              left: { width: 2, color: "#ffffff" },
              bottom: { width: 2, color: "#8d8d8d" },
              right: { width: 2, color: "#8d8d8d" }
            },
          content: row(
              alignment: "spaceBetween",
              children: [
                counter_box.call(mines_text),
                bevel.call(container(width: 36, height: 36, alignment: "center", bgcolor: "#d0d0d0", content: face_text, on_click: ->(_e) { reset_game.call })),
                counter_box.call(timer_text)
              ]
            )
          ),
          container(
            padding: 8,
            width: board_width + 16,
            height: board_height + 16,
            bgcolor: "#c0c0c0",
            border: {
              top: { width: 2, color: "#ffffff" },
              left: { width: 2, color: "#ffffff" },
              bottom: { width: 2, color: "#8d8d8d" },
              right: { width: 2, color: "#8d8d8d" }
            },
            content: board_gesture
          ),
          status
        ]
      )
    end

    def build_minesweeper_grid(page)
      size = 26
      controls = []
      9.times do |r|
        9.times do |c|
          controls << container(
            width: size,
            height: size,
            left: c * size,
            top: r * size,
            bgcolor: r.even? == c.even? ? "#e9ecef" : "#dee2e6",
            border: { width: 1, color: "#ced4da" }
          )
        end
      end
      controls
    end
  end
end
