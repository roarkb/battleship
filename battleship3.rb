#!/usr/bin/env ruby

#system('clear')

SHIPS = {
  :a => { :length => 5, :name => 'Arcraft Carrier' },
  :b => { :length => 4, :name => 'Battleship' },
  :s => { :lentgh => 3, :name => 'Submarine' },
  :c => { :length => 3, :name => 'Cruiser' },
  :d => { :length => 2, :name => 'Destroyer' }
}

ships = [
  [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
  [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
  [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
  [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
  [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
  [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
  [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
  [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
  [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
  [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]
]

score = {
  :player => {
    :a => 'x',
    :b => ' ',
    :s => ' ',
    :c => 'x',
    :d => ' ',
  },
  :enemy => {
    :a => ' ',
    :b => 'x',
    :s => ' ',
    :c => ' ',
    :d => 'x',
  }
}

def grid(data, indent = 4)
  chr_id = 97 # => 'a'

  puts "#{' ' * (indent + 5)}#{(1..10).to_a.join('   ')}"
  puts div = "#{' ' * (indent + 3)}#{'+---' * 10}+"

  data.each do |row|
    puts "#{' ' * indent}#{chr_id.chr}  | #{row.join(' | ')} |\n#{div}"
    chr_id += 1
  end
end

#puts
#grid(ships)
#puts

def board(player_data, enemy_data, score, indent = 4)
  chr_id = 97 # => 'a'
  score_indent = ' ' * (indent + 12)
  score_btwdent = ' ' * (indent + 20)
  score_border = "#{score_indent}+---+-----------------+#{score_btwdent}+---+-----------------+"
  num_header = "#{' ' * (indent + 5)}#{(1..10).to_a.join('   ')}"
  div = "#{' ' * (indent + 3)}#{'+---' * 10}+"

  puts <<~EOF
    #{' ' * (indent + 20)}PLAYER#{' ' * (indent + 39)}ENEMY

    #{score_border}
  EOF

  SHIPS.each do |k, v|
    puts "#{score_indent}| #{score[:player][k]} | #{v[:name].ljust(15)} |#{score_btwdent}| #{score[:enemy][k]} | #{v[:name].ljust(15)} |"
  end

  puts <<~EOF
    #{score_border}

    #{num_header}#{num_header}
    #{div}#{div}
  EOF

  (0..9).each do |i|
    pre = "#{' ' * indent}#{chr_id.chr}  | "

    puts "#{pre}#{player_data[i].join(' | ')} |#{pre}#{enemy_data[i].join(' | ')} |\n#{div}#{div}"

    chr_id += 1
  end
end

puts
board(ships, ships, score, 4)
puts
