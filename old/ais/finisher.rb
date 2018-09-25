require 'ais/random'

class Finisher < Random

  @first_hit_x = nil
  @first_hit_y = nil

  def move(previous_hit=false, previous_sink=false)
    x, y = nil, nil # this is the move I will make

    # set up some knowledge
    if previous_hit
      if @first_hit_x.nil?
        @first_hit_x = @prev_x
        @first_hit_y = @prev_y
      end
      @prev_hit_x = @prev_x
      @prev_hit_y = @prev_y
    end
    if previous_sink
      @first_hit_x = nil
      @first_hit_y = nil
      @prev_hit_x = nil
      @prev_hit_y = nil
      #puts 'Sunk a ship.  Turning off move near hit mode'
      @move_near_hit = false
    end

    # am I in move_near_hit mode?
    @move_near_hit = true if previous_hit and !previous_sink
    if @move_near_hit
      x, y = move_near_hit
      if x.nil? # guess there was nowhere near to move
      #puts 'nowhere to move.  Turning off move near hit mode'
        @move_near_hit = false
        @first_hit_x = nil
        @first_hit_y = nil
        x, y = move_anywhere
      end
    else
      # nope, I'm in stupid mode
      x, y = move_anywhere
    end

    # save my move and do it
    @prev_x = x
    @prev_y = y
    return x, y
  end

  def move_anywhere
    random_move
  end

  def move_near_hit
    #puts "moving near hit"
    if @first_hit_x == @prev_hit_x and @first_hit_y == @prev_hit_y
      if @prev_hit_x < 9 and !@enemy_board.shots[@prev_hit_x+1][@prev_hit_y]
        return @prev_hit_x+1, @prev_hit_y
      elsif @prev_hit_y < 9 and !@enemy_board.shots[@prev_hit_x][@prev_hit_y+1]
        return @prev_hit_x, @prev_hit_y+1
      elsif @prev_hit_x > 0 and !@enemy_board.shots[@prev_hit_x-1][@prev_hit_y]
        return @prev_hit_x-1, @prev_hit_y
      elsif @prev_hit_y > 0 and !@enemy_board.shots[@prev_hit_x][@prev_hit_y-1]
        return @prev_hit_x, @prev_hit_y-1
      end
    else
      if @first_hit_x == @prev_hit_x
        #puts "shooting in y direction"
        # shooting in y direction
        if @prev_hit_y > @first_hit_y
          if !@enemy_board.shots[@prev_hit_x][@prev_hit_y+1]
            return @prev_hit_x, @prev_hit_y+1
          elsif !@enemy_board.shots[@prev_hit_x][@first_hit_y-1]
            return @prev_hit_x, @first_hit_y-1
          end
        else
          if !@enemy_board.shots[@prev_hit_x][@prev_hit_y-1]
            return @prev_hit_x, @prev_hit_y-1
          elsif !@enemy_board.shots[@prev_hit_x][@first_hit_y+1]
            return @prev_hit_x, @first_hit_y+1
          end
        end
      else
        #puts "shooting in x direction"
        # shooting in x direction
        if @prev_hit_x > @first_hit_x 
          if !@enemy_board.shots[@prev_hit_x+1][@prev_hit_y]
            return @prev_hit_x+1, @prev_hit_y
          elsif !@enemy_board.shots[@first_hit_x-1][@prev_hit_y]
            return @first_hit_x-1, @prev_hit_y
          end
        else
          if !@enemy_board.shots[@prev_hit_x-1][@prev_hit_y]
            return @prev_hit_x-1, @prev_hit_y
          elsif !@enemy_board.shots[@first_hit_x+1][@prev_hit_y]
            return @first_hit_x+1, @prev_hit_y
          end
        end
      end
    end
    #puts "UH OH"
    return nil, nil
  end

end
