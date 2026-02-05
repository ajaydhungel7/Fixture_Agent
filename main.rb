# frozen_string_literal: true

require "optparse"
require_relative "lib/config"
require_relative "lib/fixtures_app"
require_relative "lib/agentcore_client"
require "json"

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
  # Run server mode for deployment
  API_KEY = ENV['API_KEY']
  FOOTBALL_API_KEY = ENV['FOOTBALL_API_KEY']

  require 'sinatra'

  set :bind, '0.0.0.0'
  set :port, 8080

  get '/health' do
    'OK'
  end

  post '/invoke' do
    # Do NOT require API key here - let the Bedrock AgentCore gateway call the runtime
    client_key = request.env['HTTP_X_API_KEY']
    STDERR.puts "[invoke] client_key_present=#{!client_key.nil?}"

    raw = request.body.read
    payload = {}
    begin
      payload = raw && !raw.empty? ? JSON.parse(raw) : {}
    rescue JSON::ParserError => e
      STDERR.puts "[invoke] invalid JSON payload: "+e.message
      payload = {}
    end

    STDERR.puts "[invoke] headers=#{request.env.select { |k, _| k.start_with?('HTTP_') }}"
    STDERR.puts "[invoke] raw_payload=#{raw}"
    STDERR.puts "[invoke] parsed_payload=#{payload.inspect}"

    # Accept Bedrock Agent Runtime shapes: prefer `inputText` per gateway spec
    input_text = payload['inputText'] || payload['input'] || (payload['input'] && payload['input']['text'])

    # Minimal handling: echo back so we can verify end-to-end
    result = if input_text && !input_text.to_s.empty?
      "Echo: "+input_text.to_s
    else
      "No input provided"
    end

    content_type :json
    { outputText: result, sessionId: payload['sessionId'] || nil }.to_json
  end
else
  # Run CLI mode
  API_KEY = ENV['API_KEY']
  FOOTBALL_API_KEY = ENV['FOOTBALL_API_KEY']

  if options[:remote]
    runtime_arn = ENV.fetch("AGENTCORE_RUNTIME_ARN")
    client = AgentCoreClient.new(runtime_arn: runtime_arn)
    puts client.invoke(prompt, session_id: options[:session_id])
  else
    app = FixturesApp.new
    puts app.call(prompt)
  end
end
