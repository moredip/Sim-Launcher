require 'uri'
require 'cgi'
require 'net/http'

module SimLauncher
  class Client
    DEFAULT_SERVER_URI = "http://localhost:8881"

    def initialize( app_path, sdk, family )
      @app_path = File.expand_path( app_path )
      @sdk = sdk
      @family = family
      self.server_uri = DEFAULT_SERVER_URI
    end

    def self.for_ipad_app( app_path, sdk = nil )
      self.new( app_path, sdk, 'ipad' )
    end

    def self.for_iphone_app( app_path, sdk = nil )
      self.new( app_path, sdk, 'iphone' )
    end

    def server_uri=(uri)
      @server_uri = URI.parse( uri.to_s )
    end

    def launch(restart=false)
      begin
        full_request_uri = launch_uri(restart)
        puts "requesting #{full_request_uri}" if $DEBUG
        response = Net::HTTP.get( full_request_uri )
        puts "iphonesim server reponded with:\n#{response}" if $DEBUG
      rescue => ex
        puts "There was an error reaching the sim launcher proxy, which is a little sinatra web app that ships with this Gem.  Make sure that it is running and operational.\n"
        puts "The error was:\n"
        puts ex.to_s
      end
    end

    def relaunch
      launch(true)
    end

    # check that there appears to be a server ready for us to send commands to
    def ping
      # our good-enough solution is just request the list of available iOS sdks and
      # check that we get a 200 response 
      begin
        uri = list_sdks_uri
        Net::HTTP.start( uri.host, uri.port) do |http|
          response = http.head(uri.path)
          return response.is_a? Net::HTTPOK
        end
      rescue
        return false
      end
    end

    private

    def launch_uri(requesting_restart)
      full_request_uri = @server_uri.dup
      full_request_uri.path = "/launch_#{@family}_app"
      full_request_uri.query = "app_path=" + CGI.escape( @app_path )
      full_request_uri.query += "&sdk=" + CGI.escape( @sdk ) unless @sdk.nil?
      full_request_uri.query += "&restart=" + (!!requesting_restart).to_s
      full_request_uri
    end

    def list_sdks_uri
      full_request_uri = @server_uri.dup
      full_request_uri.path = "/showsdks"
      full_request_uri
    end
  end
end
