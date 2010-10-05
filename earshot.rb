require "./loc"
require "./airspace"
require "./agent"
require "./broadcast"
require "./simulation"
require "./uid"
require "./message"
require "./loader"
require "./earlog"
require "./analyzer"

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

CONFIG[:width_px] = 500
CONFIG[:height_px] = 500
CONFIG[:left_margin_px] = 130
CONFIG[:top_margin_px] = 20
CONFIG[:right_margin_px] = 30
CONFIG[:bottom_margin_px] = 20

LOG = Logger.new(STDOUT)
LOG.level = Logger::ERROR # DEBUG, INFO, WARN, ERROR, FATAL
ANALYZER = Analyzer.new
EARLOG = EarLog.new(ANALYZER)

@simulation = Loader::load('scenario.scn')

if CONFIG[:headless]
  @simulation.start
  $shreduler.run_until(CONFIG[:simulation_seconds])
else
  require "gosu"
  require "gl"
  require "glu"
  require "./ui"
  
  # construct the GUI
  ui = UI.new

  # ui will render @simulation, and also give it time to run
  ui.sim = @simulation

  # note: shreds only work in the thread they were created
  @simulation.start

  ui.show
end
