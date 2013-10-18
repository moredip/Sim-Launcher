# Simulator Launcher
module SimLauncher

  # Simulator
  class Simulator

    # Initialize
    # @param [Stirng] iphonesim_path_external External iphone simulator path
    def initialize(iphonesim_path_external = nil)
      @iphonesim_path = iphonesim_path_external || iphonesim_path(xcode_version)
    end

    # Display available SKDs
    def showsdks
      run_synchronous_command('showsdks')
    end

    # Start simulator
    # @param [String] sdk_version SKD version (e.g. <i>"6.1"</i>, <i>"7.0"</i>)
    # @param [String] device_family Device family (<i>"iphone"</i>, <i>"ipad"</i>)
    # @param [Hash] options Addtional options to pass to ios-sim executable
    # @option options [nil] :retina  Retina device, use _nil_ value (<i>:retina => nil</i>)
    # @option options [nil] :tall  Tall retina device (4-inch), use _nil_ value (<i>:tall => nil</i>)
    # @option options [String] :env  Environment variables plist file
    # @option options [String] :setenv  Evnironment varible key-valur pair (<i>:setenv => "DEBUG=1"</i>)
    # @example
    #    s = SimLauncher::Simulator.new
    #    # iPad retina, SDK 6.1, load environment variables from env.plist
    #    options = { :retina => nil, :env => "env.plist" }
    #    s.start_simulator("6.1", "ipad", options)
    #    # iPhone tall retina (4-inch), SDK 7.0, set environment variables 'dev' and 'reset' to true
    #    options = { :retina => nil, :tall => nil, :setenv => "dev=true", :setenv => "reset=true" }
    #    s.start_simulator("7.0", "iphone", options)
    #    # Start with no options (backwards compatibility)
    #    s.start_simulator("7.0", "iphone")
    def start_simulator(sdk_version = nil, device_family = "iphone", options = {})
      sdk_version ||= SdkDetector.new(self).latest_sdk_version
      options = options.map { |k, v| ["--#{k.to_s}"] + (v.nil? ? [] : ["#{v}"]) }.flatten
      run_synchronous_command( :start, '--sdk', sdk_version, '--family', device_family, '--exit', *options)
    end

    # Rotate simulator left
    def rotate_left
      script_dir = File.join(File.dirname(__FILE__), "..", "..", "scripts")
      rotate_script = File.expand_path("#{script_dir}/rotate_simulator_left.applescript")
      system("osascript #{rotate_script}")
    end

    # Rotate simulator right
    def rotate_right
      script_dir = File.join(File.dirname(__FILE__), "..", "..", "scripts")
      rotate_script = File.expand_path("#{script_dir}/rotate_simulator_right.applescript")
      system("osascript #{rotate_script}")
    end

    # Reset simulator
    # @param [Array<String>] sdks Array of SDKs to reset simulator for
    def reset(sdks = nil)
      script_dir = File.join(File.dirname(__FILE__), "..", "..", "scripts")
      reset_script = File.expand_path("#{script_dir}/reset_simulator.applescript")

      sdks ||= SimLauncher::SdkDetector.new(self).available_sdk_versions

      sdks.each do |sdk_path_str|
        start_simulator(sdk_path_str, "iphone")
        system("osascript #{reset_script}")
        start_simulator(sdk_path_str, "ipad")
        system("osascript #{reset_script}")
      end

      quit_simulator

    end

    # Launch iOS app with options and arguments
    # @param [String] app_path Application bundle path
    # @param [String] sdk_version SDK version (e.g. <i>"6.1"</i>, <i>"7.0"</i>)
    # @param [String] device_family Device family (<i>"iphone"</i>, <i>"ipad"</i>)
    # @param [Hash] options Addtional options to pass to ios-sim executable (@see start_simulator)
    # @param [Array<String>] app_args Application arguments
    def launch_ios_app_with_options(app_path, sdk_version, device_family, options = {}, app_args = nil)
      if problem = SimLauncher.check_app_path(app_path)
        bangs = '!'*80
        raise "\n#{bangs}\nENCOUNTERED A PROBLEM WITH THE SPECIFIED APP PATH:\n\n#{problem}\n#{bangs}"
      end
      sdk_version ||= SdkDetector.new(self).latest_sdk_version
      options = options.map { |k, v| ["--#{k.to_s}"] + (v.nil? ? [] : ["#{v}"]) }.flatten
      args = ["--args"] + app_args.flatten if app_args
      run_synchronous_command(:launch, app_path, '--sdk', sdk_version, '--family', device_family, '--exit', *options, *args)
    end

    # Launch iOS app with arguments
    # @param [String] app_path Application bundle path
    # @param [String] sdk_version SDK version (e.g. <i>"6.1"</i>, <i>"7.0"</i>)
    # @param [String] device_family Device family (<i>"iphone"</i>, <i>"ipad"</i>)
    # @param [Array<String>] app_args Application arguments
    def launch_ios_app(app_path, sdk_version, device_family, app_args = nil)
      launch_ios_app_with_options(app_path, sdk_version, device_family, {}, app_args)
    end

    # Launch iPad app using app bundle
    # @param [String] app_path Application bundle path
    # @param [String] sdk SDK version (e.g. <i>"6.1"</i>, <i>"7.0"</i>)
    # @param [Hash] options Addtional options to pass to ios-sim executable (@see start_simulator)
    # @param [Array<String>] app_args Application arguments
    def launch_ipad_app(app_path, sdk, options = {}, app_args = nil)
      launch_ios_app_with_options(app_path, sdk, 'ipad', options, app_args)
    end

    # Launch iPad app using app name
    # @param [String] app_name Application name
    # @param [String] sdk SDK version (e.g. <i>"6.1"</i>, <i>"7.0"</i>)
    # @param [Hash] options Addtional options to pass to ios-sim executable (@see start_simulator)
    # @param [Array<String>] app_args Application arguments
    def launch_ipad_app_with_name(app_name, sdk, options = {}, app_args = nil)
      app_path = SimLauncher.app_bundle_or_raise(app_name)
      launch_ios_app_with_options(app_path, sdk, 'iphone', options, app_args)
    end

    # Launch iPhone app using app bundle
    # @param [String] app_path Application bundle path
    # @param [String] sdk SDK version (e.g. <i>"6.1"</i>, <i>"7.0"</i>)
    # @param [Hash] options Addtional options to pass to ios-sim executable (@see start_simulator)
    # @param [Array<String>] app_args Application arguments
    def launch_iphone_app(app_path, sdk, options = {}, app_args = nil)
      launch_ios_app_with_options(app_path, sdk, 'iphone', options, app_args)
    end

    # Launch iPhone app using app name
    # @param [String] app_name Application name
    # @param [String] sdk SDK version (e.g. <i>"6.1"</i>, <i>"7.0"</i>)
    # @param [Hash] options Addtional options to pass to ios-sim executable (@see start_simulator)
    # @param [Array<String>] app_args Application arguments
    def launch_iphone_app_with_name(app_name, sdk, options = {}, app_args = nil)
      app_path = SimLauncher.app_bundle_or_raise(app_name)
      launch_ios_app_with_options(app_path, sdk, 'iphone', options, app_args)
    end

    # Quit simulator
    def quit_simulator
      `echo 'application "iPhone Simulator" quit' | osascript`
    end

    # Run synchronous shell command
    # @param [Array<String>] args Command line arguments
    def run_synchronous_command(*args)
      args.compact!
      cmd = cmd_line_with_args(args)
      puts "executing #{cmd}" if $DEBUG
      `#{cmd}`
    end

    # Return shell command string with given arguments
    # @param [Array<String>] args Command line arguments
    # @return [String] Shell command string
    def cmd_line_with_args(args)
      cmd_sections = [@iphonesim_path] + args.map { |x| "\"#{x.to_s}\"" } << '2>&1'
      cmd_sections.join(' ')
    end

    # Get current Xcode version
    # @return [String] Xcode version string
    def xcode_version
      version = `xcodebuild -version`
      raise "xcodebuild not found" unless $? == 0
      version[/([0-9]\.[0-9])/, 1].to_f
    end

    # Get ios-sim version
    # @return [String] ios-sim version string
    def iphonesim_version
      `ios-sim --version`
    end

    # Get ios-sim executable path
    # @param [String] version Xcode version
    # @return [String] ios-sim executable path
    def iphonesim_path(version)
      installed = `which ios-sim`
      if installed =~ /(.*ios-sim)/
        puts "Using installed ios-sim at #{$1}"
        return $1
      end

      File.join(File.dirname(__FILE__), '..', '..', 'native', 'ios-sim')
    end

  end
end
