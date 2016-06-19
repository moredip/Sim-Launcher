require 'rspec'
require_relative '../lib/sim_launcher'

describe(SimLauncher::Simulator) do
  let(:cml)  { double }
  let(:appPath) { "myAppPath" }
  let(:invalid_appPath) { "invalidAppPath" }
  let(:simulator) { SimLauncher::Simulator.new(nil, cml) }
  let(:sdks) {
<<EOS
Simulator SDK Roots:
  'iOS 9.2' (9.2)
    /Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 9.2.simruntime/Contents/Resources/RuntimeRoot
    'iOS 9.1' (9.1)
      /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
EOS
  }
  let(:device_types) {
<<EOS
com.apple.CoreSimulator.SimDeviceType.iPhone-6s, 9.2
com.apple.CoreSimulator.SimDeviceType.iPhone-6s-Plus, 9.1
EOS
  }

  before :each do
    allow(SimLauncher).to receive(:check_app_path).with(appPath).and_return(nil)
    allow(SimLauncher).to receive(:check_app_path).with(invalid_appPath).and_return("wrong app path")
    allow(cml).to receive(:run).with('which ios-sim').and_return('/usr/bin/ios-sim')
    allow(cml).to receive(:run).with("/usr/bin/ios-sim \"showsdks\" 2>&1").and_return(sdks)
    allow(cml).to receive(:run).with("/usr/bin/ios-sim \"showdevicetypes\" 2>&1").and_return(device_types)
  end

  context("when ios-sim version is under 3.x") do

    before :each do
      allow(cml).to receive(:run).with('/usr/bin/ios-sim --version').and_return('2.0.1')
    end

    it("should tell the version of ios-sim") do
       expect(simulator.iphonesim_version).to eql(2.0)
    end

    it("should launch simulator") do
      expect(cml).to receive(:run).with("/usr/bin/ios-sim \"launch\" \"myAppPath\" \"--sdk\" \"9.3\" \"--family\" \"iPhone\" \"--exit\" \"--args\" \"appArgs\" 2>&1")
      simulator.launch_ios_app(appPath, '9.3', 'iPhone', ['appArgs'])
    end

    it("should get error if app path is invalid") do
      expect{simulator.launch_ios_app(invalid_appPath, '9.3', 'iPhone', ['appArgs'])}.to raise_error(RuntimeError)
    end

    it("should get the latest sdk version if no sdk version is provided") do
      expect(cml).to receive(:run).with("/usr/bin/ios-sim \"launch\" \"myAppPath\" \"--sdk\" \"9.2\" \"--family\" \"iPhone\" \"--exit\" 2>&1")
      simulator.launch_ios_app(appPath, nil, 'iPhone')
    end

    it("should start simulator") do
      expect(cml).to receive(:run).with("/usr/bin/ios-sim \"start\" \"--sdk\" \"9.3\" \"--family\" \"iPhone\" \"--exit\" 2>&1")
      simulator.start_simulator('9.3', 'iPhone')
    end

    it("should start simulator with the latest sdk version if no sdk version is provided") do
      expect(cml).to receive(:run).with("/usr/bin/ios-sim \"start\" \"--sdk\" \"9.2\" \"--family\" \"iPhone\" \"--exit\" 2>&1")
      simulator.start_simulator(nil, 'iPhone')
    end

  end

  context("when ios-sim version is 3.x") do

    before :each do
      allow(cml).to receive(:run).with('/usr/bin/ios-sim --version').and_return('3.0.1')
    end

    it("should tell the version of ios-sim") do
       expect(simulator.iphonesim_version).to eql(3.0)
    end

    it("should launch simulator") do
      expect(cml).to receive(:run).with("/usr/bin/ios-sim \"launch\" \"myAppPath\" \"--devicetypeid\" \"com.apple.CoreSimulator.SimDeviceType.iPhone-6s, 9.3\" \"--exit\" \"--args\" \"appArgs\" 2>&1")
      simulator.launch_ios_app(appPath, 'com.apple.CoreSimulator.SimDeviceType.iPhone-6s, 9.3', 'iPhone', ['appArgs'])
    end

    it("should get the latest device type if no sdk version is provided") do
      expect(cml).to receive(:run).with("/usr/bin/ios-sim \"launch\" \"myAppPath\" \"--devicetypeid\" \"com.apple.CoreSimulator.SimDeviceType.iPhone-6s, 9.2\" \"--exit\" 2>&1")
      simulator.launch_ios_app(appPath, nil, 'iPhone')
    end

    it("should start simulator") do
      expect(cml).to receive(:run).with("/usr/bin/ios-sim \"start\" \"--devicetypeid\" \"com.apple.CoreSimulator.SimDeviceType.iPhone-6s, 9.3\" \"--exit\" 2>&1")
      simulator.start_simulator("com.apple.CoreSimulator.SimDeviceType.iPhone-6s, 9.3")
    end

    it("should start simulator with the latest sdk version if no sdk version is provided") do
      expect(cml).to receive(:run).with("/usr/bin/ios-sim \"start\" \"--devicetypeid\" \"com.apple.CoreSimulator.SimDeviceType.iPhone-6s, 9.2\" \"--exit\" 2>&1")
      simulator.start_simulator(nil, 'iPhone')
    end
  end

  context("quit simulator") do
    it("should handle old version and new version simulator application names") do
      expect(cml).to receive(:run).with("echo 'application \"iPhone Simulator\" quit' | osascript")
      expect(cml).to receive(:run).with("echo 'application \"Simulator\" quit' | osascript")
      simulator.quit_simulator
    end
  end
end

