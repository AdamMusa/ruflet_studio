# frozen_string_literal: true

# === gallery/sections_controls/spinkit.rb ===
module Gallery
  module SectionsControls
    # All 30 flet_spinkit variants: [ruflet variant keyword, human label].
    SPINKIT_VARIANTS_GALLERY = [
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
    ].freeze

    SPINKIT_PALETTE = %w[
      #69db7c #74c0fc #ffa94d #b197fc #ff6b6b #3bc9db #f783ac #a9e34b #ffd43b #4dabf7
    ].freeze

    # A labelled grid of every SpinKit variant. Shared by the Apps gallery card
    # (build_spinkit) and the Components > SpinKit detail. Uses a wrapping row so
    # every variant is visible at any width (narrow phones wrap to more runs
    # instead of clipping columns off the right edge).
    def spinkit_gallery(page)
      cells = SPINKIT_VARIANTS_GALLERY.each_with_index.map do |(variant, label), index|
        color = SPINKIT_PALETTE[index % SPINKIT_PALETTE.size]
        # col: 4 of 12 => always 3 per row, cells flex to width (never clipped).
        container(col: 4, content: column(
          horizontal_alignment: "center",
          spacing: 8,
          children: [
            container(height: 52, alignment: "center",
                      content: spinkit(variant => { color: color, size: 38 })),
            text(value: label, style: { size: 11, color: color_subtle(page) })
          ]
        ))
      end

      responsive_row(columns: 12, spacing: 12, run_spacing: 22, children: cells)
    end

    def build_spinkit(page, status)
      column(
        spacing: 16,
        children: [
          status,
          text(value: "All 30 SpinKit loading indicators (flet_spinkit). " \
                      "Call e.g. spinkit(wave: { color: \"#74c0fc\", size: 48 }).",
               style: { size: 13, color: color_subtle(page) }),
          spinkit_gallery(page)
        ]
      )
    end
  end
end
