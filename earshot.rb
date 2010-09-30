require "./loc"
require "./airspace"
require "./transceiver"
require "./broadcast"
require "./simulation"
require "./uid"
require "./message"
require "./loader"

require "rubygems"
require "ruck"
require "logger"
require "optparse"

CONFIG = {}

# parse command-line options and GO!

opts = OptionParser.new
opts.on("--headless", "--no-gui") { CONFIG[:headless] = true }
begin
  opts.parse! ARGV
rescue OptionParser::InvalidOption => e
  $stderr.puts "#{e.reason}: #{e.args.join " "}"
  exit
end

# require gosu if using a GUI
unless CONFIG[:headless]
  require "gosu"
  require "./animator"
end

LOG = Logger.new(STDOUT)
LOG.level = Logger::INFO # DEBUG, INFO, WARN, ERROR, FATAL

@simulation = Loader::load('scenario.scn')

if CONFIG[:headless]
  @simulation.start
  $shreduler.run_until(CONFIG[:simulation_seconds])
else
  # construct the GUI
  anim = Animator.new

  # anim will render @simulation, and also give it time to run
  anim.sim = @simulation

  $start_time = Time.now
  @simulation.start

  anim.show
end
