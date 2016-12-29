class TextDialog
  BORDER = 10
  TEXT_FONT = "Courier New"

  def initialize(window, text, color)
    @window = window
    @text = text
    @color = color
    @text_size = @window.width / 10
    @font = Gosu::Font.new(@text_size, name: TEXT_FONT)
  end

  def draw
    x1 = x4 = @window.width / 5
    x2 = x3 = @window.width - @window.width / 5
    y1 = y2 = @window.height / 5
    y3 = y4 = @window.height - @window.height / 5
    c = @color

    Gosu.draw_quad(x1, y1, c, x2, y2, c, x3, y3, c, x4, y4, c)

    # inner rectangle
    ix1 = ix4 = x1 + BORDER
    ix2 = ix3 = x2 - BORDER
    iy1 = iy2 = y1 + BORDER
    iy3 = iy4 = y3 - BORDER
    ic = Gosu::Color::BLACK
    Gosu.draw_quad(ix1, iy1, ic, ix2, iy2, ic, ix3, iy3, ic, ix4, iy4, ic)

    @font.draw_rel(@text, (x1 + x2) / 2, (y1 + y2) / 2 + @text_size, 0, 0.5, 0, 1, 1, c)
  end
end
