class Lifter::Solver
  def initialize(map)
    @map = map
    @commands = %w(W L R D U)
    @solutions = {map => "A"}
    @best_solution = [0, "A", map]
  end
  
  def solve
    while !Lifter::Map.new(@best_solution[2]).won?
      solve_next
    end
  end
  
  def solve_next
    map = Lifter::Map.new(@map)
    command = @commands.shift
    begin
      map.tell_robot(command)
      p [command, map.score, @commands.size, @solutions.size]
      if @solutions[map.to_s].nil?
        @solutions[map.to_s] = command
        %w(W L R D U).each do |next_cmd|
          @commands << command + next_cmd
        end unless map.dead?
      end
    end
    if map.score > @best_solution[0]
      @best_solution = [map.score, command, map.to_s]
    end
  end
  
  def solution
    @best_solution[1]
  end
end