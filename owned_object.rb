class OwnedObject
  attr_reader :window

  def initialize(window, owner, size)
    @window = window
    @owner = owner
    @size = size

    # Body
    @body = CP::Body.new(10, 100)

    # Shape
    @shape = CP::Shape::Circle.new(@body, size, CP::Vec2.new(0, 0))
    @shape.e = 0.5
    @shape.u = 1

    @window.space.add_body(@body)
    @window.space.add_shape(@shape)
  end

  def size
    @size
  end

  def jump_to(x, y)
    @body.p.x = x
    @body.p.y = y
  end

  def draw
    raise NotImplementedError
  end

  def convert_to(obj)
    @owner = obj.owner
  end

  def x
    @body.p.x
  end

  def y
    @body.p.y
  end

  def angle
    @body.a
  end

  def close_to?(x2, y2, gap = 0)
    gap += size
    (x - x2).abs <= gap && (y - y2).abs <= gap
  end
end
