require 'sinatra'
require 'sim_launcher/simulator'

module SimLauncher
class SinatraLauncher
  def initialize(args = [])
    app.set :port, (args[0] || 8881)
  end

  def launch
    app.run!
  end

  private
  def app
    SimLauncher::SimLauncherServer
  end
end
  
class SimLauncherServer < Sinatra::Base
  class << self
    def shared_simulator
      @shared_simulator ||= SimLauncher::Simulator.new
    end
  end

  attr_accessor :restart_requested

  def shared_simulator
    self.class.shared_simulator
  end

  get '/' do
    <<-EOS
    <h1>SimLauncher is up and running</h1>
    <a href="/showsdks">Here's a list of sdks that SimLauncher has detected</a>
    EOS
  end

  get '/showsdks' do
    '<pre>' +
    shared_simulator.showsdks +
    '</pre>'
  end

  get '/launch_ios_app' do
    launch_ios_app_and_optionally_restart(app_path_from_params(params), parse_params_and_return_options(params))
  end

  def launch_ios_app_and_optionally_restart(app_path, options)
    optionally_restart
    shared_simulator.launch_ios_app(app_path, options)
  end

  def optionally_restart
    shared_simulator.quit_simulator if restart_requested
  end

  def app_path_from_params(params)
   app_path = params[:app_path]
   raise 'no app_path provided' if app_path.nil?
   app_path
  end

  def parse_params_and_return_options(params)
   self.restart_requested = ("true" == params[:restart])
   options = params.delete_if { |key, value| [:restart, :app_path].include? key.to_sym }
   options
 end

 get '/launch_iphone_app' do
  launch_iphone_app_and_optionally_restart(app_path_from_params(params), parse_params_and_return_options(params))
  end

  def launch_iphone_app_and_optionally_restart(app_path, options)
    optionally_restart
    shared_simulator.launch_iphone_app(app_path, options)
  end

  get '/launch_ipad_app' do
    launch_ipad_app_and_optionally_restart(app_path_from_params(params), parse_params_and_return_options(params))
  end

  def launch_ipad_app_and_optionally_restart(app_path, options)
    optionally_restart
    shared_simulator.launch_ipad_app(app_path, options)
  end
end
end

