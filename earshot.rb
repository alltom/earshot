GUI = true

require "./loc"
require "./airspace"
require "./transceiver"
require "./broadcast"

require "rubygems"
require "ruck"
require "logger"
if GUI
  require "Qt"
end

include Ruck

LOG = Logger.new(STDOUT)
LOG.level = Logger::INFO # DEBUG, INFO, WARN, ERROR, FATAL

# note: shreds only work in the thread they were created,
#       so you have to make shreds in Tk's thread
#       (for example, with TkAfter)

SECONDS_PER_BIT = 0.1
TRANSMISSION_RADIUS = 50
TRANSCEIVER_COUNT = 10
CHATTY_TRANSCEIVER_COUNT = 1
WIDTH, HEIGHT = 900, 600
SIMULATION_SECONDS = 20 # how long the simulation lasts (in virtual seconds)

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

  def advance
    $shreduler.run_until(Time.now - $start_time)
  end
  
  def start
    @airspace.start
    @transceivers.each { |t| t.start }
  end
end


TRANSCEIVER_RADIUS = 5
class Animator < Qt::Widget
  attr_accessor :sim
  slots 'advance_sim()'

  def initialize
    super
    resize(WIDTH, HEIGHT)

    # schedule regular breaks from the GUI to run the shreduler
    shreduler_breaks = Qt::Timer.new
    Qt::Object.connect(shreduler_breaks, SIGNAL(:timeout), self, SLOT(:advance_sim)) 
    shreduler_breaks.start(1000.0/60)
  end

  def advance_sim
    return if @sim.nil?
    @sim.advance
    repaint
  end

  def paintEvent(event)
    return if @sim.nil?

    p = Qt::Painter.new(self)
    @sim.transceivers.each do |t|
      loc = t.loc

      # visualize transceiver's transmissions and range
      r = TRANSMISSION_RADIUS 
      if t.broadcasting?
        color = Qt::Color.new(100, 0, 0, 50)
      else
        color = Qt::Color.new(50, 50, 50, 50)
      end
      p.setBrush(Qt::Brush.new(color))
      p.drawEllipse(Qt::Rect.new(loc.x-r, loc.y-r, r*2, r*2))

      # visualize transceiver
      r = TRANSCEIVER_RADIUS
      color = Qt::blue
      p.setBrush(Qt::Brush.new(color))
      p.drawEllipse(Qt::Rect.new(loc.x-r, loc.y-r, r*2, r*2))

    end
    p.end
  end
end


@simulation = Simulation.new

if GUI
  # construct the GUI
  app = Qt::Application.new(ARGV)
  anim = Animator.new

  # anim will render @simulation, and also give it time to run
  anim.sim = @simulation
  anim.show

  $start_time = Time.now
  @simulation.start

  app.exec
else
  @simulation.start
  $shreduler.run_until(SIMULATION_SECONDS)
end


