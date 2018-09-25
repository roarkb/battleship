class AI

  def initialize(player_board, enemy_board)
    #TODO is dangerous to allow ais direct access to boards - they could cheat
    @player_board = player_board
    @enemy_board = enemy_board
    if self.respond_to? :init
      init
    end
  end

  def do_place_ships
    @player_board.ships = place_ships
    if @player_board.ships.size < 5
      raise "#{self.class}#place_ships did not place 5 ships"
    end
    @player_board.ships.each do |ship|
      @player_board.ships.each do |ship2|
        next if ship == ship2
        if ship.intersects?(ship2)
          @player_board.display
          @player_board.ships.each do |s|
            puts "Ship at (#{s.x},#{s.y}) length: #{s.length} direction #{s.direction}"
          end
          raise "Invalid ship placement by #{self.class}#place_ships"
        end
      end
    end
  end

  def place_ships
    raise "AI incomplete."
  end

  def do_move
    x, y = move(@previous_hit, @previous_sink)
    #TODO validate move
    @enemy_board.ships.each do |ship|
      @previous_hit, @previous_sink = ship.detect_hit(x, y)
      break if @previous_hit
    end
    @enemy_board.shots[x][y] = true
  end
  def move(previous_hit, previous_sink)
    raise "AI incomplete."
  end

  private

  @previous_hit  = false
  @previous_sink = false

end
