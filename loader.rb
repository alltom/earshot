class Loader
  attr_reader :simulation

  def initialize
    @simulation = Simulation.new
  end
    
  def size(width_m, height_m)
    CONFIG[:width_m] = width_m
    CONFIG[:height_m] = height_m
  end

  def seconds_per_bit(spb)
    CONFIG[:seconds_per_bit] = spb
  end

  def agent_radius(ar)
    CONFIG[:agent_radius_m] = ar
  end

  def transmission_radius(tr)
    CONFIG[:transmission_radius_m] = tr
  end

  def messages(ms)
    CONFIG[:messages] = ms
  end 

  def agent(x, y)
    return @simulation.add_agent(Loc.new(x, y))
  end

  def self.load filename
    dsl = new
    dsl.instance_eval(File.read(filename), filename)
    dsl.simulation
  end
end



