require 'pry'

require 'gosu'

class Player
  attr_reader :color, :ships

  def initialize(color)
    @color = color
    @damage = 0.01
    @ships = []
    @max_ships = 50
  end

  def owns?(obj)
    self == obj.owner
  end

  def generate_ship(base)
    return if @ships.size >= @max_ships

    ship = Ship.new(base.window, self)

    angle = rand(0..360)
    radians = angle.gosu_to_radians
    new_x = Math.cos(radians) * base.shape.radius;
    new_y = Math.sin(radians) * base.shape.radius;

    ship.shape.body.a = angle
    ship.jump_to(base.x + new_x, base.y + new_y)

    @ships << ship
  end

  def remove_ship(ship)
    @ships.delete(ship)
  end
end
