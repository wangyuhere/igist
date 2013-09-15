require "spec_helper"
require "fileutils"

describe "IGist" do

  let(:igist) {
    path = File.expand_path("tmp", File.dirname(__FILE__))
    FileUtils.rm_rf(path)
    IGist::IGist.new(path: path, api: double("api"))
  }

  after(:each) do
    FileUtils.rm_rf(igist.path)
  end

  shared_context "index" do
    let(:gists) { load_json_fixture :gists }
    let(:starred_gists) { load_json_fixture :starred_gists }

    def add_index
      each_my_gist = receive(:each_my_gist)
      gists.each { |g| each_my_gist.and_yield(g) }
      allow(igist.api).to each_my_gist

      each_starred_gist = receive(:each_starred_gist)
      starred_gists.each { |g| each_starred_gist.and_yield(g) }
      allow(igist.api).to each_starred_gist

      igist.index
    end
  end

  describe "authorize" do
    it "should call api authorize, save username and token to json file" do
      token_data = {username: "test", token: "token"}
      password = "password"

      allow(igist.api).to receive(:create_authorization).with(token_data[:username], password).and_yield("token" => token_data[:token])
      igist.authorize(token_data[:username], password)
      expect(File.read(igist.token_file)).to eql(token_data.to_json)
    end
  end

  describe "index" do
    include_context "index"
    it "should write gists and starred gists data and index files" do
      add_index
      expect(File.exists?(igist.my_gists_index_file)).to be_true
      expect(File.exists?(igist.starred_gists_index_file)).to be_true
      expect(igist.my_gists.size).to eql(gists.size)
    end
  end

  describe "search" do
    include_context "index"
    it "should search the gists description based on keyword" do
      add_index
      result = igist.search("sh")
      expect(result.size).to eql(2)
      expect(result.first[:id]).to eql("2926498")
      expect(result.last[:id]).to eql("2926422")
      expect(igist.search_starred("sh").size).to eql(2)
    end
  end

  describe "clear" do
    include_context "index"
    it "should delete data and index files" do
      add_index
      igist.clear
      files = [:my_gists_file, :my_gists_index_file, :starred_gists_file, :starred_gists_index_file]
      files.each { |f| expect(File.exists?(igist.send(f))).to be_false }
    end
  end
end
