
class Simulation
  attr_reader :transceivers

  def initialize
    @airspace = Airspace.new
    @transceivers = (1..TRANSCEIVER_COUNT).map { Transceiver.new(Loc.new((rand * WIDTH).to_i, (rand * HEIGHT).to_i), @airspace) }
    @transceivers += (1..CHATTY_TRANSCEIVER_COUNT).map { ChattyTransceiver.new(Loc.new((rand * WIDTH).to_i, (rand * HEIGHT).to_i), @airspace) }
    @transceivers.each { |t| @airspace << t }

    @shreduler = Ruck::Shreduler.new
    @shreduler.make_convenient
  end

  def add_transceiver(loc=nil)
    loc ||= Loc.new((rand * WIDTH).to_i, (rand * HEIGHT).to_i)
    transceiver = Transceiver.new(loc, @airspace)
    @transceivers << transceiver
    @airspace << transceiver
    transceiver.start
  end

  def advance
    $shreduler.run_until(Time.now - $start_time)
  end
  
  def start
    @airspace.start
    @transceivers.each { |t| t.start }
  end
end
