require 'pry'

require 'gosu'

class Base < OwnedObject
  attr_reader :window, :shape, :owner, :health

  SIZE = 10 * 5
  INNER_SIZE_RATIO = 1.25
  TEXT_SIZE = (SIZE * 0.6).round
  TEXT_FONT = "Courier New"
  MAX_REGENERATION = 10

  def initialize(window, owner)
    super(window, owner, SIZE * 2)

    @body.m = 99999
    @shape.object = self
    @shape.collision_type = :base


    # Health
    @health_text = Gosu::Font.new(TEXT_SIZE, name: TEXT_FONT)
    @health = @max_health = 1000
    @health_regeneration_amount = @health_ticks = 0

    # Ship generation
    @ship_generation_amount = @ship_ticks = 0
  end

  def size
    SIZE
  end

  def draw
    x1 = x3 = x
    x2 = x + size
    x4 = x - size
    y1 = y - size
    y2 = y4 = y
    y3 = y + size
    c = @owner.color

    Gosu.draw_quad(x1, y1, c, x2, y2, c, x3, y3, c, x4, y4, c)

    # Inner diamond
    ix1 = ix3 = x
    ix2 = x + size / INNER_SIZE_RATIO
    ix4 = x - size / INNER_SIZE_RATIO
    iy1 = y - size / INNER_SIZE_RATIO
    iy2 = iy4 = y
    iy3 = y + size / INNER_SIZE_RATIO
    ic = Gosu::Color::BLACK

    Gosu.draw_quad(ix1, iy1, ic, ix2, iy2, ic, ix3, iy3, ic, ix4, iy4, ic)

    @health_text.draw_rel(health.to_i, x1, y1 + size - TEXT_SIZE / 2, 0, 0.5, 0, 1, 1, c)
  end

  def take_damage(obj)
    @taking_damage = true
    @health -= obj.damage

    if health <= 0
      convert_to(obj)
      @health = 0
      @taking_damage = false
    end
  end

  def idle
    @taking_damage = false
  end

  def regenerate_health
    return if @taking_damage

    if health >= @max_health
      @health = @max_health
      return
    end

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

    if @ship_ticks > 500 - @ship_generation_amount && @health > 0
      @owner.generate_ship(self)
      @ship_ticks = 0
    end
  end
end
