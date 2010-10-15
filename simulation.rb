class Array
  def sample
    self[rand self.length]
  end
end


class Simulation
  attr_reader :agents
  attr_reader :airspace

  def initialize
    @airspace = Airspace.new
    @agents = []

    @shreduler = Ruck::Shreduler.new
    @shreduler.make_convenient
  end

  def add_agent(loc=nil)
    loc ||= Loc.new((rand * CONFIG[:width_m]).to_i, (rand * CONFIG[:height_m]).to_i)
    agent = MovingAgent.new(loc, @airspace)
    EARLOG.born(agent)
    @agents << agent
    @airspace << agent
    agent.start
    agent
  end

  def advance
    @shreduler.run_until(Time.now - @start_time)
  end
  
  def start
    @start_time = Time.now
    @agents.each { |t| t.start }

    # every so often, introduce one agent to another
    spork_loop do
      Ruck::Shred.yield(rand * 1.0/CONFIG[:intros_per_second])
      
      a = @agents.sample
      b = (@agents - [a]).sample
      a.meet(b)
    end
  end
end
