class Human < AI


  def place_ships
    # TODO take input for ship locations and directions.
    @ships = []
    @ships << Ship.new(5,3,2,Ship::VERTICAL)
    @ships << Ship.new(7,3,3,Ship::VERTICAL)
    @ships << Ship.new(9,3,4,Ship::VERTICAL)
    @ships << ship1 = Ship.new(0,0,5,Ship::HORIZONTAL)
    @ships << ship2 = Ship.new(2,0,3,Ship::VERTICAL)
    ship2.intersects?(ship1)
    puts 'ASDFASDFASDFASDFASDFSADF'
    $stdin.gets
    @ships
  end

  def move(previous_hit, previous_sink)
    #TODO accept input like B10
    @enemy_board.display
    print 'x: '
    x = $stdin.gets
    print 'y: '
    y = $stdin.gets
    return x.to_i, y.to_i
  end
end
