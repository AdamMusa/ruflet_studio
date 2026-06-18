# frozen_string_literal: true

require "ruflet"
require "cgi"

STANDALONE_ROOT = File.expand_path("standalone_apps", __dir__)
require_relative "gallery_sections"

GENERIC_GEMFILE = <<~'GEMFILE'
  source "https://rubygems.org"

  gem "ruflet"
GEMFILE

BG = "#020617"
BAR = "#0f172a"
SURFACE = "#111827"
SURFACE_2 = "#1e293b"
EDITOR_BG = "#0b1120"
PREVIEW_BG = "#f5f6fb"
TEXT = "#f1f5f9"
MUTED = "#cbd5e1"
BORDER = "#1e293b"
BLUE = "#38bdf8"
PINK = "#cc342d"
RAIL_BLUE = "#082f49"
ORANGE = "#f7a12d"

CATEGORIES = [
  ["Getting Started", "Build your first Ruflet app", Ruflet::MaterialIcons[:rocket_launch], "getting-started"],
  ["Layout", "Layout primitives and containers", Ruflet::MaterialIcons::VIEW_MODULE, "layout"],
  ["Buttons", "Buttons and action controls", Ruflet::MaterialIcons[:smart_button], "buttons"],
  ["Input", "Text fields and selection controls", Ruflet::MaterialIcons[:input], "input"],
  ["Displays", "Text, images, and information controls", Ruflet::MaterialIcons::IMAGE, "displays"],
  ["Dialogs", "Alerts and modal surfaces", Ruflet::MaterialIcons[:chat_bubble_outline], "dialogs"],
  ["Navigation", "Routes, tabs, and app structure", Ruflet::MaterialIcons[:navigation], "navigation"],
  ["Charts", "Data visualization examples", Ruflet::MaterialIcons::SHOW_CHART, "charts"],
  ["Declarative", "Declarative routing and app shells", Ruflet::MaterialIcons::CODE, "declarative"],
  ["Games", "Interactive game examples", Ruflet::MaterialIcons[:sports_esports], "games"],
  ["Animations", "Motion and state transitions", Ruflet::MaterialIcons[:animation], "animations"],
  ["Effects", "Visual effects and polish", Ruflet::MaterialIcons[:auto_awesome], "effects"],
  ["Media", "Media and platform integrations", Ruflet::MaterialIcons[:movie], "media"]
].freeze

EXAMPLES = [
  {
    slug: "calculator",
    title: "Calculator",
    description: "Builds an iOS-style calculator app with custom button controls and arithmetic state.",
    category: "getting-started",
    files: ["main.rb", "Gemfile"],
    code: <<~'RUBY'
      require "ruflet"

      def format_calc_number(value)
        return "0" if value.nan? || value.infinite?

        value.round(8).to_s.sub(/\\.0\\z/, "")
      end

      def calc_button(value, apply)
        action = %w[/ * - + =].include?(value)
        digit = value.match?(/\\A\\d|\\.\\z/)

        button(
          expand: value == "0",
          width: value == "0" ? nil : 78,
          height: 42,
          bgcolor: action ? "#f7a12d" : (digit ? "#3f3f3f" : "#dce3e5"),
          color: action || digit ? "#ffffff" : "#111111",
          on_click: ->(_e) { apply.call(value) },
          content: text(
            value,
            style: {
              size: 17,
              weight: "w700",
              color: action || digit ? "#ffffff" : "#111111"
            }
          )
        )
      end

      Ruflet.run do |page|
        page.title = "Calculator"
        display = text("0", style: { size: 32, color: "#ffffff" })
        state = { current: "0", left: nil, operator: nil, reset: false }

        apply = lambda do |value|
          case value
          when "AC"
            state[:current] = "0"
            state[:left] = nil
            state[:operator] = nil
            state[:reset] = false
          when "+/-"
            state[:current] = state[:current].start_with?("-") ? state[:current][1..] : "-#{state[:current]}"
          when "%"
            state[:current] = format_calc_number(state[:current].to_f / 100.0)
          when "/", "*", "-", "+"
            state[:left] = state[:current].to_f
            state[:operator] = value
            state[:reset] = true
          when "="
            if state[:left] && state[:operator]
              right = state[:current].to_f
              result =
                case state[:operator]
                when "/" then right.zero? ? 0 : state[:left] / right
                when "*" then state[:left] * right
                when "-" then state[:left] - right
                else state[:left] + right
                end
              state[:current] = format_calc_number(result)
              state[:left] = nil
              state[:operator] = nil
              state[:reset] = true
            end
          when "."
            state[:current] = "0" if state[:reset]
            state[:reset] = false
            state[:current] += "." unless state[:current].include?(".")
          else
            state[:current] = state[:reset] || state[:current] == "0" ? value : "#{state[:current]}#{value}"
            state[:reset] = false
          end

          page.update(display, value: state[:current])
        end

        page.add(
          container(
            width: 400,
            padding: 18,
            border_radius: 20,
            bgcolor: "#000000",
            content: column(spacing: 14, children: [
              row(alignment: "end", children: [display]),
              row(spacing: 10, children: %w[AC +/- % /].map { |v| calc_button(v, apply) }),
              row(spacing: 10, children: %w[7 8 9 *].map { |v| calc_button(v, apply) }),
              row(spacing: 10, children: %w[4 5 6 -].map { |v| calc_button(v, apply) }),
              row(spacing: 10, children: %w[1 2 3 +].map { |v| calc_button(v, apply) }),
              row(spacing: 10, children: %w[0 . =].map { |v| calc_button(v, apply) })
            ])
          )
        )
      end
    RUBY
  },
  {
    slug: "todo",
    title: "Classic To-Do",
    description: "Classic to-do app with add, edit, delete, and filter interactions inspired by TodoMVC.",
    category: "getting-started",
    files: ["main.rb", "Gemfile", "models/task.rb"],
    code: <<~'RUBY'
      require "ruflet"

      Ruflet.run do |page|
        input = text_field(label: "What needs to be done?", expand: true)
        tasks = column(spacing: 8, children: [
          checkbox(label: "Release new Ruflet", value: true),
          checkbox(label: "Update docs", value: true),
          checkbox(label: "Write a blog post", value: false)
        ])

        page.add(column(spacing: 12, children: [
          row(children: [input, filled_button(content: text("+"))]),
          tasks
        ]))
      end
    RUBY
  },
  {
    slug: "animation",
    title: "Flet animation",
    description: "Animates scattered blocks into the FLET logo with randomized colors, sizes, and timing.",
    category: "animations",
    files: ["main.rb", "Gemfile", "animation.rb"],
    code: <<~'RUBY'
      require "ruflet"

      def block(color)
        container(width: 18, height: 18, border_radius: 3, bgcolor: color)
      end

      def block_row(color, count)
        row(spacing: 6, children: Array.new(count) { block(color) })
      end

      def letter_blocks(color, rows)
        column(spacing: 6, children: rows.map { |count| block_row(color, count) })
      end

      Ruflet.run do |page|
        page.add(
          row(spacing: 18, children: [
            letter_blocks("#df3266", [3, 2, 3]),
            letter_blocks("#ffc13d", [1, 1, 4]),
            letter_blocks("#88c557", [4, 2, 4]),
            letter_blocks("#5d3dbb", [4, 1, 1])
          ])
        )
      end
    RUBY
  },
  {
    slug: "icons-browser",
    title: "Icons browser",
    description: "Searches Material and Cupertino icon sets and copies selected icon names.",
    category: "displays",
    files: ["main.rb", "Gemfile", "icons.rb"],
    code: <<~'RUBY'
      require "ruflet"

      Ruflet.run do |page|
        page.add(column(spacing: 12, children: [
          text_field(label: "Search icons", value: "add"),
          grid_view(runs_count: 5, max_extent: 90, children: [
            icon(icon: Ruflet::MaterialIcons::ADD),
            icon(icon: Ruflet::MaterialIcons::PHOTO_CAMERA),
            icon(icon: Ruflet::MaterialIcons::ALARM)
          ])
        ]))
      end
    RUBY
  },
  {
    slug: "router",
    title: "Router featured app (declarative)",
    description: "Full-featured Router app combining layout, nav, nested routes, params, and loading.",
    category: "declarative",
    files: ["main.rb", "Gemfile", "routes.rb"],
    code: <<~'RUBY'
      require "ruflet"

      Ruflet.run do |page|
        page.title = "Router Demo"
        page.add(column(children: [
          text("Welcome to the Router Demo!", style: { size: 18, weight: "w700" }),
          filled_button(content: text("Browse projects"))
        ]))
      end
    RUBY
  },
  {
    slug: "routing-two-pages",
    title: "Routing two pages",
    description: "Demonstrates declarative view routing with theme context shared across two pages.",
    category: "navigation",
    files: ["main.rb", "Gemfile", "routes.rb"],
    code: <<~'RUBY'
      require "ruflet"

      Ruflet.run do |page|
        page.add(column(children: [
          row(children: [text("Flet app"), switch(value: false, label: "Dark mode")]),
          filled_button(content: text("Visit Store")),
          filled_button(content: text("Do something"))
        ]))
      end
    RUBY
  }
].freeze

CONTROL_EXAMPLES = {
  "layout" => %w[Card Column Container DataTable Divider GridView Row Stack],
  "buttons" => ["Button", "FilledButton", "OutlinedButton", "IconButton", "FloatingActionButton"],
  "input" => ["TextField", "Checkbox", "Switch", "RadioGroup", "Dropdown"],
  "displays" => ["Text", "Image", "Icon", "ProgressRing", "ListTile"],
  "dialogs" => ["AlertDialog", "BottomSheet", "SnackBar"],
  "navigation" => ["AppBar", "NavigationRail", "Tabs", "Routes"],
  "charts" => ["LineChart", "BarChart", "PieChart"],
  "declarative" => ["View", "Route", "Page", "Component"],
  "games" => ["TicTacToe", "Memory", "CounterGame"],
  "animations" => ["AnimatedContainer", "Fade", "Scale", "Slide"],
  "effects" => ["Shadow", "Gradient", "Blur", "Opacity"],
  "media" => ["Audio", "Video", "Camera", "FilePicker"],
  "getting-started" => []
}.freeze

def slugify(value)
  value.to_s.gsub(/([a-z])([A-Z])/, '\1-\2').downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-+\z/, "")
end

def path(page) = page.route.to_s.split("?").first
def mobile?(page) = page.width.to_f.positive? && page.width.to_f < 700
def examples_for(category_slug)
  EXAMPLES.select { |item| item[:category] == category_slug } +
    Array(CONTROL_EXAMPLES[category_slug]).map { |name| generated_example(category_slug, name) }
end

def example(slug)
  EXAMPLES.find { |item| item[:slug] == slug } ||
    CONTROL_EXAMPLES.flat_map { |category, names| names.map { |name| generated_example(category, name) } }.find { |item| item[:slug] == slug } ||
    EXAMPLES.first
end

def generated_example(category, name)
  slug = "#{category}-#{slugify(name)}"
  {
    slug: slug,
    title: name,
    description: "Demonstrates the Ruflet #{name} control with a focused live preview.",
    category: category,
    files: ["main.rb", "Gemfile"],
    code: generated_code(name)
  }
end

def generated_code(name)
  <<~RUBY
    require "ruflet"

    Ruflet.run do |page|
      page.title = "#{name}"
      page.add(
        container(
          padding: 24,
          content: #{generated_code_body(name)}
        )
      )
    end
  RUBY
end

def generated_code_body(name)
  case name
  when "Card"
    'container(width: 320, padding: 18, border_radius: 8, bgcolor: "#ffffff", content: column(spacing: 10, children: [text("Card title", style: { size: 22, weight: "w700" }), text("Cards group related content and actions.")]))'
  when "Column"
    'column(spacing: 12, children: [text("First item"), text("Second item"), text("Third item")])'
  when "Container"
    'container(width: 260, height: 140, border_radius: 12, bgcolor: "#dbeafe", alignment: "center", content: text("Container"))'
  when "DataTable"
    'column(spacing: 8, children: [row(spacing: 60, children: [text("Name", style: { weight: "w700" }), text("Role", style: { weight: "w700" })]), row(spacing: 60, children: [text("Ada"), text("Engineer")]), row(spacing: 60, children: [text("Lin"), text("Designer")])])'
  when "Divider"
    'column(spacing: 12, children: [text("Above"), container(height: 1, bgcolor: "#9ca3af"), text("Below")])'
  when "GridView"
    'grid_view(max_extent: 90, spacing: 10, run_spacing: 10, children: Array.new(8) { |i| container(height: 64, border_radius: 8, bgcolor: i.even? ? "#bfdbfe" : "#fecdd3", alignment: "center", content: text((i + 1).to_s)) })'
  else
    'column(spacing: 14, children: [text("Live Ruflet preview", style: { size: 22, weight: "w700" }), filled_button(content: text("Action")), text("This example renders its own control surface.")])'
  end
end

class ShowcaseStudioPreview
  include Showcase::Helpers
  include Showcase::Views
  include Showcase::SectionsControls
  include Showcase::SectionsMedia
  include Showcase::SectionsMisc
end

SHOWCASE_PREVIEW = ShowcaseStudioPreview.new

SHOWCASE_ROUTES = [
  ["counter", "Counter", "getting-started", :build_counter],
  ["todo", "To-do", "getting-started", :build_todo],
  ["calculator", "Calculator", "getting-started", :build_calculator],
  ["code-editor", "Code Editor", "getting-started", :build_code_editor],
  ["responsive-row", "Responsive Row", "layout", :build_responsive_row],
  ["components", "Components", "layout", :build_components],
  ["drawing", "Drawing Tool", "effects", :build_drawing],
  ["material", "Material controls", "buttons", :build_material_controls],
  ["cupertino", "Cupertino controls", "buttons", :build_cupertino_controls],
  ["charts", "Charts", "charts", :build_charts],
  ["minesweeper", "Minesweeper", "games", :build_minesweeper],
  ["icon-search", "Icon Search", "displays", :build_icon_search],
  ["animation", "Ruflet Animation", "animations", :build_animation],
  ["rive", "Rive", "animations", :build_rive],
  ["accelerometer", "Accelerometer", "media", :build_accelerometer],
  ["gyroscope", "Gyroscope", "media", :build_gyroscope],
  ["user-accelerometer", "User Accelerometer", "media", :build_user_accelerometer],
  ["magnetometer", "Magnetometer", "media", :build_magnetometer],
  ["barometer", "Barometer", "media", :build_barometer],
  ["browser-context-menu", "Browser Context Menu", "media", :build_browser_context_menu],
  ["shake-detector", "Shake Detector", "media", :build_shake_detector],
  ["semantics-service", "Semantics Service", "media", :build_semantics_service],
  ["screenshot", "Screenshot", "media", :build_screenshot],
  ["audio", "Audio Player", "media", :build_audio],
  ["audio-recorder", "Audio Recorder", "media", :build_audio_recorder],
  ["video", "Video Player", "media", :build_video],
  ["battery", "Battery", "media", :build_battery],
  ["screen-brightness", "Screen Brightness", "media", :build_screen_brightness],
  ["clipboard", "Clipboard", "media", :build_clipboard],
  ["storage-paths", "Storage Paths", "media", :build_storage_paths],
  ["share", "Share", "media", :build_share],
  ["webview", "WebView", "media", :build_webview],
  ["flashlight", "Flashlight", "media", :build_flashlight],
  ["connectivity", "Connectivity", "media", :build_connectivity],
  ["geolocator", "Geolocator", "media", :build_geolocator],
  ["map", "Map", "media", :build_map],
  ["permission-handler", "Permission Handler", "media", :build_permission_handler],
  ["secure-storage", "Secure Storage", "media", :build_secure_storage],
  ["camera", "Camera", "media", :build_camera],
  ["file-picker", "File Picker", "media", :build_file_picker],
  ["window", "Window", "media", :build_window]
].freeze

COMPONENT_CATEGORIES = {
  "hello-world" => "getting-started",
  "text" => "displays",
  "button" => "buttons",
  "container" => "layout",
  "row" => "layout",
  "column" => "layout",
  "text-field" => "input",
  "icon" => "displays",
  "image" => "displays",
  "dialog" => "dialogs",
  "date-picker" => "input",
  "date-range-picker" => "input",
  "time-picker" => "input",
  "data-table" => "layout",
  "dropdown" => "input",
  "checkbox" => "input",
  "radio" => "input",
  "tabs" => "navigation",
  "progress-bar" => "displays",
  "progress-ring" => "displays",
  "grid-view" => "layout",
  "interactive-viewer" => "effects",
  "list-tile" => "layout",
  "switch" => "input",
  "slider" => "input"
}.freeze

def read_standalone_file(slug, file)
  absolute = File.join(STANDALONE_ROOT, slug, file)
  File.file?(absolute) ? File.read(absolute) : "# File not found: standalone_apps/#{slug}/#{file}\n"
end

# Editor sources come from the self-contained standalone_apps/<slug> bundle;
# each is a runnable, dependency-free Ruflet app.
def editor_files_for(slug)
  {
    "main.rb" => read_standalone_file(slug, "main.rb"),
    "Gemfile" => read_standalone_file(slug, "Gemfile")
  }
end

def showcase_example(slug, title, category, builder, component_slug: nil)
  {
    slug: slug,
    title: title,
    description: "Ruflet sample from standalone_apps/#{slug}/main.rb.",
    category: category,
    files: editor_files_for(slug),
    source_path: "standalone_apps/#{slug}/main.rb",
    builder: builder,
    component_slug: component_slug,
    showcase: true
  }
end

def showcase_route_examples
  SHOWCASE_ROUTES.map do |slug, title, category, builder|
    showcase_example(slug, title, category, builder)
  end
end

def showcase_component_examples
  Showcase::SectionsControls::SUPPORTED_COMPONENTS.map do |component|
    component_slug = component.fetch(:slug)
    showcase_example(
      "component-#{component_slug}",
      component.fetch(:label),
      COMPONENT_CATEGORIES.fetch(component_slug, "layout"),
      :build_component_detail,
      component_slug: component_slug
    )
  end
end

def showcase_examples
  @showcase_examples ||= (showcase_route_examples + showcase_component_examples).freeze
end

def showcase_gallery_examples
  showcase_route_examples
end

def selected_file(page, item)
  requested = page.query["file"].to_s
  files = item_files(item)
  return files.keys.first if requested.empty?

  decoded = CGI.unescape(requested)
  files.key?(decoded) ? decoded : files.keys.first
end

def file_route(page, file)
  base = path(page)
  query = "file=#{CGI.escape(file)}"
  origin = page.query["from"].to_s
  query += "&from=#{CGI.escape(origin)}" unless origin.empty?
  "#{base}?#{query}"
end

def item_files(item)
  return item[:files] if item[:files].is_a?(Hash)

  Array(item[:files]).to_h do |file|
    content =
      if file == "Gemfile"
        GENERIC_GEMFILE
      elsif file == "main.rb"
        item[:code].to_s
      else
        "# #{file}\n"
      end
    [file, content]
  end
end

def selected_code(page, item)
  item_files(item).fetch(selected_file(page, item))
end

def examples_for(category_slug)
  showcase_examples.select { |item| item[:category] == category_slug }
end

def example(slug)
  showcase_examples.find { |item| item[:slug] == slug } ||
    EXAMPLES.find { |item| item[:slug] == slug } ||
    EXAMPLES.first
end

def studio_go(page, route)
  page.route = route
  render(page)
end

def render(page)
  route = path(page)
  route = "/apps" if route.empty? || route == "/"
  page.title = "ruflet_studio"
  page.theme_mode = "dark"
  page.bgcolor = BG

  page.views = [
    case route
    when "/apps"
      apps_view(page)
    when "/signin"
      sign_in_view(page)
    when "/gallery"
      gallery_view(page)
    when %r{\A/gallery/([^/]+)/example/([^/]+)}
      category = Regexp.last_match(1)
      example_slug = Regexp.last_match(2)
      origin = page.query["from"].to_s # captured before page.query clobbers last_match
      back = origin.empty? ? "/gallery/#{category}" : origin
      editor_view(page, example(example_slug), back_route: back)
    when %r{\A/gallery/([^/]+)}
      category_view(page, Regexp.last_match(1))
    when %r{\A/settings/([^/]+)}
      settings_view(page, Regexp.last_match(1))
    else
      apps_view(page)
    end
  ]
  page.update
end

def logo_mark
  image(src: "assets/icon.png", width: 28, height: 28)
end

def top_bar(page, title, back: nil, actions: [])
  title_control =
    if back
      text(title, style: { size: 20, weight: "w700", color: TEXT })
    else
      row(spacing: 10, vertical_alignment: "center", children: [
        logo_mark,
        text(title, style: { size: 20, weight: "w700", color: TEXT })
      ])
    end

  app_bar(
    bgcolor: BAR,
    color: TEXT,
    leading: back ? icon_button(icon: Ruflet::MaterialIcons::ARROW_BACK, on_click: ->(_e) { studio_go(page, back) }) : nil,
    title: title_control,
    actions: actions + [icon_button(icon: Ruflet::MaterialIcons[:account_circle], on_click: ->(_e) { studio_go(page, "/settings/system") })]
  )
end

def desktop_shell(page, title, active, body)
  control(:view, route: path(page), bgcolor: BG, padding: 0, appbar: top_bar(page, title),
    children: [
      row(expand: true, spacing: 0, children: [
        nav_rail(page, active),
        container(width: 1, bgcolor: BORDER),
        container(expand: true, content: body)
      ])
    ])
end

def mobile_shell(page, title, active, body)
  control(:view, route: path(page), bgcolor: BG, padding: 0, appbar: top_bar(page, title),
    children: [
      column(expand: true, spacing: 0, children: [
        container(expand: true, content: body),
        bottom_nav(page, active)
      ])
    ])
end

def shell(page, title, active, body)
  mobile?(page) ? mobile_shell(page, title, active, body) : desktop_shell(page, title, active, body)
end

def nav_rail(page, active)
  container(width: 72, bgcolor: BG, content: column(spacing: 10, children: [
    container(height: 62, padding: { top: 10, left: 10, right: 10, bottom: 4 },
      content: container(width: 48, height: 48, border_radius: 14, bgcolor: RAIL_BLUE, alignment: "center",
        on_click: ->(_e) { studio_go(page, "/signin") }, content: icon(icon: Ruflet::MaterialIcons::ADD, color: "#7dd3fc", size: 24))),
    rail_item(page, "Apps", Ruflet::MaterialIcons::GRID_VIEW, "/apps", active == "apps"),
    rail_item(page, "Gallery", Ruflet::MaterialIcons::IMAGE, "/gallery", active == "gallery")
  ]))
end

def rail_item(page, label, icon_value, route, selected)
  container(padding: { left: 6, right: 6 }, content: column(horizontal_alignment: "center", spacing: 3, children: [
    container(width: 46, height: 36, border_radius: 18, bgcolor: selected ? PINK : BG, alignment: "center",
      on_click: ->(_e) { studio_go(page, route) }, content: icon(icon: icon_value, color: selected ? "#ffffff" : TEXT, size: 22)),
    text(label, style: { color: TEXT, size: 12, weight: "w600" })
  ]))
end

def bottom_nav(page, active)
  container(height: 80, bgcolor: BAR, content: row(spacing: 0, children: [
    bottom_tab(page, "Apps", Ruflet::MaterialIcons::GRID_VIEW, "/apps", active == "apps"),
    bottom_tab(page, "Gallery", Ruflet::MaterialIcons::IMAGE, "/gallery", active == "gallery")
  ]))
end

def bottom_tab(page, label, icon_value, route, selected)
  container(expand: true, alignment: "center", on_click: ->(_e) { studio_go(page, route) },
    content: column(horizontal_alignment: "center", spacing: 2, children: [
      container(width: 64, height: 34, border_radius: 20, bgcolor: selected ? PINK : BAR, alignment: "center",
        content: icon(icon: icon_value, color: TEXT, size: 22)),
      text(label, style: { color: TEXT, size: 12 })
    ]))
end

def apps_view(page)
  body = container(expand: true, alignment: "center", content: column(tight: true, horizontal_alignment: "center", spacing: 22, children: [
    column(tight: true, horizontal_alignment: "center", spacing: 2, children: [
      text("Sign in to create apps and access your work, or browse", style: { color: TEXT, size: 16, weight: "w600" }),
      row(tight: true, spacing: 4, alignment: "center", children: [
        container(on_click: ->(_e) { studio_go(page, "/gallery") }, content: text("Gallery", style: { color: BLUE, size: 16, weight: "w600" })),
        text("for examples.", style: { color: TEXT, size: 16, weight: "w600" })
      ])
    ]),
    filled_button(
      on_click: ->(_e) { studio_go(page, "/signin") },
      content: row(tight: true, spacing: 8, alignment: "center", children: [
        icon(icon: Ruflet::MaterialIcons[:login]),
        text("Sign in")
      ])
    )
  ]))

  shell(page, "Apps", "apps", body)
end

def sign_in_view(page)
  base = container(expand: true, alignment: "center", content: column(tight: true, horizontal_alignment: "center", spacing: 18, children: [
    column(tight: true, horizontal_alignment: "center", spacing: 2, children: [
      text("Sign in to create apps and access your work, or browse", style: { color: TEXT, size: 16 }),
      row(tight: true, spacing: 4, children: [
        text("Gallery", style: { color: BLUE, size: 16 }),
        text("for examples.", style: { color: TEXT, size: 16 })
      ])
    ]),
    filled_button(content: row(spacing: 8, children: [icon(icon: Ruflet::MaterialIcons[:login]), text("Sign in")]))
  ]))

  modal = container(expand: true, alignment: "center", bgcolor: "#00000099", content: container(width: 550, padding: 36, border_radius: 20, bgcolor: "#2a2d33",
    content: column(spacing: 18, children: [
      text("Sign in to Ruflet Studio", style: { color: TEXT, size: 30, weight: "w700" }),
      text("Sign in to create apps, save versions, and access your work from anywhere.", style: { color: TEXT, size: 17 }),
      text("By signing in to Ruflet Studio, you agree to our Terms of Service and Privacy Policy.", style: { color: MUTED, size: 14 }),
      sign_button("Sign in with GitHub", Ruflet::MaterialIcons[:code]),
      sign_button("Sign in with Google", Ruflet::MaterialIcons[:g_mobiledata]),
      sign_button("Sign in with Microsoft", Ruflet::MaterialIcons::GRID_VIEW)
    ])))

  body = stack(expand: true, children: [base, modal])
  shell(page, "Apps", "apps", body)
end

def sign_button(label, icon_value)
  outlined_button(content: row(alignment: "center", spacing: 10, children: [
    icon(icon: icon_value, color: TEXT),
    text(label, style: { color: TEXT, size: 16, weight: "w600" })
  ]))
end

def gallery_view(page)
  categories = column(expand: true, scroll: "auto", spacing: 0, children: [
    container(padding: { left: 12, right: 12, top: 12, bottom: 10 },
      content: text_field(label: "Search...", prefix_icon: Ruflet::MaterialIcons::SEARCH, expand: true, height: 46)),
    *CATEGORIES.map { |label, desc, icon_value, slug| category_tile(page, label, icon_value, slug) }
  ])

  body =
    if mobile?(page)
      categories
    else
      row(expand: true, spacing: 0, children: [
        container(width: 220, content: categories),
        container(width: 1, bgcolor: BORDER),
        container(expand: true, padding: 24, content: grid_view(
          expand: true,
          max_extent: 420,
          child_aspect_ratio: 1.04,
          spacing: 24,
          run_spacing: 24,
          children: showcase_gallery_examples.map { |item| gallery_card(page, item) }
        ))
      ])
    end
  shell(page, "Gallery", "gallery", body)
end

def category_tile(page, label, icon_value, slug)
  container(height: 52, content: list_tile(
    content_padding: { left: 12, right: 8, top: 0, bottom: 0 },
    leading: icon(icon: icon_value, color: TEXT, size: 20),
    title: text(label, style: { color: TEXT, size: 15, weight: "w700" }),
    trailing: icon(icon: Ruflet::MaterialIcons::CHEVRON_RIGHT, color: TEXT, size: 20),
    on_click: ->(_e) { studio_go(page, "/gallery/#{slug}") }))
end

def gallery_card(page, item)
  container(bgcolor: SURFACE, border_radius: 12, padding: 14, on_click: ->(_e) { studio_go(page, "/gallery/#{item[:category]}/example/#{item[:slug]}?from=#{CGI.escape('/gallery')}") },
    content: column(spacing: 12, children: [
      container(height: 156, border_radius: 8, bgcolor: PREVIEW_BG, padding: 12, content: thumbnail_for(page, item[:slug])),
      text(item[:title], style: { color: TEXT, size: 22, weight: "w700" }),
      text(item[:description], style: { color: MUTED, size: 16, max_lines: 2 })
    ]))
end

def category_view(page, slug)
  category = CATEGORIES.find { |item| item[3] == slug } || CATEGORIES.first
  rows = examples_for(slug)
  children = [
    container(padding: { top: 22, left: 20, right: 20, bottom: 8 }, content: column(spacing: 14, children: [
      text(category[0], style: { color: TEXT, size: 16, weight: "w700" }),
      text(category[1], style: { color: MUTED, size: 14 })
    ])),
    *rows.map { |item| example_row(page, item, slug) }
  ]
  control(:view, route: path(page), bgcolor: BG, padding: 0, appbar: top_bar(page, category[0], back: "/gallery"),
    children: [column(expand: true, scroll: "auto", spacing: 0, children: children)])
end

def example_row(page, item, slug)
  list_tile(
    leading: icon(icon: Ruflet::MaterialIcons[:widgets], color: TEXT),
    title: text(item[:title], style: { color: TEXT, size: 18, weight: "w700" }),
    subtitle: text(item[:description], style: { color: MUTED, size: 14 }),
    trailing: icon(icon: Ruflet::MaterialIcons::CHEVRON_RIGHT, color: TEXT),
    on_click: ->(_e) { studio_go(page, "/gallery/#{slug}/example/#{item[:slug]}?from=#{CGI.escape("/gallery/#{slug}")}") })
end

def editor_view(page, item, back_route:)
  actions = [
    text_button(content: row(spacing: 6, children: [icon(icon: Ruflet::MaterialIcons[:fork_right], color: TEXT), text("Fork", style: { color: TEXT })])),
    text_button(content: row(spacing: 6, children: [icon(icon: Ruflet::MaterialIcons[:ios_share], color: TEXT), text("Share", style: { color: TEXT })])),
    icon_button(icon: Ruflet::MaterialIcons[:open_in_new]),
    icon_button(icon: Ruflet::MaterialIcons[:download])
  ]

  workspace =
    if mobile?(page)
      mobile_editor_workspace(page, item)
    else
      desktop_editor_workspace(page, item)
    end

  control(:view, route: path(page), bgcolor: BG, padding: 0,
    appbar: top_bar(page, item[:title], back: back_route, actions: actions),
    children: [workspace])
end

def desktop_editor_workspace(page, item)
  row(expand: true, spacing: 0, children: [
    file_pane(page, item),
    container(width: 1, bgcolor: BORDER),
    code_pane(page, item),
    container(width: 1, bgcolor: BORDER),
    preview_pane(page, item)
  ])
end

def mobile_editor_workspace(page, item)
  column(expand: true, spacing: 0, children: [
    container(height: 48, bgcolor: BG, content: row(spacing: 0, children: [
      mobile_workspace_tab("Files", Ruflet::MaterialIcons::FOLDER, false),
      mobile_workspace_tab("Code", Ruflet::MaterialIcons::CODE, false),
      mobile_workspace_tab("Preview", Ruflet::MaterialIcons[:play_circle_outline], true)
    ])),
    container(expand: true, bgcolor: PREVIEW_BG, padding: 14, content: preview_for(page, item[:slug], large: true)),
    console_bar
  ])
end

def mobile_workspace_tab(label, icon_value, selected)
  container(expand: true, alignment: "center", bgcolor: BG, border: selected ? { width: 0, color: BLUE } : nil,
    content: row(alignment: "center", spacing: 6, children: [
      icon(icon: icon_value, color: selected ? BLUE : MUTED, size: 18),
      text(label, style: { color: selected ? BLUE : MUTED, size: 14 })
    ]))
end

def file_pane(page, item)
  current_file = selected_file(page, item)
  files = item_files(item)
  container(width: 330, bgcolor: BG, padding: 12, content: column(expand: true, spacing: 8, children: [
    row(children: [
      text("Files", style: { color: TEXT, size: 14, weight: "w700" }),
      container(expand: true, content: text("")),
      icon(icon: Ruflet::MaterialIcons[:unfold_less], color: TEXT, size: 18)
    ]),
    *files.keys.map do |file|
      selected = file == current_file
      container(border_radius: 8, bgcolor: selected ? "#1c2630" : BG, padding: { top: 8, bottom: 8, left: 8, right: 8 },
        on_click: ->(_e) { studio_go(page, file_route(page, file)) },
        content: row(spacing: 8, children: [
          icon(icon: Ruflet::MaterialIcons[:insert_drive_file], color: MUTED),
          text(file, style: { color: TEXT, size: 18, weight: selected ? "w700" : "w500" })
        ]))
    end
  ]))
end

def code_pane(page, item)
  status = text("Read-only preview. Fork it to make changes.", style: { color: MUTED, size: 14 })
  editor = code_editor(selected_code(page, item), language: "ruby", code_theme: "atom-one-dark", read_only: true, expand: true)
  container(width: 780, bgcolor: EDITOR_BG, content: column(expand: true, spacing: 0, children: [
    container(height: 66, bgcolor: "#2a2d33", padding: { left: 20, right: 18 },
      content: row(spacing: 10, children: [
        icon(icon: Ruflet::MaterialIcons[:lock], color: MUTED, size: 20),
        status,
        container(expand: true, content: text("")),
        outlined_button(content: row(spacing: 8, children: [icon(icon: Ruflet::MaterialIcons[:fork_right]), text("Fork")]), disabled: true)
      ])),
    container(expand: true, content: editor)
  ]))
end

def preview_pane(page, item)
  container(expand: true, bgcolor: "#12161a", content: column(expand: true, spacing: 0, children: [
    container(expand: true, alignment: "center", bgcolor: item[:slug] == "calculator" ? "#12161a" : PREVIEW_BG,
      padding: 24, content: preview_for(page, item[:slug], large: true)),
    console_bar
  ]))
end

def console_bar
  container(height: 48, bgcolor: "#090c0f", padding: { left: 14, right: 10 }, content: row(spacing: 12, children: [
    icon(icon: Ruflet::MaterialIcons::CHEVRON_RIGHT, color: TEXT),
    text("Console", style: { color: TEXT, size: 14, weight: "w700" }),
    container(expand: true, content: text("")),
    icon(icon: Ruflet::MaterialIcons[:delete_outline], color: "#60656d")
  ]))
end

def thumbnail_for(page, slug)
  item = example(slug)
  return showcase_preview(page, item, large: false) if item[:showcase]

  case slug
  when "calculator"
    static_calculator_thumbnail
  when "todo"
    static_todo_thumbnail
  when "animation"
    static_flet_logo_thumbnail
  when "icons-browser"
    static_icons_thumbnail
  when "router"
    static_router_thumbnail
  else
    static_control_thumbnail(slug)
  end
end

def preview_for(page, slug, large:)
  item = example(slug)
  return showcase_preview(page, item, large: large) if item[:showcase]

  case slug
  when "calculator"
    calculator_preview(page, large)
  when "todo"
    todo_preview
  when "animation"
    flet_logo_preview
  when "icons-browser"
    icons_preview
  when "router"
    router_preview
  when "routing-two-pages"
    routing_preview
  else
    control_example_preview(slug, large)
  end
end

def showcase_status
  text(value: "", style: { color: MUTED, size: 12 })
end

def showcase_preview(page, item, large:)
  content =
    if item[:component_slug]
      SHOWCASE_PREVIEW.build_component_detail(page, showcase_status, item[:component_slug])
    else
      SHOWCASE_PREVIEW.public_send(item[:builder], page, showcase_status)
    end

  container(
    width: large ? nil : 320,
    height: large ? nil : 132,
    padding: large ? 0 : 8,
    clip_behavior: "hardEdge",
    content: content
  )
rescue StandardError => e
  container(width: large ? 420 : 260, padding: 16, border_radius: 8, bgcolor: "#ffffff",
    content: column(spacing: 8, children: [
      text("Preview unavailable", style: { color: "#111827", weight: "w700" }),
      text(e.message, style: { color: "#4b5563", size: 12, max_lines: 3 })
    ]))
end

def calculator_preview(page, large)
  state = { current: "0", left: nil, operator: nil, reset: false }
  display = text("0", style: { color: "#ffffff", size: large ? 28 : 16 })

  apply = lambda do |value|
    case value
    when "AC"
      state[:current] = "0"
      state[:left] = nil
      state[:operator] = nil
      state[:reset] = false
    when "+/-"
      state[:current] = state[:current].start_with?("-") ? state[:current][1..] : "-#{state[:current]}"
    when "%"
      state[:current] = format_calc_number(state[:current].to_f / 100.0)
    when "/", "*", "-", "+"
      state[:left] = state[:current].to_f
      state[:operator] = value
      state[:reset] = true
    when "="
      if state[:left] && state[:operator]
        right = state[:current].to_f
        result =
          case state[:operator]
          when "/" then right.zero? ? 0 : state[:left] / right
          when "*" then state[:left] * right
          when "-" then state[:left] - right
          else state[:left] + right
          end
        state[:current] = format_calc_number(result)
        state[:left] = nil
        state[:operator] = nil
        state[:reset] = true
      end
    when "."
      state[:current] = "0" if state[:reset]
      state[:reset] = false
      state[:current] += "." unless state[:current].include?(".")
    else
      state[:current] = state[:reset] || state[:current] == "0" ? value : "#{state[:current]}#{value}"
      state[:reset] = false
    end

    page&.update(display, value: state[:current])
  end

  container(width: large ? 340 : 270, padding: large ? 16 : 18, border_radius: 20, bgcolor: "#000000",
    content: column(spacing: 12, children: [
      row(alignment: "end", children: [display]),
      calc_row(%w[AC +/- % /], large, apply),
      calc_row(%w[7 8 9 *], large, apply),
      calc_row(%w[4 5 6 -], large, apply),
      calc_row(%w[1 2 3 +], large, apply),
      calc_row(%w[0 . =], large, apply)
    ]))
end

def format_calc_number(value)
  return "0" if value.nan? || value.infinite?

  formatted = value.round(8).to_s
  formatted.sub(/\.0\z/, "")
end

def calc_row(values, large, apply)
  row(spacing: large ? 8 : 6, children: values.map { |value| calc_button(value, large, apply) })
end

def calc_button(value, large, apply)
  orange = %w[/ * - + =].include?(value)
  button(expand: value == "0", width: value == "0" ? nil : (large ? 62 : 54), height: large ? 42 : 26,
    bgcolor: orange ? ORANGE : (value =~ /\d|\./ ? "#3f3f3f" : "#dce3e5"),
    color: orange || value =~ /\d|\./ ? "#ffffff" : "#111111",
    on_click: ->(_e) { apply.call(value) },
    content: text(value, style: { color: orange || value =~ /\d|\./ ? "#ffffff" : "#111111", size: large ? 18 : 10, weight: "w700" }))
end

def static_calculator_thumbnail
  container(width: 240, padding: 12, border_radius: 16, bgcolor: "#000000",
    content: column(spacing: 7, children: [
      row(alignment: "end", children: [text("0", style: { color: "#ffffff", size: 15 })]),
      static_calc_row([false, false, false, true]),
      static_calc_row([false, false, false, true]),
      static_calc_row([false, false, false, true]),
      static_calc_row([false, false, false, true])
    ]))
end

def static_calc_row(actions)
  row(spacing: 6, children: actions.map { |action| static_calc_button(action) })
end

def static_calc_button(action)
  container(width: 44, height: 22, border_radius: 16, bgcolor: action ? ORANGE : "#3f3f3f")
end

def static_todo_thumbnail
  container(padding: 10, bgcolor: PREVIEW_BG, content: column(spacing: 6, children: [
    text("Todos", style: { color: "#111827", weight: "w700", size: 13 }),
    container(height: 22, border: { width: 1, color: "#9ca3af" }, content: text(" What needs to be done?", style: { size: 9, color: "#374151" })),
    static_todo_line(true, "Release new Ruflet"),
    static_todo_line(true, "Update docs"),
    static_todo_line(false, "Write a blog post")
  ]))
end

def static_todo_line(done, label)
  row(spacing: 8, children: [
    container(width: 10, height: 10, border: { width: 1, color: "#64748b" }, bgcolor: done ? "#5b7da9" : PREVIEW_BG),
    text(label, style: { color: "#111827", size: 9 })
  ])
end

def static_flet_logo_thumbnail
  row(alignment: "center", spacing: 16, children: [
    logo_column("#df3266", [3, 2, 3]),
    logo_column("#ffc13d", [1, 1, 4]),
    logo_column("#88c557", [4, 2, 4]),
    logo_column("#5d3dbb", [4, 1, 1])
  ])
end

def static_icons_thumbnail
  column(spacing: 8, children: [
    container(height: 26, border: { width: 1, color: "#9ca3af" }, content: text("  add", style: { color: "#111827", size: 10 })),
    row(spacing: 16, children: [Ruflet::MaterialIcons::ADD, Ruflet::MaterialIcons::PHOTO_CAMERA, Ruflet::MaterialIcons[:alarm], Ruflet::MaterialIcons[:accessibility]].map { |i| icon(icon: i, color: "#446b9e", size: 20) })
  ])
end

def static_router_thumbnail
  column(spacing: 8, children: [
    text("Router Demo", style: { color: "#111827", weight: "w700", size: 12 }),
    row(spacing: 12, children: %w[Home Projects Settings].map { |label| text(label, style: { color: label == "Home" ? "#2563eb" : "#111827", size: 9 }) }),
    text("Welcome to the Router Demo!", style: { color: "#111827", size: 10 })
  ])
end

def static_routing_thumbnail
  column(spacing: 8, children: [
    row(spacing: 20, children: [
      text("Flet app", style: { color: "#111827", size: 14, weight: "w700" }),
      container(width: 34, height: 18, border_radius: 12, bgcolor: "#d1d5db")
    ]),
    container(width: 92, height: 22, border_radius: 14, bgcolor: "#e8edf5", alignment: "center",
      content: text("Visit Store", style: { color: "#46658d", size: 9 }))
  ])
end

def static_control_thumbnail(slug)
  control_example_preview(slug, false)
end

def control_example_preview(slug, large)
  title = example(slug)[:title]
  case title
  when "Card"
    container(width: large ? 340 : 220, padding: 18, border_radius: 8, bgcolor: "#ffffff",
      content: column(spacing: 10, children: [
        text("Card title", style: { color: "#111827", size: large ? 22 : 13, weight: "w700" }),
        text("Cards group related content and actions.", style: { color: "#4b5563", size: large ? 14 : 9 }),
        row(spacing: 8, children: [outlined_button(content: text("Cancel")), filled_button(content: text("Open"))])
      ]))
  when "Column"
    column(spacing: large ? 14 : 7, children: %w[First Second Third].map.with_index do |label, i|
      container(width: large ? 260 : 170, height: large ? 44 : 24, border_radius: 6, bgcolor: ["#dbeafe", "#dcfce7", "#fee2e2"][i], alignment: "center",
        content: text("#{label} item", style: { color: "#111827", size: large ? 14 : 9 }))
    end)
  when "Container"
    container(width: large ? 280 : 190, height: large ? 150 : 90, border_radius: 14, bgcolor: "#dbeafe", alignment: "center",
      content: text("Container", style: { color: "#1e3a8a", size: large ? 22 : 13, weight: "w700" }))
  when "DataTable"
    container(width: large ? 360 : 230, padding: 12, bgcolor: "#ffffff", border_radius: 6,
      content: column(spacing: 8, children: [
        row(spacing: large ? 78 : 36, children: [text("Name", style: { color: "#111827", weight: "w700" }), text("Role", style: { color: "#111827", weight: "w700" })]),
        container(height: 1, bgcolor: "#d1d5db"),
        row(spacing: large ? 92 : 50, children: [text("Ada", style: { color: "#111827" }), text("Engineer", style: { color: "#111827" })]),
        row(spacing: large ? 98 : 55, children: [text("Lin", style: { color: "#111827" }), text("Designer", style: { color: "#111827" })])
      ]))
  when "Divider"
    column(width: large ? 320 : 220, spacing: 14, children: [
      text("Above", style: { color: "#111827", size: large ? 18 : 12 }),
      container(height: 1, bgcolor: "#9ca3af"),
      text("Below", style: { color: "#111827", size: large ? 18 : 12 })
    ])
  when "GridView"
    grid_view(width: large ? 340 : 230, height: large ? 240 : 130, max_extent: large ? 76 : 48, spacing: 10, run_spacing: 10,
      children: Array.new(8) { |i| container(height: large ? 58 : 32, border_radius: 8, bgcolor: i.even? ? "#bfdbfe" : "#fecdd3", alignment: "center", content: text((i + 1).to_s, style: { color: "#111827" })) })
  else
    container(width: large ? 340 : 230, padding: 18, border_radius: 8, bgcolor: "#ffffff",
      content: column(spacing: 14, children: [
        text(title, style: { color: "#111827", size: large ? 24 : 15, weight: "w700" }),
        text("Live Ruflet preview", style: { color: "#4b5563", size: large ? 14 : 10 }),
        filled_button(content: text("Action"))
      ]))
  end
end

def todo_preview
  container(padding: 12, bgcolor: PREVIEW_BG, content: column(spacing: 8, children: [
    text("Todos", style: { color: "#111827", weight: "w700" }),
    row(spacing: 8, children: [container(expand: true, height: 28, border: { width: 1, color: "#9ca3af" }, content: text(" What needs to be done?", style: { size: 10, color: "#374151" })), container(width: 32, height: 32, bgcolor: "#dbeafe", border_radius: 8, content: text("+", style: { color: "#2563eb" }))]),
    checkbox(label: "Release new Ruflet", value: true),
    checkbox(label: "Update docs", value: true),
    checkbox(label: "Write a blog post", value: false)
  ]))
end

def flet_logo_preview
  row(alignment: "center", spacing: 22, children: [
    logo_column("#df3266", [3, 2, 3]),
    logo_column("#ffc13d", [1, 1, 4]),
    logo_column("#88c557", [4, 2, 4]),
    logo_column("#5d3dbb", [4, 1, 1])
  ])
end

def logo_column(color, rows)
  column(spacing: 6, children: rows.map { |count| row(spacing: 6, children: Array.new(count) { container(width: 18, height: 18, bgcolor: color, border_radius: 3) }) })
end

def icons_preview
  column(spacing: 10, children: [
    container(height: 30, border: { width: 1, color: "#9ca3af" }, content: text("  add", style: { color: "#111827" })),
    row(spacing: 16, children: [Ruflet::MaterialIcons::ADD, Ruflet::MaterialIcons::PHOTO_CAMERA, Ruflet::MaterialIcons[:alarm], Ruflet::MaterialIcons[:accessibility]].map { |i| icon(icon: i, color: "#446b9e") })
  ])
end

def router_preview
  column(spacing: 10, children: [
    text("Router Demo", style: { color: "#111827", weight: "w700" }),
    row(spacing: 12, children: %w[Home Projects Settings].map { |label| text(label, style: { color: label == "Home" ? "#2563eb" : "#111827", size: 12 }) }),
    text("Welcome to the Router Demo!", style: { color: "#111827" }),
    filled_button(content: text("Browse projects"))
  ])
end

def routing_preview
  column(spacing: 12, children: [
    row(spacing: 20, children: [text("Flet app", style: { color: "#111827", size: 20, weight: "w700" }), switch(value: false, label: "Dark mode")]),
    outlined_button(content: text("Visit Store")),
    outlined_button(content: text("Do something"))
  ])
end

def settings_view(page, tab)
  tabs = {
    "account" => ["Account", account_settings],
    "system" => ["System", system_settings],
    "about" => ["About", about_settings]
  }
  active_label, content = tabs[tab] || tabs["system"]

  control(:view, route: path(page), bgcolor: BG, padding: 0,
    appbar: app_bar(bgcolor: BAR, color: TEXT,
      leading: icon_button(icon: Ruflet::MaterialIcons::CLOSE, on_click: ->(_e) { studio_go(page, "/apps") }),
      title: text("Settings", style: { color: TEXT, size: 20, weight: "w700" })),
    children: [
      column(expand: true, spacing: 0, children: [
        row(spacing: 0, children: tabs.keys.map do |key|
          label = tabs[key][0]
          container(padding: { left: 16, right: 16, top: 14, bottom: 14 },
            on_click: ->(_e) { studio_go(page, "/settings/#{key}") },
            content: text(label, style: { color: label == active_label ? BLUE : MUTED, size: 14 }))
        end),
        container(height: 1, bgcolor: BORDER),
        container(expand: true, padding: 20, content: content)
      ])
    ])
end

def account_settings
  column(spacing: 16, children: [
    text("You are not signed in.", style: { color: TEXT, size: 16 }),
    filled_button(content: text("Sign in")),
    text("Plan & usage", style: { color: TEXT, weight: "w700" }),
    text("Sign in to create apps and save versions.", style: { color: MUTED })
  ])
end

def system_settings
  column(spacing: 18, children: [
    text("General", style: { color: TEXT, weight: "w700" }),
    control(:radio_group, value: "system", content: column(spacing: 8, children: [
      control(:radio, value: "system", label: "System"),
      control(:radio, value: "light", label: "Light"),
      control(:radio, value: "dark", label: "Dark")
    ])),
    text("Editor", style: { color: TEXT, weight: "w700" }),
    row(spacing: 12, children: [text("Font size", style: { color: TEXT }), text_field(value: "13", width: 100)])
  ])
end

def about_settings
  column(spacing: 16, children: [
    text("App", style: { color: TEXT, weight: "w700" }),
    text("Ruflet Studio version 1.0.0", style: { color: TEXT }),
    text("Ruflet SDK version #{Ruflet::VERSION}", style: { color: TEXT }),
    text("Resources", style: { color: TEXT, weight: "w700" }),
    text("Docs, What's New, GitHub, Discord, Email", style: { color: MUTED })
  ])
end

Ruflet.run do |page|
  page.on_route_change = ->(_e) { render(page) }
  render(page)
end
