# base class for all AIs to ensure that rules are followed and a player does not
# have direct access to opponent's grid
#
# AIs will exchange y, x moves in array index format (eg. [0, 1]) and not
# letter, number format (eg. "a1")
# the game board will handle the 0 => a translations
class Player
  # create the player and enemy boards used to track gameplay
  # validate that player AI is not cheeting
  # sure, player AI could simply overwrite the initialize and bypass all validation but that's a Ruby! `\_(")_/`
  def initialize
    validate_subclass

    @player_grid = place_ships
    validate_player_grid

    @enemy_grid = Array.new(10) { Array.new(10) } # start off with empty 10x10 grid
  end

  # methods to be overwritten by individual AI classes to implement their special strategies

  # return a 10x10 2d array
  def place_ships
  end

  # return an y, x coordinate [(0..9), (0..9)]
  def next_move
  end

  # methods to be called by main battleship script to facilitate gameplay
  # do not overwrite these
  #
  # a typical turn will go:
  #   player1.attack
  #   player2.respond
  #   player1.record

  # call AI's next_move method to get the y, x
  # validate it is a valid move
  # return y, x
  def attack
  end

  # determine if hit/miss/sink (if so, which ship)
  # write y, x to player_grid and enemy_grid
  # return false if miss, true if hit, ship symbol if hit and sink
  def respond(y, x) # (0-9, 0-9)
  end

  # write you attack results to enemy_grid
  # verdict can be false, true, ship symbol
  def record(y, x, verdict)
  end

  private

  # ensure AI subclass is setup correctly
  def validate_subclass
    superclass_name = 'Player'

    begin
      # ensure AI inherits from Player
      raise unless self.class.superclass.name == superclass_name

      # ensure AI has implemented AI methods
      %i[ place_ships next_move ].each { |e| raise if method(e).owner.name == superclass_name }

      # ensure AI has NOT overwritten gameplay  methods
      %i[ attack respond record ].each { |e| raise unless method(e).owner.name == superclass_name }
    rescue
      puts '[ERROR] AI is cheating'
      exit 1
    end
  end

  def validate_player_grid
    begin
      # validate the basics
      raise unless @player_grid.class == Array
      raise unless @player_grid.length == 10

      @player_grid.each do |e|
        raise unless e.class == Array
        raise unless e.length == 10
      end

      all_values = @player_grid.flatten
      non_nil_values = all_values.compact

      raise unless all_values.count(nil) == 83
      raise unless non_nil_values.length == 17

      SHIPS.each { |k, v| raise unless non_nil_values.count(k) == v[:length] }

      # validate that all ship's points are linear + contiguous
      positions = @player_grid.each_with_object({}).with_index do |(row, h), row_i|
        row.each_with_index do |point, point_i|
          if point
            if h[point]
              h[point] << [ row_i, point_i ]
            else
              h[point] = [ [ row_i, point_i ] ]
            end
          end
        end
      end

      raise unless SHIPS.keys.sort == positions.keys.sort

      positions.each do |k, v|
        raise unless SHIPS[k][:length] == v.length

        ys = v.map(&:first).uniq.sort
        xs = v.map(&:last).uniq.sort

        horizontal_check, vertical_check = 0, 0

        [ ys, xs ].each do |e|
          if e.length == 1
            horizontal_check += 1
          elsif e.last - e.first + 1 == e.length
            vertical_check += 1
          end
        end

        raise unless horizontal_check == 1
        raise unless vertical_check == 1
      end
    rescue
      puts '[ERROR] malformed player grid'
      exit 1
    end
  end
end
