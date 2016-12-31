class MiniMap
  BORDER = 1
  POS_RATIO = 15.0
  SHIP_SIZE_RATIO = 5.0
  BASE_SIZE_RATIO = 12.5
  MARGIN = 15
  VIEWPORT_BORDER = 1

  def initialize(map:, viewport:, bases:, players:)
    @map = map
    @viewport = viewport
    @bases = bases
    @players = players
  end

  def draw
    # Border
    mx1 = 0
    mx2 = @map.width / POS_RATIO
    my1 = 0
    my3 = @map.height / POS_RATIO
    cb = Gosu::Color::GRAY

    mx1 = mx4 = @viewport.width - mx1 - (MARGIN + BORDER)
    mx2 = mx3 = @viewport.width - mx2 - (MARGIN + BORDER)
    my1 = my2 = my1 + MARGIN + BORDER
    my3 = my4 = my3 + MARGIN + BORDER

    c = Gosu::Color::BLACK

    Gosu.draw_quad(mx1 + BORDER, my1 - BORDER, cb, mx2 - BORDER, my2 - BORDER, cb, mx3 - BORDER, my3 + BORDER, cb, mx4 + BORDER, my4 + BORDER, cb)
    Gosu.draw_quad(mx1, my1, c, mx2, my2, c, mx3, my3, c, mx4, my4, c)

    # Viewport
    x1 = x4 = @viewport.x_real / POS_RATIO + mx2
    x2 = x3 = @viewport.x_real / POS_RATIO + @viewport.width_real / POS_RATIO + mx2
    y1 = y2 = @viewport.y_real / POS_RATIO + my1
    y3 = y4 = @viewport.y_real / POS_RATIO + @viewport.height_real / POS_RATIO + my1
    cb = Gosu::Color::WHITE

    Gosu.draw_quad(x1, y1, cb, x2, y2, cb, x3, y3, cb, x4, y4, cb)
    Gosu.draw_quad(x1 + VIEWPORT_BORDER, y1 + VIEWPORT_BORDER, c, x2 - VIEWPORT_BORDER, y2 + VIEWPORT_BORDER, c, x3 - VIEWPORT_BORDER, y3 - VIEWPORT_BORDER, c, x4 + VIEWPORT_BORDER, y4 - VIEWPORT_BORDER, c)

    # Bases
    @bases.each do |base|
      x1 = x3 = base.x / POS_RATIO + mx2
      x2 = base.x / POS_RATIO + base.size / BASE_SIZE_RATIO + mx2
      x4 = base.x / POS_RATIO - base.size / BASE_SIZE_RATIO + mx2
      y1 = base.y / POS_RATIO - base.size / BASE_SIZE_RATIO + my1
      y2 = y4 = base.y / POS_RATIO + my1
      y3 = base.y / POS_RATIO + base.size / BASE_SIZE_RATIO + my1
      c = base.owner.color

      Gosu.draw_quad(x1, y1, c, x2, y2, c, x3, y3, c, x4, y4, c)
    end

    # Ships
    @players.flat_map(&:ships).each do |ship|
      x1 = ship.x / POS_RATIO + ship.size / SHIP_SIZE_RATIO + mx2
      x2 = ship.x / POS_RATIO + mx2
      x3 = ship.x / POS_RATIO - ship.size / SHIP_SIZE_RATIO + mx2
      y1 = y3 = ship.y / POS_RATIO + my1
      y2 = ship.y / POS_RATIO - ship.size * 2 / SHIP_SIZE_RATIO + my1
      c = ship.owner.color

      Gosu.draw_triangle(x1, y1, c, x2, y2, c, x3, y3, c)
      Gosu.draw_triangle(x1, y1, c, x2, y2 + ship.size * 3 / SHIP_SIZE_RATIO, c, x3, y3, c)
    end
  end
end
