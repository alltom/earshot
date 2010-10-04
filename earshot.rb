require "./loc"
require "./airspace"
require "./transceiver"
require "./broadcast"
require "./simulation"
require "./uid"
require "./message"
require "./loader"
require "./earlog"

require "rubygems"
require "ruck"
require "logger"
require "optparse"

CONFIG = {}

# parse command-line options and GO!

opts = OptionParser.new
opts.on("--headless", "--no-gui") { CONFIG[:headless] = true }
opts.on("--slow-gl") { CONFIG[:slow_gl] = true } # set to true on systems without OpenGL 1.5
begin
  opts.parse! ARGV
rescue OptionParser::InvalidOption => e
  $stderr.puts "#{e.reason}: #{e.args.join " "}"
  exit
end


LOG = Logger.new(STDOUT)
LOG.level = Logger::ERROR # DEBUG, INFO, WARN, ERROR, FATAL
EARLOG = EarLog.new(STDOUT)

@simulation = Loader::load('scenario.scn')

if CONFIG[:headless]
  @simulation.start
  $shreduler.run_until(CONFIG[:simulation_seconds])
else
  require "gosu"
  require "gl"
  require "glu"
  require "./animator"
  
  # construct the GUI
  anim = Animator.new

  # anim will render @simulation, and also give it time to run
  anim.sim = @simulation

  # note: shreds only work in the thread they were created
  @simulation.start

  anim.show
end
