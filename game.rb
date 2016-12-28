require 'pry'

require 'gosu'
require 'chipmunk'
require_relative 'numeric'
require_relative 'player'
require_relative 'owned_object'
require_relative 'ship'
require_relative 'base'

def ppp(hash)
  pp "#{hash}"
end

class TwoDeeGeo < Gosu::Window
  attr_accessor :space

  SUBSTEPS = 6

  def initialize
    super(Gosu::available_width, Gosu::available_height)
    self.caption = 'Two-Dee Geo!'

    @space = CP::Space.new
    @space.damping = 0.7
    @dt = (1.0/60.0)

    @players = []
    @player = Player.new(Gosu::Color::GREEN)
    @players << @player

    @enemy = Player.new(Gosu::Color::FUCHSIA)
    @players << @enemy

    @bases = []
    @player_base = base = Base.new(self, @player)
    base.jump_to(width / 2, height / 10)
    @bases << base

    base = Base.new(self, @enemy)
    base.jump_to(width / 2, height - height / 10)
    @bases << base

    # Just for testing
    @player.generate_ship(@player_base)

    @space.add_collision_func(:ship, :base) do |ship_shape, base_shape|
      ship = ship_shape.object
      base = base_shape.object

      if ship.moving_to?(base)
        # Stop
        ship.stop

        # Set to attack base
        ship.attack_base(base)
      end

      # No physics collision
      nil
    end

    # @space.add_collision_func(:ship, :ship, &nil)
    @space.add_collision_func(:base, :base, &nil)
  end

  def needs_cursor?; true; end

  def update
    SUBSTEPS.times do
      # Idle bases reset to regenerate if not being shot at
      @bases.each(&:idle)

      # Move ships via mouse
      if button_down?(Gosu::MsLeft)
        move_ships(@player)
      elsif button_down?(Gosu::KbSpace)
        move_ships(@enemy)
      end

      # Move all ships
      @players.flat_map(&:ships).each do |ship|
        # Reset phyics for ship
        ship.shape.body.reset_forces
        ship.move
      end

      # Base regeneration
      @bases.each(&:increase_regeneration) if button_down?(Gosu::KbUp)
      @bases.each(&:regenerate_health)
      @bases.each(&:generate_ships)

      @space.step(@dt)
    end
  end

  def draw
    @bases.each(&:draw)
    @players.flat_map(&:ships).each(&:draw)
  end

  def button_up(id)
    if id == Gosu::KbEscape
      close
    end
  end

  def move_ships(player)
    base = clicked_base

    if base
      player.ships.each { |s| s.move_to_obj(base) }
    else
      player.ships.each { |s| s.move_to_coords(mouse_x, mouse_y) }
    end
  end

  def clicked_base
    p = CP::Vec2.new(mouse_x, mouse_y)

    bases = @bases.each do |base|
      if base.shape.point_query(p)
        return base
      end
    end

    nil
  end

  private

  def self.angle_between_points(x1, y1, x2, y2)
    dy = -y2 - -y1
    dx = x2 - x1
    radians = Math.atan2(dy, dx)
    radians.radians_to_gosu
  end
end

window = TwoDeeGeo.new
window.show
