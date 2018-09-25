require 'ship'

class Board

  attr_accessor :ships
  # I regret having shots be a 2 diminsional array.
  # If I did it again, it would be an array of Point objects
  attr_accessor :shots

  def initialize
    @ships = []
    @shots = []
    (0..9).each do |column|
      @shots[column] = Array.new(10, false)
    end
  end

  def to_s
    display_grid = []
    # "empty" grid
    (0..9).each do |column|
      display_grid[column] = Array.new(10, '.')
    end

    # now draw * for all shots
    (0..9).each do |column|
      (0..9).each do |row|
        display_grid[column][row] = '*' if @shots[column][row]
      end
    end

    # overlay ships

    @ships.each do |ship|
      (0..ship.length-1).each do |offset|
        xpos = ship.x
        ypos = ship.y
        ship.direction == Ship::VERTICAL ? ypos += offset : xpos += offset
        if @shots[xpos][ypos]
          display_grid[xpos][ypos] = 'x'
        else
          display_grid[xpos][ypos] = '0'
        end
      end
    end


    # flush to screen
    puts '  1 2 3 4 5 6 7 8 9 10'
    (0..9).each do |column|
      print "#{column} "
      (0..9).each do |row|
        print "#{display_grid[column][row]} "
      end
      puts
    end
    puts
  end
  alias :display :to_s

end
