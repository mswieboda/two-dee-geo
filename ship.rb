require 'pry'

require 'gosu'

class Ship < OwnedObject
  attr_reader :window, :shape, :damage, :owner

  SIZE = 5
  ROTATE_SPEED = 0.00333

  def initialize(window, owner)
    super(window, owner, SIZE * 0.75)

    @shape.layers = 0b1
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
    @body.apply_force(CP::Vec2.new(-@body.f.x, -@body.f.y), CP::Vec2.new(0.0, 0.0))
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

      stop if close_to?(move_to_x, move_to_y)
    end
  end

  def auto_rotation
    if @rotate_around_obj
      obj = @rotate_around_obj
      radius = obj.shape.radius

      # Add 180 since Y is negative
      @rotating_angle ||= (TwoDeeGeo.angle_between_points(x, y, obj.x, obj.y) + 180).gosu_to_radians
      @rotating_angle += ROTATE_SPEED;
      new_x = Math.cos(@rotating_angle) * radius;
      new_y = Math.sin(@rotating_angle) * radius;

      jump_to(obj.x + new_x, obj.y + new_y)
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
    @move_to_obj = nil
    @rotating_angle = nil
    @rotate_around_obj = nil
    @move_to_x = x
    @move_to_y = y
  end

  def move_to_obj(obj)
    return if @move_to_obj == obj || @rotate_around_obj == obj
    @move_to_x = nil
    @move_to_y = nil
    @rotating_angle = nil
    @rotate_around_obj = nil
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
