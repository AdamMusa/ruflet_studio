# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.margin = 0
  page.padding = 0
  page.title = "SpinKit"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"

  variants = [
    [:rotating_circle, "Rotating Circle"],
    [:rotating_plain, "Rotating Plain"],
    [:double_bounce, "Double Bounce"],
    [:wave, "Wave"],
    [:wandering_cubes, "Wandering Cubes"],
    [:fading_four, "Fading Four"],
    [:fading_cube, "Fading Cube"],
    [:pulse, "Pulse"],
    [:chasing_dots, "Chasing Dots"],
    [:three_bounce, "Three Bounce"],
    [:circle, "Circle"],
    [:cube_grid, "Cube Grid"],
    [:fading_circle, "Fading Circle"],
    [:folding_cube, "Folding Cube"],
    [:pumping_heart, "Pumping Heart"],
    [:hour_glass, "Hour Glass"],
    [:pouring_hour_glass, "Pouring Hour Glass"],
    [:pouring_hour_glass_refined, "Pouring Hour Glass Refined"],
    [:fading_grid, "Fading Grid"],
    [:ring, "Ring"],
    [:ripple, "Ripple"],
    [:dual_ring, "Dual Ring"],
    [:spinning_circle, "Spinning Circle"],
    [:spinning_lines, "Spinning Lines"],
    [:square_circle, "Square Circle"],
    [:three_in_out, "Three In Out"],
    [:dancing_square, "Dancing Square"],
    [:piano_wave, "Piano Wave"],
    [:pulsing_grid, "Pulsing Grid"],
    [:wave_spinner, "Wave Spinner"]
  ]
  palette = %w[#69db7c #74c0fc #ffa94d #b197fc #ff6b6b #3bc9db #f783ac #a9e34b #ffd43b #4dabf7]

  cells = []
  variants.each_with_index do |(variant, label), i|
    color = palette[i % palette.size]
    # col: 4 of 12 => always 3 per row, cells flex to width (never clipped).
    cells << container(col: 4, content: column(
      horizontal_alignment: "center",
      spacing: 8,
      children: [
        container(height: 52, alignment: "center",
                  content: spinkit(variant => { color: color, size: 38 })),
        text(label, style: { size: 11, color: "#64748b" })
      ]
    ))
  end

  page.add(
    container(
      expand: true,
      padding: 24,
      content: column(
        scroll: "auto",
        children: [
          responsive_row(columns: 12, spacing: 12, run_spacing: 22, children: cells)
        ]
      )
    )
  )
end
