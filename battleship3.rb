#!/usr/bin/env ruby

require 'pp'

#system('clear')

SHIPS = {
  :a => { :length => 5, :name => 'Arcraft Carrier' },
  :b => { :length => 4, :name => 'Battleship' },
  :s => { :length => 3, :name => 'Submarine' },
  :c => { :length => 3, :name => 'Cruiser' },
  :d => { :length => 2, :name => 'Destroyer' }
}

#$score = { :player => {}, :enemy => {} }

score = {
  :player => {
    :a => 'x',
    :s => 'x'
  },
  :enemy => {
    :b => 'x',
    :d => 'x'
  }
}

# display single 10x10 grid
# use for player ship placment
def print_grid(data, indent = 4)
  chr_id = 97 # => 'a'

  puts "#{' ' * (indent + 5)}#{[*1..10].join('   ')}"
  puts div = "#{' ' * (indent + 3)}#{'+---' * 10}+"

  data.each do |row|
    puts "#{' ' * indent}#{chr_id.chr}  | #{row.map { |x| x ? x : ' ' }.join(' | ')} |\n#{div}"
    chr_id += 1
  end
end

# display main game board
def print_board(player_data, enemy_data, score, indent = 4)
  chr_id = 97 # => 'a'
  score_indent = ' ' * (indent + 12)
  score_btwdent = ' ' * (indent + 20)
  score_div = '+---+-----------------+'
  score_border = score_indent + score_div + score_btwdent + score_div
  board_header = "#{' ' * (indent + 5)}#{[*1..10].join('   ')}"
  board_div = "#{' ' * (indent + 3)}#{'+---' * 10}+"

  puts <<~EOF
    #{' ' * (indent + 20)}PLAYER#{' ' * (indent + 39)}ENEMY

    #{score_border}
  EOF

  SHIPS.each do |k, v|
    puts "#{score_indent}| #{score[:player][k] ? score[:player][k] : ' '} | #{v[:name].ljust(15)} |" \
         "#{score_btwdent}| #{score[:enemy][k] ? score[:enemy][k] : ' '} | #{v[:name].ljust(15)} |"
  end

  puts <<~EOF
    #{score_border}

    #{board_header}#{board_header}
    #{board_div}#{board_div}
  EOF

  (0..9).each do |i|
    pre = "#{' ' * indent}#{chr_id.chr}  | "

    # replace all nils with ' '
    player_row = player_data[i].map { |x| ' ' unless x }
    enemy_row = enemy_data[i].map { |x| ' ' unless x }

    puts "#{pre}#{player_data[i].map { |x| x ? x : ' ' }.join(' | ')} |" \
         "#{pre}#{enemy_data[i].map { |x| x ? x : ' ' }.join(' | ')} |\n#{board_div}#{board_div}"

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
              :placable => yx.first.between?(0, 9) && yx.last.between?(0, 9) && grid[yx.first][yx.last].nil?,
              :yx => yx
            }
          end

          next_yx = choose_next_yx.call

          if next_yx[:placable]
            placement << next_yx[:yx] # place 3rd

            if length > 3
              next_yx = choose_next_yx.call

              if next_yx[:placable]
                placement << next_yx[:yx] # place 4th

                if length == 5
                  next_yx = choose_next_yx.call
                  placement << next_yx[:yx] if next_yx[:placable] # place 5th
                end
              end
            end
          end
        end
      end
    end

    placement.each { |e| grid[e.first][e.last] = k.to_s.upcase } # place all
  end

  grid
end

puts
#print_grid(place_ships)
print_board(place_ships, place_ships, score, 4)
puts
