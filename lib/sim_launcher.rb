require 'sim_launcher/client'
require 'sim_launcher/direct_client'
require 'sim_launcher/simulator'
require 'sim_launcher/sdk_detector'

module SimLauncher

  DERIVED_DATA = File.expand_path("~/Library/Developer/Xcode/DerivedData")
  DEFAULT_DERIVED_DATA_INFO = File.expand_path("#{DERIVED_DATA}/*/info.plist")

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

  def self.derived_data_dir_for_project_name(project_name)

    build_dirs = Dir.glob("#{DERIVED_DATA}/*").find_all do |xc_proj|
      File.basename(xc_proj).start_with?(project_name)
    end

    if (build_dirs.count == 0 && !project_name.empty?)
      # check for directory named "workspace-{deriveddirectoryrandomcharacters}"
      build_dirs = Dir.glob("#{DERIVED_DATA}/*").find_all do |xc_proj|
        File.basename(xc_proj).downcase.start_with?(project_name)
      end
    end

    puts build_dirs

    if (build_dirs.count == 0)
      msg = ["Unable to find your built app."]
      msg << "This means that sim_launcher can't automatically launch the build for the #{project_name}."
      msg << "Searched in Xcode 4.x default: #{DERIVED_DATA}"
      raise msg.join("\n")

    elsif (build_dirs.count > 1)
      msg = ["Unable to auto detect APP_BUNDLE_PATH."]
      msg << "You have several projects with the same name: #{project_name} in #{DERIVED_DATA}:\n"
      msg << build_dirs.join("\n")

      msg << "\nThis means that Calabash can't automatically launch iOS simulator."
      msg << "Searched in Xcode 4.x default: #{DEFAULT_DERIVED_DATA_INFO}"
      msg << "\nIn features/support/launch.rb set APP_BUNDLE_PATH to"
      msg << "the path where Xcode has built your Calabash target."
      msg << "Alternatively you can use the environment variable APP_BUNDLE_PATH.\n"
      raise msg.join("\n")
    else
      puts "Found potential build dir: #{build_dirs.first}"
      puts "Checking..."
      return build_dirs.first
    end
  end

  def self.app_bundle_or_raise(path)
    bundle_path = nil

    if path and not File.directory?(path)
      puts "Unable to find .app bundle at #{path}. It should be an .app directory."
      dd_dir = derived_data_dir_for_project_name(path)
      app_bundles = Dir.glob(File.join(dd_dir, "Build", "Products", "*", "*.app"))
      msg = "Try setting APP_BUNDLE_PATH in features/support/launch.rb to one of:\n\n"
      msg << app_bundles.join("\n")
      raise msg
    elsif path
      bundle_path = path
    else
      dd_dir = derived_data_dir_for_project_name(path)
      sim_dirs = Dir.glob(File.join(dd_dir, "Build", "Products", "*-iphonesimulator", "*.app"))
      if sim_dirs.empty?
        msg = ["Unable to auto detect APP_BUNDLE_PATH."]
        msg << "Have you built your app for simulator?."
        msg << "Searched dir: #{dd_dir}/Build/Products"
        msg << "Please build your app from Xcode"
        msg << "You should build the -cal target."
        msg << ""
        msg << "Alternatively, specify APP_BUNDLE_PATH in features/support/launch.rb"
        msg << "This should point to the location of your built app linked with calabash.\n"
        raise msg.join("\n")
      end
      preferred_dir = find_preferred_dir(sim_dirs)
      if preferred_dir.nil?
        msg = ["Error... Unable to find APP_BUNDLE_PATH."]
        msg << "Cannot find a built app that is linked with calabash.framework"
        msg << "Please build your app from Xcode"
        msg << "You should build your calabash target."
        msg << ""
        msg << "Alternatively, specify APP_BUNDLE_PATH in features/support/launch.rb"
        msg << "This should point to the location of your built app linked with calabash.\n"
        raise msg.join("\n")
      end
      puts("-"*37)
      puts "Auto detected APP_BUNDLE_PATH:\n\n"

      puts "APP_BUNDLE_PATH=#{preferred_dir || sim_dirs[0]}\n\n"
      puts "Please verify!"
      puts "If this is wrong please set it as APP_BUNDLE_PATH in features/support/launch.rb\n"
      puts("-"*37)
      bundle_path = sim_dirs[0]
    end
    bundle_path
  end

end
