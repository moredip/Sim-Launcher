require 'spec_helper'

describe "SinatraLauncher" do
  include Rack::Test::Methods

  def app
    SimLauncher::SimLauncherServer
  end

  SimLauncher::SimLauncherServer.set :environment, :test

  # it "should return a nice message" do
  #   get '/'
  #   last_response.body.should == <<-EOS
  #   <h1>SimLauncher is up and running</h1>
  #   <a href="/showsdks">Here's a list of sdks that SimLauncher has detected</a>
  #   EOS
  # end

  def app_path
    'the/app/path'
  end

  let(:sim) { double(SimLauncher::Simulator) }

  before(:each) do
    app.stub(:shared_simulator).and_return(sim)
  end

  it "should raise if missing app_path" do
    expect { get "/launch_ios_app" }.to raise_error
  end

  it "should launch an ios app" do
    sim.should_receive(:launch_ios_app).with(app_path, {})

    get "/launch_ios_app?app_path=#{app_path}"
  end

  it "should pass down options" do
    sim.should_receive(:launch_ios_app).with(app_path, {"someoption" => "true"})

    get "/launch_ios_app?app_path=#{app_path}&someoption=true"
  end

  it "should pass down options, iphone" do
    sim.should_receive(:launch_iphone_app).with(app_path, {"someoption" => "true"})

    get "/launch_iphone_app?app_path=#{app_path}&someoption=true"
  end

  it "should pass down options, ipad" do
    sim.should_receive(:launch_ipad_app).with(app_path, {"someoption" => "true"})

    get "/launch_ipad_app?app_path=#{app_path}&someoption=true"
  end

  it "should launch an iphone app" do
    sim.should_receive(:launch_iphone_app).with(app_path, {})

    get "/launch_iphone_app?app_path=#{app_path}"
  end

  it "should launch an ipad app" do
    sim.should_receive(:launch_ipad_app).with(app_path, {})

    get "/launch_ipad_app?app_path=#{app_path}"
  end

  it "should not allow specifying a device when calling a device specific endpoint" do
    expect { get "/launch_ipad_app?app_path=#{app_path}&device=ipad" }.to raise_error
    expect { get "/launch_ipad_app?app_path=#{app_path}&device=iphone" }.to raise_error
    expect { get "/launch_iphone_app?app_path=#{app_path}&device=iphone" }.to raise_error
    expect { get "/launch_ipad_app?app_path=#{app_path}&device=ipad" }.to raise_error
  end

  it "should restart the simulator if requested, ios" do
    sim.stub(:launch_ios_app).with(app_path, {})
    sim.should_receive(:quit_simulator)

    get "/launch_ios_app?app_path=#{app_path}&restart=true"
  end

  it "should restart the simulator if requested, iphone" do
    sim.stub(:launch_iphone_app).with(app_path, {})
    sim.should_receive(:quit_simulator)

    get "/launch_iphone_app?app_path=#{app_path}&restart=true"
  end

  it "should restart the simulator if requested, ipad" do
    sim.stub(:launch_ipad_app).with(app_path, {})
    sim.should_receive(:quit_simulator)

    get "/launch_ipad_app?app_path=#{app_path}&restart=true"
  end
end