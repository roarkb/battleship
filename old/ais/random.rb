class Random < AI

  def place_ships
    @ships = []
    [5,4,3,3,2].each do |ship_size|
      # no do-while in ruby
      new_ship = nil
      loop do
        # TODO I've tried this a couple ways, and it still sometimes puts ships on top of ships
        # I don't think the problem is in ship.rb, because ai.rb uses that to expose the issue.
        new_ship = create_ship(ship_size)
        break if @ships.all?{|ship| !ship.intersects?(new_ship)}
      end
      @ships << new_ship
    end
    return @ships
  end

  def create_ship(ship_size)
      direction = rand(2) == 0 ? Ship::VERTICAL : Ship::HORIZONTAL
      x = direction == Ship::VERTICAL ? rand(10) : rand(10-ship_size)
      y = direction == Ship::HORIZONTAL ? rand(10) : rand(10-ship_size)
      Ship.new(x,y,ship_size,direction)
  end

  def move(previous_hit=false, previous_sink=false)
    return random_move
  end

  def random_move
    possible_moves = []
    (0..9).each do |column|
      (0..9).each do |row|
        possible_moves << Point.new(column,row) unless @enemy_board.shots[column][row]
      end
    end
    if possible_moves.empty?
      @enemy_board.display
    end

    move = possible_moves[rand(possible_moves.size)]
    return move.x, move.y
  end

  class Point
    attr_accessor :x, :y
    def initialize(x,y)
      @x, @y = x, y
    end
  end
end
