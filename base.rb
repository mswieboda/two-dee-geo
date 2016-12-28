require 'pry'

require 'gosu'

class Base
  attr_reader :window, :x, :y, :width, :height, :owner

  SIZE = 10 * 5
  TEXT_SIZE = 30
  MAX_REGENERATION = 10

  def initialize(window, owner)
    @window = window

    @x = @y = @vel_x = @vel_y = 0.0

    @height = SIZE
    @width = SIZE

    @owner = owner

    @health_text = Gosu::Font.new(TEXT_SIZE, name: "Courier New")
    @health = @max_health = 1000
    @health_regeneration_amount = @health_ticks = 0
    @ship_generation_amount = @ship_ticks = 0
  end

  def jump_to(new_x, new_y)
    @x = new_x
    @y = new_y
  end

  def draw
    x1 = x3 = @x
    x2 = @x + width
    x4 = @x - width
    y1 = @y - height
    y2 = y4 = @y
    y3 = @y + height
    c = @owner.color

    Gosu.draw_quad(x1, y1, c, x2, y2, c, x3, y3, c, x4, y4, c)

    # Inner diamond
    inner_size = 1.125
    ix1 = ix3 = @x
    ix2 = @x + width / inner_size
    ix4 = @x - width / inner_size
    iy1 = @y - height / inner_size
    iy2 = iy4 = @y
    iy3 = @y + height / inner_size
    ic = Gosu::Color::BLACK

    Gosu.draw_quad(ix1, iy1, ic, ix2, iy2, ic, ix3, iy3, ic, ix4, iy4, ic)
    @health_text.draw_rel(@health.to_i, x1, y1 + height - TEXT_SIZE / 2, 0, 0.5, 0, 1, 1, c)
  end

  def collides?(x, y, gap = 0)
    (@x - x).abs <= width / 2 && (@y - y).abs <= height / 2
  end

  def take_damage(obj)
    @taking_damage = true
    @health -= obj.damage

    if @health <= 0
      convert_to(obj)
    end
  end

  def idle
    @taking_damage = false
  end

  def regenerate_health
    return if @health == @max_health || @taking_damage
    @health_ticks += 1
    if @health_ticks > 100 - @health_regeneration_amount
      @health += 1
      @health_ticks = 0
    end
  end

  def convert_to(obj)
    @owner = obj.owner
  end

  def increase_regeneration
    return if @health_regeneration_amount + 1 > MAX_REGENERATION
    @health_regeneration_amount += 1
  end

  def generate_ships
    @ship_ticks += 1
    if @ship_ticks > 100 - @ship_generation_amount
      @owner.generate_ship(self)
      @ship_ticks = 0
    end
  end
end
