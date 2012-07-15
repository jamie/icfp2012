class Lifter::Map
  ROBOT       = 'R'
  WALL        = '#'
  ROCK        = '*'
  LAMBDA      = '\\'
  CLOSED_LIFT = 'L'
  OPEN_LIFT   = 'O'
  EARTH       = '.'
  EMPTY       = ' '
  
  def initialize(map, lambdas=0, moves=0)
    @lambdas = lambdas
    @moves = moves
    @aborted = @won = false
    @map = map.split("\n").reverse
  end
  
  def to_s(include_score = true)
    out = @map.reverse.join("\n")
    return out unless include_score
    [
      out,
      "",
      "Lambdas: %d, Moves: %d, Score: %d" % [@lambdas, @moves, score]
    ].join("\n")
  end
  
  def score
    score = @lambdas
    score *= 2 if @aborted
    score *= 3 if @won
    score * 25 - @moves
  end
  
  def tell_robot(command)
    raise "Commands after execution aborted!" if @aborted
    @moves += 1
    send({
      "A" => :abort,
      "D" => :move_down,
      "L" => :move_left,
      "R" => :move_right,
      "U" => :move_up,
      "W" => :wait
    }[command])
  end
  
  def position(thing)
    y = @map.index{|line| line.include? thing}
    x = @map[y].index(thing)
    [x,y]
  end
  
  def map(x,y)
    @map[y][x]
  end
  def set_map(v,x,y)
    @map[y][x] = v
  end
  
  def setup_new_map
    @new_map = @map.clone
  end
  def set_new_map(v,x,y)
    @new_map[y][x] = v
  end
  def finalize_new_map
    @map = @new_map
  end
  
  def robot
    position(ROBOT)
  end
  
  def abort
    @aborted = true
  end
  
  def move_down
    next_pos = [robot[0], robot[1] - 1]
    update(next_pos)
  end
  
  def move_left
    next_pos = [robot[0] - 1, robot[1]]
    update(next_pos)
  end
  
  def move_right
    next_pos = [robot[0] + 1, robot[1]]
    update(next_pos)
  end
  
  def move_up
    next_pos = [robot[0], robot[1] + 1]
    update(next_pos)
  end
  
  def wait
    update_environment
  end
  
  def update(next_pos)
    next_tile = map(*next_pos)
    puts next_tile
    if [EMPTY, EARTH, LAMBDA, OPEN_LIFT].include? next_tile
      set_map(EMPTY, *robot)
      set_map(ROBOT, *next_pos)
      @lambdas += 1 if next_tile == LAMBDA
      @won = true if next_tile == OPEN_LIFT
    end
    update_environment
  end
  
  def try_open_lift
    if @map.flatten.count(LAMBDA) == 0
      lift = position(CLOSED_LIFT)
      set_map(OPEN_LIFT, *lift)
    end
  end
  
  def update_environment
    setup_new_map
    @map.each_with_index do |row, y|
      row.size.times do |x|
        update_environment_cell(x, y)
      end
    end
    finalize_new_map
  end
  
  def update_environment_cell(x, y)
    case map(x,y)
      when ROCK
        if map(x,y-1) == EMPTY
          set_new_map(EMPTY, x, y)
          set_new_map(ROCK, x, y-1)
        elsif map(x,y-1) == ROCK
          if map(x+1,y) == EMPTY && map(x+1,y-1) == EMPTY
            set_new_map(EMPTY, x, y)
            set_new_map(ROCK, x+1, y-1)
          elsif map(x-1,y) == EMPTY && map(x-1,y-1) == EMPTY
            set_new_map(EMPTY, x, y)
            set_new_map(ROCK, x-1, y-1)
          end
        elsif map(x,y-1) == LAMBDA
          if map(x+1,y) == EMPTY && map(x+1,y-1) == EMPTY
            set_new_map(EMPTY, x, y)
            set_new_map(ROCK, x+1, y-1)
          end
        end
      when CLOSED_LIFT
        if @map.flatten.count(LAMBDA) == 0
          set_new_map(OPEN_LIFT, x, y)
        end
    end
  end
end
