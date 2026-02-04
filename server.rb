# frozen_string_literal: true

require "json"
require "webrick"
require_relative "lib/config"
require_relative "lib/fixtures_app"

AppConfig.load!

app = FixturesApp.new

server = WEBrick::HTTPServer.new(Port: Integer(ENV.fetch("PORT", "8080"), 10))

server.mount_proc "/health" do |_req, res|
  res.status = 200
  res.body = "ok"
end

server.mount_proc "/invoke" do |req, res|
  begin
    payload = JSON.parse(req.body.to_s)
    prompt = payload.fetch("prompt")
    result = app.call(prompt)
    res.status = 200
    res["Content-Type"] = "application/json"
    res.body = JSON.generate({ result: result })
  rescue KeyError
    res.status = 400
    res.body = JSON.generate({ error: "missing prompt" })
  rescue StandardError => e
    res.status = 500
    res.body = JSON.generate({ error: e.message })
  end
end

trap("INT") { server.shutdown }
server.start
