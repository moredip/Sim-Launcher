module SimLauncher
  class SdkDetector

    def initialize(simulator = Simulator.new)
      @simulator = simulator
    end

    def available_sdk_versions
      @simulator.showsdks.split("\n").map { |sdk_line|
        sdk_line[/\(([\d.]+)\)$/,1] # grab any "(x.x)" part at the end of the line
      }.compact
    end

    def latest_sdk_version
      available_sdk_versions.sort.last
    end

  end
end
