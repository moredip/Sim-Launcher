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

    def self.for_ipad_app( app_path, sdk = '4.2' )
      self.new( app_path, sdk, 'ipad' )
    end

    def self.for_iphone_app( app_path, sdk = '4.2' )
      self.new( app_path, sdk, 'iphone' )
    end

    def server_uri=(uri)
      @server_uri = URI.parse( uri.to_s )
    end

    def launch
      full_request_uri = @server_uri.dup
      full_request_uri.path = "/launch_#{@family}_app"
      full_request_uri.query = "app_path=" + CGI.escape( @app_path ) + "&sdk=" + CGI.escape(@sdk)
      puts "requesting #{full_request_uri}"
      response = Net::HTTP.get( full_request_uri )
      puts "iphonesim server reponded with:\n#{response}"
    end

    def relaunch
      launch
    end

  end
end
