require './lib/lifter'

class String
  def undent(n)
    self.split("\n").map{|line| line[(n)..-1]}.join("\n")
  end
end

describe Lifter::Map do
  describe "#update_environment" do
    it "must drop rocks vertically" do
      map = Lifter::Map.new(<<-MAP.undent(6))
      ######
      # * RO
      #    #
      ######
      MAP
      map.update_environment
      map.to_s(false).must_equal <<-MAP.undent(6)
      ######
      #   RO
      # *  #
      ######
      MAP
    end
    
    it "must roll rocks to the right" do
      map = Lifter::Map.new(<<-MAP.undent(6))
      ######
      # * RO
      # *  #
      ######
      MAP
      map.update_environment
      map.to_s(false).must_equal <<-MAP.undent(6)
      ######
      #   RO
      # ** #
      ######
      MAP
    end
    
    it "must roll rocks to the left if right is blocked" do
      map = Lifter::Map.new(<<-MAP.undent(6))
      ######
      # *.RO
      # *  #
      ######
      MAP
      map.update_environment
      map.to_s(false).must_equal <<-MAP.undent(6)
      ######
      #  .RO
      #**  #
      ######
      MAP
    end
    
    it "must roll rocks to the left if down-right is blocked" do
      map = Lifter::Map.new(<<-MAP.undent(6))
      ######
      # * RO
      # *. #
      ######
      MAP
      map.update_environment
      map.to_s(false).must_equal <<-MAP.undent(6)
      ######
      #   RO
      #**. #
      ######
      MAP
    end
    
    it "must roll rocks right over a lambda" do
      map = Lifter::Map.new(<<-MAP.undent(6))
      ######
      # * RO
      # \\  #
      ######
      MAP
      map.update_environment
      map.to_s(false).must_equal <<-MAP.undent(6)
      ######
      #   RO
      # \\* #
      ######
      MAP
    end
    
    it "updates atomically" do
      map = Lifter::Map.new(<<-MAP.undent(6))
      ######
      #* *RO
      #* * #
      ######
      MAP
      map.update_environment
      map.to_s(false).must_equal <<-MAP.undent(6)
      ######
      #   RO
      #*** #
      ######
      MAP
    end
  end
end
