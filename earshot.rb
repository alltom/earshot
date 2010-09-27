require "./loc"
require "./airspace"
require "./transceiver"
require "./broadcast"

require "rubygems"
require "ruck"
require "logger"

CONFIG = {}

# parse command-line options and GO!

opts = OptionParser.new
opts.on("--headless", "--no-gui") { CONFIG[:headless] = true }
opts.parse! ARGV

unless CONFIG[:headless]
  require "Qt"
  require "./animator"
end

include Ruck

LOG = Logger.new(STDOUT)
LOG.level = Logger::INFO # DEBUG, INFO, WARN, ERROR, FATAL

# note: shreds only work in the thread they were created,
#       so you have to make shreds in Tk's thread
#       (for example, with TkAfter)

SECONDS_PER_BIT = 0.5
TRANSMISSION_RADIUS = 50
TRANSCEIVER_COUNT = 10
CHATTY_TRANSCEIVER_COUNT = 1
WIDTH, HEIGHT = 900, 600
SIMULATION_SECONDS = 20 # how long the simulation lasts (in virtual seconds);
TRANSCEIVER_RADIUS = 5

MESSAGES = ["HELLO", "OK", "HELP!", "HOW ARE YOU", "GOOD MORNING", "WHAT IS YOUR QUEST?", "SIR OR MADAM, DO YOU HAVE ANY GREY POUPON? I SEEM TO BE FRESH OUT!"]

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


@simulation = Simulation.new

if CONFIG[:headless]
  @simulation.start
  $shreduler.run_until(SIMULATION_SECONDS)
else
  # construct the GUI
  app = Qt::Application.new(ARGV)
  anim = Animator.new

  # anim will render @simulation, and also give it time to run
  anim.sim = @simulation
  anim.show

  $start_time = Time.now
  @simulation.start

  app.exec
end
