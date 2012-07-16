class Lifter < Thor
  desc "sim MAP ROUTE", "Simulate a map"
  def sim(map, route)
    require './lib/lifter'
    ::Lifter::Simulator.new(File.read(map), route).simulate
  end
  
  desc "solve MAP", "Solve a map and output the robot commands and score"
  method_options :profile => false
  def solve(map)
    require './lib/lifter'
    require 'profile' if options[:profile]
    solver = ::Lifter::Solver.new(File.read(map))
    solver.solve(true)
    puts solver.solution
  end
  
  desc "solve_sim MAP", "Solve a map and simulate its output"
  def solve_sim(map)
    require './lib/lifter'
    solver = ::Lifter::Solver.new(File.read(map))
    solver.solve(false)
    puts solver.solution
    ::Lifter::Simulator.new(File.read(map), solver.solution).simulate
  end
  
  desc "solve:all", "Solve all maps in test/*.map, and output robot commands and score"
  def solve_all
    require './lib/lifter'
    Dir['./test/contest*.map'].each do |map|
      solver = ::Lifter::Solver.new(File.read(map))
      time = Time.now
      solver.solve(false)
      time = Time.now - time
      puts "%s (%.2fs): %s" % [map, time, solver.solution]
    end
  end
end
