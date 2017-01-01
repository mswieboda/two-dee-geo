class Viewport
  attr_accessor :width, :height, :x, :y, :zoom

  PAN_AMOUNT = 4
  ZOOM_AMOUNT = 1
  ZOOM_MAX = 5

  def initialize(map, width, height, init_x = 0, init_y = 0)
    @map = map
    @width = width
    @height = height
    @x = init_x
    @y = init_y
    @zoom = 1
    @font = Gosu::Font.new(25, name: "Courier New")
  end

  def x_real
    x / zoom
  end

  def y_real
    y / zoom
  end

  def width_real
    width / zoom
  end

  def height_real
    height / zoom
  end

  def mouse_x(mouse_x)
    x_real + mouse_x / zoom
  end

  def mouse_y(mouse_y)
    y_real + mouse_y / zoom
  end

  def zoom_in
    return if @zoom + 1 > ZOOM_MAX

    center_x = (x + (width / 2.0).round) / @zoom
    center_y = (y + (height / 2.0).round) / @zoom

    @zoom += ZOOM_AMOUNT

    center_x *= @zoom
    center_y *= @zoom

    center_x -= width / 2
    center_y -= height / 2

    jump_to(center_x, center_y)
  end

  def zoom_out
    return if @zoom - 1 <= 0

    center_x = (x + (width / 2.0).round) / @zoom
    center_y = (y + (height / 2.0).round) / @zoom

    @zoom -= ZOOM_AMOUNT

    center_x *= @zoom
    center_y *= @zoom

    center_x -= width / 2
    center_y -= height / 2

    jump_to(center_x, center_y)
  end

  def jump_to(new_x, new_y)
    if new_x + width * @zoom > @map.width * @zoom
      @x = @map.width * @zoom - width * @zoom
    elsif new_x < 0
      @x = 0
    else
      @x = new_x
    end

    if new_y + height * @zoom > @map.height * @zoom
      @y = @map.height * @zoom - height * @zoom
    elsif new_y < 0
      @y = 0
    else
      @y = new_y
    end
  end

  def pan_x(dx)
    if x + dx + width > @map.width * @zoom
      @x = @map.width * @zoom - width
    elsif x + dx < 0
      @x = 0
    else
      @x += dx
    end
  end

  def pan_y(dy)
    if y + dy + height > @map.height * @zoom
      @y = @map.height * @zoom - height
    elsif y + dy * @zoom < 0
      @y = 0
    else
      @y += dy
    end
  end

  def pan
    if Gosu.button_down?(Gosu::KbD)
      pan_x(PAN_AMOUNT)
    end

    if Gosu.button_down?(Gosu::KbA)
      pan_x(-PAN_AMOUNT)
    end

    if Gosu.button_down?(Gosu::KbS)
      pan_y(PAN_AMOUNT)
    end

    if Gosu.button_down?(Gosu::KbW)
      pan_y(-PAN_AMOUNT)
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

  def draw
    c = Gosu::Color::WHITE
    center_x = (width / 2.0).round
    center_y = (height / 2.0).round
    text = "origin: (#{x}, #{y}) center: (#{x + center_x}, #{y + center_y}) zoom: x#{@zoom}"
    @font.draw_rel(text, 0, 0, 0, 0, 0, 1, 1, c)

    Gosu.draw_line(center_x - 5, center_y, c, center_x + 5, center_y, c)
    Gosu.draw_line(center_x, center_y - 5, c, center_x, center_y + 5, c)
  end

  # Drawing helpers
  def draw_line(x1, y1, c1, x2, y2, c2)
    x1 *= @zoom
    y1 *= @zoom
    x2 *= @zoom
    y2 *= @zoom

    return unless visible?([x1, x2], [y1, y2])
    Gosu.draw_line(x1 - x, y1 - y, c1, x2 - x, y2 - y, c2)
  end

  def draw_quad(x1, y1, c1, x2, y2, c2, x3, y3, c3, x4, y4, c4)
    x1 *= @zoom
    y1 *= @zoom
    x2 *= @zoom
    y2 *= @zoom
    x3 *= @zoom
    y3 *= @zoom
    x4 *= @zoom
    y4 *= @zoom

    return unless visible?([x1, x2, x3, x4], [y1, y2, y3, y4])
    Gosu.draw_quad(x1 - x, y1 - y, c1, x2 - x, y2 - y, c2, x3 - x, y3 - y, c3, x4 - x, y4 - y, c4)
  end

  def draw_triangle(x1, y1, c1, x2, y2, c2, x3, y3, c3)
    x1 *= @zoom
    y1 *= @zoom
    x2 *= @zoom
    y2 *= @zoom
    x3 *= @zoom
    y3 *= @zoom

    return unless visible?([x1, x2, x3], [y1, y2, y3])
    Gosu.draw_triangle(x1 - x, y1 - y, c1, x2 - x, y2 - y, c2, x3 - x, y3 - y, c3)
  end

  def draw_rotated(angle, x_origin, y_origin)
    x_origin *= @zoom
    y_origin *= @zoom

    Gosu.rotate(angle, x_origin - x, y_origin - y) do
      yield
    end
  end

  def draw_font_rel(font, text, x1, y1, z, x_rel, y_rel, x_scale, y_scale, c)
    # TODO: needs to include x_rel and y_rel
    x1 *= @zoom
    y1 *= @zoom
    x2 = x1 + font.text_width(text) * x_scale * @zoom
    y2 = y1 + font.height * y_scale * @zoom

    if font.height != font.height * @zoom
      font = Gosu::Font.new(font.height * @zoom, name: font.name)
    end

    return unless visible?([x1, x2], [y1, y2])
    font.draw_rel(text, x1 - x, y1 - y, z, x_rel, y_rel, x_scale, y_scale, c)
  end
end
