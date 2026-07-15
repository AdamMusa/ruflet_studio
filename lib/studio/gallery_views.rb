# frozen_string_literal: true

def show_categories_menu?(page) = page.width.to_f >= 760

# Search box: submit (Enter) filters the gallery grid by the typed query.
def search_field(page)
  text_field(
    label: "Search...",
    prefix_icon: "search",
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
    leading: icon(icon: "image", color: PINK, size: 20),
    title: text("Gallery", style: { color: TEXT, size: 15, weight: "w700" }),
    subtitle: text("Browse all examples", style: { color: MUTED, size: 12 }),
    trailing: icon(icon: "chevron_right", color: TEXT, size: 20),
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

def gallery_back_bar(page, _title = nil)
  # Just a left-aligned back arrow — the shell app bar already shows the title.
  container(height: 48, bgcolor: BG, padding: { left: 4, right: 12 },
    content: row(alignment: "start", spacing: 2, children: [
      icon_button(icon: "arrow_back", on_click: ->(_e) { studio_go(page, "/gallery") })
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
    trailing: icon(icon: "chevron_right", color: TEXT, size: 22),
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
  # Title lives in the (left-aligned) appbar; only a short description stays in
  # the body so the heading isn't duplicated.
  children = [
    container(padding: { top: 14, left: 20, right: 20, bottom: 8 },
              content: text(category[1], style: { color: MUTED, size: 14 })),
    *rows.map { |item| example_row(page, item, slug) }
  ]
  control(:view, route: route_path(page), bgcolor: BG, padding: 0, appbar: top_bar(page, category[0], back: "/gallery"),
    children: [column(expand: true, scroll: "auto", spacing: 0, children: children)])
end

def example_row(page, item, slug)
  list_tile(
    leading: icon(icon: "widgets", color: TEXT),
    title: text(item[:title], style: { color: TEXT, size: 18, weight: "w700" }),
    subtitle: text(item[:description], style: { color: MUTED, size: 14 }),
    trailing: icon(icon: "chevron_right", color: TEXT),
    on_click: ->(_e) { studio_go(page, "/gallery/#{slug}/example/#{item[:slug]}?from=#{CGI.escape("/gallery/#{slug}")}") })
end
