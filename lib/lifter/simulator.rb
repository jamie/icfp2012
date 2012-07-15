class Lifter::Simulator
  def initialize(map, solution)
    @map = Lifter::Map.new(map)
    @solution = solution.split(//)
  end

  def clear
    puts "" # "\x1bc"
  end
  
  def simulate
    clear
    puts @map.to_s(true)
    @solution.each do |command|
      sleep 0.2
      @map.tell_robot(command)
      clear
      puts @map.to_s(true)
    end
  end
end
