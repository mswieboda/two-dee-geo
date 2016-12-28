require 'pry'

require 'gosu'

class ClickVisual < OwnedObject
  attr_reader :window, :shape, :owner

  SIZE = 10 * 3
  INNER_SIZE_RATIO = 1.25
  ANIMATION_FRAMES = 250

  def initialize(window, owner, x, y)
    super(window, owner, SIZE)

    @shape.layers = 0b0

    @frame_ticks = 0

    jump_to(x, y)
  end

  def update
    @frame_ticks += 1

    if @frame_ticks >= ANIMATION_FRAMES
      @destroy = true
    end
  end

  def destroy?
    @destroy == true
  end

  def draw
    @frame = (@frame_ticks / 50 % ANIMATION_FRAMES) + 1

    if @frame > 3
      x1 = x3 = x
      x2 = x + size / (@frame - 3)
      x4 = x - size / (@frame - 3)
      y1 = y - size / (@frame - 3)
      y2 = y4 = y
      y3 = y + size / (@frame - 3)
      c = @owner.color

      # Inner diamond
      ix1 = ix3 = x
      ix2 = x + size / (@frame - 3) / INNER_SIZE_RATIO
      ix4 = x - size / (@frame - 3) / INNER_SIZE_RATIO
      iy1 = y - size / (@frame - 3) / INNER_SIZE_RATIO
      iy2 = iy4 = y
      iy3 = y + size / (@frame - 3) / INNER_SIZE_RATIO
      ic = Gosu::Color::BLACK

      Gosu.draw_quad(x1, y1, c, x2, y2, c, x3, y3, c, x4, y4, c)
      Gosu.draw_quad(ix1, iy1, ic, ix2, iy2, ic, ix3, iy3, ic, ix4, iy4, ic)
    end

    x1 = x3 = x
    x2 = x + size / @frame
    x4 = x - size / @frame
    y1 = y - size / @frame
    y2 = y4 = y
    y3 = y + size / @frame
    c = @owner.color

    # Inner diamond
    ix1 = ix3 = x
    ix2 = x + size / @frame / INNER_SIZE_RATIO
    ix4 = x - size / @frame / INNER_SIZE_RATIO
    iy1 = y - size / @frame / INNER_SIZE_RATIO
    iy2 = iy4 = y
    iy3 = y + size / @frame / INNER_SIZE_RATIO
    ic = Gosu::Color::BLACK

    Gosu.draw_quad(x1, y1, c, x2, y2, c, x3, y3, c, x4, y4, c)
    Gosu.draw_quad(ix1, iy1, ic, ix2, iy2, ic, ix3, iy3, ic, ix4, iy4, ic)

  end
end
