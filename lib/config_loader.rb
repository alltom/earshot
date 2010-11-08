
class ConfigLoader
  def method_missing(a, b)
    CONFIG[a] = b
  end
  
  def self.load filename
    dsl = new
    dsl.instance_eval(File.read(filename), filename)
  end
end
