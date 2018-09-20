#!/usr/bin/env ruby

require 'pp'

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
    puts "#{' ' * INDENT}#{chr_id.chr}  | #{row.map { |x| x ? x : ' ' }.join(' | ')} |\n#{div}"
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
    puts "#{score_indent}| #{$score[:player][k][:sunk] ? 'x' : ' '} | #{v[:name].ljust(15)} |" \
         "#{score_btwdent}| #{$score[:enemy][k][:sunk] ? 'x' : ' '} | #{v[:name].ljust(15)} |"
  end

  puts <<~EOF
    #{score_border}

    #{board_header}#{board_header}
    #{board_div}#{board_div}
  EOF

  (0..9).each do |i|
    print "#{' ' * INDENT}#{chr_id.chr}  | "

    $player_data[i].each do |value|
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

    $enemy_data[i].map do |value|
      print_value =
        if DEBUG
          value ? value : ' '
        else
          case value
            when nil, Symbol # empty OR occupied
              ' '
            when Array # hit
              $score[:enemy][value][:sunk] ? value.to_s.upcase : 'x'
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

# place ships randomly in a 10x10 grid
def place_ships
    # start off with empty 10x10 grid
  grid = Array.new(10) { Array.new(10) }

  # place ships in random order
  SHIPS.keys.shuffle.each do |k|
    placement = []
    length = SHIPS[k][:length]

    # attempt to choose available on-grid positions
    # only move onto the next position if the previous one succeeded
    # repeat until you get it right
    until placement.length == length
      placement.clear

      # choose random unused starting point
      y1, x1 = rand(0..9), rand(0..9)

      until grid[y1][x1].nil?
        y1, x1 = rand(0..9), rand(0..9)
      end

      placement << [ y1, x1 ] # place first

      # choose random adjacent point
      y2, x2 = [ [ y1 + 1, x1 ], [ y1 - 1, x1 ], [ y1, x1 + 1 ], [ y1, x1 - 1 ] ].sample

      # is it unused and on-grid?
      if y2.between?(0, 9) && x2.between?(0, 9) && grid[y2][x2].nil?
        placement << [ y2, x2 ] # place 2nd

        if length > 2

          # anon function to choose randomly between the positions
          # on either end of the already chosen positions
          # return position and bool => is position available and on-grid?
          choose_next_yx = lambda do
            placement.sort!

            yx =
              if placement[0][0] == placement[1][0] # horizontal
                [ [ placement[0][0], placement[0][1] - 1 ], [ placement[0][0], placement[-1][1] + 1 ] ].sample
              else # vertical
                [ [ placement[0][0] - 1, placement[0][1] ], [ placement[-1][0] + 1, placement[0][1] ] ].sample
              end

            {
              :available => yx.first.between?(0, 9) && yx.last.between?(0, 9) && grid[yx.first][yx.last].nil?,
              :yx => yx
            }
          end

          next_yx = choose_next_yx.call

          if next_yx[:available]
            placement << next_yx[:yx] # place 3rd

            if length > 3
              next_yx = choose_next_yx.call

              if next_yx[:available]
                placement << next_yx[:yx] # place 4th

                if length == 5
                  next_yx = choose_next_yx.call
                  placement << next_yx[:yx] if next_yx[:available] # place 5th
                end
              end
            end
          end
        end
      end
    end

    placement.each { |e| grid[e.first][e.last] = k } # place all
  end

  grid
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
  $score.each_value do |player|
    player.each do |k, v|
      v[:sunk] = true if (v[:sunk] == false && v[:hits] >= SHIPS[k][:length])
    end
  end
end

# ------------- TEST -------------

# take normal turn, write to grid and return true if hit, fail if miss
def normal_turn(available_positions, grid)
  # choose random available position and remove it from list of available positions
  y, x = available_positions.delete(available_positions.sample)

  if grid[y][x] # hit
    grid[y][x] = 'x'
    true
  else # miss
    grid[y][x] = '*'
    false
  end
end

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


$score = {
  :player => {
    :a => { :hits => 0, :sunk => false },
    :b => { :hits => 0, :sunk => false },
    :s => { :hits => 0, :sunk => false },
    :c => { :hits => 0, :sunk => false },
    :d => { :hits => 0, :sunk => false }
  },
  :enemy => {
    :a => { :hits => 0, :sunk => true },
    :b => { :hits => 0, :sunk => false },
    :s => { :hits => 0, :sunk => false },
    :c => { :hits => 0, :sunk => false },
    :d => { :hits => 0, :sunk => false }
  }
}

$player_data = place_ships
$enemy_data = place_ships

#
puts
update_score

puts

puts

print_board

#grid = Array.new(10) { Array.new(10) }
#grid[rand(0..9)][rand(0..9)] = 'X'
#
#print_grid(grid)
#
#grid = Array.new(10) { Array.new(10) }
#
#positions = choose_positions(true)
#positions.each { |e| grid[e.first][e.last] = 'X' }
#
#puts
#
#print_grid(grid)

#print_grid(place_ships)
#print_board(place_ships, place_ships, score)
puts
