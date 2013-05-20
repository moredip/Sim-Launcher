module SimLauncher
  class DirectClient

    # @param [String] app_path the app_path to launch.
    # @param [Hash] options the options to launch the app with.
    # @see SimLauncher::Simulator#launch_ios_app Simulator#launch_ios_app for valid options.
    def initialize( app_path, options = {} )
      @app_path = File.expand_path( app_path )
      @options = options
    end

    def self.for_ipad_app( app_path, sdk = nil )
      self.new( app_path, :sdk => sdk, :device => DeviceType::iPad )
    end

    def self.for_iphone_app( app_path, sdk = nil )
      self.new( app_path, :sdk => sdk, :device => DeviceType::iPhone )
    end

    def launch
      SimLauncher::Simulator.new.launch_ios_app( @app_path, @options ) 
    end

    def rotate_left
      simulator = SimLauncher::Simulator.new
      simulator.rotate_left
    end
    
    def rotate_right
      simulator = SimLauncher::Simulator.new
      simulator.rotate_right
    end

    def relaunch
      simulator = SimLauncher::Simulator.new
      simulator.quit_simulator
      simulator.launch_ios_app( @app_path, @options )
    end
  end
end
