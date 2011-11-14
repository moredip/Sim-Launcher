module SimLauncher
  class DirectClient
    def initialize( app_path, sdk, family )
      @app_path = File.expand_path( app_path )
      @sdk = sdk
      @family = family
    end

    def self.for_ipad_app( app_path, sdk = nil )
      self.new( app_path, sdk, 'ipad' )
    end

    def self.for_iphone_app( app_path, sdk = nil )
      self.new( app_path, sdk, 'iphone' )
    end

    def launch
      SimLauncher::Simulator.new.launch_ios_app( @app_path, @sdk, @family ) 
    end

    def relaunch
      simulator = SimLauncher::Simulator.new
      simulator.quit_simulator
      simulator.launch_ios_app( @app_path, @sdk, @family )
    end
  end
end
