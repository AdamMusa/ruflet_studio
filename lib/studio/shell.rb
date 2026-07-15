# frozen_string_literal: true

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
    # iOS centers the title by default; keep it left-aligned next to the back button.
    center_title: false,
    leading: back ? icon_button(icon: "arrow_back", on_click: ->(_e) { studio_go(page, back) }) : nil,
    title: title_control,
    actions: actions + [icon_button(icon: "account_circle", on_click: ->(_e) { studio_go(page, "/settings/system") })]
  )
end

def desktop_shell(page, title, active, body)
  control(:view, route: route_path(page), bgcolor: BG, padding: 0, appbar: top_bar(page, title),
    children: [
      row(expand: true, spacing: 0, children: [
        nav_rail(page, active),
        container(width: 1, bgcolor: BORDER),
        container(expand: true, content: body)
      ])
    ])
end

def mobile_shell(page, title, active, body)
  control(:view, route: route_path(page), bgcolor: BG, padding: 0, appbar: top_bar(page, title),
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
        on_click: ->(_e) { show_sign_in_dialog(page) }, content: icon(icon: "add", color: TEXT, size: 24))),
    rail_item(page, "Apps", "grid_view", "/apps", active == "apps"),
    rail_item(page, "Gallery", "image", "/gallery", active == "gallery")
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
    bottom_tab(page, "Apps", "grid_view", "/apps", active == "apps"),
    bottom_tab(page, "Gallery", "image", "/gallery", active == "gallery")
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
        icon(icon: "login"),
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
        icon_button(icon: "close", icon_color: MUTED, on_click: ->(_e) { studio_go(page, "/apps") })
      ]),
      text("Sign in to create apps, save versions, and access your work from anywhere.", style: { color: TEXT, size: 17 }),
      text("By signing in to Ruflet Studio, you agree to our Terms of Service and Privacy Policy.", style: { color: MUTED, size: 14 }),
      sign_button("Sign in with GitHub", "code"),
      sign_button("Sign in with Google", "g_mobiledata"),
      sign_button("Sign in with Microsoft", "grid_view")
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
