require 'pry'

require 'gosu'

class Base
  attr_reader :window
  attr_reader :x, :y, :width, :height

  SIZE = 10

  def initialize(window)
    @window = window

    @x = @y = @vel_x = @vel_y = 0.0

    @height = SIZE
    @width = SIZE

    @c = Gosu::Color::AQUA
  end

  def jump_to(new_x, new_y)
    @x = new_x
    @y = new_y
  end

  def draw
    x1 = @x + width
    x2 = @x
    x3 = @x - width
    x4 = @x
    y1 = y3 = @y
    y2 = @y - height
    y4 = @y + height
    c = @c

    Gosu.draw_quad(x1, y1, c, x2, y2, c, x3, y3, c, x4, y4, c, 0, mode = :default)
  end

  def collides?(x, y, gap = 0)
    (@x - x).abs <= width / 2 && (@y - y).abs <= height / 2
  end
end
