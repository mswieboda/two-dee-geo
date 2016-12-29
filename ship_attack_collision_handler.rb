class ShipAttackCollisionHandler
  def begin(ship_shape, enemy_ship_shape)
    ship = ship_shape.object
    enemy_ship = enemy_ship_shape.object

    if !ship.owner.owns?(enemy_ship)
      ship.attack_ship(enemy_ship)
    end

    # No physics collision
    false
  end

  def separate(ship_shape, enemy_ship_shape)
    ship = ship_shape.object
    enemy_ship = enemy_ship_shape.object

    if !ship.owner.owns?(enemy_ship)
      ship.stop_attacking_ship
    end

    # No physics collision
    false
  end
end
