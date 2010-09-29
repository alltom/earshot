
class Simulation
  attr_reader :transceivers

  def initialize
    @airspace = Airspace.new
    @transceivers = []

    @shreduler = Ruck::Shreduler.new
    @shreduler.make_convenient
  end

  def add_transceiver(loc=nil)
    loc ||= Loc.new((rand * CONFIG[:width]).to_i, (rand * CONFIG[:height]).to_i)
    transceiver = ChattyTransceiver.new(loc, @airspace)
    @transceivers << transceiver
    @airspace << transceiver
    transceiver.start
    transceiver
  end

  def advance
    $shreduler.run_until(Time.now - $start_time)
  end
  
  def start
    @airspace.start
    @transceivers.each { |t| t.start }
  end
end
