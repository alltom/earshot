
class Simulation
  attr_reader :transceivers

  def initialize
    @airspace = Airspace.new
    @transceivers = (1..CONFIG[:transceiver_count]).map { Transceiver.new(Loc.new((rand * CONFIG[:width]).to_i, (rand * CONFIG[:height]).to_i), @airspace) }
    @transceivers += (1..CONFIG[:chatty_transceiver_count]).map { ChattyTransceiver.new(Loc.new((rand * CONFIG[:width]).to_i, (rand * CONFIG[:height]).to_i), @airspace) }
    @transceivers.each { |t| @airspace << t }

    @shreduler = Ruck::Shreduler.new
    @shreduler.make_convenient
  end

  def add_transceiver(loc=nil)
    loc ||= Loc.new((rand * CONFIG[:width]).to_i, (rand * CONFIG[:height]).to_i)
    transceiver = Transceiver.new(loc, @airspace)
    @transceivers << transceiver
    @airspace << transceiver
    transceiver.start
  end

  def advance
    $shreduler.run_until(Time.now - @start_time)
  end
  
  def start
    @start_time = Time.now
    @airspace.start
    @transceivers.each { |t| t.start }
  end
end
