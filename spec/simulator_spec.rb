require 'spec_helper'

describe "SimLauncher" do 
  describe "launching" do
    let(:sim) { SimLauncher::Simulator.new() }

    before(:each) do
      sim.stub(:`).with('xcodebuild -version').and_return(xcodebuild_version)
      sim.stub(:`).with('which ios-sim').and_return(iossim_path)
      sim.stub(:`).with("#{iossim_path} \"showsdks\" 2>&1").and_return(iossim_showsdks)

      File.stub(:exists?).with(app_path).and_return(true)
      File.stub(:directory?).with(app_path).and_return(true)
    end

    it "should launch an ios app" do
      sim.should_receive(:`).with(launch_cmd('iphone'))

      sim.launch_ios_app(app_path)
    end

    it "should launch an ipad app" do
      sim.should_receive(:`).with(launch_cmd('ipad'))

      sim.launch_ipad_app(app_path)
    end

    it "should launch an iphone app" do
      sim.should_receive(:`).with(launch_cmd('iphone'))

      sim.launch_iphone_app(app_path)
    end  

    it "should not allow specifying a device when calling a device specific endpoint" do
      expect { sim.launch_iphone_app(app_path, {:device => 'ipad'}) }.to raise_error
      expect { sim.launch_ipad_app(app_path, {:device => 'iphone'})  }.to raise_error
      expect { sim.launch_iphone_app(app_path, {:device => 'iphone'})  }.to raise_error
      expect { sim.launch_ipad_app(app_path, {:device => 'ipad'})  }.to raise_error
    end

    it "should not allow specifying an invalid device" do
      expect { sim.launch_ios_app(app_path, :device => 'windows phone') }.to raise_error
    end

    it "should launch the specified device" do
      sim.should_receive(:`).with(launch_cmd('iphone'))
      sim.launch_ios_app(app_path, :device => 'iphone')

      sim.should_receive(:`).with(launch_cmd('ipad'))
      sim.launch_ios_app(app_path, :device => 'ipad')
    end

    it "should launch in retina" do
      sim.should_receive(:`).with(launch_cmd('iphone', :retina => true))
      sim.launch_ios_app(app_path, :device => 'retina iphone (3.5 inch)')

      sim.should_receive(:`).with(launch_cmd('ipad', :retina => true))
      sim.launch_ios_app(app_path, :device => 'retina ipad')
    end

    it "should launch in tall retina" do
      sim.should_receive(:`).with(launch_cmd('iphone', :retina => true, :tall => true))
      sim.launch_ios_app(app_path, :device => 'retina iphone (4 inch)')
    end

    def xcodebuild_version
      "Xcode 4.6.3
      Build version 4H150"
    end

    def iossim_path
      '/path/to/ios-sim'
    end

    def iossim_showsdks
      "Simulator SDK Roots:
      'Simulator - iOS 6.1' (6.1)
      /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.1.sdk"
    end

    def app_path
      'app_path/not_a_real_path'
    end

    def tall_cmd(options)
      return %Q{"--tall" } if options[:tall]
      return ""
    end

    def retina_cmd(options)
      return %Q{"--retina" } if options[:retina]
      return ""
    end

    def launch_cmd(device, options = {})
      %Q{#{iossim_path} "launch" "#{app_path}" "--sdk" "6.1" "--family" "#{device}" #{retina_cmd(options)}#{tall_cmd(options)}"--exit" 2>&1}
    end
  end
end
