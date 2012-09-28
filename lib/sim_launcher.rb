require 'sim_launcher/client'
require 'sim_launcher/direct_client'
require 'sim_launcher/simulator'
require 'sim_launcher/sdk_detector'

module SimLauncher
  def self.check_app_path( app_path )
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
end
