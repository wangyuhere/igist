require "io/console"
require "open-uri"
require "optparse"
require "igist/version"
require "igist/igist"

module IGist

  class CLI

    def initialize(igist=nil)
      @igist = igist || IGist.new
    end

    def run
      options = {}
      opts = OptionParser.new do |opt|

        opt.banner = <<-EOS
Index and search your gists on github.

Note: Run "igist -i" before your first search or if your gists are changed.
You can also "igist -i -s KEYWORD" to first index and then search.

Usage: igist [-i|-u|-v]
       igist [-t|-a] -s KEYWORD
       igist -p ID

Options:
        EOS

        opt.on("-v", "--version", "Show version") do
          puts VERSION
          exit
        end

        opt.on("-i", "--index", "Index your gists") do
          index
          exit
        end

        opt.on("-u", "--auth", "Authorize igist") do
          authorize
          exit
        end

        opt.on("-s", "--search KEYWORD", "Search your own gists by keyword in description") do |keyword|
          options[:search] = keyword
        end

        opt.on("-t", "--starred", "Only your starred gists") do
          options[:starred] = true
        end

        opt.on("-a", "--all", "Both your gists and starred gists") do
          options[:all] = true
        end

        opt.on("-p", "--print ID", "Print gist content by gist id") do |id|
          print_gist(id)
          exit
        end

        opt.on("-o", "--open ID", "Open gist in the browser") do |id|
          open_gist(id)
          exit
        end

        opt.on("--clear", "Remove your gists index data locally") do
          clear
          exit
        end

      end

      opts.parse!

      if options[:search]
        search(options)
      end

    end

    def authorize
      puts "Authorize igist and fetch access token from Github."
      print "Github username: "
      username = $stdin.gets.strip
      print "Github password: "
      password = $stdin.noecho(&:gets).strip
      puts ""

      @igist.authorize(username, password)
      puts "Authorized!"
    end

    def index
      authorize unless @igist.has_token?
      puts "Fetching and indexing your gists ..."
      @igist.index
      puts "Indexed #{@igist.my_gists.size} gists and #{@igist.starred_gists.size} starred gists!"
    end

    def search(options)
      keyword = options[:search]

      unless options[:starred]
        print_result("My Own Gists", @igist.search(keyword))
      end

      if options[:all] or options[:starred]
        print_result("My Starred Gists", @igist.search_starred(keyword))
      end
    end

    def print_gist(id)
      gist = @igist.single_gist(id)
      gist['files'].each_pair { |file, data| print_gist_file(file, data) }
    rescue => e
      puts e.message
    end

    def open_gist(id)
      gist = @igist.single_gist(id)
      command = RUBY_PLATFORM =~ /darwin/ ? 'open' : 'firefox'
      `#{command} #{gist["html_url"]}`
    rescue => e
      puts e.message
    end

    def clear
      @igist.clear
      puts "Your local index files are deleted!"
    end

    private

    def print_gist_file(file, data)
      len = file.size
      puts
      puts "*" * len
      puts file
      puts "*" * len
      puts
      puts open(data["raw_url"]).read
    end

    def print_result(title, result)
      puts "#{title}: "
      if result.empty?
        puts "Nothing found."
      else
        result.each { |gist| puts "#{gist[:id]} \t #{gist[:description]}" }
      end
      puts ""
    end

  end

end
