# Simulator Launcher
module SimLauncher
  # SDK Detector
  class SdkDetector

    # Initialize
    # @param [Simulator] simulator Simulator to initialize with
    def initialize(simulator = Simulator.new)
      @simulator = simulator
    end

    # Get available SDK versions
    # @return [String] SDK versions
    def available_sdk_versions
      @simulator.showsdks.split("\n").map { |sdk_line|
        sdk_line[/\(([\d.]+)\)$/,1] # grab any "(x.x)" part at the end of the line
      }.compact
    end

    # Get latest SDK version
    # @return [String] Latest SDK version
    def latest_sdk_version
      available_sdk_versions.sort.last
    end

  end
end
