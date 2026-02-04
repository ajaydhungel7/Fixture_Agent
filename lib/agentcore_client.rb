# frozen_string_literal: true

require "json"
require "aws-sdk-bedrockagentcore"

class AgentCoreClient
  def initialize(runtime_arn:, region: ENV["AWS_REGION"])
    @runtime_arn = runtime_arn
    @client = Aws::BedrockAgentCore::Client.new(region: region)
  end

  def invoke(prompt, session_id: nil, qualifier: nil)
    payload = { prompt: prompt, session_id: session_id }.compact
    params = {
      agent_runtime_arn: @runtime_arn,
      payload: JSON.generate(payload),
      content_type: "application/json"
    }
    params[:qualifier] = qualifier if qualifier

    resp = @client.invoke_agent_runtime(params)
    resp.response.read
  end
end
