class Lifter < Thor
  desc "sim MAP ROUTE", "Simulate a map"
  def sim(map, route)
    require './lib/lifter'
    ::Lifter::Simulator.new(File.read(map), route).simulate
  end
  
  desc "solve MAP", "Solve a map and output the robot commands and score"
  def solve(map)
    require './lib/lifter'
    solver = ::Lifter::Solver.new(File.read(map))
    solver.solve
    puts solver.solution
  end
  
  desc "solve:all", "Solve all maps in test/*.map, and output robot commands and score"
  def solve_all
    
  end
end
