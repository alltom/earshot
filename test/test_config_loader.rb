
require "helper"

class TestConfigLoader < Test::Unit::TestCase
  def setup
    CONFIG.clear
  end
  
  def test_works
    Tempfile.new do |f|
      f.puts "boogers 5"
      f.flush
      
      ConfigLoader::load(f.path)
      
      assert_equal CONFIG, { :boogers => 5 }
    end
  end
end
