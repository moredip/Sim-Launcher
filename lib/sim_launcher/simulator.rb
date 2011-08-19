module SimLauncher
class Simulator

  def initialize( iphonesim_path = nil )
    @iphonesim_path = iphonesim_path || File.join( File.dirname(__FILE__), '..', '..', 'native', 'iphonesim' )
  end

  def showsdks
    run_synchronous_command( 'showsdks' )
  end

  def launch_ios_app(app_path, sdk_version, device_family)
    sdk_version ||= SdkDetector.instance.latest_sdk_version
  	run_synchronous_command( :launch, app_path, sdk_version, device_family )
  end

  def launch_ipad_app( app_path, sdk )
    launch_ios_app( app_path, sdk, 'ipad' )
  end

  def launch_iphone_app( app_path, sdk )
    launch_ios_app( app_path, sdk, 'iphone' )
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
end
end
