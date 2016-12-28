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

    ship.jump_to(base.x, base.y)
    @ships << ship
  end
end
