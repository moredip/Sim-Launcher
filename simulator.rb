class Simulator

  IPHONESIM_PATH = File.join( File.dirname(__FILE__), 'bin', 'iphonesim' )

  def showsdks
    run_synchronous_command( 'showsdks' )
  end

  def launch_ios_app(app_path, sdk_version, device_family)
  	run_synchronous_command( :launch, app_path, sdk_version, device_family )
  end

  def launch_ipad_app( app_path, sdk )
    sdk ||= '3.2'
    launch_ios_app( app_path, sdk, 'ipad' )
  end

  def launch_iphone_app( app_path, sdk )
    sdk ||= '4.0'
    launch_ios_app( app_path, sdk, 'iphone' )
  end

  def run_synchronous_command( *args )
    cmd = cmd_line_with_args( args )
    puts "executing #{cmd}"
    `#{cmd}`
  end

  def cmd_line_with_args( args )
    cmd_sections = [IPHONESIM_PATH] + args.map{ |x| "\"#{x.to_s}\"" } << '2>&1'
    cmd_sections.join(' ')
  end
end
