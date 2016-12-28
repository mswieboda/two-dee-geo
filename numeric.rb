class Numeric
  def gosu_to_radians
    (self - 90) * Math::PI / 180.0
  end

  def radians_to_gosu
    90 - (self * 180.0 / Math::PI)
  end

  def radians_to_vec2
    CP::Vec2.new(Math::cos(self), Math::sin(self))
  end
end
