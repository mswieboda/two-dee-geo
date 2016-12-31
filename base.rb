class Base < OwnedObject
  include Health

  attr_reader :window, :shape, :owner

  SIZE = 10 * 5
  INNER_SIZE_RATIO = 1.25
  TEXT_SIZE = (SIZE * 0.6).round
  TEXT_FONT = "Courier New"
  MAX_HEALTH = 1000
  HEALTH_MULTIPLIER = 100
  MAX_REGENERATION = 10
  HEALTH_REGENERATION_INCREASE = 30
  ROTATE_SPEED = 0.1313
  SHIP_GENERATION_TICKS = 250

  def initialize(window, owner)
    super(window, owner, SIZE * 2)

    @body.m = 99999
    @body.a = 0
    @shape.layers = 0b1
    @shape.object = self
    @shape.collision_type = :base

    # Health
    init_health(MAX_HEALTH * HEALTH_MULTIPLIER)
    @health_text = Gosu::Font.new(TEXT_SIZE, name: TEXT_FONT)
    @health_regeneration_speed = @health_ticks = 0

    # Ship generation
    @ship_generation_amount = @ship_ticks = 0
  end

  def size
    SIZE
  end

  def health_to_display
    (health / HEALTH_MULTIPLIER).round
  end

  def draw
    x1 = x3 = x
    x2 = x + size
    x4 = x - size
    y1 = y - size
    y2 = y4 = y
    y3 = y + size
    c = @owner.color

    # Inner diamond
    ix1 = ix3 = x
    ix2 = x + size / INNER_SIZE_RATIO
    ix4 = x - size / INNER_SIZE_RATIO
    iy1 = y - size / INNER_SIZE_RATIO
    iy2 = iy4 = y
    iy3 = y + size / INNER_SIZE_RATIO
    ic = Gosu::Color::BLACK

    window.viewport.draw_rotated(@body.a, x, y) do
      window.viewport.draw_quad(x1, y1, c, x2, y2, c, x3, y3, c, x4, y4, c)
      window.viewport.draw_quad(ix1, iy1, ic, ix2, iy2, ic, ix3, iy3, ic, ix4, iy4, ic)
    end

    window.viewport.draw_font_rel(@health_text, health_to_display, x1, y1 + size - TEXT_SIZE / 2, 0, 0.5, 0, 1, 1, c)
  end

  def take_damage_from(obj)
    return if obj.health <= 0 || owner.owns?(obj)
    take_damage(obj.damage) do
      convert_to(obj.owner)
    end
  end

  def idle
    @taking_damage = false
    @body.a += ROTATE_SPEED
    @body.a = 0 if @body.a >= 360
  end

  def regenerate_health
    return if @taking_damage

    if health >= @max_health
      @health = @max_health
      return
    end

    @health_ticks += 1
    if @health_ticks > 100 - @health_regeneration_speed
      @health += HEALTH_REGENERATION_INCREASE
      @health_ticks = 0
    end
  end

  def convert_to(owner)
    @owner = owner
    @health = owner.init_base_health
  end

  def increase_regeneration
    return if @health_regeneration_speed + 1 > MAX_REGENERATION
    @health_regeneration_speed += 1
  end

  def generate_ships
    @ship_ticks += 1

    if @ship_ticks > SHIP_GENERATION_TICKS - @ship_generation_amount && @health > 0
      @owner.generate_ship(self)
      @ship_ticks = 0
    end
  end
end
