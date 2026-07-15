# frozen_string_literal: true

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
  ["spinkit", "SpinKit", "components", :build_spinkit],
  ["drawing", "Drawing Tool", "effects", :build_drawing],
  ["material", "Material controls", "components", :build_material_controls],
  ["cupertino", "Cupertino controls", "components", :build_cupertino_controls],
  ["charts", "Charts", "charts", :build_charts],
  ["minesweeper", "Minesweeper", "games", :build_minesweeper],
  ["icon-search", "Icon Search", "displays", :build_icon_search],
  ["animation", "Ruflet Animation", "animations", :build_animation],
  ["rive", "Rive", "animations", :build_rive],
  ["accelerometer", "Accelerometer", "services", :build_accelerometer],
  ["gyroscope", "Gyroscope", "services", :build_gyroscope],
  ["user-accelerometer", "User Accelerometer", "services", :build_user_accelerometer],
  ["magnetometer", "Magnetometer", "services", :build_magnetometer],
  ["barometer", "Barometer", "services", :build_barometer],
  ["browser-context-menu", "Browser Context Menu", "services", :build_browser_context_menu],
  ["shake-detector", "Shake Detector", "services", :build_shake_detector],
  ["semantics-service", "Semantics Service", "services", :build_semantics_service],
  ["screenshot", "Screenshot", "services", :build_screenshot],
  ["audio", "Audio Player", "services", :build_audio],
  ["audio-recorder", "Audio Recorder", "services", :build_audio_recorder],
  ["video", "Video Player", "services", :build_video],
  ["battery", "Battery", "services", :build_battery],
  ["screen-brightness", "Screen Brightness", "services", :build_screen_brightness],
  ["clipboard", "Clipboard", "services", :build_clipboard],
  ["storage-paths", "Storage Paths", "services", :build_storage_paths],
  ["share", "Share", "services", :build_share],
  ["webview", "WebView", "services", :build_webview],
  ["flashlight", "Flashlight", "services", :build_flashlight],
  ["connectivity", "Connectivity", "services", :build_connectivity],
  ["geolocator", "Geolocator", "services", :build_geolocator],
  ["map", "Map", "services", :build_map],
  ["permission-handler", "Permission Handler", "services", :build_permission_handler],
  ["secure-storage", "Secure Storage", "services", :build_secure_storage],
  ["camera", "Camera", "services", :build_camera],
  ["file-picker", "File Picker", "services", :build_file_picker],
  ["window", "Window", "services", :build_window]
].freeze

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
      "components",
      :build_component_detail,
      component_slug: component_slug
    )
  end
end

def showcase_examples
  @showcase_examples ||= (showcase_route_examples + showcase_component_examples).freeze
end

def showcase_gallery_examples
  showcase_route_examples + showcase_component_examples
end

def selected_file(page, item)
  requested = page.query["file"].to_s
  files = item_files(item)
  return files.keys.first if requested.empty?

  decoded = CGI.unescape(requested)
  files.key?(decoded) ? decoded : files.keys.first
end

def file_route(page, file)
  base = route_path(page)
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
  file = selected_file(page, item)
  editor_session(page, item, file)[:code]
end

def editor_sessions(page)
  sessions = page.instance_variable_get(:@ruflet_studio_editor_sessions)
  return sessions if sessions

  sessions = {}
  page.instance_variable_set(:@ruflet_studio_editor_sessions, sessions)
  sessions
end

def editor_session(page, item, file)
  key = "#{item[:slug]}:#{file}"
  initial_code = item_files(item).fetch(file).to_s
  editor_sessions(page)[key] ||= {
    code: initial_code.dup,
    last_successful_code: initial_code.dup,
    editable: false,
    preview: nil,
    last_successful_preview: nil,
    preview_host: nil
  }
end

def editor_change_source(event)
  data = event.data
  data = data["value"] || data[:value] if data.is_a?(Hash)
  data.to_s
end

# Page proxy used to render an example's OWN code into the preview area:
# `page.add` collects the controls so we can host them in the preview, while the
# app-level setters are ignored and everything else (notably `page.update`, used
# by live handlers like the counter buttons) flows through to the real page.
