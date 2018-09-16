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


ships = [
  [ 'B', nil, nil, nil, nil, nil, nil, nil, nil, nil ],
  [ 'B', nil, nil, nil, nil, nil, nil, nil, nil, nil ],
  [ 'B', nil, nil, nil, nil, nil, nil, nil, 'S', nil ],
  [ 'B', nil, nil, nil, nil, nil, nil, nil, 'S', nil ],
  [ nil, nil, nil, nil, nil, nil, nil, nil, 'S', nil ],
  [ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ],
  [ nil, nil, 'A', 'A', 'A', 'A', 'A', nil, nil, nil ],
  [ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ],
  [ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ],
  [ nil, nil, 'C', 'C', 'C', nil, nil, nil, 'D', 'D' ]
]

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

def print_grid(data, indent = 4)
  chr_id = 97 # => 'a'

  puts "#{' ' * (indent + 5)}#{[*1..10].join('   ')}"
  puts div = "#{' ' * (indent + 3)}#{'+---' * 10}+"

  data.each do |row|
    puts "#{' ' * indent}#{chr_id.chr}  | #{row.map { |x| x ? x : ' ' }.join(' | ')} |\n#{div}"
    chr_id += 1
  end
end

def place_ships
  # start off with empty 10x10 grid
  grid = Array.new(10) { Array.new(10) }

  # place ships in random order
  SHIPS.keys.shuffle.each do |k|
    placement = []
    length = SHIPS[k][:length]

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
            placement << next_yx[:yx]

            if length > 3
              next_yx = choose_next_yx.call

              if next_yx[:placable]
                placement << next_yx[:yx]

                if length > 4
                  next_yx = choose_next_yx.call
                  placement << next_yx[:yx] if next_yx[:placable]
                end
              end
            end
          end
        end
      end
    end

    placement.each { |e| grid[e.first][e.last] = k.to_s.upcase }

    p k.to_s.upcase
    p length
    p placement
    puts
  end

  grid
end

puts

print_grid(place_ships)

#grid = Array.new(10) { Array.new(10) }
#grid[0][0] = 'B'
#p grid[0][-1].nil?




puts

def print_board(player_data, enemy_data, score, indent = 4)
  chr_id = 97 # => 'a'
  score_indent = ' ' * (indent + 12)
  score_btwdent = ' ' * (indent + 20)
  score_border = "#{score_indent}+---+-----------------+#{score_btwdent}+---+-----------------+"
  num_header = "#{' ' * (indent + 5)}#{[*1..10].join('   ')}"
  div = "#{' ' * (indent + 3)}#{'+---' * 10}+"

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

    #{num_header}#{num_header}
    #{div}#{div}
  EOF

  (0..9).each do |i|
    pre = "#{' ' * indent}#{chr_id.chr}  | "

    # replace all nils with ' '
    player_row = player_data[i].map { |x| ' ' unless x }
    enemy_row = enemy_data[i].map { |x| ' ' unless x }

    puts "#{pre}#{player_data[i].map { |x| x ? x : ' ' }.join(' | ')} |" \
         "#{pre}#{enemy_data[i].map { |x| x ? x : ' ' }.join(' | ')} |\n#{div}#{div}"

    chr_id += 1
  end
end

#puts
#print_board(ships, ships, score, 4)
#puts
