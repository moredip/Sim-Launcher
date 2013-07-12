module SimLauncher

module DeviceType
  Phone = 'iphone'
  PhoneRetina3_5Inch = 'retina iphone (3.5 inch)'
  PhoneRetina4Inch = 'retina iphone (4 inch)'

  Pad = 'ipad'
  PadRetina = 'retina ipad'

  PhoneDevices = [Phone, PhoneRetina3_5Inch, PhoneRetina4Inch]
  PadDevices = [Pad, PadRetina]
  Devices = PhoneDevices.clone.concat PadDevices

  RetinaDevices = [PhoneRetina3_5Inch, PhoneRetina4Inch, PadRetina]
end

module DeviceFamily
  Phone = 'iphone'
  Pad = 'ipad'
end

class Simulator
  def initialize( iphonesim_path_external = nil )
    @iphonesim_path_external = iphonesim_path_external
  end

  def iphonesim_path
    @iphonesim_path ||= (@iphonesim_path_external || ask_for_iphonesim_path(xcode_version))
  end

  def showsdks
    run_synchronous_command( 'showsdks' )
  end

  def start_simulator(sdk_version=nil, device_family="iphone")
    sdk_version ||= SdkDetector.new(self).latest_sdk_version
    run_synchronous_command( :start, '--sdk', sdk_version, '--family', device_family, '--exit' )
  end


  def rotate_left
    script_dir = File.join(File.dirname(__FILE__),"..","..","scripts")
    rotate_script = File.expand_path("#{script_dir}/rotate_simulator_left.applescript")
    system("osascript #{rotate_script}")
  end

  def rotate_right
    script_dir = File.join(File.dirname(__FILE__),"..","..","scripts")
    rotate_script = File.expand_path("#{script_dir}/rotate_simulator_right.applescript")
    system("osascript #{rotate_script}")
  end

  def reset(sdks=nil)
    script_dir = File.join(File.dirname(__FILE__),"..","..","scripts")
    reset_script = File.expand_path("#{script_dir}/reset_simulator.applescript")

    sdks ||= SimLauncher::SdkDetector.new(self).available_sdk_versions

    sdks.each do |sdk_path_str|
      start_simulator(sdk_path_str,"iphone")
      system("osascript #{reset_script}")
      start_simulator(sdk_path_str,"ipad")
      system("osascript #{reset_script}")
    end

    quit_simulator

  end

  # Deprecated. Use #launch_ios_app.
  def launch_ipad_app( app_path, options = {} )
    raise "Don't specify a device when calling launch_ipad_app." if options[:device]
    options[:device] = DeviceType::Pad
    launch_ios_app( app_path, options )
  end

  # Deprecated. Use #launch_ios_app.
  def launch_iphone_app( app_path, options = {} )
    raise "Don't specify a device when calling launch_iphone_app." if options[:device]
    options[:device] = DeviceType::Phone
    launch_ios_app( app_path, options )
  end

  # @param [String] app_path the app_path to launch.
  # @param [Hash] options the options to launch the app with.
  # @option options [String] :sdk the sdk version. Defaults to latest.
  # @option options [String] :device the device. Defaults to non-retina iphone.
  # @see SimLauncher::DeviceType
  # @option options [String] :app_args arguments to pass to the app being launched.
  def launch_ios_app( app_path, options = {} )
    if problem = SimLauncher.check_app_path( app_path )
      bangs = '!'*80
      raise "\n#{bangs}\nENCOUNTERED A PROBLEM WITH THE SPECIFIED APP PATH:\n\n#{problem}\n#{bangs}"
    end
    sdk_version = options[:sdk] || SdkDetector.new(self).latest_sdk_version
    args = ["--args"] + options[:app_args].flatten if options[:app_args]
    device = options[:device] || 'iphone' 
    raise "Unrecognized device type: #{device}" unless DeviceType::Devices.include? device

    run_synchronous_command( :launch, app_path, '--sdk', sdk_version, *args_to_select_device(device), '--exit', *args )
  end

  def args_to_select_device( device )
    args = ['--family', family_for_device(device)]

    if DeviceType::RetinaDevices.include? device
      args = args + ['--retina']

      if device == DeviceType::PhoneRetina4Inch
        args = args + ['--tall']
      end
    end
    
    args
  end

  def family_for_device( device )
    if DeviceType::PhoneDevices.include? device
      DeviceFamily::Phone
    else
      DeviceFamily::Pad
    end
  end

  def quit_simulator
    `echo 'application "iPhone Simulator" quit' | osascript`
  end

  def run_synchronous_command( *args )
    cmd = cmd_line_with_args( args )
    puts "executing #{cmd}" if $DEBUG
    `#{cmd}`
  end

  def cmd_line_with_args( args )
    cmd_sections = [iphonesim_path] + args.map{ |x| "\"#{x.to_s}\"" } << '2>&1'
    cmd_sections.join(' ')
  end
  
  def xcode_version
    version = `xcodebuild -version`
    raise "xcodebuild not found" unless $? == 0
    version[/([0-9]\.[0-9])/, 1].to_f
  end
  
  def ask_for_iphonesim_path(version)
    installed = `which ios-sim`
    if installed =~ /(.*ios-sim)/
      puts "Using installed ios-sim at #{$1}"
      return $1
    end

    File.join( File.dirname(__FILE__), '..', '..', 'native', 'ios-sim' )
  end
end
end
