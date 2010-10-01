class Loader
  attr_reader :simulation

  def initialize
    @simulation = Simulation.new
  end
    
  def size(width, height)
    CONFIG[:width] = width
    CONFIG[:height] = height
  end

  def seconds_per_bit(spb)
    CONFIG[:seconds_per_bit] = spb
  end

  def transceiver_radius(tr)
    CONFIG[:transceiver_radius] = tr
  end

  def transmission_radius(tr)
    CONFIG[:transmission_radius] = tr
  end

  def messages(ms)
    CONFIG[:messages] = ms
  end 

  def agent(x, y)
    return @simulation.add_transceiver(Loc.new(x, y))
  end

  def self.load filename
    dsl = new
    dsl.instance_eval(File.read(filename), filename)
    dsl.simulation
  end
end



