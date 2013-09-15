require "igist"

def load_json_fixture(name)
  path = File.expand_path("fixtures", File.dirname(__FILE__))
  file = File.join(path, "#{name.to_s}.json")
  JSON.parse(File.read(file))
end
