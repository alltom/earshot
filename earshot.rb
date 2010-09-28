require "./loc"
require "./airspace"
require "./transceiver"
require "./broadcast"
require "./simulation"
require "./uid"
require "./message"

require "rubygems"
require "ruck"
require "logger"
require "optparse"

CONFIG = {}

CONFIG[:seconds_per_bit] = 0.5
CONFIG[:transmission_radius] = 50
CONFIG[:transceiver_radius] = 4
CONFIG[:transceiver_count] = 40
CONFIG[:chatty_transceiver_count] = 1
CONFIG[:width], CONFIG[:height] = 900, 600
CONFIG[:simulation_seconds] = 20 # how long the simulations lasts (in virtual seconds)
CONFIG[:messages] = ["HELLO", "OK", "HELP!", "HOW ARE YOU", "GOOD MORNING", "WHAT IS YOUR QUEST?", "SIR OR MADAM, DO YOU HAVE ANY GREY POUPON? I SEEM TO BE FRESH OUT!"]

# parse command-line options and GO!

opts = OptionParser.new
opts.on("--headless", "--no-gui") { CONFIG[:headless] = true }
begin
  opts.parse! ARGV
rescue OptionParser::InvalidOption => e
  $stderr.puts "#{e.reason}: #{e.args.join " "}"
  exit
end

LOG = Logger.new(STDOUT)
LOG.level = Logger::INFO # DEBUG, INFO, WARN, ERROR, FATAL

@simulation = Simulation.new

if CONFIG[:headless]
  @simulation.start
  $shreduler.run_until(CONFIG[:simulation_seconds])
else
  require "gosu"
  require "./animator"
  
  # construct the GUI
  anim = Animator.new

  # anim will render @simulation, and also give it time to run
  anim.sim = @simulation

  # note: shreds only work in the thread they were created
  @simulation.start

  anim.show
end
