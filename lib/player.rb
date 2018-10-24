require_relative 'util'

# base class for all AIs to ensure that rules are followed and a player does not
# have direct access to opponent's grid
#
# AIs will exchange y, x moves in array index format (eg. [0, 1]) and not
# letter, number format (eg. "a1")
# the game board will handle the 0 => a translations
#
# defaults to random player behavior
class Player
  extend Util

  def initialize(player_grid)
    @player_grid = player_grid # place your own ships
    @enemy_grid = Array.new(10) { Array.new(10) } # start off with empty 10x10 grid
  end

  # call AI's turn method to get the x, y
  # validate it is a valid move
  # return x, y
  def attack
    y, x = turn
  end

  def respond(y, x) # (0-9, 0-9)
  end

  # methods to be overwritten by individual AI classes to implement their special strategies

  # defaults to random ship placement
  # return a 10x10 2d array
  def place_ships
    place_ships_randomly
  end

  # defaults to choosing a random available on-grid position
  # return an y, x coordinate [(0..9), (0..9)]
  def turn
  end
end
