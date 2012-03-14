#!/usr/bin/ruby -w



#          +++++++++++++++++++++++++++++++
#          ++ "Command Line Battleship" ++
#          +++++++++++++++++++++++++++++++             
#
#                     Created by 
#                   Roark Brewster
#                       2012
#                      ______
#                       ====
#                        []
#                        [] 
#                        []
#                        []
#                        []
#                        []
#                       ----
#                      ______
#
#
#            
#            it's gonna be like this:
#            
#
#      i2 -> 0  1  2  3  4  5  6  7  8  9
#    NUMS -> 1  2  3  4  5  6  7  8  9  10
#            |  |  |  |  |  |  |  |  |  | 
#          +------------------------------
#    0-A-->| .  .  .  .  .  .  .  .  .  .     
#    1-B-->| .  .  .  .  .  .  .  .  .  .
#    2-C-->| .  .  .  .  .  .  .  .  .  .
#    3-D-->| .  .  .  .  .  .  .  .  .  .
#    4-E-->| .  .  .  .  .  .  .  .  .  .
#    5-F-->| .  .  .  .  .  .  .  .  .  .
#    6-G-->| .  .  .  .  .  .  .  .  .  .
#    7-H-->| .  .  .  .  .  .  .  .  .  .
#    8-I-->| .  .  .  .  .  .  .  .  .  .
#    9-J-->| .  .  .  .  .  .  .  .  .  .
#    | |
#   i1-ALPHAS



## SETUP
#
# determines which hud is used
if ARGV[0] == "debug"
  $debug = 1
else
  $debug = 0
end



## DEFINITIONS
SHIPS = {   # length, symbol, display_name
  :carrier    => [ 5, "A", "Arcraft Carrier" ],
  :battleship => [ 4, "B", "Battleship" ],
  :submarine  => [ 3, "S", "Submarine" ],
  :cruiser    => [ 3, "C", "Cruier" ],
  :destroyer  => [ 2, "D", "Destroyer" ]
}

ALPHAS      = %w[ a b c d e f g h i j ]         # y axis
NUMS        = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] # x axis
INDEX       = [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]
INDEX_ALPHA = Hash[ *INDEX.zip(ALPHAS).flatten ]

# grid symbols
DEFAULT = " "
HIT     = "x"
MISS    = "*"

def grid
  v = DEFAULT
  [
    [ v, v, v, v, v, v, v, v, v, v ],
    [ v, v, v, v, v, v, v, v, v, v ],
    [ v, v, v, v, v, v, v, v, v, v ],
    [ v, v, v, v, v, v, v, v, v, v ],
    [ v, v, v, v, v, v, v, v, v, v ],
    [ v, v, v, v, v, v, v, v, v, v ],
    [ v, v, v, v, v, v, v, v, v, v ],
    [ v, v, v, v, v, v, v, v, v, v ],
    [ v, v, v, v, v, v, v, v, v, v ],
    [ v, v, v, v, v, v, v, v, v, v ]
  ]
end

def grid_indexes
  a = []
  
  grid.flatten.each_index do |i|
    ncols = grid.first.size
    i1    = i / ncols
    i2    = i % ncols
    
    a.push( [ i1, i2 ] )
  end

  return a
end

$player_grid = grid # player's ships view
$shots_grid  = grid # player's hit/miss view
$enemy_grid  = grid # enemy's ships view (replaces shots grid in cheat mode)
$ai_grid     = grid # internal enemy AI

$sunken_ships = {
  :player => [],
  :enemy  => []
}

# will need to save enemy grid positions to track on $shots_grid when sunk
$enemy_ships = {}
SHIPS.values.each { |e| $enemy_ships[ e[1] ] = [] }

# used by enemy AI
$last_move = []
$stored_ii = []


## METHODS

# HELPERS
def clear
  system( "clear" )
end

# choose random element from an array
def a_rand ( a )
  a[ rand( a.size ) ]
end


# VALIDATION
#
# validate a yes/no answer
def yes_no( q )
  print "\n#{q} (yes/no)? "
  r = $stdin.gets.strip

  4.times do
    unless r == "yes" or r == "no"
      print "\nPlease type 'yes' or 'no': "
      r = $stdin.gets.strip
    end
  end
  
  unless r == "yes" or r == "no"
    puts "\nYou are a fucking idiot... goodbye\n\n"
    exit
  end

  return r
end

# make sure player inputs correctly formatted position
# convert grid position(pos) to 2d array index(ii)
# make sure player does not try to hit the same location more than once
# returns ii
def player_input
  print "\nYour move> "
  pos = $stdin.gets.strip
  v   = 0 # validated?
  i1  = nil
  i2  = nil

  format_dialog   = "\nPlease enter a valid grid position [a-j1-10]> "
  location_dialog = "\nYou have already hit me there, try again> "

  9.times do
    unless v == 1
      
      if pos =~ /^[a-jA-J]\d+$/
        num = pos.slice( /\d+/ ).to_i - 1
        
        if "#{num}" =~ /^[0-9]$/
          i1 = INDEX_ALPHA.invert[ pos.slice( /\D/ ).downcase ]
          i2 = num
          g  = grid_value( $shots_grid, [ i1, i2 ] )
          
          if g != DEFAULT
            print location_dialog
            pos = $stdin.gets.strip
          else
            v = 1
          end
        
        else
          print format_dialog
          pos = $stdin.gets.strip
        end
      
      else
        print format_dialog
        pos = $stdin.gets.strip
      end
    end
  end

  unless v == 1
    puts "\nYou are just not with it today, goodbye\n\n"
    exit
  end

  return [ i1, i2 ]
end

# DISPLAY
def key_score
ind = 7
a = []

  SHIPS.values.sort.reverse.each do |s|
    [ :player, :enemy ].each do |p|
      if $sunken_ships[ p ].index( s[1] )
        a.push( "X" )
      else 
        a.push( " " )
      end
    end
  end

  puts "\n\n                            | P | E |
                            |---+---|
       A -> Arcraft Carrier | #{a[0]} | #{a[1]} |
       B -> Battleship      | #{a[2]} | #{a[3]} |
       S -> Submarine       | #{a[4]} | #{a[5]} |
       C -> Cruier          | #{a[6]} | #{a[7]} |
       D -> Destroyer       | #{a[8]} | #{a[9]} |\n\n"
  puts " " * ind + "#{HIT} -> Hit"
  puts " " * ind + "#{MISS} -> Miss\n\n"
end

def key
  ind = 7
  puts
  SHIPS.values.sort.reverse.each { |e| puts " " * ind + "#{e[1]} -> #{e[2]}" }
  puts
  puts " " * ind + "#{HIT} -> Hit"
  puts " " * ind + "#{MISS} -> Miss\n\n"
end

# pretty print any grid
def display( grid )
  puts "\n         #{NUMS.join( "  " ) }"
  puts "       +------------------------------"

  grid.zip( ALPHAS ).each do |b, a|
    print "    #{a}  | "
    b.each { |e| print "#{e}  " }
    puts
  end
  puts
end

# a tailored heads-up-display
def player_hud
  ind = 20
  
  case $cheat
  when "yes"
    track_grid = $enemy_grid
  when "no"
    track_grid = $shots_grid
  end

  key_score
  puts "\n" + " " * ind + "ENEMY"
  display( track_grid )
  puts "\n\n" + " " * ind + "PLAYER"
  display( $player_grid )
  puts
end

# for debug mode
def debug_hud
  ind = 20
  puts
  print "sunken_ships: "
  p $sunken_ships
  print "last_move: "
  p $last_move
  print "stored_ii: "
  p $stored_ii
  puts
  puts " " * ind + "ai"
  display( $ai_grid )
  puts " " * ind + "enemy(cheat)"
  display( $enemy_grid )
  puts " " * ind + "enemy(no cheat)"
  display( $shots_grid )
  puts " " * ind + "player"
  display( $player_grid )
  puts
end

def hud
  case $debug
  when 0
    player_hud
  when 1
    debug_hud
  end
end


# TRANSALATE
#
# translate a 2d array index(ii) to a grid position(pos)
def to_pos( ii )
  pos = "#{INDEX_ALPHA[ ii[0] ]}#{ii[1] + 1}"
end

# POSITIONING
# all positions here use the 2d index coordinates "ii"
# while terminology used is still "position" and "pos"
#
# choose a random position on array-map
def random_pos
  [ INDEX[ rand( INDEX.size ) ], INDEX[ rand( INDEX.size ) ] ] # [ i1, i2 ]
end

# return all positions on 10x10 grid next to another position
def next_to( ii )
  i1    = ii[0]
  i2    = ii[1]
  up    = [ i1, i2 - 1 ]
  down  = [ i1, i2 + 1 ]
  left  = [ i1 - 1, i2 ]
  right = [ i1 + 1, i2 ]
  
  if ii == [ 0, 0 ]    # top left
    a = [ down, right ]
  elsif ii == [ 0, 9 ] # bottom left
    a = [ up, right ]
  elsif ii == [ 9, 0 ] # top right
    a = [ down, left ]
  elsif ii == [ 9, 9 ] # bottom right
    a = [ up, left ]
  elsif i2 == 0        # top
    a = [ down, left, right ]
  elsif i2 == 9        # bottom
    a = [ up, left, right ]
  elsif i1 == 0        # left
    a = [ up, down, right ]
  elsif i1 == 9        # right
    a = [ up, down, left ]
  else                 # all other positions
    a = [ up, down, left, right ]
  end
end

# return horizontal/vertical direction of any two grid positions
def direction( one, two )
  if one[1] == two[1]
    d = "v"
  elsif one[0] == two[0]
    d = "h"
  end
end

# return the bordering positions on either end of two ordered end positions
def ends( first, last )
  if direction( first, last ) == "v"

    if first[0] == 0   # borders left
      a = [ [ last[0] + 1, last[1] ] ]
    elsif last[0] == 9 # borders right
      a = [ [ first[0] - 1, first[1] ] ]
    else               # no borders
      a = [ [ first[0] - 1, first[1] ], [ last[0] + 1, last[1] ] ]
    end

  elsif direction( first, last ) == "h"

    if first[1] == 0   # borders top
      a = [ [ last[0], last[1] + 1 ] ]
    elsif last[1] == 9 # borders bottom
      a = [ [ first[0], first[1] - 1 ] ]
    else               # no borders
      a = [ [ first[0], first[1] - 1 ], [ last[0], last[1] + 1 ] ]
    end

  end  
end

# randomly generate two in a row
def random_two
  p1 = random_pos
  p2 = a_rand( next_to( p1 ) )
  return [ p1, p2 ].sort
end

# randomly generate three in a row
def random_three
  r = random_two
  p = a_rand( ends( r.first, r.last ) )
  return [ r[0], r[1], p ].sort
end

# randomly generate four in a row
def random_four
  r = random_three
  p = a_rand( ends( r.first, r.last ) )
  return [ r[0], r[1], r[2], p ].sort
end

# randomly generate five in a row
def random_five
  r = random_four
  p = a_rand( ends( r.first, r.last ) )
  return [ r[0], r[1], r[2], r[3], p ].sort
end

# wrapper for random_#'s
def random_series( num )
  case num
  when 2
    random_two
  when 3
    random_three
  when 4
    random_four
  when 5
    random_five
  end
end

# READING/WRITING
def grid_value( grid, ii )
  grid[ii[0]][ii[1]]
end

def set_grid_value( grid, ii, value )
  grid[ii[0]][ii[1]] = value
end

def place_ship( num, value, grid )
  l = 0

  until l == num
    a = []
    r = random_series( num )
    r.each { |e| a.push( grid[e[0]][e[1]] ) }
    l = a.join.scan( DEFAULT ).length
  end

  r.each { |e| set_grid_value( grid, e, value ) }
end

def place_all_ships( grid )
  SHIPS.values.map { |num, sym| place_ship( num, sym, grid ) }
end


# GAMEPLAY

def intro
  clear
  puts "\n\n                                                Welcome\n\n"
  sleep 1
  puts "                                                   To"
  puts "\n                                        C O M A N D _ L I N E"
  sleep 1
  puts "\n    ~~~~~           ~~      ~~~~~~~~~  ~~~~~~~~~  ~       ~~~~~   ~~~~~   ~      ~  ~~~~~~~~~  ~~~~~
    ~    ~         ~  ~         ~          ~      ~       ~      ~        ~      ~      ~      ~    ~   
    ~     ~       ~    ~        ~          ~      ~       ~     ~         ~      ~      ~      ~     ~  
    ~    ~       ~      ~       ~          ~      ~       ~      ~        ~      ~      ~      ~    ~ 
    ~~~~~       ~~~~~~~~~~      ~          ~      ~       ~~~~~   ~~~~    ~~~~~~~~      ~      ~~~~~       
    ~    ~     ~          ~     ~          ~      ~       ~           ~   ~      ~      ~      ~       
    ~     ~   ~            ~    ~          ~      ~       ~            ~  ~      ~      ~      ~       
    ~    ~   ~              ~   ~          ~      ~       ~           ~   ~      ~      ~      ~       
    ~~~~~   ~                ~  ~          ~      ~~~~~~  ~~~~~  ~~~~~    ~      ~  ~~~~~~~~~  ~\n\n"
  puts "\n                                                 ~
                                                 ~~
                                                 ~~~
                                                 ~
                                                 ~
                                     ~~~~       ~ ~                            
                           ~~~      ~    ~     ~   ~                ~~~~~~~~~~~~~
                            ~  ~~~~~      ~~~~~     ~~~~~~~~~~~~~~~            ~ 
                             ~                                                ~
                               ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  sleep 1
  puts "\n\n                                                Created by" 
  puts"                                              Roark Brewster" 
  puts"                                                  (2012)"
  sleep 2
  puts "\n\n"
end

def game_setup
  $cheat    = yes_no( "Do you wish to play in \"cheat mode\"") unless $debug == 1
  $go_first = yes_no( "Do you wish to go first" )

  # place player ships
  a = ""
  
  10.times do
    unless a == "yes"
      $player_grid = grid
      clear
      puts "Loading your game, please wait..."
      sleep 3 unless $debug == 1
      clear
      place_all_ships( $player_grid )
      key
      display( $player_grid )
      a = yes_no( "Your ships have been placed.  Do you accept this configuration" )
    end
  end

  unless a == "yes"
    puts "\nThere is just no pleasing you is there?, Goodbye.\n\n"
    exit
  end
  
  # place enemy ships
  place_all_ships( $enemy_grid )
  
  # save enemy grid positions to track on $shots_grid when sunk
  $enemy_ships.each do |k,v|
    grid_indexes.each { |e| v.push( e ) if grid_value( $enemy_grid, e ) == k }
  end
end

# "who" is the one getting attacked
# assumes uncharted position
def damage( who, ii ) #=>( :player, [ 1, 2 ] )
  case who
  when :player
    ships_grid = $player_grid
    track_grid = $ai_grid
    words  = [ "I", "your", "You lose" ]
  when :enemy
    ships_grid = $enemy_grid
    track_grid = $shots_grid
    words  = [ "You", "my", "You win" ]
  end
  
  old_v = grid_value( ships_grid, ii )

  # hit/miss?
  if old_v == DEFAULT
    new_v = MISS
    puts "Miss\n\n"
  else
    new_v = HIT
    puts "Hit\n\n"
  end

  set_grid_value( ships_grid, ii, new_v )
  set_grid_value( track_grid, ii, new_v )
  
  if new_v == HIT

    if who == :player
      $stored_ii = []
    end

    # if sunk
    if ships_grid.flatten.count( old_v ) == 0
      # add to sunken array
      $sunken_ships[ who ].push( old_v )
      
      case who
      when :player # track it on $ai_grid
        ai_sunk( old_v )
      when :enemy  # track it on $shots_grid
        $enemy_ships[ old_v ].each { |e| set_grid_value( $shots_grid, e, old_v ) }
      end
      
      # get ship display name and announce sink
      a = SHIPS.values.flatten
      i = a.index( old_v ) + 1
      puts "#{words[0]} sunk #{words[1]} #{a[i]}!\n\n"
       
      # win/lose?
      if $sunken_ships[ who ].count == 5
        hud
        puts "\n#{words[2]} !!!\n\n"
        exit
      end
    end
  end
end

# iis is an array of 2d indexes(ii)
# returns subset of ii's from iis that point to 'DEFAULT' values on grid
def available_pos( iis, grid )
  a = []
  iis.each { |e| a.push( e ) if grid_value( grid, e ) == DEFAULT }
  return a
end

def enemy_move
  # get ii's of all hits("x") on AI grid
  # they will already be ordered
  hits = []
  grid_indexes.each { |e| hits.push( e ) if grid_value( $ai_grid, e ) == HIT }
  
  if hits.length == 0
    # make random available move
    l = 0

    until l == 1
      p = available_pos( [ random_pos ], $ai_grid )
      l = p.length
    end

    move = p.flatten
  elsif hits.length == 1
    # make random available move next to only hit
    move = a_rand( available_pos( next_to( hits[0] ), $ai_grid ) )
  else # > 1
    i1s = [] # i1's
    i2s = [] # i2's

    hits.each do |e|
      i1s.push( e[0] )
      i2s.push( e[1] )
    end
    
    # if hits are in a row
    if i1s.uniq.length == 1 or i2s.uniq.length == 1
      b = available_pos( ends( hits.first, hits.last ), $ai_grid )
      
      # if available ends
      if b.length > 0
        move = a_rand( b )
      # no available ends, branch off for first time
      elsif $stored_ii.length == 0
        l = 0

        until l == 2
          r = a_rand( hits )
          move = a_rand( available_pos( next_to( r ), $ai_grid ) )
          l = move.length
        end

        # assume it's a miss, then clear $stored_ii later if not
        $stored_ii = r
      # no available ends, last branch off attempt resulted in a miss
      # try again from same branch point, there should only be one available position left
      else
        move = a_rand( available_pos( next_to( $stored_ii ), $ai_grid ) )
      end
    
    # not in a row because you already branched off and got at least one hit
    else
      # hash of occurrences of element in index array
      i1_occur = i1s.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
      i2_occur = i2s.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
      
      # seperate hits into 2 arrays by the axis they reside on
      hits_axis1 = []
      hits_axis2 = []

      hits.each do |e|
        hits_axis1.push( e ) if e[0] == i1s.sort_by { |v| i1_occur[v] }.last
        hits_axis2.push( e ) if e[1] == i2s.sort_by { |v| i2_occur[v] }.last
      end
      
      # get all available ends of both axes of hits (though only one have any) 
      b = []
      [ hits_axis1, hits_axis2 ].each { |e| b.push( available_pos( ends( e.first, e.last ), $ai_grid ) ) }
      # and choose a random one
      move = a_rand( b.flatten(1) )
    end
  end
  
  puts "\nEnemy moves: #{to_pos( move )}"
  $last_move = move
  return move
end

# count last # of HIT spaces from last move and mark AI grid with ship symbol
def ai_sunk( symbol )
  p1     = $last_move
  vals   = SHIPS.values.flatten
  length = vals[ vals.index( symbol ) - 1 ]
  
  # there should only be one hit next to $last_move
  p2 = []
  next_to( p1 ).each { |e| p2.push( e ) if grid_value( $ai_grid, e ) == HIT }
  p2.flatten!(1)
  
  # if destroyer then stop there
  if length == 2
    ship = [ p1, p2 ]
  else
    ship = [ p1 ]

    # determine direction of rest of ship, count in that direction to build ship array
    case direction( p1, p2 )
    when "h"
      
      if p1[1] > p2[1]    # count down (left)
        ( length - 1 ).times { ship.push( [ p1[0], ship.last[1] - 1 ] ) }
      elsif p1[1] < p2[1] # count up (right)
        ( length - 1 ).times { ship.push( [ p1[0], ship.last[1] + 1 ] ) }
      end
      
    when "v"
      
      if p1[0] > p2[0]    # count down (up)
        ( length - 1 ).times { ship.push( [ ship.last[0] - 1, p1[1] ] ) }
      elsif p1[0] < p2[0] # count up (down)
        ( length - 1 ).times { ship.push( [ ship.last[0] + 1, p1[1] ] ) }
      end
    end  
  end
  ship.each { |e| set_grid_value( $ai_grid, e, symbol ) }
end

def player_turn
  damage( :enemy, player_input )
end

def enemy_turn
  damage( :player, enemy_move )
end

def play
  loop do
    player_turn
    sleep 1 unless $debug == 1
    enemy_turn
    hud
  end
end



## MAIN
def main 
  intro unless $debug == 1
  game_setup

  case $go_first
  when "yes"
    hud
    play
  when "no"
    enemy_turn
    hud
    play
  end
end

main
