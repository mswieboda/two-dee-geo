class Square
  attr_reader :window, :shape, :owner

  SIZE = 100

  def initialize(x, y)
    @x = x
    @y = y
    @c = Gosu::Color::FUCHSIA
  end

  def draw
    x1 = x4 = x
    x2 = x3 = x + size
    y1 = y2 = y
    y3 = y4 = y + size
    c = @c
    window.viewport.draw_quad(x1, y1, c, x2, y2, c, x3, y3, c, x4, y4, c, true)
  end
end