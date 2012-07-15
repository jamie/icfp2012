require './lib/lifter'

class String
  def undent(n)
    self.split("\n").map{|line| line[(n)..-1]}.join("\n")
  end
end

describe Lifter::Map do
  describe "movement" do
    it "pushes rocks left" do
      map = Lifter::Map.new(<<-MAP.undent(6))
      ######
      # *R O
      #    #
      ######
      MAP
      map.move_left
      map.to_s.must_equal <<-MAP.undent(6)
      ######
      #*R  O
      #    #
      ######
      MAP
    end

    it "pushes rocks right" do
      map = Lifter::Map.new(<<-MAP.undent(6))
      ######
      # R* O
      #    #
      ######
      MAP
      map.move_right
      map.to_s.must_equal <<-MAP.undent(6)
      ######
      #  R*O
      #    #
      ######
      MAP
    end
  end
  
  describe "#update_environment" do
    it "must drop rocks vertically" do
      map = Lifter::Map.new(<<-MAP.undent(6))
      ######
      # * RO
      #    #
      ######
      MAP
      map.update_environment
      map.to_s.must_equal <<-MAP.undent(6)
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
      map.to_s.must_equal <<-MAP.undent(6)
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
      map.to_s.must_equal <<-MAP.undent(6)
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
      map.to_s.must_equal <<-MAP.undent(6)
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
      map.to_s.must_equal <<-MAP.undent(6)
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
      map.to_s.must_equal <<-MAP.undent(6)
      ######
      #   RO
      #*** #
      ######
      MAP
    end

    it "squishes robots" do
      map = Lifter::Map.new(<<-MAP.undent(6))
      ######
      # *  O
      #    #
      # R  #
      ######
      MAP
      map.update_environment
      map.dead?.must_equal true

      map = Lifter::Map.new(<<-MAP.undent(6))
      ######
      # *  O
      # *  #
      # .R #
      ######
      MAP
      map.update_environment
      map.dead?.must_equal true

      map = Lifter::Map.new(<<-MAP.undent(6))
      ######
      # *. O
      # *  #
      #R.  #
      ######
      MAP
      map.update_environment
      map.dead?.must_equal true

      map = Lifter::Map.new(<<-MAP.undent(6))
      ######
      # *  O
      # \\  #
      #  R #
      ######
      MAP
      map.update_environment
      map.dead?.must_equal true
    end
  end
end
