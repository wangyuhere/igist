module IGist
  class API

    def initialize(options={})
      @username = options[:username]
      @token = options[:token]
      @api_uri = URI("https://api.github.com")
    end

    def has_token?
      !@token.nil?
    end

    def create_authorization(username, password)
      request = Net::HTTP::Post.new(authorization_url)
      request.body = JSON.dump({
        scopes: [:gist],
        note: "The igist gem",
        note_url: ""
      })
      request.content_type = "application/json"
      request.basic_auth(username, password)
      response = send_request(request)

      if response.is_a?(Net::HTTPUnauthorized) && response["X-GitHub-OTP"]
        print "two factor authentication code: "
        otp = $stdin.gets.strip
        puts ""
        request["X-GitHub-OTP"] = otp
        response = send_request(request)
      end

      if response.is_a?(Net::HTTPCreated)
        result = JSON.parse(response.body)
        @token = result["token"]
        @username = username
        yield result if block_given?
      else
        raise "Can not authorize because: #{response.body}"
      end
    end

    def each_my_gist(&block)
      each_gist(gists_url, &block)
    end

    def each_starred_gist(&block)
      each_gist(starred_gists_url, &block)
    end

    private

    def each_gist(url, &block)
      request = Net::HTTP::Get.new(url)
      connection.start do |http|
        while true
          response = http.request(request)
          gists = JSON.parse(response.body)
          gists.each { |g| block.call(g) }
          break if response["Links"].nil?
          if match = response["Links"].match(/<(.*)>;\s*rel=\"next\"/)
            request = Net::HTTP::Get.new(match.captures[0])
          else
            raise "Invalid Links format: #{response['Links']}"
          end
        end
      end
    end

    def connection
      connection = Net::HTTP.new(@api_uri.host, @api_uri.port)
      connection.use_ssl = true
      connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      connection.open_timeout = 10
      connection.read_timeout = 10
      connection
    end

    def send_request(request)
      connection.start do |http|
        http.request(request)
      end
    end

    def api_url
      "https://api.github.com"
    end

    def authorization_url
      "#{api_url}/authorizations"
    end

    def gists_url
      append_token "#{api_url}/users/#{@username}/gists"
    end

    def starred_gists_url
      append_token "#{api_url}/gists/starred"
    end

    def append_token(url)
      "#{url}?access_token=#{@token}"
    end

  end
end