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

  def speed(mps)
    CONFIG[:speed_mps] = mps
  end

  def grid(grid_m)
    CONFIG[:grid_m] = grid_m
  end

  def title(t)
    CONFIG[:title] = t
  end

  def intros_per_second(rate)
    CONFIG[:intros_per_second] = rate
  end

  def agent_moves_per_second(rate)
    CONFIG[:agent_moves_per_second] = rate
  end

  def agent_novel_broadcasts_per_second(rate)
    CONFIG[:agent_novel_broadcasts_per_second] = rate
  end

  def agent_relays_per_second(rate)
    CONFIG[:agent_relays_per_second] = rate
  end

  def self.load filename
    dsl = new
    dsl.instance_eval(File.read(filename), filename)
    dsl.simulation
  end
end



