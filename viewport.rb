class Viewport
  attr_accessor :width, :height, :x, :y

  AMOUNT = 2

  def initialize(map, width, height, init_x = 0, init_y = 0)
    @map = map
    @width = width
    @height = height
    @x = init_x
    @y = init_y
  end

  def jump_to(new_x, new_y)
    if new_x + width > map.width
      @x = @map.width - width
    elsif new_x < 0
      @x = 0
    else
      @x = new_x
    end

    if new_y + height > @map.height
      @y = @map.height - height
    elsif new_y < 0
      @y = 0
    else
      @y = new_y
    end
  end

  def move_x(dx)
    if x + dx + width > @map.width
      @x = @map.width - width
    elsif x + dx < 0
      @x = 0
    else
      @x += dx
    end
  end

  def move_y(dy)
    if y + dy + height > @map.height
      @y = @map.height - height
    elsif y + dy < 0
      @y = 0
    else
      @y += dy
    end
  end

  def move
    if Gosu.button_down?(Gosu::KbRight)
      move_x(AMOUNT)
    end

    if Gosu.button_down?(Gosu::KbLeft)
      move_x(-AMOUNT)
    end

    if Gosu.button_down?(Gosu::KbDown)
      move_y(AMOUNT)
    end

    if Gosu.button_down?(Gosu::KbUp)
      move_y(-AMOUNT)
    end
  end

  def visible?(x_coords, y_coords)
    x_visible = x_coords.any? do |x_coord|
      x_coord > x && x_coord < x + width
    end

    y_visible = y_coords.any? do |y_coord|
      y_coord > y && y_coord < y + height
    end

    x_visible && y_visible
  end

  # Drawing helpers
  def draw_line(x1, y1, c1, x2, y2, c2)
    return unless visible?([x1, x2], [y1, y2])
    Gosu.draw_line(x1 - x, y1 - y, c1, x2 - x, y2 - y, c2)
  end

  def draw_quad(x1, y1, c1, x2, y2, c2, x3, y3, c3, x4, y4, c4)
    return unless visible?([x1, x2, x3, x4], [y1, y2, y3, y4])
    Gosu.draw_quad(x1 - x, y1 - y, c1, x2 - x, y2 - y, c2, x3 - x, y3 - y, c3, x4 - x, y4 - y, c4)
  end

  def draw_triangle(x1, y1, c1, x2, y2, c2, x3, y3, c3)
    return unless visible?([x1, x2, x3], [y1, y2, y3])
    Gosu.draw_triangle(x1 - x, y1 - y, c1, x2 - x, y2 - y, c2, x3 - x, y3 - y, c3)
  end

  def draw_rotated(angle, x_origin, y_origin)
    Gosu.rotate(angle, x_origin - x, y_origin - y) do
      yield
    end
  end

  def draw_font_rel(font, text, x1, y1, z, x_rel, y_rel, x_scale, y_scale, c)
    # TODO: needs to include x_rel and y_rel
    x2 = x1 + font.text_width(text) * x_scale
    y2 = y1 + font.height * y_scale
    return unless visible?([x1, x2], [y1, y2])
    font.draw_rel(text, x1 - x, y1 - y, z, x_rel, y_rel, x_scale, y_scale, c)
  end
end
