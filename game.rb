require 'pry'
require 'gosu'
require 'chipmunk'
require_relative 'numeric'
require_relative 'player'
require_relative 'owned_object'
require_relative 'click_visual'
require_relative 'health'
require_relative 'ship'
require_relative 'base'
require_relative 'ship_attack_collision_handler'
require_relative 'text_dialog'

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

    @remove_shapes = []
    @click_visuals = []
    @dialog_drawables = []

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

    # Collision handling
    @space.add_collision_func(:ship, :base) do |ship_shape, base_shape|
      ship = ship_shape.object
      base = base_shape.object

      if ship.moving_to?(base)
        if ship.owner.owns?(base)
          ship.rotate_around(base)
        else
          ship.attack_base(base)
        end
      else
        # TODO: make rotating around work
        # if base is in the way
        # ship.rotate_around(base)
      end

      # No physics collision
      nil
    end

    ship_attack_collision_handler = ShipAttackCollisionHandler.new
    @space.add_collision_handler(:ship_range, :ship, ship_attack_collision_handler)
    @space.add_collision_func(:base, :base, &nil)
    @space.add_collision_func(:ship_range, :base, &nil)
    @space.add_collision_func(:ship_range, :ship_range, &nil)
  end

  def needs_cursor?; true; end

  def update
    SUBSTEPS.times do
      return if done?
      win if win?
      lose if lost?

      @remove_shapes.each do |shape|
        @click_visuals.delete_if { |cv| cv.shape == shape }
        @space.remove_body(shape.body) if shape.body
        @space.remove_shape(shape)
      end

      # Idle bases reset to regenerate if not being shot at
      # And also makes them spin / animate
      @bases.each(&:idle)

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

      # Remove click visuals that are finished
      @click_visuals.each(&:update)
      cvs_to_remove = @click_visuals.select(&:destroy?).map(&:shape)
      @remove_shapes += cvs_to_remove if cvs_to_remove.any?

      # # Remove dead ships
      ships_to_remove = @players.flat_map(&:ships).select(&:destroy?).compact
      ships_to_remove.each do |ship|
        ship.owner.remove_ship(ship)
      end

      # Remove ship shapes
      ships_to_remove = ships_to_remove.flat_map do |ship|
        [ship.shape, ship.ship_range]
      end.compact

      @remove_shapes += ships_to_remove if ships_to_remove.any?

      @space.step(@dt)
    end
  end

  def draw
    @bases.each(&:draw)
    @click_visuals.each(&:draw)
    @players.flat_map(&:ships).each(&:draw)
    @dialog_drawables.each(&:draw)
  end

  def button_up(id)
    if id == Gosu::KbEscape
      close
    elsif id == Gosu::MsLeft
      move_ships(@player)
    elsif id == Gosu::KbSpace
      move_ships(@enemy)
    end
  end

  def move_ships(player)
    base = clicked_base

    if base
      player.ships.each { |s| s.move_to_obj(base) }
    else
      player.ships.each { |s| s.move_to_coords(mouse_x, mouse_y) }

      # Create visual
      @click_visuals << ClickVisual.new(self, player, mouse_x, mouse_y)
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

  def win?
    @bases.all? { |b| b.owner == @player }
  end

  def win
    @done = true
    Thread.new do
      sleep 1
      @dialog_drawables << TextDialog.new(self, "You win!", @player.color)
      sleep 3
      close
    end
  end

  def lost?
    @bases.none? { |b| b.owner == @player }
  end

  def lose
    @done = true
    Thread.new do
      sleep 1
      @dialog_drawables << TextDialog.new(self, "You lost!", @player.color)
      sleep 3
      close
    end
  end

  def done?
    !!@done
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
