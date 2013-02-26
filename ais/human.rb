class Human < AI


  def place_ships
    # TODO take input for ship locations and directions.
    @ships = []
    @ships << Ship.new(2,0,2,Ship::VERTICAL)
    @ships << Ship.new(3,0,3,Ship::VERTICAL)
    @ships << Ship.new(5,0,4,Ship::VERTICAL)
    @ships << Ship.new(6,8,3,Ship::HORIZONTAL)
    @ships << Ship.new(7,0,5,Ship::VERTICAL)
    @ships
  end

  def move(previous_hit, previous_sink)
    #TODO accept input like B10
    @player_board.display
    print 'x: '
    x = $stdin.gets
    print 'y: '
    y = $stdin.gets
    return x.to_i, y.to_i
  end
end
