# frozen_string_literal: true

require "json"
require "dotenv"
require "aws-sdk-secretsmanager"

module AppConfig
  module_function

  def load!
    load_dotenv
    load_secrets_manager
  end

  def load_dotenv
    return unless ENV.fetch("RUBYRANA_ENV", "development") == "development"
    return unless File.exist?(File.expand_path(".env", Dir.pwd))

    Dotenv.load
  end

  def load_secrets_manager
    secret_id = ENV["SECRETS_MANAGER_SECRET_ID"]
    return if secret_id.nil? || secret_id.strip.empty?

    client = Aws::SecretsManager::Client.new
    resp = client.get_secret_value(secret_id: secret_id)
    payload = resp.secret_string || "{}"
    data = JSON.parse(payload)

    data.each do |key, value|
      ENV[key] ||= value.to_s
    end
  end
end
