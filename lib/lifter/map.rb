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
    x = @map.index{|line| line.include? thing}
    y = @map[x].index(thing)
    [x,y]
  end
  
  def robot
    position(:robot)
  end
  
  def abort
    @aborted = true
  end
  
  def move_down
    next_pos = [robot[0] - 1, robot[1]]
    update(next_pos)
  end
  
  def move_left
    next_pos = [robot[0], robot[1] - 1]
    update(next_pos)
  end
  
  def move_right
    next_pos = [robot[0], robot[1] + 1]
    update(next_pos)
  end
  
  def move_up
    next_pos = [robot[0] + 1, robot[1]]
    update(next_pos)
  end
  
  def wait
    update_environment
  end
  
  def update(next_pos)
    next_tile = @map[next_pos[0]][next_pos[1]]
    puts next_tile
    if [:empty, :earth, :lambda, :open_lift].include? next_tile
      @map[robot[0]   ][robot[1]   ] = :empty
      @map[next_pos[0]][next_pos[1]] = :robot
      if next_tile == :lambda
        @lambdas += 1
        try_open_lift
      end
      if next_tile == :open_lift
        @won = true
      end
    end
    update_environment
  end
  
  def try_open_lift
    if @map.flatten.count(:lambda) == 0
      lift = position(:closed_lift)
      @map[lift[0]][lift[1]] = :open_lift
    end
  end
  
  def update_environment
  end
end
