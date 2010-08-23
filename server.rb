require 'rubygems'
require 'sinatra'

IPHONESIM_PATH = File.join( File.dirname(__FILE__), 'bin', 'iphonesim' )

def cmd_line_with_args( args )
  cmd_sections = [IPHONESIM_PATH] + args.map{ |x| "\"#{x.to_s}\"" } + ['2>&1']
  cmd_sections.join(' ')
end

def run_iphonesim_command( *args )
  cmd = cmd_line_with_args( args ) 
  puts "executing #{cmd}"
  output = `#{cmd}`
  return "<pre>"+output+"</pre>"
end

get '/showsdks' do
  run_iphonesim_command( :showsdks )
end

get '/launch_ipad_app' do
  app_path = params[:app_path]
  raise 'no app_path provided' if app_path.nil?

  run_iphonesim_command( :launch, app_path, '3.2', 'ipad' )
end
