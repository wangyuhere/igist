require "spec_helper"

describe "Search" do
  include IGist::Search

  let(:data) {
    {
      "1" => "a b a",
      "2" => "b c b",
      "3" => "c"
    }
  }

  let(:index) {
    {
      "a" => ["1"],
      "b" => ["1", "2"],
      "c" => ["2", "3"]
    }
  }

  describe "build_index" do
    it "should build inverse index" do
      expect(build_index(data)).to eql(index)
    end
  end

  describe "search_index" do
    it "should return correct search result" do
      expect(search_index(index, "a")).to eql(["1"])
      expect(search_index(index, "a b")).to eql(["1", "2"])
      expect(search_index(index, "xxx")).to eql([])
    end
  end
end