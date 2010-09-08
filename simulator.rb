class Simulator

  IPHONESIM_PATH = File.join( File.dirname(__FILE__), 'bin', 'iphonesim' )

  def showsdks
    run_synchronous_command( 'showsdks' )
  end

  def launch_app( app_path )
    run_asynchronous_command( :launch, app_path, '3.2', 'ipad' )
  end

  def run_synchronous_command( *args )
    cmd = cmd_line_with_args( args )
    puts "executing #{cmd}"
    `#{cmd}`
  end
  
  def run_asynchronous_command( *args )
    kill_any_previous_running_commands
    puts 'kicking off async command'
    @prev_async_pid = fork do
      Signal.trap("HUP") do
        puts 'being killed!'
        exit
      end
      run_synchronous_command( *args )
    end

    "async command #{@prev_async_pid} kicked off"
  end

  def cmd_line_with_args( args )
    cmd_sections = [IPHONESIM_PATH] + args.map{ |x| "\"#{x.to_s}\"" } << '2>&1'
    cmd_sections.join(' ')
  end
    
  def kill_any_previous_running_commands
    return if @prev_async_pid.nil?
    puts "killing #{@prev_async_pid}"
    Process.kill( "HUP", @prev_async_pid )
  end
  
end
