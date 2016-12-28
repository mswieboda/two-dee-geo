require 'pry'

require 'gosu'
require 'chipmunk'
require_relative 'numeric'
require_relative 'player'
require_relative 'owned_object'
require_relative 'ship'
require_relative 'base'

class TwoDeeGeo < Gosu::Window
  attr_accessor :space

  SUBSTEPS = 6

  def initialize
    super(Gosu::available_width, Gosu::available_height, false)
    self.caption = 'Two-Dee Geo!'


    @space = CP::Space.new
    @space.damping = 0.8
    # @space.gravity = CP::Vec2.new(0, 10)
    @dt = (1.0/60.0)

    @players = []
    @player = Player.new(Gosu::Color::GREEN)
    @players << @player

    enemy = Player.new(Gosu::Color::FUCHSIA)
    @players << enemy

    @bases = []
    @player_base = base = Base.new(self, @player)
    base.jump_to(width / 2, height / 10)
    @bases << base

    base = Base.new(self, enemy)
    base.jump_to(width / 2, height - height / 10)
    @bases << base

    @space.add_collision_func(:ship, :base) do |ship_shape, base_shape|
      ship = ship_shape.object
      base = base_shape.object

      if ship.owner.owns?(base)
        nil
      else
        # Stop
        ship.stop

        # Set to attack base
        ship.attack_base(base)

        true
      end
    end

    @space.add_collision_func(:base, :base, &nil)
  end

  def needs_cursor?; true; end

  def update
    SUBSTEPS.times do
      # Idle bases reset to regenerate if not being shot at
      @bases.each(&:idle)

      # Player mouse click event
      if button_down?(Gosu::MsLeft)
        base = clicked_base

        if base
          @player.ships.each { |s| s.move_to_obj(base) }
        else
          @player.ships.each { |s| s.move_to_coords(mouse_x, mouse_y) }
        end
      end

      # Move all ships
      @players.flat_map(&:ships).each do |ship|
        # Reset phyics for ship
        ship.shape.body.reset_forces
        ship.move
      end

      # Base regeneration
      @bases.each(&:increase_regeneration) if button_down?(Gosu::KbSpace)
      @bases.each(&:regenerate_health)
      @bases.each(&:generate_ships)

      @space.step(@dt)
    end

    if button_down?(Gosu::KbSpace)
      @owner.generate_ship(@player_base)
    end
  end

  def draw
    @bases.each(&:draw)
    @players.flat_map(&:ships).each(&:draw)
  end

  def button_down(id)
    close if id == Gosu::KbEscape
  end

  def clicked_base
    x = mouse_x
    y = mouse_y

    bases = @bases.select do |base|
      false # base.collides?(x, y)
    end

    bases.any? ? bases.first : nil
  end

  private

  def self.angle_between_points(x1, y1, x2, y2)
    dy = -y2 - -y1
    dx = x2 - x1
    radians = Math.atan2(dy, dx)
    degrees = radians * 180 / Math::PI
    360 - degrees + 90
  end

  # def self.draw_circle(x0, y0, radius, c, thickness)
  #   x = radius
  #   y = 0
  #   err = 0

  #   while x >= y do
  #     [
  #       { x: x0 + x, y: y0 + y },
  #       { x: x0 + y, y: y0 + x },
  #       { x: x0 - y, y: y0 + x },
  #       { x: x0 - x, y: y0 + y },
  #       { x: x0 - x, y: y0 - y },
  #       { x: x0 - y, y: y0 - x },
  #       { x: x0 + y, y: y0 - x },
  #       { x: x0 + x, y: y0 - y }
  #     ].each do |point|
  #       draw_pixel(point[:x], point[:y], c, thickness)
  #     end

  #     if err <= 0
  #       y += 1;
  #       err += 2*y + 1
  #     else
  #       x -= 1;
  #       err -= 2*x + 1
  #     end
  #   end
  # end

  # def self.draw_pixel(x, y, c, thickness = 1)
  #   Gosu.draw_line(x, y, c, x + 1, y, c, 0, mode = :default)
  # end
end

window = TwoDeeGeo.new
window.show
