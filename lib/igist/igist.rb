require "json"
require "net/https"
require "uri"
require "igist/api"
require "igist/search"

module IGist

  class IGist
    include Search

    attr_reader :path, :token_file, :my_gists_file, :my_gists_index_file, :starred_gists_file, :starred_gists_index_file

    def initialize(options={})
      @path = options[:path] || File.expand_path("~/.igist")
      @token_file = options[:token_file] || File.join(@path, "token")
      @my_gists_file = options[:my_gists_file] || File.join(@path, "my_gists")
      @my_gists_index_file = options[:my_gists_index_file] || File.join(@path, "my_gists_index")
      @starred_gists_file = options[:starred_gists_file] || File.join(@path, "starred_gists")
      @starred_gists_index_file = options[:starred_gists_index_file] || File.join(@path, "starred_gists_index")
      Dir.mkdir(@path) unless File.exists?(@path)
      @api = options[:api]
    end

    # igist is authorized or not
    def has_token?
      api.has_token?
    end

    def api
      if @api.nil?
        token_json = read_json_file(token_file)
        @api = API.new({username: token_json['username'], token: token_json['token']})
      end
      @api
    end

    def my_gists
      @my_gists ||= read_json_file(my_gists_file)
    end

    def starred_gists
      @starred_gists ||= read_json_file(starred_gists_file)
    end

    def my_gists_index
      @my_gists_index ||= read_json_file(my_gists_index_file)
    end

    def starred_gists_index
      @starred_gists_index ||= read_json_file(starred_gists_index_file)
    end

    # authorize igist and save username and token in token file
    def authorize(username, password)
      api.create_authorization(username, password) do |res|
        write_json_file({username: username, token: res["token"]}, token_file)
      end
    end

    # fetch all gists data from api and write data and index files
    def index
      @my_gists = {}
      @starred_gists = {}
      save_gists_data
      save_gists_index
    end

    def search(keyword)
      search_index(my_gists_index, keyword).map { |id| {id: id, description: my_gists[id]} }
    end

    def search_starred(keyword)
      search_index(starred_gists_index, keyword).map { |id| {id: id, description: starred_gists[id]} }
    end

    def clear
      File.delete(my_gists_file, my_gists_index_file, starred_gists_file, starred_gists_index_file)
    end

    private

    def save_gists_data
      api.each_my_gist { |g| @my_gists[g["id"]] = g["description"]}
      api.each_starred_gist { |g| @starred_gists[g["id"]] = g["description"]}
      write_json_file(my_gists, my_gists_file)
      write_json_file(starred_gists, starred_gists_file)
    end

    def save_gists_index
      @my_gists_index = build_index(my_gists)
      @starred_gists_index = build_index(starred_gists)
      write_json_file(my_gists_index, my_gists_index_file)
      write_json_file(starred_gists_index, starred_gists_index_file)
    end

    def read_json_file(file)
      if File.exists?(file)
        JSON.parse(File.read(file))
      else
        {}
      end
    end

    def write_json_file(data, file)
      File.open(file, 'w', 0600) do |f|
        f.write(data.to_json)
      end
    end

  end

end