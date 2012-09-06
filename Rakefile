require 'bundler'
Bundler::GemHelper.install_tasks

desc "compile ios-sim binary"
task "build_ios_sim" do
  native_dir = File.expand_path( '../native',__FILE__)
  Dir.mktmpdir do |tmp_dir|
    sh %Q{xcodebuild -project vendor/iphonesim/iphonesim.xcodeproj -configuration Debug SYMROOT='#{tmp_dir}' clean build}
    FileUtils.cp( File.join(tmp_dir,'Debug','iphonesim'), native_dir )
  end
end

task :default => [:build_ios_sim, :build]
