#!/usr/bin/env ruby
require 'board'
require 'ai'
Dir["ais/*"].each{|ai| require ai}

class Battleship2

  attr_accessor :board1, :board2
  attr_accessor :ai1, :ai2

  def initialize(ai1, ai2)
    @board1 = Board.new
    @board2 = Board.new
    @ai1 = Object.const_get(ai1).new(@board1, @board2)
    @ai2 = Object.const_get(ai2).new(@board2, @board1)
  end

  def start
    @ai1.do_place_ships
    @ai2.do_place_ships
    turn_count = 0
    while !@board1.ships.all?{|s| s.sunk}
      puts "#{ai1.class}'s ships:"
      @board1.display
      puts "#{ai2.class}'s ships:"
      @board2.display
      @ai1.do_move
      break if @board2.ships.all?{|s| s.sunk}
      @ai2.do_move
      turn_count += 1
    end

    puts "#{ai1.class}'s ships:"
    @board1.display
    puts "#{ai2.class}'s ships:"
    @board2.display
    if @board1.ships.all?{|s| s.sunk}
      puts "Player 2 (#{@ai2.class}) wins after #{turn_count} turns."
    else
      puts "Player 1 (#{@ai1.class}) wins after #{turn_count} turns."
    end
  end

end

begin
  game = Battleship2.new(ARGV[0], ARGV[1])
  game.start
rescue NameError => e
  puts "No AI found matching parameter."
  raise e
  exit 1
end

