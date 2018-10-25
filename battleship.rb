#!/usr/bin/env ruby

require 'pp'

require_relative 'lib/util'

include Util

SHIPS = {
  :a => { :length => 5, :name => 'Arcraft Carrier' },
  :b => { :length => 4, :name => 'Battleship' },
  :s => { :length => 3, :name => 'Submarine' },
  :c => { :length => 3, :name => 'Cruiser' },
  :d => { :length => 2, :name => 'Destroyer' }
}

INDENT = 4
TRUE_FALSE = [ true, false ].sample # random bool decider
DEBUG = ARGV.first ? true : false

# display single 10x10 grid
# use for player ship placment
def print_grid(data)
  chr_id = 97 # => 'a'

  puts "#{' ' * (INDENT + 5)}#{[*1..10].join('   ')}"
  puts div = "#{' ' * (INDENT + 3)}#{'+---' * 10}+"

  data.each do |row|
    puts "#{' ' * INDENT}#{chr_id.chr}  | #{row.map { |x| x || ' ' }.join(' | ')} |\n#{div}"
    chr_id += 1
  end
end

# display main game board
def print_board
  chr_id = 97 # => 'a'
  score_indent = ' ' * (INDENT + 12)
  score_btwdent = ' ' * (INDENT + 20)
  score_div = '+---+-----------------+'
  score_border = score_indent + score_div + score_btwdent + score_div
  board_header = "#{' ' * (INDENT + 5)}#{[*1..10].join('   ')}"
  board_div = "#{' ' * (INDENT + 3)}#{'+---' * 10}+"

  puts <<~EOF
    #{' ' * (INDENT + 20)}PLAYER#{' ' * (INDENT + 39)}ENEMY

    #{score_border}
  EOF

  SHIPS.each do |k, v|
    puts "#{score_indent}| #{@score[:player][k][:sunk] ? 'x' : ' '} | #{v[:name].ljust(15)} |" \
         "#{score_btwdent}| #{@score[:enemy][k][:sunk] ? 'x' : ' '} | #{v[:name].ljust(15)} |"
  end

  puts <<~EOF
    #{score_border}

    #{board_header}#{board_header}
    #{board_div}#{board_div}
  EOF

  (0..9).each do |i|
    print "#{' ' * INDENT}#{chr_id.chr}  | "

    @player_grid[i].each do |value|
      print_value =
        case value
          when nil # empty
            ' '
          when Symbol # occupied
            value.to_s.upcase
        else # hit OR miss
          value
        end

      print "#{print_value} | "
    end

    print "#{' ' * (INDENT - 1)}#{chr_id.chr}  | "

    @enemy_grid[i].map do |value|
      print_value =
        if DEBUG # display enemy board like player board
          case value
            when nil # empty
              ' '
            when Symbol # occupied
              value.to_s.upcase
            when Array
              'x'
          else # miss
            value
          end
        else
          case value
            when nil, Symbol # empty OR occupied
              ' '
            when Array # hit
              @score[:enemy][value.first][:sunk] ? value.first.to_s.upcase : 'x'
          else # miss
            value
          end
        end
      print "#{print_value} | "
    end

    puts "\n#{board_div}#{board_div}"

    chr_id += 1
  end
end

# generate array of all [ y, x ] positions that the enemy can choose from when taking a turn
def generate_available_positions(difficult = true)
  if difficult # choose only diagonal positions
    (0..9).each_with_object([]) do |y, a|
      x_row =
        if TRUE_FALSE
          y.even? ? [ 0, 2, 4, 6, 8 ] : [ 1, 3, 5, 7, 9 ]
        else
          y.odd? ? [ 0, 2, 4, 6, 8 ] : [ 1, 3, 5, 7, 9 ]
        end

      x_row.each { |x| a << [ y, x ] }
    end
  else # choose all positions
    (0..9).each_with_object([]) { |y, a| (0..9).each { |x| a << [ y, x ] } }
  end
end

def update_score
  @score.each_value do |player|
    player.each do |k, v|
      v[:sunk] = true if v[:sunk] == false && v[:hits] >= SHIPS[k][:length]
    end
  end
end

# take normal turn, write to grid and return true if hit, fail if miss
def enemy_move
  # choose random available position and remove it from list of available positions
  y, x = @available_positions.delete(@available_positions.sample)

  if @player_grid[y][x] # hit
    @player_grid[y][x] = 'x'

    true
  else # miss
    @player_grid[y][x] = '*'

    false
  end
end

def player_move
  counter = 0

  msg = [
    'Invalid input. Please enter a letter + integer combination: [a-j][1-10]',

    "That's still invalid. You need to enter a lowercase letter between 'a' and
  'j' followed by a number between 1 and 10.",

    "Dude! just type like #{('a'..'j').to_a.sample}#{rand(1..10)} or something.",

    'Wow!, you are really dense.',

    "You don't even want to play Battleship do you? You instead derive joy from
  inputing garbage over and over just to see how I will react.",

    'I feel so empty inside.',

    'broken...',

    "Alright smart ass. I'm done taking your abuse. You have ONE MORE chance to
  enter a PROPER battleship move or else I'm gonna go back to sleep.",

    'Goodnight forever!'
  ]

  msg.length.times do
    print 'player move> '
    input = gets.chomp.chars
    y = ('a'..'j').to_a.index(input.delete_at(0))
    x = input.join.to_i - 1

    if y && x && y.between?(0, 9) && x.between?(0, 9)
      p 'y'
      break
    else
      puts "  #{msg[counter]}\n\n"

      counter += 1
    end
  end

  exit
  p value = @enemy_grid[y][x]

  case value
    when nil # miss
      puts 'miss'
      @enemy_grid[y][x] = '*'
    when Symbol # hit
      puts 'hit'
      @enemy_grid[y][x] = [ value ]
    when Array, '*' # you already shot there
      puts 'try again'
  else
    puts 'oops'
  end
end

# ------------- TEST -------------

#system('clear')

# [ 'c', false]
# [ 'c', true ]
# [ nil, false]
# [ nil, true ]
#
# { :value => 'c' }
# { :value => 'c', :hit => true }
# { :value => nil }
# { :valus => nil, :hit => true }
#
# nil
# [ nil, true ]
# 'c'
# [ 'c', true ]
#
# nil => empty
# '*' => miss
# :c => occupied
# [ :c, 'x' ] => hit

# nil => empty
# '*' => miss
# :c => occupied
# [ :c ] => hit

# set game state and do it with global vars

@score = {
  :player => {
    :a => { :hits => 0, :sunk => false },
    :b => { :hits => 0, :sunk => false },
    :s => { :hits => 0, :sunk => false },
    :c => { :hits => 0, :sunk => false },
    :d => { :hits => 0, :sunk => false }
  },
  :enemy => {
    :a => { :hits => 0, :sunk => true },
    :b => { :hits => 0, :sunk => true },
    :s => { :hits => 0, :sunk => true },
    :c => { :hits => 0, :sunk => true },
    :d => { :hits => 0, :sunk => true }
  }
}

#@player_grid = place_ships_randomly
#@enemy_grid = place_ships_randomly
#@available_positions = generate_available_positions
#puts
#player_move
#puts

puts
print_grid(place_ships_randomly)
puts
puts
print_grid(place_ships_randomly_no_touching)
puts

