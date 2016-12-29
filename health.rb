module Health
  attr_reader :health

  def init_health(health)
    @health = @max_health = health
    @taking_damage = false
  end

  def take_damage(damage)
    @taking_damage = true
    @health -= damage

    if health <= 0
      @health = 0
      @taking_damage = false
      yield if block_given?
    end
  end
end
