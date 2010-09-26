GUI = false

require "./loc"
require "./airspace"
require "./transceiver"
require "./broadcast"

require "rubygems"
require "ruck"
require "logger"
if GUI
  require "tk"
end

include Ruck

LOG = Logger.new(STDOUT)
LOG.level = Logger::INFO # DEBUG, INFO, WARN, ERROR, FATAL

# note: shreds only work in the thread they were created,
#       so you have to make shreds in Tk's thread
#       (for example, with TkAfter)

# note: all the commented out Tk code is for reference; having to look that stuff up sucks

SECONDS_PER_BIT = 0.1
TRANSMISSION_RADIUS = 100
TRANSCEIVER_COUNT = 40
CHATTY_TRANSCEIVER_COUNT = 1
WIDTH, HEIGHT = 900, 600
SIMULATION_SECONDS = 20 # how long the simulation lasts (in virtual seconds)

MESSAGES = ["HELLO", "OK", "HELP!", "HOW ARE YOU", "GOOD MORNING", "WHAT IS YOUR QUEST?", "SIR OR MADAM, DO YOU HAVE ANY GREY POUPON? I SEEM TO BE FRESH OUT!"]

class Simulation
  def initialize
    @airspace = Airspace.new
    @transceivers = (1..TRANSCEIVER_COUNT).map { Transceiver.new(Loc.new((rand * WIDTH).to_i, (rand * HEIGHT).to_i), @airspace) }
    @transceivers += (1..CHATTY_TRANSCEIVER_COUNT).map { ChattyTransceiver.new(Loc.new((rand * WIDTH).to_i, (rand * HEIGHT).to_i), @airspace) }
    @transceivers.each { |t| @airspace << t }

    @shreduler = Ruck::Shreduler.new
    @shreduler.make_convenient
    
    initialize_interface
  end
  
  def initialize_interface
    if GUI
      # TkButton.new {
      #   text "Hello, world!"
      #   command { puts "Hello, world!" }
      #   pack
      # }

      # TkMessage.new {
      #   text "* Ruby\n* Perl\n* Python"
      #   pack
      # }

      @canvas = TkCanvas.new {
	bg "red"
	height HEIGHT
	width WIDTH
	pack
      }
    
      @transceivers.each do |transceiver|
	transceiver.range_oval = TkcOval.new(@canvas, transceiver.loc.x, transceiver.loc.y, transceiver.loc.x, transceiver.loc.y, "fill" => "red", "width" => TRANSMISSION_RADIUS * 2)
	transceiver.progress_oval = TkcOval.new(@canvas, transceiver.loc.x, transceiver.loc.y, transceiver.loc.x, transceiver.loc.y, "fill" => "red", "width" => 2)
	puts 'hi'
      end
    end
  end
  
  def start
    @airspace.start
    @transceivers.each { |t| t.start }
  end
end

# x1, y1, x2, y2 = 50, 50, 100, 100
# TkcOval.new(c, x1.to_i, y1.to_i, x1.to_i + 4, y1.to_i + 4, 'fill'=>'red')
# TkcLine.new(c, x1.to_i, y1.to_i, x2.to_i, y2.to_i, 'width'=>2 )
# TkcRectangle.new(c, x1.to_i, y1.to_i, x2.to_i, y2.to_i, 'width'=>2 )
# $o = TkcOval.new(c, x1.to_i, y1.to_i, x2.to_i, y2.to_i, 'width'=>2)

@simulation = Simulation.new

if GUI
  TkAfter.new(100, -1, proc { $shreduler.run_until(Time.now - $start_time) }).start
  TkAfter.new(0, 1, proc { @simulation.start }).start

  $start_time = Time.now
  Tk.mainloop
else
  @simulation.start
  $shreduler.run_until(SIMULATION_SECONDS)
end


