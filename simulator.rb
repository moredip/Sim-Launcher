class Simulator

  IPHONESIM_PATH = File.join( File.dirname(__FILE__), 'bin', 'iphonesim' )

  def showsdks
    run_synchronous_command( 'showsdks' )
  end

  def launch_app( app_path )
    run_synchronous_command( :launch, app_path, '3.2', 'ipad' )
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
