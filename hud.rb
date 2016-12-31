class Hud
  BASE_SIZE = 15
  X_MARGIN = 15
  Y_MARGIN = 100
  TEXT_HEIGHT = 30

  def initialize(player:, players:, bases:)
    @player = player
    @players = players
    @bases = bases
    @font = Gosu::Font.new(TEXT_HEIGHT, name: "Courier New")
  end

  def draw
    draw_bases
  end

  def draw_bases
    y_margin = Y_MARGIN
    x_margin = X_MARGIN

    @players.each do |player|
      bases = @bases.select { |b| b.owner == player }.count

      # Base
      x1 = X_MARGIN
      x2 = x4 = BASE_SIZE + x1
      x3 = BASE_SIZE + x2
      y1 = y3 = y_margin + BASE_SIZE
      y2 = y_margin
      y4 = BASE_SIZE + y3
      c = player.color

      Gosu.draw_quad(x1, y1, c, x2, y2, c, x3, y3, c, x4, y4, c)

      x_margin += BASE_SIZE + X_MARGIN

      # Base count
      @font.draw(bases, x1 + x_margin, y1 - BASE_SIZE, 0, 1, 1, c)

      y_margin += BASE_SIZE + Y_MARGIN / 2
      x_margin = X_MARGIN
    end
  end
end
