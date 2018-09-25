module Util

# place ships randomly in a 10x10 grid
def place_ships_randomly
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
