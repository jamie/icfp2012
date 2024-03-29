class Lifter::Map
  attr_reader :lambdas, :moves

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
    @dead = false
    @aborted = @won = false
    @map = map.split("\n").reverse
  end
  
  def to_s(include_score = false)
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
    score += @lambdas if !dead?
    score += @lambdas if won?
    score * 25 - @moves
  end
  
  def solver_score
    @lambdas * 10 - @moves
  end
  
  def dead?
    @dead
  end
  def won?
    position(CLOSED_LIFT).nil? && position(OPEN_LIFT).nil?
  end
  
  def tell_robot(command)
    command.split(//).each do |cmd|
      raise "Commands after execution aborted!" if @aborted
      raise "Commands after robot was crushed!" if dead?
      @moves += 1
      send({
        "A" => :abort,
        "D" => :move_down,
        "L" => :move_left,
        "R" => :move_right,
        "U" => :move_up,
        "W" => :wait
      }[cmd])
      update_environment
    end
  end
  
  def position(thing)
    y = @map.index{|line| line.include? thing}
    x = @map[y].index(thing)
    [x,y]
  rescue
    nil
  end
  
  def map(x,y)
    @map[y][x]
  end
  def set_map(v,x,y)
    @map[y][x] = v
  end
  
  def setup_new_map
    @new_map = @map.map{|line| line.dup}
  end
  def set_new_map(v,x,y)
    @new_map[y][x] = v
  end
  def move_new(v, x, y, x2, y2)
    set_new_map(EMPTY, x, y)
    set_new_map(v, x2, y2)
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
    move_to(next_pos)
  end
  
  def move_left
    next_pos = [robot[0] - 1, robot[1]]
    push_pos = [robot[0] - 2, robot[1]]
    push_rock(next_pos, push_pos)
    move_to(next_pos)
  end
  
  def move_right
    next_pos = [robot[0] + 1, robot[1]]
    push_pos = [robot[0] + 2, robot[1]]
    push_rock(next_pos, push_pos)
    move_to(next_pos)
  end
  
  def move_up
    next_pos = [robot[0], robot[1] + 1]
    move_to(next_pos)
  end
  
  def wait
  end
  
  def move_to(next_pos)
    next_tile = map(*next_pos)
    if [EMPTY, EARTH, LAMBDA, OPEN_LIFT].include? next_tile
      set_map(EMPTY, *robot)
      set_map(ROBOT, *next_pos)
      @lambdas += 1 if next_tile == LAMBDA
      @won = true if next_tile == OPEN_LIFT
    end
  end
  
  def push_rock(next_pos, push_pos)
    if map(*next_pos) == ROCK && map(*push_pos) == EMPTY
      set_map(EMPTY, *next_pos)
      set_map(ROCK, *push_pos)
    end
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
          move_new(ROCK, x, y, x, y-1)
          @dead = true if map(x,y-2) == ROBOT
        elsif map(x,y-1) == ROCK
          if map(x+1,y) == EMPTY && map(x+1,y-1) == EMPTY
            move_new(ROCK, x, y, x+1, y-1)
            @dead = true if map(x+1,y-2) == ROBOT
          elsif map(x-1,y) == EMPTY && map(x-1,y-1) == EMPTY
            move_new(ROCK, x, y, x-1, y-1)
            @dead = true if map(x-1,y-2) == ROBOT
          end
        elsif map(x,y-1) == LAMBDA
          if map(x+1,y) == EMPTY && map(x+1,y-1) == EMPTY
            move_new(ROCK, x, y, x+1, y-1)
            @dead = true if map(x+1,y-2) == ROBOT
          end
        end
      when CLOSED_LIFT
        if @map.flatten.join.split(//).count(LAMBDA) == 0
          set_new_map(OPEN_LIFT, x, y)
        end
    end
  end
end
