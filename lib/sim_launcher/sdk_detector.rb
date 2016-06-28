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

    def available_device_types
      @simulator.showdevicetypes.chomp.split("\n").map { |device_type_line|
        [device_type_line, Float(device_type_line.split(',').last.strip)]
       }
    end

    def latest_device_type
      available_device_types.sort do |line1, line2| 
        line1.last <=> line2.last 
      end.last.first
    end

  end
end
