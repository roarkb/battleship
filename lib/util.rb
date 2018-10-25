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

        # choose random starting point
        y1, x1 = random_point

        # repeat until it's available
        until grid[y1][x1].nil?
          y1, x1 = random_point
        end

        placement << [ y1, x1 ] # place first

        # choose random adjacent point
        y2, x2 = adjacent_points(y1, x1).sample

        # only proceed if it's available
        next if grid[y2][x2]

        placement << [ y2, x2 ] # place 2nd

        # place 3rd, 4th, 5th
        count = 2

        3.times do
          next if length == count

          y, x = bookend_points(placement).sample

          next if grid[y][x]

          placement << [ y, x ]
          count += 1
        end
      end

      placement.each { |e| grid[e.first][e.last] = k } # write ship to grid
    end

    grid
  end

  # place ships randomly in a 10x10 grid and ensure they are not touching one another
  def place_ships_randomly_no_touching
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

        # choose random starting point
        y1, x1 = random_point

        # repeat until it's available and not touching another ship
        until available_isolated_point?(grid, y1, x1)
          y1, x1 = random_point
        end

        placement << [ y1, x1 ] # place first

        # choose random adjacent point
        y2, x2 = adjacent_points(y1, x1).sample

        # only proceed if it's available and not touching another ship
        next unless available_isolated_point?(grid, y2, x2)

        placement << [ y2, x2 ] # place 2nd

        # place 3rd, 4th, 5th
        count = 2

        3.times do
          next if length == count

          y, x = bookend_points(placement).sample

          next unless available_isolated_point?(grid, y, x)

          placement << [ y, x ]
          count += 1
        end
      end

      placement.each { |e| grid[e.first][e.last] = k } # write ship to grid
    end

    grid
  end

  # return random point
  def random_point
    [ rand(0..9), rand(0..9) ]
  end

  # is a given point nil and not occupied by another ship?
  def available_point?(grid, y, x)
    grid[y][x].nil?
  end

  # return the subset of points that are on-grid
  def on_grid_points(points)
    points.select { |yx| yx.first.between?(0, 9) && yx.last.between?(0, 9) }
  end

  # return all on-grid adjacent points of a single point
  def adjacent_points(y, x)
    on_grid_points([ [ y + 1, x ], [ y - 1, x ], [ y, x + 1 ], [ y, x - 1 ] ])
  end

  # return on-grid bookend points
  # assumes points in points array are linier + contiguous
  def bookend_points(points)
    points.sort!

    bookends =
      if points[0][0] == points[1][0] # horizontal
        [ [ points[0][0], points[0][1] - 1 ], [ points[0][0], points[-1][1] + 1 ] ]
      else # vertical
        [ [ points[0][0] - 1, points[0][1] ], [ points[-1][0] + 1, points[0][1] ] ]
      end

    # only return if on-grid
    on_grid_points(bookends)
  end

  # ensure an yx position is available and not touching any other ships
  def available_isolated_point?(grid, y, x)
    grid[y][x].nil? && adjacent_points(y, x).all? { |yx| grid[yx.first][yx.last].nil? }
  end
end
