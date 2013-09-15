require "io/console"
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

Options:
        EOS

        opt.on("-v", "--version", "Show version") do
          puts VERSION
        end

        opt.on("-i", "--index", "Index your gists") do
          index
        end

        opt.on("-u", "--auth", "Authorize igist") do
          authorize
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

        opt.on("--clear", "Remove your gists index data locally") do
          clear
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
      puts "Done!"
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

    def clear
      @igist.clear
      puts "Your local index files are deleted!"
    end

    private

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
