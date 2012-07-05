module SimLauncher
class Simulator

  def initialize( iphonesim_path_external = nil )
    @iphonesim_path = iphonesim_path_external || iphonesim_path(xcode_version)
  end

  def check_app_path( app_path )
    unless File.exists?( app_path )
      return "The specified app path doesn't seem to exist:  #{app_path}"
    end

    unless File.directory? app_path
      file_appears_to_be_a_binary = !!( `file "#{app_path}"` =~ /Mach-O executable/ )
      if file_appears_to_be_a_binary
        return <<-EOS
        The specified app path is a binary executable, rather than a directory. You need to provide the path to the app *bundle*, not the app executable itself.
        The path you specified was:               #{app_path}
        You might want to instead try specifying: #{File.dirname(app_path)}
        EOS
      else
        return "The specified app path is not a directory. You need to provide the path to your app bundle.\nSpecified app path was: #{app_path}"
      end
    end

    nil
  end

  def showsdks
    run_synchronous_command( 'showsdks' )
  end

  def launch_ios_app(app_path, sdk_version, device_family)
    if problem = check_app_path( app_path )
      bangs = '!'*80
      raise "\n#{bangs}\nENCOUNTERED A PROBLEM WITH THE SPECIFIED APP PATH:\n\n#{problem}\n#{bangs}"
    end
    sdk_version ||= SdkDetector.new(self).latest_sdk_version
  	run_synchronous_command( :launch, app_path, '--sdk', sdk_version, '--family', device_family, '--exit' )
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
