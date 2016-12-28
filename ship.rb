require 'pry'

require 'gosu'

class Ship
  attr_reader :window, :damage, :owner

  AMOUNT = 0.6
  SIZE = 4 * 2
  STOP_GAP = 15

  def initialize(window, owner)
    @window = window

    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @owner = owner
    @damage = 0.01
  end

  def jump_to(x, y)
    @x = x
    @y = y
  end

  def turn(angle)
    @angle += angle
  end

  def turn_left
    turn(-4.5)
  end

  def turn_right
    turn(4.5)
  end

  def left
    @vel_x -= AMOUNT
  end

  def right
    @vel_x += AMOUNT
  end

  def accelerate
    @vel_x += Gosu::offset_x(@angle, AMOUNT)
    @vel_y += Gosu::offset_y(@angle, AMOUNT)
  end

  def reverse
    @vel_x -= Gosu::offset_x(@angle, AMOUNT)
    @vel_y -= Gosu::offset_y(@angle, AMOUNT)
  end

  def stop
    @vel_x = 0
    @vel_y = 0
  end

  def move
    auto_movement
    auto_rotation

    @x += @vel_x
    @y += @vel_y
    @x %= window.width
    @y %= window.height

    # slow down
    @vel_x *= 0.9
    @vel_y *= 0.9
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
      @angle = TwoDeeGeo.angle_between_points(@x, @y, move_to_x, move_to_y)

      if collides?(move_to_x, move_to_y, STOP_GAP)
        stop

        move_to_x = move_to_y = nil

        if @move_to_obj
          @rotate_around_obj = @move_to_obj
          @move_to_obj = nil
        end
      else
        accelerate
      end
    end
  end

  def auto_rotation
    if @rotate_around_obj
      if @x <= @rotate_around_obj.x + @rotate_around_obj.width / 2 &&
        @y <= @rotate_around_obj.y - @rotate_around_obj.height / 2
        @vel_x += AMOUNT
      elsif @x >= @rotate_around_obj.x + @rotate_around_obj.width / 2 &&
        @y <= @rotate_around_obj.y + @rotate_around_obj.height / 2
        @vel_y += AMOUNT
      elsif @x >= @rotate_around_obj.x - @rotate_around_obj.width / 2 &&
        @y >= @rotate_around_obj.y + @rotate_around_obj.height / 2
        @vel_x -= AMOUNT
      elsif @x <= @rotate_around_obj.x - @rotate_around_obj.width / 2 &&
        @y >= @rotate_around_obj.y - @rotate_around_obj.height / 2
        @vel_y -= AMOUNT
      elsif @x <= @rotate_around_obj.x - @rotate_around_obj.width / 2 &&
        @y <= @rotate_around_obj.y - @rotate_around_obj.height / 2
        @vel_x -= AMOUNT
      end

      @angle = TwoDeeGeo.angle_between_points(@x, @y, @rotate_around_obj.x, @rotate_around_obj.y)

      shoot_at(@rotate_around_obj) unless @owner.owns?(@rotate_around_obj)
    end
  end

  def shoot_at(obj)
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

  def draw
    x1 = @x + SIZE
    x2 = @x
    x3 = @x - SIZE
    y1 = y3 = @y
    y2 = @y - SIZE * 3
    c = @owner.color
    Gosu.rotate(@angle, @x, @y - SIZE) do
      Gosu.draw_triangle(x1, y1, c, x2, y2, c, x3, y3, c, 0, mode = :default)
    end
  end

  def collides?(x, y, gap = 0)
    gap += SIZE * 2
    (@x - x).abs <= gap && (@y - y).abs <= gap
  end
end
