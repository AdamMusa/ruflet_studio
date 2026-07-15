# frozen_string_literal: true

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
  route = route_path(page)
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
