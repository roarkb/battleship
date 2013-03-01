require 'ais/finisher'

class Pattern < Finisher
  attr_accessor :point_weights

  def init
    spread = 2
    @point_weights = []
    (0..9).each do |column|
      @point_weights[column] = Array.new(10,0)
      (0..9).each do |row|
        (0..spread).each do |i|
          if column % spread == i and row % spread == i
            @point_weights[column][row] = 1
          end
        end
      end
    end

    #debug
    (0..9).each do |column|
      (0..9).each do |row|
        print "#{@point_weights[column][row]} "
      end
      puts
    end
    puts
  end

  def move_anywhere
    possible_moves = []
    (0..1).each do |weight|
      (0..9).each do |column|
        (0..9).each do |row|
          if @point_weights[column][row] == weight
            possible_moves << Point.new(column,row) unless @enemy_board.shots[column][row]
          end
        end
      end
    end
    if possible_moves.empty?
      @enemy_board.display
      puts "ERROR: I was asked to make a move after the game is over"
    end

    move = possible_moves.pop
    return move.x, move.y
  end

  class Point
    attr_accessor :x, :y
    def initialize(x,y)
      @x, @y = x, y
    end
  end
end
