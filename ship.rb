class Ship < OwnedObject
  include Health

  attr_reader :window, :shape, :damage, :owner, :ship_range

  SIZE = 5
  SPEED = 0.5
  ROTATE_SPEED = 0.00333
  SHIP_RANGE = 10

  def initialize(window, owner)
    super(window, owner, SIZE * 0.75)

    @shape.layers = 0b11
    @shape.object = self
    @shape.collision_type = :ship

    # Range attack shape
    @shape_range = CP::Shape::Circle.new(@body, size * SHIP_RANGE, CP::Vec2.new(0, 0))
    @shape_range.layers = 0b01
    @shape_range.object = self
    @shape_range.collision_type = :ship_range
    window.space.add_shape(@shape_range)

    @damage = 1
    @facing_angle = nil
    init_health(100)
  end

  def size
    SIZE
  end

  def accelerate
    @body.apply_force(@body.a.radians_to_vec2 * SPEED, CP::Vec2.new(0.0, 0.0))
  end

  def stop
    @body.apply_force(CP::Vec2.new(-@body.f.x, -@body.f.y), CP::Vec2.new(0.0, 0.0))
  end

  def move
    auto_movement
    auto_rotation
    auto_attack

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

      if close_to?(move_to_x, move_to_y, size * 3)
        stop
      else
        accelerate
      end
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
    end
  end

  def auto_attack
    if @attack_ship
      @facing_angle = TwoDeeGeo.angle_between_points(x, y, @attack_ship.x, @attack_ship.y)
      attack(@attack_ship)
    elsif @attack_base
      if @attack_base.health <= 0 || owner.owns?(@attack_base)
        stop_attacking_base
      else
        attack(@attack_base)
      end
    end
  end

  def take_damage_from(obj)
    take_damage(obj.damage) do
      @destroy = true
    end
  end

  def attack_ship(obj)
    @attack_ship = obj
  end

  def stop_attacking_ship
    @attack_ship = nil
    @facing_angle = nil
  end

  def attack_base(obj)
    @attack_base = obj unless owner.owns?(obj)
    stop
    rotate_around(obj)
  end

  def stop_attacking_base
    @attack_base = nil
  end

  def attack(obj)
    obj.take_damage_from(self)
  end

  def move_to_coords(x, y)
    clear_orders
    @move_to_x = x
    @move_to_y = y
  end

  def move_to_obj(obj)
    return if @move_to_obj == obj || @rotate_around_obj == obj
    clear_orders
    @move_to_obj = obj
  end

  def moving_to?(obj)
    return false unless obj
    @move_to_obj == obj || @rotate_around_obj == obj
  end

  def rotate_around(obj)
    clear_moving_orders
    @rotate_around_obj = obj
  end

  def clear_orders
    clear_moving_orders
    @attack_base = nil
  end

  def clear_moving_orders
    @move_to_x = nil
    @move_to_y = nil
    @move_to_obj = nil
    @rotating_angle = nil
    @rotate_around_obj = nil
  end

  def facing_angle
    if @facing_angle
      @facing_angle
    else
      angle
    end
  end

  def destroy?
    !!@destroy
  end

  def remove_from_owner
    owner.remove_ship(self)
  end

  def draw
    x1 = x + size
    x2 = x
    x3 = x - size
    y1 = y3 = y
    y2 = y - size * 2
    c = owner.color
    Gosu.rotate(facing_angle, x, y - size) do
      Gosu.draw_triangle(x1, y1, c, x2, y2, c, x3, y3, c)
      Gosu.draw_triangle(x1, y1, c, x2, y2 + size * 3, c, x3, y3, c)
    end

    # Draw bullet line attacking ship
    if @attack_ship
      Gosu.draw_line(x, y, c, @attack_ship.x, @attack_ship.y, c)
    end

    # Draw bullet line attacking base
    if @attack_base
      Gosu.draw_line(x, y, c, @attack_base.x, @attack_base.y, c)
    end
  end
end
