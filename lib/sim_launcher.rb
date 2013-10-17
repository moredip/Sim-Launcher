require 'sim_launcher/client'
require 'sim_launcher/direct_client'
require 'sim_launcher/simulator'
require 'sim_launcher/sdk_detector'

# Simulator Launcher
module SimLauncher

  # Default derived data path
  DERIVED_DATA = File.expand_path("~/Library/Developer/Xcode/DerivedData")
  # Default derived data info plist
  DEFAULT_DERIVED_DATA_INFO = File.expand_path("#{DERIVED_DATA}/*/info.plist")

  # Check app path
  # @param [String] app_path app path to check
  # @return [String] Error message or _nil_ on success
  def self.check_app_path(app_path)
    unless File.exists?(app_path)
      return "The specified app path doesn't seem to exist:  #{app_path}"
    end

    unless File.directory? app_path
      file_appears_to_be_a_binary = !!(`file "#{app_path}"` =~ /Mach-O executable/)
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

  # Get derived data directory for the project
  # @param [String] project_name Name of the project
  # @return [String] Derived data directory path
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
      msg = ["Unable to auto detect bundle."]
      msg << "You have several projects with the same name: #{project_name} in #{DERIVED_DATA}:\n"
      msg << build_dirs.join("\n")

      msg << "\n\nThis means that sim_launcher can't automatically launch iOS simulator."
      msg << "Searched in Xcode 4.x default: #{DEFAULT_DERIVED_DATA_INFO}\n"
      raise msg.join("\n")
    else
      puts "Found potential build dir: #{build_dirs.first}"
      puts "Checking..."
      return build_dirs.first
    end
  end

  # Get app bundle for path or raise an exception
  # @param [String] path Path
  # @return [String] App bundle path
  def self.app_bundle_or_raise(path)
    bundle_path = nil

    if path and not File.directory?(path)
      puts "Unable to find .app bundle at #{path}. It should be an .app directory."
      dd_dir = derived_data_dir_for_project_name(path)
      app_bundles = Dir.glob(File.join(dd_dir, "Build", "Products", "*", "*.app"))
      msg = "sim_launcher found the following bundles:\n\n"
      msg << app_bundles.join("\n")
      raise msg
    elsif path
      bundle_path = path
    else
      dd_dir = derived_data_dir_for_project_name(path)
      sim_dirs = Dir.glob(File.join(dd_dir, "Build", "Products", "*-iphonesimulator", "*.app"))
      if sim_dirs.empty?
        msg = ["Unable to auto detect bundle."]
        msg << "Have you built your app for simulator?."
        msg << "Searched dir: #{dd_dir}/Build/Products"
        msg << "Please build your app from Xcode\n"
        raise msg.join("\n")
      end
      preferred_dir = find_preferred_dir(sim_dirs)
      if preferred_dir.nil?
        msg = ["Error... Unable to find bundle."]
        msg << "Cannot find a built app that is linked with calabash.framework"
        msg << "Please build your app from Xcode"
        msg << "You should build your calabash target.\n"
        raise msg.join("\n")
      end
      puts("-"*37)
      puts "Auto detected bundle:\n\n"
      puts "bundle = #{preferred_dir || sim_dirs[0]}\n\n"
      puts "Please verify!"
      puts("-"*37)
      bundle_path = sim_dirs[0]
    end
    bundle_path
  end

end
