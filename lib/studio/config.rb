# frozen_string_literal: true

STANDALONE_ROOT = File.expand_path("../../standalone_apps", __dir__)
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
  ["Getting Started", "Build your first Ruflet app", "rocket_launch", "getting-started"],
  ["Layout", "Layout primitives and containers", "view_module", "layout"],
  ["Components", "Individual control demos", "widgets", "components"],
  ["Displays", "Text, images, and information controls", "image", "displays"],
  ["Charts", "Data visualization examples", "show_chart", "charts"],
  ["Games", "Interactive game examples", "sports_esports", "games"],
  ["Animations", "Motion and state transitions", "animation", "animations"],
  ["Effects", "Visual effects and polish", "auto_awesome", "effects"],
  ["Services", "Device and platform integrations", "settings", "services"]
].freeze
