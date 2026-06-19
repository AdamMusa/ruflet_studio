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
# Dark backdrop behind the live preview, so light components (e.g. Counter's
# pale card) stay legible instead of washing out on white.
PREVIEW_SURFACE = "#12161a"
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

def show_sign_in_dialog(page)
  studio_go(page, "/apps?signin=1")
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
      content: container(width: 48, height: 48, border_radius: 14, bgcolor: SURFACE_2, alignment: "center",
        on_click: ->(_e) { show_sign_in_dialog(page) }, content: icon(icon: Ruflet::MaterialIcons::ADD, color: TEXT, size: 24))),
    rail_item(page, "Apps", Ruflet::MaterialIcons::GRID_VIEW, "/apps", active == "apps"),
    rail_item(page, "Gallery", Ruflet::MaterialIcons::IMAGE, "/gallery", active == "gallery")
  ]))
end

def rail_item(page, label, icon_value, route, selected)
  container(padding: { left: 6, right: 6 }, content: column(horizontal_alignment: "center", spacing: 3, children: [
    container(width: 46, height: 36, border_radius: 18, bgcolor: selected ? PINK : BG, alignment: "center",
      on_click: ->(_e) { studio_go(page, route) }, content: icon(icon: icon_value, color: selected ? "#ffffff" : MUTED, size: 22)),
    text(label, style: { color: selected ? TEXT : MUTED, size: 12, weight: selected ? "w700" : "w600" })
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
  base = container(expand: true, alignment: "center", content: column(tight: true, horizontal_alignment: "center", spacing: 22, children: [
    column(tight: true, horizontal_alignment: "center", spacing: 2, children: [
      text("Sign in to create apps and access your work, or browse", style: { color: TEXT, size: 16, weight: "w600" }),
      row(tight: true, spacing: 4, alignment: "center", children: [
        container(on_click: ->(_e) { studio_go(page, "/gallery") }, content: text("Gallery", style: { color: BLUE, size: 16, weight: "w600" })),
        text("for examples.", style: { color: TEXT, size: 16, weight: "w600" })
      ])
    ]),
    filled_button(
      width: 136,
      height: 38,
      on_click: ->(_e) { show_sign_in_dialog(page) },
      content: row(tight: true, spacing: 8, alignment: "center", children: [
        icon(icon: Ruflet::MaterialIcons[:login]),
        text("Sign in")
      ])
    )
  ]))

  body = page.query["signin"].to_s == "1" ? stack(expand: true, children: [base, sign_in_dialog(page)]) : base
  shell(page, "Apps", "apps", body)
end

def sign_in_dialog(page)
  container(expand: true, alignment: "center", padding: 16, bgcolor: "#00000099", content: container(width: 430, height: 450, padding: 24, border_radius: 18, bgcolor: "#2a2d33",
    content: column(tight: true, spacing: 14, children: [
      row(alignment: "center", children: [
        container(expand: true, content: text("Sign in to Ruflet Studio", style: { color: TEXT, size: 30, weight: "w700" })),
        icon_button(icon: Ruflet::MaterialIcons::CLOSE, icon_color: MUTED, on_click: ->(_e) { studio_go(page, "/apps") })
      ]),
      text("Sign in to create apps, save versions, and access your work from anywhere.", style: { color: TEXT, size: 17 }),
      text("By signing in to Ruflet Studio, you agree to our Terms of Service and Privacy Policy.", style: { color: MUTED, size: 14 }),
      sign_button("Sign in with GitHub", Ruflet::MaterialIcons[:code]),
      sign_button("Sign in with Google", Ruflet::MaterialIcons[:g_mobiledata]),
      sign_button("Sign in with Microsoft", Ruflet::MaterialIcons::GRID_VIEW)
    ])))
end

def sign_button(label, icon_value)
  outlined_button(width: 374, height: 40, content: row(tight: true, alignment: "center", spacing: 10, children: [
    icon(icon: icon_value, color: TEXT),
    text(label, style: { color: TEXT, size: 16, weight: "w600" })
  ]))
end

# The category menu is a wide-screen convenience; below this it is hidden so the
# gallery grid gets the full width (the grid shows every example anyway).
def show_categories_menu?(page) = page.width.to_f >= 760

# Search box: submit (Enter) filters the gallery grid by the typed query.
def search_field(page)
  text_field(
    label: "Search...",
    prefix_icon: Ruflet::MaterialIcons::SEARCH,
    value: page.query["q"],
    expand: true,
    height: 46,
    on_submit: ->(e) { studio_go(page, search_route(page, e.data)) }
  )
end

def search_route(page, query)
  q = query.to_s.strip
  base = show_categories_menu?(page) ? "/gallery" : "/gallery?view=grid"
  return base if q.empty?

  separator = base.include?("?") ? "&" : "?"
  "#{base}#{separator}q=#{CGI.escape(q)}"
end

def categories_menu(page)
  column(expand: true, scroll: "auto", spacing: 0, children: [
    container(padding: { left: 12, right: 12, top: 12, bottom: 10 }, content: search_field(page)),
    *CATEGORIES.map { |label, desc, icon_value, slug| category_tile(page, label, icon_value, slug) }
  ])
end

# Phones use a lazy list so only visible thumbnails are built. Wide screens keep
# the responsive multi-column grid.
def gallery_grid(page)
  query = page.query["q"].to_s.strip
  examples = showcase_gallery_examples
  unless query.empty?
    needle = query.downcase
    examples = examples.select { |it| "#{it[:title]} #{it[:description]}".downcase.include?(needle) }
  end

  if examples.empty?
    return container(expand: true, alignment: "center", padding: 40,
      content: text("No examples match \"#{query}\".", style: { color: MUTED, size: 16 }))
  end

  if page.width.to_f >= 760
    # Desktop: 2–3 columns reflow with responsive_row inside a scroll view.
    container(expand: true, padding: 20, content: column(expand: true, scroll: "auto", children: [
      responsive_row(
        columns: 12, spacing: 20, run_spacing: 20,
        children: examples.map { |item| container(col: { "sm" => 6, "lg" => 4 }, content: gallery_card(page, item)) }
      )
    ]))
  else
    # Phones: lazy single-column list — only on-screen cards build their preview.
    list_view(expand: true, padding: 20, spacing: 20,
      children: examples.map { |item| gallery_card(page, item) })
  end
end

# Small-screen-only "Gallery" entry at the top of the category list; tapping it
# opens the full card grid (which the desktop layout shows permanently).
def gallery_browse_tile(page)
  container(height: 56, content: list_tile(
    content_padding: { left: 12, right: 8, top: 0, bottom: 0 },
    leading: icon(icon: Ruflet::MaterialIcons::IMAGE, color: PINK, size: 20),
    title: text("Gallery", style: { color: TEXT, size: 15, weight: "w700" }),
    subtitle: text("Browse all examples", style: { color: MUTED, size: 12 }),
    trailing: icon(icon: Ruflet::MaterialIcons::CHEVRON_RIGHT, color: TEXT, size: 20),
    on_click: ->(_e) { studio_go(page, "/gallery?view=grid") }))
end

# Small screens default to the category list with the Gallery entry on top.
def mobile_gallery_menu(page)
  column(expand: true, scroll: "auto", spacing: 0, children: [
    container(padding: { left: 12, right: 12, top: 12, bottom: 10 }, content: search_field(page)),
    gallery_browse_tile(page),
    container(height: 1, bgcolor: BORDER),
    *CATEGORIES.map { |label, _desc, icon_value, slug| category_tile(page, label, icon_value, slug) }
  ])
end

def gallery_back_bar(page, title)
  container(height: 48, bgcolor: BG, padding: { left: 4, right: 12 },
    content: row(alignment: "center", spacing: 2, children: [
      icon_button(icon: Ruflet::MaterialIcons::ARROW_BACK, on_click: ->(_e) { studio_go(page, "/gallery") }),
      text(title, style: { color: TEXT, size: 16, weight: "w700" })
    ]))
end

def gallery_view(page)
  body =
    if show_categories_menu?(page)
      # Desktop: category list + card grid side by side.
      row(expand: true, spacing: 0, children: [
        container(width: 300, content: categories_menu(page)),
        container(width: 1, bgcolor: BORDER),
        gallery_grid(page)
      ])
    elsif page.query["view"] == "grid"
      # Small screen: the card grid, reached from the "Gallery" list entry.
      column(expand: true, spacing: 0, children: [
        gallery_back_bar(page, "Gallery"),
        container(height: 1, bgcolor: BORDER),
        gallery_grid(page)
      ])
    else
      # Small screen default: the category list.
      mobile_gallery_menu(page)
    end
  shell(page, "Gallery", "gallery", body)
end

def category_tile(page, label, icon_value, slug)
  container(height: 60, content: list_tile(
    content_padding: { left: 16, right: 12, top: 0, bottom: 0 },
    leading: icon(icon: icon_value, color: TEXT, size: 22),
    title: text(label, style: { color: TEXT, size: 17, weight: "w700" }),
    trailing: icon(icon: Ruflet::MaterialIcons::CHEVRON_RIGHT, color: TEXT, size: 22),
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
  actions =
    if page.width.to_f >= 760
      [
        text_button(content: row(spacing: 6, children: [icon(icon: Ruflet::MaterialIcons[:fork_right], color: TEXT), text("Fork", style: { color: TEXT })])),
        text_button(content: row(spacing: 6, children: [icon(icon: Ruflet::MaterialIcons[:ios_share], color: TEXT), text("Share", style: { color: TEXT })])),
        icon_button(icon: Ruflet::MaterialIcons[:open_in_new]),
        icon_button(icon: Ruflet::MaterialIcons[:download])
      ]
    else
      # Compact icon-only actions on phones so the app bar doesn't overflow.
      [
        icon_button(icon: Ruflet::MaterialIcons[:fork_right]),
        icon_button(icon: Ruflet::MaterialIcons[:download])
      ]
    end

  # The 3-pane (files + code + preview) layout; on phones fall back to the
  # compact tabbed workspace.
  workspace =
    if page.width.to_f >= 760
      desktop_editor_workspace(page, item)
    else
      mobile_editor_workspace(page, item)
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

# Compact editor for narrow screens: the Files / Code / Preview tabs switch the
# visible pane via a ?tab= param (instead of cramming all three side by side).
def mobile_editor_workspace(page, item)
  tab = page.query["tab"].to_s
  tab = "preview" unless %w[files code preview].include?(tab)

  body =
    case tab
    when "files" then mobile_file_list(page, item)
    when "code"  then code_pane(page, item)
    else mobile_preview_pane(page, item)
    end

  column(expand: true, horizontal_alignment: "stretch", spacing: 0, children: [
    container(height: 48, bgcolor: BAR, content: row(spacing: 0, children: [
      mobile_workspace_tab(page, "Files", Ruflet::MaterialIcons::FOLDER, "files", tab == "files"),
      mobile_workspace_tab(page, "Code", Ruflet::MaterialIcons::CODE, "code", tab == "code"),
      mobile_workspace_tab(page, "Preview", Ruflet::MaterialIcons[:play_circle_outline], "preview", tab == "preview")
    ])),
    container(expand: true, content: body),
    console_bar
  ])
end

def mobile_preview_pane(page, item)
  container(expand: true, bgcolor: PREVIEW_SURFACE, padding: 14,
    content: column(expand: true, scroll: "auto", horizontal_alignment: "stretch",
      children: [preview_for(page, item[:slug], large: true)]))
end

def mobile_workspace_tab(page, label, icon_value, tab_key, selected)
  container(expand: true, alignment: "center", bgcolor: selected ? BG : BAR,
    on_click: ->(_e) { studio_go(page, tab_route(page, tab_key)) },
    content: row(alignment: "center", spacing: 6, children: [
      icon(icon: icon_value, color: selected ? BLUE : MUTED, size: 18),
      text(label, style: { color: selected ? BLUE : MUTED, size: 14, weight: selected ? "w700" : "w600" })
    ]))
end

def mobile_file_list(page, item)
  current = selected_file(page, item)
  container(expand: true, bgcolor: BG, padding: 12, content: column(expand: true, scroll: "auto", spacing: 6, children:
    item_files(item).keys.map do |file|
      sel = file == current
      container(border_radius: 8, bgcolor: sel ? SURFACE_2 : BG, padding: 12,
        on_click: ->(_e) { studio_go(page, tab_route(page, "code", file: file)) },
        content: row(spacing: 10, children: [
          icon(icon: Ruflet::MaterialIcons[:insert_drive_file], color: sel ? BLUE : MUTED),
          text(file, style: { color: TEXT, size: 16, weight: sel ? "w700" : "w500" })
        ]))
    end))
end

# Route to a workspace tab, preserving the selected file and the back origin.
def tab_route(page, tab, file: nil)
  base = path(page)
  selected = file || page.query["file"]
  origin = page.query["from"]
  params = { "tab" => tab }
  params["file"] = selected unless selected.to_s.empty?
  params["from"] = origin unless origin.to_s.empty?
  "#{base}?" + params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
end

def file_pane(page, item)
  current_file = selected_file(page, item)
  files = item_files(item)
  container(width: 250, bgcolor: BG, padding: 12, content: column(expand: true, spacing: 8, children: [
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
          text(file, style: { color: TEXT, size: 15, weight: selected ? "w700" : "w500" })
        ]))
    end
  ]))
end

def code_pane(page, item)
  compact = mobile?(page)
  status = text(compact ? "Read-only preview" : "Read-only preview. Fork it to make changes.",
    style: { color: MUTED, size: compact ? 12 : 14 }, max_lines: 1)
  editor = code_editor(selected_code(page, item), language: "ruby", code_theme: "atom-one-dark", read_only: true, expand: true)
  container(expand: true, bgcolor: EDITOR_BG, content: column(expand: true, spacing: 0, children: [
    container(height: compact ? 52 : 66, bgcolor: "#2a2d33", padding: { left: compact ? 12 : 20, right: compact ? 12 : 18 },
      content: row(spacing: 10, children: [
        icon(icon: Ruflet::MaterialIcons[:lock], color: MUTED, size: 20),
        status,
        container(expand: true, content: text("")),
        *(compact ? [] : [outlined_button(content: row(spacing: 8, children: [icon(icon: Ruflet::MaterialIcons[:fork_right]), text("Fork")]), disabled: true)])
      ])),
    container(expand: true, content: editor)
  ]))
end

def preview_pane(page, item)
  container(expand: true, bgcolor: "#12161a", content: column(expand: true, spacing: 0, children: [
    container(expand: true, bgcolor: PREVIEW_SURFACE, padding: 24,
      content: column(expand: true, scroll: "auto", horizontal_alignment: "stretch",
        children: [preview_for(page, item[:slug], large: true)])),
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

# Category slug -> icon, for the lightweight gallery card thumbnails.
CATEGORY_ICON = CATEGORIES.each_with_object({}) do |(_label, _desc, icon_value, slug), acc|
  acc[slug] = icon_value
end.freeze

# A static, lightweight thumbnail for a gallery card. The grid renders ~40 of
# these at once; embedding the *live* preview here (video/webview/map/sensors)
# overwhelms iOS and blanks the grid. The live preview lives in the detail view,
# one at a time, where it works fine.
def gallery_card_thumb(item)
  container(expand: true, alignment: "center", clip_behavior: "hardEdge",
    content: showcase_thumbnail(item))
end

def showcase_thumbnail(item)
  slug = item[:slug]
  return compact_counter_thumbnail if slug == "counter"
  return static_todo_thumbnail if slug == "todo"
  return static_calculator_thumbnail if slug == "calculator"
  return compact_code_thumbnail if slug == "code-editor"
  return compact_layout_thumbnail if %w[responsive-row components].include?(slug)
  return compact_drawing_thumbnail if slug == "drawing"
  return compact_buttons_thumbnail if %w[material cupertino].include?(slug)
  return compact_chart_thumbnail if slug == "charts"
  return compact_game_thumbnail if slug == "minesweeper"
  return static_icons_thumbnail if slug == "icon-search"
  return static_flet_logo_thumbnail if slug == "animation"
  return compact_rive_thumbnail if slug == "rive"
  return compact_media_thumbnail(item) if item[:category] == "media"
  return static_control_thumbnail(item[:slug]) if item[:component_slug]

  compact_feature_thumbnail(item)
end

def compact_counter_thumbnail
  column(tight: true, horizontal_alignment: "center", spacing: 8, children: [
    text("0", style: { color: "#111827", size: 28, weight: "w700" }),
    row(tight: true, spacing: 8, children: [
      mini_pill("-1", "#dbeafe", "#1d4ed8"),
      mini_pill("+1", "#2563eb", "#ffffff")
    ])
  ])
end

def mini_pill(label, bgcolor, color)
  container(width: 58, height: 24, border_radius: 12, bgcolor: bgcolor,
    alignment: "center", content: text(label, style: { color: color, size: 10 }))
end

def compact_code_thumbnail
  container(width: 250, height: 116, padding: 10, border_radius: 6, bgcolor: "#20242b",
    content: column(spacing: 5, children: [
      text("1  require \"ruflet\"", style: { color: "#c678dd", size: 8 }),
      text("2  Ruflet.run do |page|", style: { color: "#61afef", size: 8 }),
      text("3    page.add(text(\"Hello\"))", style: { color: "#98c379", size: 8 }),
      text("4  end", style: { color: "#61afef", size: 8 })
    ]))
end

def compact_layout_thumbnail
  column(tight: true, spacing: 6, children: [
    row(tight: true, spacing: 6, children: [
      mini_layout_block(76, "#bfdbfe"), mini_layout_block(152, "#bbf7d0")
    ]),
    row(tight: true, spacing: 6, children: [
      mini_layout_block(134, "#fecdd3"), mini_layout_block(94, "#fde68a")
    ])
  ])
end

def mini_layout_block(width, color)
  container(width: width, height: 38, border_radius: 5, bgcolor: color)
end

def compact_drawing_thumbnail
  stack(width: 240, height: 112, children: [
    container(width: 240, height: 112, border_radius: 8, bgcolor: "#ffffff"),
    container(left: 18, top: 20, width: 76, height: 54, border_radius: 10, bgcolor: "#60a5fa"),
    container(left: 82, top: 46, width: 92, height: 10, border_radius: 5, bgcolor: "#f43f5e", rotate: 0.35),
    container(left: 170, top: 22, width: 42, height: 42, border_radius: 21, bgcolor: "#fbbf24")
  ])
end

def compact_buttons_thumbnail
  column(tight: true, horizontal_alignment: "center", spacing: 10, children: [
    mini_button("Primary", "#2563eb", "#ffffff"),
    mini_button("Secondary", "#e2e8f0", "#334155")
  ])
end

def mini_button(label, bgcolor, color)
  container(width: 150, height: 30, border_radius: 15, bgcolor: bgcolor,
    alignment: "center", content: text(label, style: { color: color, size: 10 }))
end

def compact_chart_thumbnail
  row(alignment: "end", spacing: 12, children: [36, 72, 52, 94, 64].map.with_index do |height, index|
    container(width: 26, height: height, border_radius: 4,
      bgcolor: ["#60a5fa", "#4ade80", "#fb7185", "#fbbf24", "#a78bfa"][index])
  end)
end

def compact_game_thumbnail
  cells = Array.new(16) do |index|
    marked = (index % 5).zero?
    container(width: 24, height: 24, border_radius: 3,
      bgcolor: marked ? "#ef4444" : "#cbd5e1", alignment: "center",
      content: marked ? icon(icon: Ruflet::MaterialIcons[:flag], color: "#ffffff", size: 11) : nil)
  end
  column(tight: true, spacing: 4, children: cells.each_slice(4).map do |slice|
    row(tight: true, spacing: 4, children: slice)
  end)
end

def compact_rive_thumbnail
  column(tight: true, horizontal_alignment: "center", spacing: 8, children: [
    icon(icon: Ruflet::MaterialIcons[:directions_car], color: "#2563eb", size: 52),
    row(tight: true, spacing: 5,
      children: Array.new(5) { container(width: 24, height: 4, border_radius: 2, bgcolor: "#94a3b8") })
  ])
end

def compact_media_thumbnail(item)
  icons = {
    "audio" => :audiotrack, "audio-recorder" => :mic, "video" => :play_circle,
    "camera" => :photo_camera, "map" => :map, "geolocator" => :location_on,
    "file-picker" => :folder_open, "share" => :share, "webview" => :language,
    "battery" => :battery_full, "flashlight" => :flashlight_on
  }
  icon_value = Ruflet::MaterialIcons[icons[item[:slug]] || :sensors]
  column(tight: true, horizontal_alignment: "center", spacing: 10, children: [
    container(width: 72, height: 72, border_radius: 36, bgcolor: "#dbeafe",
      alignment: "center", content: icon(icon: icon_value, color: "#2563eb", size: 34)),
    text(item[:title], style: { color: "#334155", size: 11, weight: "w600" })
  ])
end

def compact_feature_thumbnail(item)
  icon_value = CATEGORY_ICON[item[:category]] || Ruflet::MaterialIcons::CODE
  column(tight: true, horizontal_alignment: "center", spacing: 10, children: [
    icon(icon: icon_value, color: "#2563eb", size: 40),
    container(width: 150, height: 8, border_radius: 4, bgcolor: "#cbd5e1"),
    container(width: 100, height: 8, border_radius: 4, bgcolor: "#e2e8f0")
  ])
end

def thumbnail_for(page, slug)
  item = example(slug)
  return gallery_card_thumb(item) if item[:showcase]

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
    content: large ? content : column(height: 116, scroll: "hidden", children: [content])
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
  # Some clients (e.g. the embedded/iOS runtime) don't know their size at the
  # initial handshake, so page.width starts at 0 and the responsive layout
  # collapses. The real size arrives via the resize event; re-render when it
  # crosses a layout breakpoint (700 = mobile shell, 760 = side menu).
  layout_sig = nil
  page.on_resize = ->(_e) do
    sig = [page.width.to_f >= 700, page.width.to_f >= 760]
    next if sig == layout_sig

    layout_sig = sig
    render(page)
  end
  render(page)
end
