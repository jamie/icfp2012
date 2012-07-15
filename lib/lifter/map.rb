class Lifter::Map
  MAPCHARS = {
    'R' => :robot,
    '#' => :wall,
    '*' => :rock,
    '\\' => :lambda,
    'L' => :closed_lift,
    'O' => :open_lift,
    '.' => :earth,
    ' ' => :empty
  }
  
  def initialize(map, lambdas=0, moves=0)
    @lambdas = lambdas
    @moves = moves
    @aborted = @won = false
    @map = []
    map.split("\n").each do |line|
      @map.unshift line.split(//).map{|c| MAPCHARS[c]}
    end
  end
  
  def to_s(include_score = true)
    out = @map.map{|line| line.map{|tile| MAPCHARS.key(tile)}.join}.reverse.join("\n")
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
  
  def robot
    position(:robot)
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
    if [:empty, :earth, :lambda, :open_lift].include? next_tile
      set_map(:empty, *robot)
      set_map(:robot, *next_pos)
      @lambdas += 1 if next_tile == :lambda
      @won = true if next_tile == :open_lift
    end
    update_environment
  end
  
  def try_open_lift
    if @map.flatten.count(:lambda) == 0
      lift = position(:closed_lift)
      set_map(:open_lift, *lift)
    end
  end
  
  def update_environment
    @map.each_with_index do |row, y|
      row.each_with_index do |tile, x|
        update_environment_cell(x, y)
      end
    end
  end
  
  def update_environment_cell(x, y)
    case map(x,y)
      when :rock
        if map(x,y-1) == :empty
          set_map(:empty, x, y)
          set_map(:rock, x, y-1)
        elsif map(x,y-1) == :rock
          if map(x+1,y) == :empty && map(x+1,y-1) == :empty
            set_map(:empty, x, y)
            set_map(:rock, x+1, y-1)
          elsif map(x-1,y) == :empty && map(x-1,y-1) == :empty
            set_map(:empty, x, y)
            set_map(:rock, x-1, y-1)
          end
        elsif map(x,y-1) == :lambda
          if map(x+1,y) == :empty && map(x+1,y-1) == :empty
            set_map(:empty, x, y)
            set_map(:rock, x+1, y-1)
          end
        end
      when :closed_lift
        if @map.flatten.count(:lambda) == 0
          set_map(:open_lift, x, y)
        end
    end
  end
end
