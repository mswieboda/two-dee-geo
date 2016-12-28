require 'pry'

require 'gosu'

class Ship < OwnedObject
  attr_reader :window, :shape, :damage, :owner

  SIZE = 5
  ROTATE_SPEED = 0.333

  def initialize(window, owner)
    super(window, owner, SIZE * 0.75)

    @shape.object = self
    @shape.collision_type = :ship

    @damage = 0.01
  end

  def size
    SIZE
  end

  def accelerate
    @body.apply_force(@body.a.radians_to_vec2, CP::Vec2.new(0.0, 0.0))
  end

  def stop
    @body.apply_force(CP::Vec2.new(0.0, 0.0), CP::Vec2.new(0.0, 0.0))
  end

  def move
    auto_movement
    auto_rotation

    @body.p.x += @body.f.x
    @body.p.y += @body.f.y

    @body.p.x %= window.width
    @body.p.y %= window.height
  end

  def auto_movement
    if @move_to_x && @move_to_y
      move_to_x = @move_to_x
      move_to_y = @move_to_y
    elsif @move_to_obj
      move_to_x = @move_to_obj.x
      move_to_y = @move_to_obj.y
    end

    if move_to_x && move_to_y
      @body.a = TwoDeeGeo.angle_between_points(x, y, move_to_x, move_to_y)
      accelerate
    end
  end

  def auto_rotation
    if @rotate_around_obj
      obj = @rotate_around_obj

      dx = dy = 0.0

      if x <= obj.x + obj.size / 0.75 &&
        y <= obj.y - obj.size / 0.75
        dx = 1
      elsif x >= obj.x + obj.size / 0.75 &&
        y <= obj.y + obj.size / 0.75
        dy = 1
      elsif x >= obj.x - obj.size / 0.75 &&
        y >= obj.y + obj.size / 0.75
        dx = -1
      elsif x <= obj.x - obj.size / 0.75 &&
        y >= obj.y - obj.size / 0.75
        dy = -1
      elsif x <= obj.x - obj.size / 0.75 &&
        y <= obj.y - obj.size / 0.75
        dx = -1
      end

      @body.a = CP::Vec2.new(dx, dy).to_angle
      @body.apply_force(@body.a.radians_to_vec2 * ROTATE_SPEED, CP::Vec2.new(0.0, 0.0))
      @body.a = TwoDeeGeo.angle_between_points(x, y, obj.x, obj.y)

      attack(obj) unless obj.health <= 0 || owner.owns?(obj)
    end
  end

  def attack_base(obj)
    rotate_around(obj)
  end

  def attack(obj)
    obj.take_damage(self)
  end

  def move_to_coords(x, y)
    @rotate_around_obj = nil
    @move_to_obj = nil
    @move_to_x = x
    @move_to_y = y
  end

  def move_to_obj(obj)
    @rotate_around_obj = nil
    @move_to_x = nil
    @move_to_y = nil
    @move_to_obj = obj
  end

  def moving_to?(obj)
    return false unless obj
    @move_to_obj == obj || @rotate_around_obj == obj
  end

  def rotate_around(obj)
    @move_to_x = nil
    @move_to_y = nil
    @move_to_obj = nil
    @rotate_around_obj = obj
  end

  def draw
    x1 = x + size
    x2 = x
    x3 = x - size
    y1 = y3 = y
    y2 = y - size * 2
    c = @owner.color
    Gosu.rotate(angle, x, y - size) do
      Gosu.draw_triangle(x1, y1, c, x2, y2, c, x3, y3, c, 0)
      Gosu.draw_triangle(x1, y1, c, x2, y2 + size * 3, c, x3, y3, c, 0)
    end
  end
end
