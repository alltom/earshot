class Array
  def sample
    self[rand self.length]
  end
end


class Simulation
  attr_reader :agents

  def initialize
    @airspace = Airspace.new
    @agents = []

    @shreduler = Ruck::Shreduler.new
    @shreduler.make_convenient
  end

  def add_agent(loc=nil)
    loc ||= Loc.new((rand * CONFIG[:width]).to_i, (rand * CONFIG[:height]).to_i)
    agent = ChattyAgent.new(loc, @airspace)
    @agents << agent
    @airspace << agent
    agent.start
    agent
  end

  def advance
    $shreduler.run_until(Time.now - @start_time)
  end
  
  def start
    @start_time = Time.now
    @airspace.start
    @agents.each { |t| t.start }

    # every so often, introduce one agent to another
    spork_loop do
      Ruck::Shred.yield(rand * 10)
      
      a = @agents.sample
      b = (@agents - [a]).sample
      a.meet(b)
    end
  end
end
