# frozen_string_literal: true

require "optparse"
require_relative "lib/config"
require_relative "lib/fixtures_app"
require_relative "lib/agentcore_client"

AppConfig.load!

options = { remote: false, session_id: nil }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby main.rb [options] \"your prompt\""

  opts.on("--remote", "Call Bedrock AgentCore runtime instead of local app") do
    options[:remote] = true
  end

  opts.on("--session SESSION", "Session ID for remote AgentCore calls") do |val|
    options[:session_id] = val
  end
end.parse!

prompt = ARGV.join(" ").strip
if prompt.empty?
  puts "Usage: ruby main.rb [options] \"your prompt\""
  exit 1
end

API_KEY = ENV['API_KEY']
FOOTBALL_API_KEY = ENV['FOOTBALL_API_KEY']

# Example: expose /invoke and /health endpoints
require 'sinatra'

set :port, 8080

get '/health' do
  'OK'
end

post '/invoke' do
  client_key = request.env['HTTP_X_API_KEY']
  halt 401, 'Unauthorized' unless client_key && client_key == API_KEY
  # Use FOOTBALL_API_KEY for Football Org API calls
  # ...agent logic...
  'Invoked'
end

if options[:remote]
  runtime_arn = ENV.fetch("AGENTCORE_RUNTIME_ARN")
  client = AgentCoreClient.new(runtime_arn: runtime_arn)
  puts client.invoke(prompt, session_id: options[:session_id])
else
  app = FixturesApp.new
  puts app.call(prompt)
end
