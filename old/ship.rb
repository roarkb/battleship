class Ship
  VERTICAL = 0
  HORIZONTAL = 1

  attr_accessor :x, :y, :length, :direction, :hits

  def initialize(x, y, length, direction)
    @x, @y, @length, @direction = x, y, length, direction
    @hits = []
  end

  def sunk
    return @hits.size >= @length
  end

  def detect_hit(x,y)
    # TODO refactor to use contains_point
    hit = false
    if @direction == VERTICAL
      (0..@length-1).each do |y_offset|
        if x == @x and y == @y+y_offset
          hits << y_offset unless hits.include? y_offset
          hit = true
        end
      end
    else
      (0..@length-1).each do |x_offset|
        if x == @x+x_offset and y == @y
          hits << x_offset unless hits.include? x_offset
          hit = true
        end
      end
    end
    return hit, sunk
  end

  def intersects?(ship)
    #puts "should test #{ship.length * self.length} points"
    if ship.direction == VERTICAL
      (0..ship.length-1).each do |y_offset|
        if self.contains_point(ship.x, ship.y+y_offset)
          return true
        end
      end
    else
      (0..ship.length-1).each do |x_offset|
        if self.contains_point(ship.x+x_offset, ship.y)
          return true
        end
      end
    end
    return false
  end

  def contains_point(x,y)
    #puts "Testing (#{x},#{y})"
    if @direction == VERTICAL
      (0..@length-1).each do |y_offset|
        #puts "Against (#{@x},#{@y+y_offset})"
        if x == @x and y == @y+y_offset
          return true
        end
      end
    else
      (0..@length-1).each do |x_offset|
        #puts "Against (#{@x+x_offset},#{@y+y})"
        if x == @x+x_offset and y == @y
          return true
        end
      end
    end
    return false
  end

  def name
    case @length
    when 5
      "Aircraft Carrier"
    when 4
      "Battleship"
    when 3
      "Cruiser or other guy"
    when 2
      "Destroyer"
    end
  end
end
