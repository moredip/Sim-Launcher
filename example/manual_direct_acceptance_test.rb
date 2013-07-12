require 'sim_launcher'

# When run, builds and launches the TestApp, printing out any command run via Kernel#`. Modify the #launch method to use different methods on SimLauncher::Simulator to perform launching. Make a note of the final launch command run to add to simulator_spec.rb to fix the behavior of Sim_Launcher with respect to ios-sim.
# NB: You must use `bundle exec ruby manual_direct_acceptance_test.rb` to use the Sim_Launcher gem with :path => '../'. Using just `ruby manual_direct_acceptance_test.rb` will run using any system installed Sim_Launcher.

def build_test_app
  sh("xcodebuild -project '#{project_dir}/TestApp.xcodeproj' -sdk iphonesimulator6.1 install INSTALL_PATH='/./' DSTROOT='#{built_products_dir}'")
end

def sh(cmd)
  puts "Running: #{cmd}"
  system cmd
end

def example_dir
  File.dirname(File.expand_path(__FILE__))
end

def project_dir
  File.join(example_dir, 'TestApp')
end

def built_products_dir
  File.join(project_dir, 'built-products')
end

def test_app_path
  File.join(built_products_dir, 'TestApp.app')
end


module Kernel
  alias_method :orig_backtick, :`

  def `(cmd)
    puts "Running: #{cmd}..."
    return_string = orig_backtick(cmd)
    puts "Returned: #{return_string}\n"
    return_string
  end
end

def sim
  @sim ||= SimLauncher::Simulator.new()
end

def launch
  sim.launch_ios_app(test_app_path, :device => 'retina iphone (4 inch)')
  # sim.launch_ipad_app(test_app_path)
  # sim.launch_iphone_app(test_app_path, {})
  # sim.launch_ios_app(test_app_path)
end

build_test_app
launch