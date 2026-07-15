# frozen_string_literal: true

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
            icon(icon: "add"),
            icon(icon: "photo_camera"),
            icon(icon: "alarm")
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
  "services" => ["Audio", "AudioRecorder", "Map", "Camera", "FilePicker"],
  "getting-started" => []
}.freeze

def slugify(value)
  value.to_s.gsub(/([a-z])([A-Z])/, '\1-\2').downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-+\z/, "")
end

def route_path(page) = page.route.to_s.split("?").first
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
