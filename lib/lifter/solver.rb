class Lifter::Solver
  def initialize(map)
    @map = map
    @commands = {0 => %w(W L R D U)}
    @solutions = {map => "A"}
    @best_solution = [0, "A", map]
  end
  
  def solve
    i=0
    while !Lifter::Map.new(@best_solution[2]).won?
      i += 1
      solve_next(i == 1000)
      i %= 1000
    end
  end
  
  def solve_next(noisy=false)
    map = Lifter::Map.new(@map)
    best_score = @commands.keys.max
    command = @commands[best_score].shift
    @commands.delete(best_score) if @commands[best_score].empty?
    begin
      map.tell_robot(command)
      p [command, map.score, map.solver_score, @commands.size, @solutions.size] if noisy
      if @solutions[map.to_s].nil?
        @solutions[map.to_s] = command
        %w(L R D U).each do |next_cmd|
          @commands[map.solver_score] ||= []
          @commands[map.solver_score] << command + next_cmd
        end unless map.dead?
      end
    end
    if map.score > @best_solution[0]
      @best_solution = [map.solver_score, command, map.to_s]
    end
  end
  
  def solution
    @best_solution[1]
  end
end