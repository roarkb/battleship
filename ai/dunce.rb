require_relative '../lib/player'
require_relative '../lib/util'

# a fool with no strategy, will place their ships randomly
# and choose a random available space when making a move
class Dunce < Player
  include Util

  # return a 10x10 2d array
  def place_ships
    place_ships_randomly
  end

  # return an y, x coordinate [(0..9), (0..9)]
  def next_move
    position = 1 # something other than nil

    until position.nil?
      x, y = rand(0..9), rand(0..9)
      position = @enemy_grid[x][y]
    end

    [ x, y ]
  end
end
