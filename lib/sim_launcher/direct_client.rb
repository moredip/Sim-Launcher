# Simulator Launcher
module SimLauncher
  # Direct Client
  class DirectClient

    # Initialize
    # @param [String] app_path App path
    # @param [String] sdk SDK
    # @param [String] family Device family
    def initialize(app_path, sdk, family)
      @app_path = File.expand_path(app_path)
      @sdk = sdk
      @family = family
    end

    # Direct client for iPad app
    # @param [String] app_path App path
    # @param [String] sdk SDK
    # @return [DirectClient] Direct client object for iPad app
    def self.for_ipad_app(app_path, sdk = nil)
      self.new(app_path, sdk, 'ipad')
    end

    # Direct client for iPhone app
    # @param [String] app_path App path
    # @param [String] sdk SDK
    # @return [DirectClient] Direct client object for iPhone app
    def self.for_iphone_app(app_path, sdk = nil)
      self.new(app_path, sdk, 'iphone')
    end

    # Launch
    def launch
      SimLauncher::Simulator.new.launch_ios_app(@app_path, @sdk, @family)
    end

    # Rotate left
    def rotate_left
      simulator = SimLauncher::Simulator.new
      simulator.rotate_left
    end

    # Rotate right
    def rotate_right
      simulator = SimLauncher::Simulator.new
      simulator.rotate_right
    end

    # Relaunch
    def relaunch
      simulator = SimLauncher::Simulator.new
      simulator.quit_simulator
      simulator.launch_ios_app( @app_path, @sdk, @family )
    end
  end
end
