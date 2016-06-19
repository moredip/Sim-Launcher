module SimLauncher
class Cml
  def run(arg)
    return `#{arg}`
  end
end
class Simulator

  def initialize( iphonesim_path_external = nil, cml = nil )
    @cml = cml || Cml.new
    @iphonesim_path = iphonesim_path_external || iphonesim_path
  end

  def showsdks
    run_synchronous_command( 'showsdks' )
  end

  def showdevicetypes
    run_synchronous_command( 'showdevicetypes' )
  end

  def start_simulator(sdk_version=nil, device_family="iphone")
    if iphonesim_version < 3.0 
      sdk_version ||= SdkDetector.new(self).latest_sdk_version
      run_synchronous_command( :start, '--sdk', sdk_version, '--family', device_family, '--exit' )
    else
      sdk_version ||= SdkDetector.new(self).latest_device_type
      run_synchronous_command( :start, '--devicetypeid', sdk_version, '--exit')
    end
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

  def launch_ios_app(app_path, sdk_version, device_family, app_args = nil)
    if problem = SimLauncher.check_app_path( app_path )
      bangs = '!'*80
      raise "\n#{bangs}\nENCOUNTERED A PROBLEM WITH THE SPECIFIED APP PATH:\n\n#{problem}\n#{bangs}"
    end
    args = ["--args"] + app_args.flatten if app_args
    if iphonesim_version < 3.0 
      sdk_version ||= SdkDetector.new(self).latest_sdk_version
      run_synchronous_command( :launch, app_path, '--sdk', sdk_version, '--family', device_family, '--exit', *args )
    else
      sdk_version ||= SdkDetector.new(self).latest_device_type
      run_synchronous_command( :launch, app_path, '--devicetypeid', sdk_version, '--exit', *args )
    end
  end

  def launch_ipad_app( app_path, sdk )
    launch_ios_app( app_path, sdk, 'ipad' )
  end

  def launch_ipad_app_with_name( app_name, sdk )
    app_path = SimLauncher.app_bundle_or_raise(app_name)
    launch_ios_app( app_path, sdk, 'iphone' )
  end

  def launch_iphone_app( app_path, sdk )
    launch_ios_app( app_path, sdk, 'iphone' )
  end

  def launch_iphone_app_with_name( app_name, sdk )
    app_path = SimLauncher.app_bundle_or_raise(app_name)
    launch_ios_app( app_path, sdk, 'iphone' )
  end

  def quit_simulator
    @cml.run("echo 'application \"iPhone Simulator\" quit' | osascript")
    # new version of simulator called "Simulator"
    @cml.run("echo 'application \"Simulator\" quit' | osascript")
  end

  def run_synchronous_command( *args )
    args.compact!
    cmd = cmd_line_with_args( args )
    puts "executing #{cmd}" if $DEBUG
    @cml.run("#{cmd}")
  end

  def cmd_line_with_args( args )
    cmd_sections = [@iphonesim_path] + args.map{ |x| "\"#{x.to_s}\"" } << '2>&1'
    cmd_sections.join(' ')
  end

  def xcode_version
    version_out = @cml.run("xcodebuild -version")
    begin
      Float(version_out[/([0-9]\.[0-9])/, 1])
    rescue => ex
      raise "Cannot determine xcode version: #{ex}"
    end
  end

  def iphonesim_path
    installed = @cml.run("which ios-sim")
    if installed =~ /(.*ios-sim)/
      puts "Using installed ios-sim at #{$1}" if $DEBUG
      return $1
    end

    raise "Didn't find the ios-sim binary in your $PATH.\n\nPlease install, e.g. using Homebrew:\n\tbrew install ios-sim\n\n"
  end

  def iphonesim_version
    version_out = @cml.run("#{@iphonesim_path} --version")
    begin
      Float(version_out[/([0-9]\.[0-9])/, 1])
    rescue => ex
      raise "Cannot determine ios-sim version: #{ex}"
    end
  end
end
end
