module SimLauncher
class Simulator

  def initialize( iphonesim_path_external = nil )
    @iphonesim_path = iphonesim_path_external || iphonesim_path(xcode_version)
  end

  def showsdks
    run_synchronous_command( 'showsdks' )
  end

  def start_simulator(sdk_version=nil, device_family="iphone")
    sdk_version ||= SdkDetector.new(self).latest_sdk_version
    run_synchronous_command( :start, '--sdk', sdk_version, '--family', device_family, '--exit' )
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

  def launch_ios_app(app_path, sdk_version, device_family, app_args = nil)
    if problem = SimLauncher.check_app_path( app_path )
      bangs = '!'*80
      raise "\n#{bangs}\nENCOUNTERED A PROBLEM WITH THE SPECIFIED APP PATH:\n\n#{problem}\n#{bangs}"
    end
    sdk_version ||= SdkDetector.new(self).latest_sdk_version
    args = ["--args"] + app_args.flatten if app_args
    run_synchronous_command( :launch, app_path, '--sdk', sdk_version, '--family', device_family, '--exit', *args )
  end

  def launch_ipad_app( app_path, sdk )
    launch_ios_app( app_path, sdk, 'ipad' )
  end

  def launch_iphone_app( app_path, sdk )
    launch_ios_app( app_path, sdk, 'iphone' )
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
    cmd_sections = [@iphonesim_path] + args.map{ |x| "\"#{x.to_s}\"" } << '2>&1'
    cmd_sections.join(' ')
  end
  
  def xcode_version
    version = `xcodebuild -version`
    raise "xcodebuild not found" unless $? == 0
    version[/([0-9]\.[0-9])/, 1].to_f
  end
  
  def iphonesim_path(version)
    installed = `which ios-sim`
    if installed =~ /(.*ios-sim)/
      puts "Using installed ios-sim at #{$1}"
      return $1
    end

    File.join( File.dirname(__FILE__), '..', '..', 'native', 'ios-sim' )
  end
end
end
