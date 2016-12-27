require 'pry'

require 'gosu'
require_relative 'player'

class TwoDeeGeo < Gosu::Window
  def initialize
    super(Gosu::available_width, Gosu::available_height, false)
    self.caption = 'Two-Dee Geo!'
    # @background_image = Gosu::Image.new(self, "media/space.jpg", true)

    @player = Player.new(self)
    # @player.jump_to(width / 2, height - height / 10)
    @player.jump_to(width / 2, height / 2)
  end

  def needs_cursor?; true; end

  def update
    @player.turn_left if button_down?(Gosu::KbLeft)
    @player.turn_right if button_down?(Gosu::KbRight)
    @player.accelerate if button_down?(Gosu::KbUp)
    @player.reverse if button_down?(Gosu::KbDown)
    @player.move_to(mouse_x, mouse_y) if button_down?(Gosu::MsLeft)
    puts "collides!!!" if button_down?(Gosu::KbSpace) && @player.collides?(mouse_x, mouse_y)
    @player.move
  end

  def draw
    @player.draw
    # @background_image.draw(0, 0, 0, 5, 5)
  end

  def button_down(id)
    close if id == Gosu::KbEscape
  end

  private

  def self.angle_between_points(x1, y1, x2, y2)
    dy = -y2 - -y1
    dx = x2 - x1
    radians = Math.atan2(dy, dx)
    degrees = radians * 180 / Math::PI
    360 - degrees + 90
  end
end

window = TwoDeeGeo.new
window.show
