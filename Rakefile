require 'bundler'
Bundler::GemHelper.install_tasks

desc "compile iphonesim binary"
task "build_iphonesim" do
  sh 'xcodebuild -project vendor/iphonesim/iphonesim.xcodeproj/ clean build'
  cp 'vendor/iphonesim/build/Release/iphonesim', 'native/iphonesim'
end

desc "compile ios-sim binary"
task "build_ios_sim" do
  native_dir = File.expand_path( '../native',__FILE__)
  Dir.mktmpdir do |tmp_dir|
    sh %Q{xcodebuild -project vendor/ios-sim/ios-sim.xcodeproj -configuration Debug SYMROOT='#{tmp_dir}' clean build}
    FileUtils.cp( File.join(tmp_dir,'Debug','ios-sim'), native_dir )
  end
end

task :default => [:build_ios_sim, :build]
