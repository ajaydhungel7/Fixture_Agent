# frozen_string_literal: true

require "json"
require "net/http"
require "uri"
require "date"
require "rubyrana"

class FixturesApp
  CACHE_TTL_SECONDS = Integer(ENV.fetch("FIXTURES_CACHE_TTL", "300"), 10)

  def initialize
    @fixtures_cache = {}
    @model = ENV.fetch("RUBYRANA_MODEL", "claude-3-5-sonnet-20240620")

    Rubyrana.configure do |config|
      config.default_provider = Rubyrana::Providers::Anthropic.new(
        api_key: ENV.fetch("ANTHROPIC_API_KEY"),
        model: @model
      )
    end

    @fixtures_lookup = build_fixtures_tool
    @laliga_agent = Rubyrana::Agent.new(
      system_prompt: "You are a LaLiga fixtures assistant. Use fixtures_lookup with league=laliga.",
      tools: [@fixtures_lookup]
    )

    @premier_agent = Rubyrana::Agent.new(
      system_prompt: "You are a Premier League fixtures assistant. Use fixtures_lookup with league=premier_league.",
      tools: [@fixtures_lookup]
    )

    @serie_a_agent = Rubyrana::Agent.new(
      system_prompt: "You are a Serie A fixtures assistant. Use fixtures_lookup with league=serie_a.",
      tools: [@fixtures_lookup]
    )

    @router = Rubyrana::Multiagent::Router.new
    @classifier = Rubyrana::Agent.new(
      system_prompt: <<~PROMPT,
        Extract leagues and optional date range from the user request.
        Leagues must be from: laliga, premier_league, serie_a.
        If none are explicitly mentioned, return an empty list.
        Dates must be YYYY-MM-DD. If not provided, return nulls.
      PROMPT
      structured_output_schema: {
        type: "object",
        properties: {
          leagues: {
            type: "array",
            items: { type: "string", enum: ["laliga", "premier_league", "serie_a"] }
          },
          date_from: { type: ["string", "null"] },
          date_to: { type: ["string", "null"] }
        },
        required: ["leagues", "date_from", "date_to"]
      }
    )
  end

  def call(task)
    league_to_agent = {
      "laliga" => @laliga_agent,
      "premier_league" => @premier_agent,
      "serie_a" => @serie_a_agent
    }

    extracted = @classifier.structured_output(task)
    leagues = extracted.fetch("leagues")
    date_from = extracted.fetch("date_from")
    date_to = extracted.fetch("date_to")

    if leagues.empty?
      chosen = @router.route(task, agents: league_to_agent.values)
      return chosen.call(task)
    end

    outputs = leagues.map do |league|
      agent = league_to_agent.fetch(league)
      call_league_agent(agent, league, task, date_from, date_to)
    end

    leagues.length == 1 ? outputs.first : outputs.join("\n\n")
  end

  private

  def call_league_agent(agent, league, task, date_from, date_to)
    label =
      if league == "laliga"
        "LaLiga"
      elsif league == "premier_league"
        "Premier League"
      else
        "Serie A"
      end

    request =
      if date_from || date_to
        from = date_from || Date.today.to_s
        to = date_to || (Date.today + 7).to_s
        "#{task}\nUse date_from=#{from} and date_to=#{to}."
      else
        task
      end

    "#{label}:\n#{agent.call(request)}"
  end

  def build_fixtures_tool
    Rubyrana::Tool.new(
      "fixtures_lookup",
      description: "Return fixtures for a league from football-data.org",
      schema: {
        type: "object",
        properties: {
          league: {
            type: "string",
            enum: ["laliga", "premier_league", "serie_a"]
          },
          date_from: { type: "string", description: "YYYY-MM-DD" },
          date_to: { type: "string", description: "YYYY-MM-DD" }
        },
        required: ["league"]
      }
    ) do |league:, date_from: nil, date_to: nil|
      api_key = ENV.fetch("FOOTBALL_DATA_API_KEY")
      league_codes = {
        "laliga" => "PD",
        "premier_league" => "PL",
        "serie_a" => "SA"
      }

      code = league_codes.fetch(league)
      from = date_from || Date.today.to_s
      to = date_to || (Date.today + 7).to_s

      cache_key = "#{league}|#{from}|#{to}"
      cached = @fixtures_cache[cache_key]
      if cached && (Time.now.to_i - cached.fetch(:ts)) < CACHE_TTL_SECONDS
        return cached.fetch(:data)
      end

      uri = URI("https://api.football-data.org/v4/competitions/#{code}/matches")
      uri.query = URI.encode_www_form(dateFrom: from, dateTo: to)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri)
      request["X-Auth-Token"] = api_key

      response = http.request(request)
      unless response.is_a?(Net::HTTPSuccess)
        return "API error #{response.code}: #{response.body}"
      end

      payload = JSON.parse(response.body)
      matches = payload.fetch("matches", [])
      result =
        if matches.empty?
          "No fixtures found for #{league} between #{from} and #{to}."
        else
          matches.map do |m|
            date = m.fetch("utcDate")[0, 10]
            home = m.dig("homeTeam", "name")
            away = m.dig("awayTeam", "name")
            "#{date}: #{home} vs #{away}"
          end.join("\n")
        end

      @fixtures_cache[cache_key] = { ts: Time.now.to_i, data: result }
      result
    end
  end
end
