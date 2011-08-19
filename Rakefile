require 'bundler'
Bundler::GemHelper.install_tasks

desc "compile iphonesim binary"
task "build_iphonesim" do
  sh 'xcodebuild -project vendor/iphonesim/iphonesim.xcodeproj/ clean build'
  cp 'vendor/iphonesim/build/Release/iphonesim', 'native/iphonesim'
end
