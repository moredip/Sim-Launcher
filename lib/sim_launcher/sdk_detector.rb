require 'singleton'

module SimLauncher
  class SdkDetector
    include Singleton

    def latest_sdk_version
      unless @latest_sdk_version
        latest_iphone_sdk = `xcodebuild -showsdks | grep -o "iphonesimulator.*$"`.split.sort.last
        @latest_sdk_version = latest_iphone_sdk[/iphonesimulator(.*)/,1]
      end
      @latest_sdk_version
    end

  end
end
