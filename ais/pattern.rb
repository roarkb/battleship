require 'ais/finisher'

class Pattern < Finisher
  attr_accessor :point_weights

  def init
    point_weights = []
    (0..9).each do |column|
      point_weights[column] = Array.new(10,0)
      (0..9).each do |row|
        if column % 3 == 1 and row % 3 == 1
          point_weights[column][row] = 1
        end
      end
    end

    #debug
    (0..9).each do |column|
      (0..9).each do |row|
        print "#{point_weights[column][row]} "
      end
      puts
    end
    puts
  end

  def move_anywhere
    #TODO

  end
end
