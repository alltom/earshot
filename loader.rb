require "./airspace"
require "./simulation"
require "./transceiver"
require "./loc"
require "./uid"
require "ruck"

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
    l = Loc.new(x, y)
    a = @simulation.add_transceiver(l)
    a
  end

  def self.load filename
    dsl = new
    dsl.instance_eval(File.read(filename), filename)
    dsl.simulation
  end
end


