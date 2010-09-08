require 'rubygems'
require 'sinatra'

require 'simulator'

shared_simulator = Simulator.new

get '/showsdks' do
  '<pre>' +
  shared_simulator.showsdks +
  '</pre>'
end

get '/launch_ipad_app' do
  app_path = params[:app_path]
  raise 'no app_path provided' if app_path.nil?

  shared_simulator.launch_app( app_path )
end
