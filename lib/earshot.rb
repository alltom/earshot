
require "ruck"
require "logger"

CONFIG = {}

require File.join(File.dirname(__FILE__), "earlog")
require File.join(File.dirname(__FILE__), "loc")
require File.join(File.dirname(__FILE__), "airspace")
require File.join(File.dirname(__FILE__), "agent")
require File.join(File.dirname(__FILE__), "simulation")
require File.join(File.dirname(__FILE__), "uid")
require File.join(File.dirname(__FILE__), "message")
require File.join(File.dirname(__FILE__), "loader")
require File.join(File.dirname(__FILE__), "earlog")
require File.join(File.dirname(__FILE__), "analyzer")
require File.join(File.dirname(__FILE__), "uid")
require File.join(File.dirname(__FILE__), "binary")
require File.join(File.dirname(__FILE__), "config_loader")

ConfigLoader.load File.join(File.dirname(__FILE__), "..", "config", "default.rb")

ANALYZER = Analyzer.new
EARLOG = EarLog.new(ANALYZER)
